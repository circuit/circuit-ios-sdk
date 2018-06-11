// Apache 2.0 License
//
// Copyright 2017 Unify Software and Solutions GmbH & Co.KG.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//  ConversationsController.swift
//  SampleApp
//
//

import UIKit
import CircuitSDK

class ConversationsTableViewController: UITableViewController {

    static let kLogTag = "ConversationsTableViewController"
    fileprivate var selectedIndexRow: Int?
    fileprivate let rowHeight: CGFloat = 70.0
    fileprivate let convDataSource = ConversationDataSource.sharedInstance
    fileprivate var alertController: UIAlertController?
    fileprivate var callViewController: CallViewController?
    fileprivate var conversations = [Conversation]() {
        didSet {
            reloadData()
          }
    }
    fileprivate var calls: [Call]?
    static var directCall: Call?

    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addEventObservers()
        fetchConversationsWithCompletion { [unowned self] () -> Void in
            // Let's check if calls are present, and push related cells on top of the list.
            self.placeCellOnTopIfCallInProgress(call: self.calls)
        }
        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailConversationSegue" {
            guard let index = selectedIndexRow else {
                ANSLoge(ConversationsTableViewController.kLogTag, "Failed to obtain cell index")
                return
            }
            let detailConversationVC = segue.destination as? DetailConversationViewController
            detailConversationVC?.conversation = conversations[index]

            // Obtaining cell by provided index
            let path = IndexPath(row: index, section: 0)
            guard let cell = tableView.cellForRow(at: path) as? ConversationTableViewCell else {
                ANSLoge(ConversationsTableViewController.kLogTag, "Failed to obtain cell")
                return
            }

            if cell.cellState == .initiated {
                detailConversationVC?.call = calls?.first(where: { (call) -> Bool in
                    call.convId == conversations[index].convId
                })
                detailConversationVC?.presentConferenceBanner()
            }

            DispatchQueue.main.async {
                let backItem = UIBarButtonItem()
                backItem.title = ""
                self.navigationItem.backBarButtonItem = backItem
            }
        } else if segue.identifier == "NewConversationSegue" {
          let navigationController = segue.destination as? UINavigationController
          let controller = navigationController?.topViewController as? CreateConversationViewController
          controller?.delegate = self
        }
    }

    // MARK: - UITextViewDelegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId =  ConversationTableViewCell.reuseId
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId,
                                                 for: indexPath) as! ConversationTableViewCell

        let conversation = self.conversations[indexPath.row]
        cell.configureCell(conversation)

        if let call = calls?.first(where: { (call) -> Bool in
            call.convId == conversation.convId }) {
            cell.updateCellForCallState(call.state)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexRow = indexPath.row
        self.performSegue(withIdentifier: "DetailConversationSegue", sender: self)
    }

    // MARK: - Notifications

    func addEventObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(conversationUpdated),
                                               name: NSNotification.Name(rawValue: CKTNotificationItemAdded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(conversationUpdated),
                                               name: NSNotification.Name(rawValue: CKTNotificationItemUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchConversations),
                                               name: NSNotification.Name(rawValue: CKTNotificationConversationCreated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchConversations),
                                               name: NSNotification.Name(rawValue: CKTNotificationConversationUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDirectIncomingCall(_:)),
                                               name: NSNotification.Name(rawValue: CKTNotificationCallIncoming), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGroupIncomingCall(_:)),
                                               name: NSNotification.Name(rawValue: CKTNotificationCallStatus), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCallEnded(_:)),
                                               name: NSNotification.Name(rawValue: CKTNotificationCallEnded), object: nil)
    }

    @objc func handleCallEnded (_ notification: Notification) {
        guard let dict = notification.userInfo,
            let call = CallDataSource.sharedInstance.callObjectFromJSCall(dict),
            call.state == .terminated else {
                ANSLogd(ConversationsTableViewController.kLogTag, "Skip notification")
                return
        }
        // Group calls
        if call.convType == .group {
            guard let cell = getCellByConversationId(call.convId) else {
                ANSLoge(ConversationsTableViewController.kLogTag, "Failed to obtain cell")
                return
            }
            // Clear the call object and cell state.
            if let index = self.calls?.index(where: {(callItem) -> Bool in
                callItem.callId == call.callId }) {
                calls?.remove(at: index)
            }
            cell.updateCellForCallState(call.state)
        // Direct calls
        } else if call.convType == .direct && call.callId == ConversationsTableViewController.directCall?.callId {
            // Clear the call object
            ConversationsTableViewController.directCall = nil
        }
    }

    @objc fileprivate func handleDirectIncomingCall (_ notification: Notification) {
        guard let dict = notification.userInfo,
            let call = CallDataSource.sharedInstance.callObjectFromJSCall(dict) else {
            ANSLoge(ConversationsTableViewController.kLogTag, "Failed to parce notification")
            return
        }
        // Check if direct call is already in progress, and end incoming if so.
        guard ConversationsTableViewController.directCall == nil else {
            CKTClient.sharedInstance().endCall(call.callId) { (error) in
                guard error == nil else {
                    ANSLoge(ConversationsTableViewController.kLogTag, "Failed to decline call")
                    return
                }
                ANSLoge(ConversationsTableViewController.kLogTag, "Call declined")
            }
            return
        }

        callViewController = CallScreenManager.sharedInstance
            .prepereCallViewControllerForIncomingCall(call: call, delegate: self)
        self.alertController?.dismiss(animated: false, completion: nil)
        guard let callVC = callViewController else {
            Utils.showAlertAsync(controller: self, title: "Call error", message: "Can't start the call")
            return
        }
        ConversationsTableViewController.directCall = call
        self.present(callVC, animated: true, completion: nil)
    }

    @objc fileprivate func fetchConversations() {
        convDataSource.fetchConversations { (conversations, error) in
            DispatchQueue.main.async {
                self.conversations = conversations
            }
        }
    }

    fileprivate func fetchConversationsWithCompletion(_ completion: @escaping () -> Void?) {
        convDataSource.fetchConversations { (conversations, error) in
            DispatchQueue.main.async {
                self.conversations = conversations
                completion()
            }
        }
    }

    @objc fileprivate func conversationUpdated(_ notification: Notification) {
        guard let tmpItem = notification.userInfo, let eventItem = tmpItem["item"] as? NSDictionary else {
            return
        }
        var isConversationInList = false
        // Grab the conversation id for the conversation we need to update
        let convId = eventItem["convId"] as? String

        // Loop over all conversations until we find the correct one
        for (index, var conversation) in self.conversations.enumerated() {
            if conversation.convId == convId {
                // If we have the correct conversation we need to update the recent item
                conversation.recentItem = Utils().contentOfConversationItem(eventItem)
                conversations.remove(at: index)
                conversations.insert(conversation, at: 0)
                isConversationInList = true
                break
            }
        }
        // In case the conversation is not found in current list, let's pull over updated conversation list
        if !isConversationInList {
            fetchConversations()
        }

        // Let's check if calls are present, and push related cells on top of the list.
        placeCellOnTopIfCallInProgress(call: self.calls)
    }

    @objc func handleGroupIncomingCall (_ notification: Notification) {
        guard let dict = notification.userInfo,
            let call = CallDataSource.sharedInstance.callObjectFromJSCall(dict),
            call.state == .started, call.convType == .group else {
                ANSLogd(ConversationsTableViewController.kLogTag, "Skip notification")
                return
        }

        if calls == nil {
            calls = [Call]()
        }
        // Store the call into calls array if the call is not in the list.
        if let isContained = calls?.contains(where: { (callItem) -> Bool in callItem.callId == call.callId }),
            !isContained {
            calls?.append(call)
        }

        updateConversationPosition(convId: call.convId) { (error) in
            guard error == nil else {
                Utils.showError(controller: self, errorDescription: error.debugDescription)
                return
            }
            if let cell = self.getCellByConversationId(call.convId) {
                cell.updateCellForCallState(call.state)
            }
        }
    }

    // MARK: - Actions

    @IBAction func logoutWasTapped(_ sender: UIBarButtonItem) {
        CKTClient().logout {
            self.performSegue(withIdentifier: "logoutSegue", sender: self)
        }
    }

    @IBAction func createWasTapped(_ sender: UIBarButtonItem) {
        alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let conversationAction = UIAlertAction(title: "Conversation", style: .default) { (action) in
            self.performSegue(withIdentifier: "NewConversationSegue", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController?.addAction(conversationAction)
        alertController?.addAction(cancelAction)
        if let controller = alertController {
            present(controller, animated: true, completion: nil)
        }
    }

    // MARK: - Private methods

    fileprivate func reloadData() {
        self.tableView.reloadData()
    }

    fileprivate func insertConversationIntoTableView(_ conversation: Conversation) {
        tableView.beginUpdates()
        conversations.append(conversation)
        let path = IndexPath(row: conversations.count - 1, section: 0)
        tableView.insertRows(at: [path], with: .automatic)
        tableView.endUpdates()
    }

    fileprivate func updateConversationPosition(convId: String, completion: @escaping (_ error: Error?) -> Void) {
        // Update conversation position
        var isConversationInList = false
        for (index, conversation) in self.conversations.enumerated() {
            if conversation.convId == convId {
                conversations.remove(at: index)
                conversations.insert(conversation, at: 0)
                isConversationInList = true
                completion(nil)
                break
            }
        }
        if !isConversationInList {
            self.convDataSource.getConversationById(convId: convId) { [weak self] (conversation, error) in
                guard error == nil else {
                    completion(error)
                    return
                }
                guard let conv = conversation else {
                    completion(FetchConversationDataError.getConversationByIdException)
                    return
                }
                DispatchQueue.main.async {
                    self?.conversations.insert(conv, at: 0)
                    completion(nil)
                }
            }
        }
    }

    fileprivate func getCellByConversationId(_ convId: String) -> ConversationTableViewCell? {
        guard let index = conversations.index(where: {$0.convId == convId}) else {
            ANSLoge(ConversationsTableViewController.kLogTag, "Failed to obtain cell")
            return nil
        }
        let path = IndexPath(row: index, section: 0)
        return tableView.cellForRow(at: path) as? ConversationTableViewCell
    }

    fileprivate func placeCellOnTopIfCallInProgress(call: [Call]?) {
        if let calls = calls {
            for call in calls {
                self.updateConversationPosition(convId: call.convId) { (error) in
                    if error != nil {
                        Utils.showError(controller: self, errorDescription: error.debugDescription)
                    }
                }
            }
        }
    }

}

extension ConversationsTableViewController: CreateConversationDelegate {

    func createConversationViewControllerDidCancel(_ controller: CreateConversationViewController) {
        dismiss(animated: true, completion: nil)
    }

    func createConversationViewController(_ controller: CreateConversationViewController, didFinishCreating jsConversation: AnyObject) {
        dismiss(animated: true, completion: nil)
        if let conversation = convDataSource.conversationObjectFromJSConversation(jsConversation) {
            insertConversationIntoTableView(conversation)
        }
    }

}

extension ConversationsTableViewController: CallViewControllerDelegate {

    func callViewControllerDidEndCall(withError error: Error?) {
        callViewController?.dismiss(animated: false, completion: {
            if let error = error {
                Utils.showAlert(controller: self, title: "Call error",
                                message: error.localizedDescription)
            }
        })
    }

    func callViewControllerDidEndCall() {
        callViewController?.dismiss(animated: false, completion: nil)
        ConversationsTableViewController.directCall = nil
    }
}

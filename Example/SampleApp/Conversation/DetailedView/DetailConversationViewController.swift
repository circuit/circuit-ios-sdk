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
//  DetailConversationViewController.swift
//  SampleApp
//
//

import UIKit
import CircuitSDK

class DetailConversationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    static let kLogTag = "DetailConversationViewController"
    lazy var messageArea: MessageAreaView = {
        var messageArea = MessageAreaView()
        messageArea.delegate = self
        return messageArea
    }()
    var callViewController: CallViewController?
    var messageAreaBottomConstraint: NSLayoutConstraint?
    var conversation: Conversation?
    var conversationItems = [ConversationItem]() {
        didSet {
            reloadData()
        }
    }
    var call: Call?
    private var callId: String?
    private var conferenceBannerView: ConferenceBannerView?
    private let kTopAnchorConstant: CGFloat = 60
    private let kHeightAnchorConstant: CGFloat = 40

    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none

        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        messageArea.textInputField.isEnabled = false

        setupMessageAreaViewConstraints(messageArea: messageArea)
        setupTableViewConstraints()

        self.fetchConversationItems { (conversationItems) in
            DispatchQueue.main.async {
                self.conversationItems = conversationItems
                self.initialTableViewPosition()
                self.messageArea.textInputField.isEnabled = true
            }
        }

        setViewControllerTitle()
        self.registerForNotifications()
    }

    func presentConferenceBanner() {
        if conferenceBannerView == nil {
            conferenceBannerView = ConferenceBannerView(frame: CGRect.zero, delegate: self)
        }
        guard let conferenceBanner = conferenceBannerView else {
            ANSLoge(DetailConversationViewController.kLogTag, "Fail to create conferenceBannerView")
            return
        }
        view.addSubview(conferenceBanner)
        conferenceBanner.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11.0, *) {
            conferenceBanner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            conferenceBanner.topAnchor.constraint(equalTo: view.topAnchor, constant: kTopAnchorConstant).isActive = true
        }
        conferenceBanner.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        conferenceBanner.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        conferenceBanner.heightAnchor.constraint(equalToConstant: kHeightAnchorConstant).isActive = true
    }

    // MARK: - Notifications

    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(itemAddedToConversation(_:)),
                                               name: NSNotification.Name(rawValue: CKTNotificationItemAdded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGroupIncomingCall(_:)),
                                               name: NSNotification.Name(rawValue: CKTNotificationCallStatus), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleGroupCallEnded(_:)),
                                               name: NSNotification.Name(rawValue: CKTNotificationCallEnded), object: nil)
    }

    @objc func handleGroupIncomingCall (_ notification: Notification) {
        if  let jsCall = notification.userInfo as? [String: AnyObject],
            let call = CallDataSource.sharedInstance.callObjectFromJSCall(jsCall),
            call.convType == .group, call.convId == conversation?.convId {
            self.call = call
            presentConferenceBanner()
        }
    }

    @objc fileprivate func handleGroupCallEnded(_ notification: Notification) {
        if  let jsCall = notification.userInfo as? [String: AnyObject],
            let call = CallDataSource.sharedInstance.callObjectFromJSCall(jsCall),
            call.convType == .group, call.state == .terminated {
            conferenceBannerView?.removeFromSuperview()
        }
    }

    @objc fileprivate func itemAddedToConversation(_ notification: Notification) {
        if let jsItem = notification.userInfo {
            let item = ConversationItemDataSource.sharedInstance.conversationItemFromJSitem(jsItem as AnyObject)
            guard let convItem = item else {
                ANSLoge(DetailConversationViewController.kLogTag, "Conversation item is not provided")
                return
            }
            guard convItem.convId == conversation?.convId  else {
                ANSLogd(DetailConversationViewController.kLogTag, "Item does not belong to this conversation, item ignored")
                return
            }

            insertConversationItemIntoTableView(convItem)
        }
    }

    // MARK: Private methods

    fileprivate func setViewControllerTitle () {
        guard let conversation = conversation else { return }
        if conversation.type == "DIRECT" {
            guard let userIds = conversation.userIds else { return }
            if let userId = userIds.first(where: {$0 != UserDataSource.currentUser.userId}) {
                UserDataSource.sharedInstance.getUser(userId) { (user) in
                    guard let userName = user.displayName else { return }
                    DispatchQueue.main.async { self.title = userName }
                }
            }
        } else {
            guard let conversationTitle = conversation.title else { return }
            self.title = conversationTitle
        }
        // If the conversation is phone calls hide the message area
        // and have a full screen table view
        if title == "VGTC VGTC" { hideMessageArea() }
    }

    fileprivate func hideMessageArea() {
        messageArea.isHidden = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    }

    fileprivate func insertConversationItemIntoTableView(_ item: ConversationItem) {
        guard !self.conversationItems.contains(where: {$0 == item}) else {return}
        self.conversationItems.append(item)
        self.tableView.layoutIfNeeded()
        scrollToBottom(animated: false)
    }

    fileprivate func scrollToBottom(animated: Bool) {
        tableView.scrollToRow(at: IndexPath(row: conversationItems.count-1, section: 0), at: .bottom, animated: animated)
    }

    fileprivate func reloadData() {
        tableView.reloadData()
    }

    fileprivate func fetchConversationItems(completion: @escaping (_ items: [ConversationItem]) -> Void) {
        guard let convId = conversation?.convId else {
            Utils.showAlert(controller: self, message: "Oops! Something went wrong.")
            return
        }
        ConversationItemDataSource.sharedInstance.fetchConversationItems(convId: convId) { (conversationItems, error) in
            guard error == nil else {
                ANSLoge(DetailConversationViewController.kLogTag,
                        "Failed to fetch convrsation items with error \(error.debugDescription)")
                return
            }
            completion(conversationItems)
        }
    }

    fileprivate func initialTableViewPosition() {
        self.spinner.stopAnimating()
        self.tableView.separatorStyle = .singleLine
        self.scrollToBottom(animated: false)
    }

    fileprivate func setupTableViewConstraints () {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.bottomAnchor.constraint(equalTo: messageArea.topAnchor).isActive = true
    }

    fileprivate func setupMessageAreaViewConstraints(messageArea: UIView) {
        view.addSubview(messageArea)
        messageArea.translatesAutoresizingMaskIntoConstraints = false
        messageArea.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        messageArea.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        messageAreaBottomConstraint = messageArea.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        messageAreaBottomConstraint?.isActive = true
        messageArea.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
}

extension DetailConversationViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = DetailConversationTableViewCell.reuseId
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
            as! DetailConversationTableViewCell
        cell.configureCellWithConversationItem(conversationItem: conversationItems[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        messageArea.textInputField.endEditing(true)
    }

 }

extension DetailConversationViewController: MessageAreaViewDelegate {

    func handleAudioCallAction() {
        guard let conversation = self.conversation else {
            Utils.showAlert(controller: self, title: "Call error", message: "Failed to make a call")
            return
        }
        // Prepare and present call view controller
        callViewController = CallScreenManager.sharedInstance
            .prepareCallViewControllerForOutgoingCall(conversation: conversation, delegate: self)
        guard let callVC = callViewController else {
            Utils.showAlertAsync(controller: self, title: "Call error", message: "Can't start the call")
            return
        }
        self.present(callVC, animated: true, completion: nil)

        if conversation.type == "DIRECT" {
            CallDataSource.sharedInstance.makeDirectCall(conversation: conversation, completion: { (callId, error) in
                guard error == nil else {
                    callVC.dismiss(animated: true, completion: nil)
                    Utils.showAlertAsync(controller: self, title: "Call error", message: error.debugDescription)
                    return
                }
                guard let callId = callId else {
                    callVC.dismiss(animated: true, completion: nil)
                    Utils.showAlertAsync(controller: self, title: "Call error", message: "CallId is not provided")
                    return
                }
                let directCall = Call(callId: callId, convId: conversation.convId ?? "" ,
                                  convType: .direct, state: CallState.active)
                callVC.call = directCall
            })
        } else {
            CallDataSource.sharedInstance.makeConferenceCall(conversation: conversation, completion: { (call, error) in
                guard error == nil else {
                    callVC.dismiss(animated: true, completion: nil)
                    Utils.showAlertAsync(controller: self, title: "Call error", message: "Error occurred \(error.debugDescription)")
                    return
                }
                callVC.call = call
            })
        }
    }

    func handleSendMessageAction() {
        guard messageArea.textInputField.hasText else {
            return
        }
        CKTClient().addTextItem(conversation?.convId, content: messageArea.textInputField.text) { (item, error) in
            guard error == nil else {
                Utils.showAlertAsync(controller: self, title: "Message Send issue",
                                     message: "Unable to send message due to \(error.debugDescription)")
                return
            }
            DispatchQueue.main.async {
                self.messageArea.textInputField.text = ""
                guard let jsItem = item as? NSDictionary else {
                    Utils.showAlert(controller: self, title: "Message Send issue", message: "Unable to send message")
                    return
                }
                let convItem = ConversationItemDataSource.sharedInstance.conversationItemFromJSitem(jsItem)
                guard let conversationItem = convItem else {
                    Utils.showAlert(controller: self, title: "Message Send issue", message: "Unable to send message")
                    return
                }
                self.insertConversationItemIntoTableView(conversationItem)
            }
        }
    }

    // MARK: Keyboard handling

    @objc func keyboardWillHide(_ notification: Notification) {
        if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            if let constraint = self.messageAreaBottomConstraint {
                constraint.constant = 0
            }
            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        //Let's use UIKeyboardFrameEndUserInfoKey instead of UIKeyboardFrameBeginUserInfoKey
        //to avoid bug with the leyboard height on iOS 11.
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
            if let constraint = self.messageAreaBottomConstraint {
                constraint.constant -= keyboardSize.height
            }
            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
                self.scrollToBottom(animated: false)
            })
        }
    }
}

extension DetailConversationViewController: ConferenceBannerViewDelegate {

    func handleTapActionPerformed() {
        guard let callId = call?.callId else {
            Utils.showAlertAsync(controller: self, title: "Call error", message: "CallId is not provided")
            return
        }
        CallDataSource.sharedInstance.joinConference(callId: callId) { [weak self] in
            guard let weakSelf = self, let conversation = self?.conversation else {
                ANSLogd(DetailConversationViewController.kLogTag, "Failed to join conference")
                return
            }
            ConversationsTableViewController.directCall = weakSelf.call
            DispatchQueue.main.async {
                weakSelf.callViewController = CallScreenManager.sharedInstance
                    .prepareCallViewControllerForOutgoingCall(conversation: conversation, delegate: self!)
                weakSelf.callViewController?.call = self?.call
                if let callViewController = weakSelf.callViewController {
                    weakSelf.present(callViewController, animated: true, completion: nil)
                }
            }
        }
    }
}

extension DetailConversationViewController: CallViewControllerDelegate {

    func callViewControllerDidEndCall(withError error: Error?) {
        callViewController?.dismiss(animated: false, completion: {
            if let error = error {
                Utils.showAlert(controller: self, title: "Call error",
                                message: error.localizedDescription)
            }
        })
    }

    func callViewControllerDidEndCall() {
        callViewController?.dismiss(animated: true, completion: nil)
        ConversationsTableViewController.directCall = nil
    }
}

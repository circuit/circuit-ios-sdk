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

    fileprivate var selectedIndexRow: Int?
    fileprivate let rowHeight: CGFloat = 70.0
    fileprivate let convDataSource = ConversationDataSource.sharedInstance

    fileprivate var conversations = [Conversation]() {
        didSet {
            reloadData()
          }
    }

    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addEventObservers()
        fetchConversations()
        tableView.rowHeight = rowHeight
        tableView.estimatedRowHeight = 0
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailConversationSegue" {
            let detailConversationVC = segue.destination as? DetailConversationViewController
            detailConversationVC?.conversation = conversations[selectedIndexRow!]
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

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedIndexRow = indexPath.row
        self.performSegue(withIdentifier: "DetailConversationSegue", sender: self)
    }

    // MARK: - Notifications

    fileprivate func addEventObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(conversationUpdated), name: NSNotification.Name(rawValue: CKTNotificationItemAdded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(conversationUpdated), name: NSNotification.Name(rawValue: CKTNotificationItemUpdated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchConversations), name: NSNotification.Name(rawValue: CKTNotificationConversationCreated), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchConversations), name: NSNotification.Name(rawValue: CKTNotificationConversationUpdated), object: nil)
    }

    @objc fileprivate func fetchConversations() {
        self.convDataSource.fetchConversations { (conv, error) in
            DispatchQueue.main.async {
                self.conversations = conv
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
    }

    // MARK: - Actions

    @IBAction func logoutWasTapped(_ sender: UIBarButtonItem) {
        CKTClient().logout {
            self.performSegue(withIdentifier: "logoutSegue", sender: self)
        }
    }

    @IBAction func createWasTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let conversationAction = UIAlertAction(title: "Conversation", style: .default) { (action) in
            self.performSegue(withIdentifier: "NewConversationSegue", sender: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(conversationAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
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

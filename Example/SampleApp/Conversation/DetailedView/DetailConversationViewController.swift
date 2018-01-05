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
    @IBOutlet weak var messageArea: UIView!
    @IBOutlet weak var messageAreaBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    var conversation: Conversation?
    var conversationItems = [ConversationItem]() {
        didSet {
            reloadData()
        }
    }

    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension

        tableView.separatorStyle = .none
        spinner.startAnimating()
        spinner.hidesWhenStopped = true

        setViewControllerTitle()
        ConversationItemDataSource.sharedInstance.fetchConversationItems(conversation: conversation!) { (items, error) in
            if error != nil { return }
            DispatchQueue.main.async {
                self.conversationItems = items
                self.spinner.stopAnimating()
                self.tableView.separatorStyle = .singleLine
                self.scrollToBottom(animated: false)
            }
        }
        registerForNotifications()
    }

    deinit {
        unregisterFromNotifications()
    }

    // MARK: - Keyboard handling

    func keyboardWillHide(_ notification: Notification) {
        if let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            self.messageAreaBottomConstraint.constant = 0
            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    func keyboardWillShow(_ notification: Notification) {
        //Let's use UIKeyboardFrameEndUserInfoKey instead of UIKeyboardFrameBeginUserInfoKey
        //to avoid bug with the leyboard height on iOS 11.
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue {
            self.messageAreaBottomConstraint.constant = keyboardSize.height

            UIView.animate(withDuration: duration, animations: {
                self.view.layoutIfNeeded()
                self.scrollToBottom(animated: false)
            })
        }
    }

    // MARK: - Actions

    @IBAction func sendMessage(_ sender: UIButton) {
        guard textField.hasText else { return }
        CKTClient().addTextItem(conversation?.convId, content: textField.text) { (item, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.textField.text = ""
                    guard let jsItem = item as? NSDictionary else { return }
                    let convItem = ConversationItemDataSource.sharedInstance.conversationItemFromJSitem(jsItem)
                    guard let conversationItem = convItem else { return }
                    self.insertConversationItemIntoTableView(conversationItem)
                }
            }
        }
    }

    // MARK: - Notifications

    func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(itemAddedToConversation(_:)), name: NSNotification.Name(rawValue: CKTNotificationItemAdded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }

    func unregisterFromNotifications() {
        NotificationCenter.default.removeObserver(self)
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
        textField.isHidden = true
        sendButton.isHidden = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    }

    @objc fileprivate func itemAddedToConversation(_ notification: Notification) {
        if let jsItem = notification.userInfo {
            let item = ConversationItemDataSource.sharedInstance.conversationItemFromJSitem(jsItem as AnyObject)
            guard let convItem = item  else { return }
            insertConversationItemIntoTableView(convItem)
        }
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
        textField.endEditing(true)
    }

 }

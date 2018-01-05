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
//  CreateConversationViewController.swift
//  SampleApp
//
//

import UIKit
import CircuitSDK

protocol CreateConversationDelegate: class {
    func createConversationViewControllerDidCancel(_ controller: CreateConversationViewController)
    func createConversationViewController(_ controller: CreateConversationViewController, didFinishCreating jsConversation: AnyObject)
}

class CreateConversationViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var addParticipantTextField: UITextField!
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var createConversationButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!

    weak var delegate: CreateConversationDelegate?
    fileprivate var users: [User] = []
    fileprivate var selectedParticipantIds: [String] = []
    fileprivate var selectedParticipantEmails: [String] = []

    // MARK: - Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Conversation"
        createConversationButton.isEnabled = false
        users = UserDataSource.users.map { $1 }
        addParticipantTextField.delegate = self
    }

    // MARK: - Actions

    @IBAction func cancelWasTapped(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        delegate?.createConversationViewControllerDidCancel(self)
    }

    @IBAction func createWasTapped(_ sender: UIBarButtonItem) {
        createConversationButton.isEnabled = false
        if !selectedParticipantEmails.isEmpty {
               UserDataSource.sharedInstance.getUsersIdsByEmails(self.selectedParticipantEmails) { (usersIds, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        self.showAlert("Can't create the conversation. Please check the Email")
                        self.createConversationButton.isEnabled = true
                    }
                    return
                }
                if let usersIds = usersIds {
                    self.selectedParticipantIds.append(contentsOf: usersIds)
                    // Remove duplicates. First by converting to a Set and then back to Array
                    self.selectedParticipantIds = Array(Set(self.selectedParticipantIds))
                    self.createConversation()
                }
            }
        } else {
            createConversation()
        }
    }

    // MARK: Private methods

    fileprivate func createConversation() {
        let creationCompletion: (_ conversation: Any?, _ error: Error?) -> Void = {[weak self] (conversation, error) in
            guard let strongSelf = self else {return}
            DispatchQueue.main.async {
                guard let conversation = conversation as? NSDictionary else {
                    strongSelf.showError(error)
                    return
                }
                if let exists = conversation["alreadyExists"] as? NSNumber, exists == true {
                    strongSelf.showAlert("Conversation already exists")
                    strongSelf.createConversationButton.isEnabled = true
                } else {
                    strongSelf.delegate?.createConversationViewController(strongSelf, didFinishCreating: conversation)
                }
            }
        }
        if selectedParticipantIds.count > 1 {
            CKTClient().createGroupConversation(selectedParticipantIds,
                                                title: titleTextField.text,
                                                completionHandler: { (conversation, error) in
                                                    creationCompletion(conversation, error)
            })
        } else if selectedParticipantIds.count == 1 {
            let participantId = selectedParticipantIds.first
            CKTClient().createDirectConversation(participantId,
                                                 completionHandler: { (conversation, error) in
                                                    creationCompletion(conversation, error)
            })
        } else {
            showAlert("There are no partisipants selected to start conversation")
        }
    }

    fileprivate func showAlert(_ message: String?) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    fileprivate func showError(_ error: Error?) {
        showAlert(error?.localizedDescription)
    }

}

extension CreateConversationViewController: UITextFieldDelegate {

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        selectedParticipantEmails.removeAll()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addParticipantTextField.resignFirstResponder()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textDidChange()
        return true
    }

    // MARK: Private methods

    fileprivate func textDidChange() {
        selectedParticipantEmails.removeAll()
        let emails = addParticipantTextField.text!.split(separator: " ").map(String.init)
        for email in emails {
            if validateTextMatchEmailStyle(condidate: email) {
                selectedParticipantEmails.append(email)
            }
        }
        createConversationButton.isEnabled = !selectedParticipantEmails.isEmpty
            || !selectedParticipantIds.isEmpty
        titleTextField.isEnabled = selectedParticipantEmails.count > 1
            || (!selectedParticipantIds.isEmpty && selectedParticipantEmails.count == 1)
            || selectedParticipantIds.count > 1
    }

    fileprivate func validateTextMatchEmailStyle (condidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: condidate)
    }

}

extension CreateConversationViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let reuseID = CreateConversationCollectionViewCell.reuseID
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as! CreateConversationCollectionViewCell
        cell.configureCellWithUser(user: users[indexPath.item])

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let cell = collectionView.cellForItem(at: indexPath) as! CreateConversationCollectionViewCell

        if let userId = users[indexPath.row].userId {
            if selectedParticipantIds.contains(userId) {
                changeSelectionStatus(forCell: cell, isSelected: false)
                selectedParticipantIds.remove(at: selectedParticipantIds.index(of: userId)!)
            } else {
                changeSelectionStatus(forCell: cell, isSelected: true)
                selectedParticipantIds.append(userId)
            }
        }
        createConversationButton.isEnabled = selectedParticipantIds.count > 0
                                            || selectedParticipantEmails.count > 0
        titleTextField.isEnabled = selectedParticipantIds.count > 1
                                            || (selectedParticipantEmails.count > 0 && selectedParticipantIds.count == 1)
                                            || selectedParticipantEmails.count > 1
    }

    // MARK: Private methods

    fileprivate func changeSelectionStatus(forCell cell: CreateConversationCollectionViewCell, isSelected state: Bool) {
        if state {
            let selectedView = UIView(frame: cell.avatarImageView.bounds)
            selectedView.backgroundColor = UIColor(red: 122/255, green: 228/255, blue: 125/225, alpha: 0.9)
            selectedView.layer.cornerRadius = cell.avatarImageView.frame.width / 2
            selectedView.layer.masksToBounds = true
            selectedView.tag = 1
            cell.avatarImageView.addSubview(selectedView)
        } else {
            if let selectedViewTag = cell.avatarImageView.viewWithTag(1) {
                selectedViewTag.removeFromSuperview()
            }
        }
        cell.checkmarkImage.isHidden = !state
    }
}

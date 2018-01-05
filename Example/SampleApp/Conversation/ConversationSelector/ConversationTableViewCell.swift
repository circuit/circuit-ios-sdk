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
//  ConversationTableViewCell.swift
//  SampleApp
//
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var conversationTitle: UILabel!
    @IBOutlet weak var conversationAvatar: UIImageView!
    @IBOutlet weak var recentItem: UILabel!
    @IBOutlet weak var timestamp: UILabel!

    static let reuseId = "convCell"
    private let defaultAvatar = "icon-general-default-avatar"

    func configureCell(_ conversation: Conversation) {
        conversationTitle.text = "Pending…"
        recentItem.text = "Pending…"
        timestamp.text = "timestamp"
        conversationAvatar.image = UIImage(named: defaultAvatar)

        if conversation.type == "DIRECT" {
            if let participantIds = conversation.userIds {
                let userId = participantIds.filter {
                    $0 != UserDataSource.currentUser.userId
                }
                UserDataSource.sharedInstance.getUser(userId[0], completion: { (user) in
                    DispatchQueue.main.async {
                        self.conversationTitle.text = user.displayName
                        if let url = user.avatarURL {
                            self.conversationAvatar.setImage(url: url)
                        }
                    }
                })
            }
        } else {
            conversationTitle.text = conversation.title
            if let url = conversation.avatarURL {
                self.conversationAvatar.setImage(url: url)
            }
        }

        recentItem.text = conversation.recentItem
        timestamp.text = Utils().createTimestampFromDate(conversation.timestamp!)
        setupUI()
    }

    fileprivate func setupUI() {
        separatorInset = UIEdgeInsets.zero
        layoutMargins = UIEdgeInsets.zero
        conversationAvatar.layer.cornerRadius = conversationAvatar.frame.size.width / 2
        conversationAvatar.layer.masksToBounds = true
        conversationAvatar.contentMode = .scaleAspectFill
    }

}

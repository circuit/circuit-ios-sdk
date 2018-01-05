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
//  DetailConversationTableViewCell.swift
//  SampleApp
//
//

import UIKit

class DetailConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var itemTimestamp: UILabel!

    static let reuseId = "itemCell"

    func configureCellWithConversationItem(conversationItem: ConversationItem) {
        userAvatar.layer.cornerRadius = 10
        userAvatar.layer.masksToBounds = true

        UserDataSource.sharedInstance.getUser(conversationItem.userId!) { (user) in
            DispatchQueue.main.async {
                self.userLabel.text = user.displayName
                guard let url = user.avatarURL else {
                    return
                }
                self.userAvatar.setImage(url: url)
            }
        }

        contentLabel.text = conversationItem.content

        let timestamp = Utils().createTimestampFromDate(conversationItem.timestamp!)
        itemTimestamp.text = timestamp
    }

}

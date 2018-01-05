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
//  CreateConversationCollectionViewCell.swift
//  SampleApp
//
//

import UIKit

class CreateConversationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var checkmarkImage: UIImageView!

    static let reuseID = "userCell"
    private let defaultAvatar = "icon-general-default-avatar"

    func configureCellWithUser (user: User) {
        self.displayName.text = user.displayName

        if let avatarURL = user.avatarURL {
            self.avatarImageView.setImage(url: avatarURL)
        } else {
            // Set default avatar
            self.avatarImageView.image = UIImage(named: defaultAvatar)
        }

        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.width / 2
        self.avatarImageView.layer.masksToBounds = true
    }

}

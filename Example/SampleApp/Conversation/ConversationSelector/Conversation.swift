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
//  Conversation.swift
//  SampleApp
//
//

import UIKit

struct Conversation {

    ///  Array of participant userId's
    var userIds: [String]?

    /// Conversation id.
    var convId: String?

    /// Type of the conversation, can be DIRECT, GROUP, OPEN or LARGE.
    var type: String?

    /** Can be either the topic of the conversation or the display name of the user. In the event this is a group
     conversation there is a possibility this can be empty.
     */
    var title: String?

    /// Modification time of the most recent item.
    var timestamp: Date?

    /// Most recent conversation item.
    var recentItem: String?

    /// Avatar image URL for conversations that are not of type DIRECT
    var avatarURL: URL?

}

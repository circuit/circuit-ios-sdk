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
//  ConversationItem.swift
//  SampleApp
//
//

import Foundation

struct ConversationItem {
    /// Internal ID of the conversation item
    var itemId: String?

    /// Owner of the conversation item
    var userId: String?

    /// Conversation item's content
    var content: String?

    /// State of the conversation item. Could be DELETED or CREATED
    var state: String?

    /// Creation or Modification time of the item
    var timestamp: Date?

    /// Conversation ID that conversation item belongs to
    var convId: String?

    static func == (lhs: ConversationItem, rhs: ConversationItem) -> Bool {
        return lhs.itemId == rhs.itemId
    }

}

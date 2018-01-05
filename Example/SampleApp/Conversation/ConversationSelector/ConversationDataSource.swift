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
//  ConversationDataSource.swift
//  SampleApp
//
//

import Foundation
import CircuitSDK

class ConversationDataSource {

    static let sharedInstance = ConversationDataSource()

    func conversationObjectFromJSConversation(_ jsConversation: AnyObject) -> Conversation? {

        var conversation = Conversation()

        if let participants = jsConversation["participants"] as? [String] {
            conversation.userIds = participants
        }

        if let avatar = jsConversation["avatarLarge"] as? String {
            let avatarURL = URL(string: avatar)
            conversation.avatarURL = avatarURL
        }

        if let type = jsConversation["type"] as? String {
            conversation.type = type
        }

        if let convId = jsConversation["convId"] as? String {
            conversation.convId = convId
        }

        if let topic = jsConversation["topic"] as? String, !topic.isEmpty {
            conversation.title = topic
        } else if let topic = jsConversation["topicPlaceholder"] as? String {
            // If there's no topic, placeholder contains first names of conversation participants
            conversation.title = topic
        }

        if let modificationTime = jsConversation["lastItemModificationTime"] as? NSNumber {
            conversation.timestamp = Utils().createDateFromUTC(modificationTime)
        }

        if let topLevelItem = jsConversation["topLevelItem"] as? NSDictionary {
            conversation.recentItem = Utils().contentOfConversationItem(topLevelItem)
        }

        return conversation
    }

    func fetchConversations(completion: @escaping (_ conversations: [Conversation], _ error: Error?) -> Void) {

        var conversations = [Conversation]()

        DispatchQueue.main.async {
            CKTClient().getConversations { (jsConversations, error) in
                guard error == nil else {
                    completion(conversations, error)
                    return
                }
                for jsConversation in jsConversations as! [AnyObject] {
                    let conv = self.conversationObjectFromJSConversation(jsConversation)
                    guard let parsedConv = conv else {
                        return
                    }
                    conversations.append(parsedConv)
                    conversations = conversations.sorted(by: { (c1: Conversation, c2: Conversation) -> Bool in
                        guard let timestamp1 = c1.timestamp, let timestamp2 = c2.timestamp else {
                            return false
                        }
                        return timestamp1 > timestamp2
                    })
                }
                completion(conversations, nil)
            }
        }
    }
}

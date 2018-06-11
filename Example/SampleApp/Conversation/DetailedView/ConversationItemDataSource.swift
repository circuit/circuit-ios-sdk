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
//  ConversationItemDataSource.swift
//  Sample
//
//

import UIKit
import CircuitSDK

class ConversationItemDataSource {

    static let sharedInstance = ConversationItemDataSource()

    /**
     Creates a conversation item object

     - parameter jsItem: Conversation item in JSON

     - returns: Conversation item object
     */
    func conversationItemFromJSitem(_ jsItem: AnyObject) -> ConversationItem? {
        var item = ConversationItem()
        /*
         We should create a copy of the jsItem since we have two ways of receiving one
         First: We send an item, the jsItem comes in as a dictionary, we can parse this as normal
         Second: We receive an item, this jsItem is a dictionary inside of another dictionary
         called item
         */
        var tmpItem = jsItem

        /*
         We should check if we have an event item, if so remove it from the item dictionary
         and set it as the tmpItem. This should only happen when someone sends us a message
         */
        if let eventItem = tmpItem["item"] as? NSDictionary {
            tmpItem = eventItem
        }

        if let itemId = tmpItem["itemId"] as? String {
            item.itemId = itemId
        }

        if let creatorId = tmpItem["creatorId"] as? String {
            item.userId = creatorId
        }

        if let text = tmpItem["text"] as? NSDictionary, let state = text["state"] as? String {
            item.state = state
        }

        if let convId = tmpItem["convId"] as? String {
            item.convId = convId
        }

        item.content = Utils().contentOfConversationItem(tmpItem)

        if let modificationTime = tmpItem["modificationTime"] as? NSNumber {
            item.timestamp = Utils().createDateFromUTC(modificationTime)
        }
        return item
    }

    enum FetchConversationItemsError: Error {
        case contentException
    }

    /**
     Fetches conversation items based on the conversation id. Returns the last 25 items.
     */
    func fetchConversationItems(convId: String, completion: @escaping (_ items: [ConversationItem], _ error: Error?) -> Void) {
        DispatchQueue.main.async {
            var conversationItems = [ConversationItem]()
            CKTClient().getConversationItems(convId, options: nil) { (items, error) in
                if error != nil {
                    completion(conversationItems, error)
                    return
                }
                for item in items as! [AnyObject] {
                    let convItem = self.conversationItemFromJSitem(item)
                    guard let parsedItem = convItem else {
                        completion(conversationItems, FetchConversationItemsError.contentException)
                        return
                    }
                    conversationItems.append(parsedItem)
                }
                completion(conversationItems, nil)
            }
        }
    }

}

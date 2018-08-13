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
//  CKTClient+Conversation.h
//  CircuitSDK
//
//

#import "CKTClient.h"

@interface CKTClient (Conversation)

/*!

 @brief Add new participants to a group conversation or community

 @discussion Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

 @param convId Conversation ID.
 @param userIds Array containing a single user id or multiple.
 @param completion A completion block that takes no arguments and returns void.

*/
- (void)addParticipant:(NSString *)convId userIds:(NSArray *)userIds completion:(void (^)(void))completion;

/*!

 @brief Adds an item to a conversation

 @discussion This method can take one of two types

 NSString - Text content

 Object - An item object

 The item object can be an NSDictionary containing up to 5 items.

 parentId - The id of the parent post if this is a reply.

 contentType - Either PLAIN or RICH. Default is RICH. Whether the content is rich text (HTML) or plain text.

 subject - Subject/Title of the message. Only supported for parent post (i.e. parentId omitted).

 content - Actual text content

 attachments - Array of picture or video attachments.

 @param convId Id of the conversation to add an item to.
 @param content Content for the item.
 @param completion A completion block that takes either the content submitted or an error and returns void.

 */
- (void)addTextItem:(NSString *)convId
              content:(id)content
    completionHandler:(void (^)(id content, NSError *error))completion;

/*!

 @brief Create a new community

 @discussion Required OAuth2 scopes: WRITE_CONVERSATIONS or FULL

 @param participants [optional] User id's of the user to create a community with.
 @param topic [optional] Topic of the community.
 @param description [optional] Description of the community.
 @param completion A completion block that takes either a community or an error and returns void.

*/
- (void)createCommunity:(NSArray *)participants
                  topic:(NSString *)topic
            description:(NSString *)description
             completion:(void (^)(id community, NSError *error))completion;

/*!

 @brief Create a new conference bridge conversation.

 @discussion Requires one ofxthe following scopes: WRITE_CONVERSATIONS or ALL.

 @param topic Topic of the conversation
 @param completion A completion block that takes either a conversation or an error and returns void.

*/
- (void)createConferenceBridge:(NSString *)topic completion:(void (^)(id conversation, NSError *error))completion;

/*!

 @brief Create a direction conversation with another user by their id.

 @param participantId Participant id to create a direct conversation with.
 @param completion    A completion block that takes either the conversation created or an error and returns void.

 */
- (void)createDirectConversation:(NSString *)participantId
               completionHandler:(void (^)(id conversation, NSError *error))completion;

/*!

 @brief Creates a group conversation from an array of participant id's

 @param participantIds Array of participant id's to create a group conversation with.
 @param title Title of the conversation.
 @param completion A completion block that takes either a created conversation or an error and returns void.

 */
- (void)createGroupConversation:(NSArray *)participantIds
                          title:(NSString *)title
              completionHandler:(void (^)(id conversation, NSError *error))completion;

/*!

 @brief Flag an item. Flags are user specific.

 @discussion Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

 @param convId Id of the conversation where the item exists.
 @param itemId Id of the item to be flagged.
 @param completion A completion block that takes no arguments and returns void.

*/
- (void)flagItem:(NSString *)convId itemId:(NSString *)itemId completion:(void (^)(void))completion;

/*!

 @brief Returns the conversations of the logged on user in JSON format.

 @param completion A completion block that takes either conversations or an error and returns void.

 */
- (void)getConversations:(void (^)(id conversations, NSError *error))completion;

/*!

 @brief Returns the conversations of the logged on user in JSON format filtered by the given options.

 @discussion This method takes an NSDictionary of options to filter by

 direction - Whether to get the conversations BEFORE or AFTER a certain timestamp. Default is BEFORE.

 timestamp - Timestamp used in conjunction with the direction option. Default is current timestamp.

 numberOfConversations - Maximum number of conversations to retrieve. Default is 25.

 @param options NSDictionary containing the options to filter by.
 @param completion A completion block that takes either conversations or an error and returns void.

 */
- (void)getConversations:(NSDictionary *)options
       completionHandler:(void (^)(id conversations, NSError *error))completion;


/*!

 @brief Get the conversation by conversationId.

 @param convId The conversation's id.
 @param completion A completion block that takes either conversations or an error and returns void.
 */

- (void)getConversationById:(NSString *)convId
          completionHandler:(void (^)(NSDictionary *conversation, NSError *error))completion;

/*!

 @brief Get the conversation details such as the bridge number and guest link.

 @discussion Required OAuth2 scopes: READ_CONVERSATIONS or ALL.

 @param convId Id of the conversation to get details of.
 @param completion A completion block that takes either conversation details or an error and returns void.

*/
- (void)getConversationDetails:(NSString *)convId completion:(void (^)(id details, NSError *error))completion;

/*!

 @brief Retrieve items of a conversation in a threaded structure before a specific timestamp. Allows specifying how many
 comments per thread to retrieve, and also how many unread messages of a thread to retireve.

 @discussion Required OAuth2 scopes: READ_CONVERSATIONS or ALL

 @param convId Conversation Id of the items to retrieve.
 @param options Dictionary containing specific options.
 @param completion A completion block that takes either a conversation feed or an error and returns void.

*/
- (void)getConversationFeed:(NSString *)convId
                    options:(NSDictionary *)options
                 completion:(void (^)(id feed, NSError *error))completion;

/*!

 @brief Returns the conversation items in JSON format by the given conversation id. You can pass an dictionary of
 options of leave this nil for defaults

 @discussion This method takes an optional dictionary of options to filter by

  modificationDate - Mutually exclusive with creationTime. Default is current timestamp.

  creationTime - Mutually exclusive with modificationTime. Default is current timestamp.

 direction - Whether to get items BEFORE or AFTER a certain timestamp. Default is BEFORE.

 numberOfItems - Maximum number of conversation items to retrieve. Default is 25.

 @param convId Conversation id for the items requested.
 @param options Options to filter the conversation items by.
 @param completion A completion block that takes either conversation items or an error and returns void.

 */
- (void)getConversationItems:(NSString *)convId
                     options:(NSDictionary *)options
                  completion:(void (^)(id convItems, NSError *error))completion;

/*!

 @brief Retrieve conversation participants using optional search criteria.

 @discussion Required OAuth2 scopes: READ_CONVERSATIONS or ALL

 @param convId Conversation id to get participants from.
 @param completion A completion block that takes either conversation participants or an error and returns void.

*/
- (void)getConversationParticipants:(NSString *)convId
                            options:(NSDictionary *)options
                         completion:(void (^)(id participants, NSError *error))completion;

/*!

 @brief Get the direct conversation with a user by their user id or email address.

 @param query User id or email address
 @param createIfNotExists Create a conversation with the user if not already existing. Default is FALSE.
 @param completion A completion block that takes either a conversation or an error and returns void.

 */
- (void)getDirectConversationWithUser:(NSString *)query
                    createIfNotExists:(BOOL)createIfNotExists
                           completion:(void (^)(id converation, NSError *error))completion;

/*!

 @brief Get all flagged items.

 @discussion Required OAuth2 scopes: READ_CONVERSATIONS OR ALL

 @param completion A completion block that takes either all flagged items or an error and returns void.

*/
- (void)getFlaggedItems:(void (^)(id items, NSError *error))completion;

/*!

 @brief Returns a single item in JSON format by the given item id.

 @param itemId Id of the item being requested.
 @param completion A completion block that takes either an item or an error and returns void.

 */
- (void)getItemById:(NSString *)itemId completionHandler:(void (^)(id item, NSError *error))completion;

/*!

 @brief Retrieve multiple conversation items by their id.

 @discussion Required OAuth2 scopes: READ_CONVERSATIONS or FULL

 @param itemIds Conversation Item IDs.
 @param completion A completion block that takes either an items or an error and returns void.

 */
- (void)getItemsById:(NSArray *)itemIds completionHandler:(void (^)(id items, NSError *error))completion;

/*!

 @brief Retrieve conversation items of a thread.

 @discussion Requires OAuth2 scopes: READ_CONVERSATIONS or ALL

 @param convId Conversation id.
 @param threadId Thread id.
 @param options Dictionary containing specific options.
 @param completion A completion block that takes either items or an error and returns void.

*/
- (void)getItemsByThread:(NSString *)convId
                threadId:(NSString *)threadId
                 options:(NSDictionary *)options
              completion:(void (^)(id items, NSError *error))completion;

/*!

 @brief Retrieve all marked (muted or favorited) converation id's.

 @discussion Required OAuth2 scopes: READ_CONVERSATIONS or ALL.

 @param completion A completion block that takes marked conversation id's or an error and returns void.

*/
- (void)getMarkedConversations:(void (^)(id conversations, NSError *error))completion;

/*!

 @brief Get the special supprt conversation id. The support conversation is a special conversation the user can report
 problems with.

 @discussion Required OAuth2 scopes: READ_CONVERSATIONS or ALL

 @param completion A completion block that takes either a conversation id or an error and returns void.

*/
- (void)getSupportConversationId:(void (^)(id conversationId, NSError *error))completion;

/*!

 @brief Get the special telephony conversation id. The telephony conversation is a speical conversation the user has in
 case the tenant is enabled for telephony.

 @discussion Required OAuth2 scopes: READ_CONVERSATIONS or ALL

 @param completion A completion block that takes either a conversation id or an error and returns void.

 */
- (void)getTelephonyConversationId:(void (^)(id conversationId, NSError *error))completion;

/*!

 @brief Like an item. Likes will be seen by others.

 @discussion Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

 @param itemId ID of the liked item.
 @param completion A completion block that takes no parameters and returns void.

*/
- (void)likeItem:(NSString *)itemId completion:(void (^)(void))completion;

/*!

 @brief Mark all items of the specified conversation, before a timestamp as read.

 @discussion Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

 @param convId Coversation ID.
 @param creationTime Items older than this timestamp are marked as read. Defaults to current time.
 @param completion A completion block that takes no arguments and returns void.

*/
- (void)markItemAsRead:(NSString *)convId creationTime:(NSNumber *)creationTime completion:(void (^)(void))completion;

/*!

 @brief Remove a participant from a group conversation or community.

 @discussion Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

 @param convId Conversation ID.
 @param userIds Single user id or array of user id's.
 @param completion A completion block that takes no arguments and returns void.

*/
- (void)removeParticipant:(NSString *)convId userIds:(id)userIds completion:(void (^)(void))completion;

/*!

 @brief Clear the flag of an item

 @discussion Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

 @param convId Conversation ID.
 @param itemId Item ID of the item to be flagged.
 @param completion A completion block that takes no arguments and returns void.

*/
- (void)unflagItem:(NSString *)convId itemId:(NSString *)itemId completion:(void (^)(void))completion;

/*!

 @brief Unlike an item

 @discussion Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

 @param itemId Item ID of the item to unlike.
 @param completion A completion block that takes no arguments and returns void.

*/
- (void)unlikeItem:(NSString *)itemId completion:(void (^)(void))completion;

/*!

 @brief Update an existing text message

 @discussion Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

 @param content Dictionary of options and content
 @param completion A completion block that takes an item or an error and returns void.

*/
- (void)updateTextItem:(NSDictionary *)content completion:(void (^)(id item, NSError *error))completion;

/*!

 @brief Update a conversation or community.

 @discussion Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

 @param convId Conversation ID
 @param attributes Attributes to change, keys
 could be "topic" of conversation/community and "description" (only applicable to communities)
 @param completion A completion block that takes an updated conversation or an error and returns void.

 */
- (void)updateConversation:(NSString *)convId
        attributesToChange:(NSDictionary *)attributes
                completion:(void (^)(id item, NSError *error))completion;

@end

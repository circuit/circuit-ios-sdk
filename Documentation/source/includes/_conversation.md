# CKTClient+Conversation

## addParticipant:userIds:completion:

```objective_c
[client addParticipant:@"CONVERSATION ID",
               userIds:@["USER ID(s)"],
            completion:^{
  // Code goes here
}];
```

```swift
CKTClient().addParticipant("CONVERSATION ID",
            userIds: ["USER ID(s)"],
            completion: {
    // Code goes here
})
```

Add new participants to a group conversation or community

Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
convId | string | Conversation ID to add the participant to.
userIds | array | Array containing a single or multiple user ids
completion | callback | A completion block that takes no arguments and returns void.

## addTextItem:content:completionHandler:

> Adding an item with the string content type

```objective_c
[client addTextItem:@"CONVERSATION ID" content:@"TEXT CONTENT" completion:^(id content, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().addTextItem("CONVERSATION ID", content: "TEXT CONTENT") { (content, error) in
  // Code goes here
}
```

> Adding an item with the object content type

```objective_c
NSDictionary *content = @{ @"parentId": @"PARENT CONVERSATION ID",
                           @"contentType": @"PLAIN",
                           @"subject": @"SUBJECT",
                           @"content": @"TEXT CONTENT",
                           @"attachments": @[ PHOTO OR VIDEO ] };

[client addTextItem:@"CONVERSATION ID" content:content completion:^(id content, NSError *error) {
  // Code goes here
  }];
```

```swift
let content = [ "parentId": "PARENT CONVERSATION ID",
                "contentType": "PLAIN",
                "subject": "SUBJECT",
                "content": "TEXT CONTENT",
                "attachments": [ PHOTOT OR VIDEO ] ]

CKTClient().addTextItem("CONVERSATION ID", content: content) { (content, error) in
  // Code goes here
}
```

Adds an item to a conversation, this method can take one of two types

Type | Description
--------- | ---------
string | Text content
object | Item object

The item object can contain any of the following

Option | Type |  Description
--------- | ----------- | ---------
parentId | string | The id of the parent post if this is a reply
contentType | string | Either PLAIN or RICH, default is RICH. Whether the content is rich text (HTML) or plain text
subject | string | Subject/Title of the message. Only supported for parent post (i.e. parentId omitted)
content | string | Actual text content
attachments | array | Picture or video attachments

Parameter | Type |  Description
--------- | ----------- | ---------
content | string   object | Content for the item
completion | callback | A completion block that takes either the sent content or an error and returns void

## createCommunity:topic:description:completion:

```objective_c
[client createCommunity:@["USER ID(s)"],
                  topic:@"COMMUNITY TOPIC",
            description:@"COMMUNITY DESCRIPTION",
             completion:^(NSDictionary *community, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().createCommunity(["USER ID(s)"],
            topic: "COMMUNITY TOPIC",
            description: "COMMUNITY DESCRIPTION",
            completion: { (community, error) in
    // Code goes here
})
```

Creates a new community

Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
participants [optional] | array |  User ID(s) of the user(s) to create a community with.
topic [optional] | string | Topic of the community.
description [optional] | string | Description of the community.
completion | callback | A completion block that takes either a community or an error and returns void.

## createConferenceBridge:completion:

```objective_c
[client createConferenceBridge:@"TOPIC"
                    completion:^(NSDictionary *conversation, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().createConferenceBridge("TOPIC", { (conversation, error) in
  // Code goes here
})
```

Create a new conference bridge conversation.

Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
topic | string | Topic of the conversation
completion | callback | A completion block that takes either a conversation or an error and returns void.

## createDirectConversation:completion:

```objective_c
[client createDirectConversation:@"PARTICIPANT ID" completion:^(NSDictionary *conversation, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().createDirectConversation("PARTICIPANT ID") { (conversation, error) in
  // Code goes here
}
```

Creates a direct conversation from  with the participant of the given id

Parameter | Type |  Description
--------- | ----------- | ---------
participantId | string | Participant id to create a direct conversation with
completion | callback | A completion block that takes either the conversation created or an error and returns void

## createGroupConversation:title:completionHandler

```objective_c
[client createGroupConversation:@[ @"PARTICIPANT ID" ] title:@"TITLE" completionHandler:^(NSDictionary *conversation, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().createGroupConversation([ "PARTICIPANT ID" ], title:"TITLE") { (conversation, error) in
  // Code goes here
}
```

Creates a group conversation from an array of participant id's

Parameter | Type |  Description
--------- | ----------- | ---------
participantId | array | Array of participant id's to create a group conversation with
topic | string | Title of the conversation to be created
completion | callback | A completion block that takes either the conversation created or an error and returns void

## flagItem:itemId:completion:

```objective_c
[client flagItem:@"CONVERSATION ID"
          itemId:@"ITEM ID"
          completion:^{
  // Code goes here
}];
```

```swift
CKTClient().flagItem("CONVERSATION ID",
              itemId:"ITEM ID") {
  // Code goes here
}
```

Flag an item. Flags are user specific

Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
conversationId | string | Id of the conversation where the item exists
itemId | string | Id of the item to be flagged
completion | callback | A completion block that takes no arguments and returns void

## getConversations:

```objective_c
[client getConversations: ^(NSArray *conversations, NSError *error) {
// Code goes here
}];
```

```swift
CKTClient().getConversations() { (conversations, error) in
// Code goes here
}
```

Returns the conversations of the logged on user in JSON format

Parameter | Type |  Description
--------- | ----------- | ---------
options [optional] | dictionary | A dictionary of options to filter conversations
completion | callback | A completion block that takes either conversations or an error and returns void

## getConversations:completionHandler:

```objective_c
NSDictionary *options = @{ @"direction": @"BEFORE",
                           @"timestamp": @1264378424,
                           @"numberOfConversations": @10
                           @"numberOfParticipants": @5
                         };

[client getConversations:options completionHandler:^(NSArray *conversations, NSError *error) {
  // Code goes here
}];
```

```swift
let options = [ "direction": "BEFORE",
                "timestamp": 1264378424,
                "numberOfConversations": 10,
                "numberOfParticipants": 5 ]

CKTClient().getConversations(options) { (conversations, error) in
  // Code goes here
}
```

Returns the conversations of the logged on user in JSON format, you can pass
in a dictionary of options or set this to nil depending on how you want to retrieve
conversations.

Option | Type |  Description
--------- | ----------- | ---------
direction | string | Whether to get the conversations BEFORE or AFTER a certain timestamp, default is BEFORE
timestamp | number | Timestamp used in conjunction with the direction option, default is current timestamp
numberOfConversations | number | Maximum number of conversations to retrieve, default is 25
numberOfParticipants | number | Maximum number of participants to return in the participants array. Default is 8

Parameter | Type |  Description
--------- | ----------- | ---------
options [optional] | dictionary | A dictionary of options to filter conversations
completion | callback | A completion block that takes either conversations or an error and returns void


## getConversationById:completionHandler:

```objective_c
[client getConversationById:@"CONVERSATION ID"
                completionHandler:^(NSDictionary conversation,  NSError *error){
  // Code goes here
}]
```
```swift
CKTClient().getConversationById("CONVERSATION ID") { (conversation, error) in
  // Code goes here
}
```

Get the conversation by conversation Id.

Parameter | Type |  Description
--------- | ----------- | ---------
convId | string | Conversation Id
completion | callback | A completion block that takes either conversations or an error and returns void.

## getConversationDetails:completion:

```objective_c
[client getConversationDetails:@"CONVERSATION ID"
                    completion:^(NSArray *details, NSError *error) {
  // Code goes here
}];
```
```swift
CKTClient().getConversationDetails("CONVERSATION ID") { (details, error) in
  // Code goes here
}
```

Get the conversation details such as the bridge number and guest link.

Required OAuth2 scopes: READ_CONVERSATIONS or ALL.

Parameter | Type |  Description
--------- | ----------- | ---------
convId | string | Conversation Id of the items to retrieve
completion | callback | A completion block that takes either conversation details or an error and returns void

## getConversationFeed:options:completion:

```objective_c
NSDictionary *options = @{ @"timestamp" : 1264378424,
                           @"minTotalItems" : 15,
                           @"maxTotalUnread" : 30,
                           @"commentsPerThread" : 5,
                           @"maxUnreadPerThread" : 2};

[client getConversationFeed:@"CONVERSATION ID"
                options: options
                completion:^(NSArray *feed, NSError *error) {
  // Code goes here
}];
```

```swift
let options = [ @"timestamp" : 1264378424,
                @"minTotalItems" : 15,
                @"maxTotalUnread" : 30,
                @"commentsPerThread" : 5,
                @"maxUnreadPerThread" : 2 ]

CKTClient().getConversationItems("CONVERSATION ID",
                options: options) { (feed, error) in
  // Code goes here
}
```

Retrieve items of a conversation in a threaded structure before a specific timestamp. Allows specifying how many
comments per thread to retrieve, and also how many unread messages of a thread to retireve.

Required OAuth2 scopes: READ_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
convId | string | Conversation Id of the items to retrieve
options | dictionary | Dictionary containing specific options
completion | callback | A completion block that takes either a conversation feed or an error and returns void

## getConversationItems:options:completion:

```objective_c
NSDictionary *options = @{ @"direction": @"BEFORE",
                           @"creationTime": @1264378424,
                           @"numberOfConversations": @10 };

[client getConversationItems:@"CONVERSATION ID"
                    threadId:@"THREAD ID"
                     options: options
                  completion:^(NSArray *items, NSError *error) {
  // Code goes here
}];
```

```swift
let options = [ "direction": "BEFORE",
                "creationTime": 1264378424,
                "numberOfConversations": 10 ]

CKTClient().getConversationItems("CONVERSATION ID",
                        threadId: "THREAD ID",
                         options: options) { (items, error) in
  // Code goes here
}
```

Returns the conversation items in JSON format by the given conversation id. You can pass a dictionary of options or leave this nil for defaults.

Option | Type |  Description
--------- | ----------- | ---------
modificationDate | number | Mutually exclusive with creationTime, default is current timestamp
creationTime | number | Mutually exclusive with modificationTime, default is current timestamp
direction | string | Whether to get the conversations BEFORE or AFTER a certain timestamp, default is BEFORE
numberOfItems | number | Maximum number of conversation items to retrieve, default is 25

Parameter | Type |  Description
--------- | ----------- | ---------
convId | string | Conversation id for the items to retrieve
threadId | string | Item Id of the initial post of the thread
options [optional] | dictionary | Options to filter the conversation items
completion | callback | A completion block that takes either conversation items or an error and returns void

## getConversationParticipants:options:completion:

```objective_c
NSDictionary *options = @{ @"pageSize": @20,
                           @"includePresence": @(YES) };

[client getConversationParticipants: @"CONVERSATION ID"
                            options: options
                            completion:^(NSDictionary *participants, NSError *error) {
  // Code goes here
}];
```

```swift
let options = ["pageSize": 20,
               "includePresence": true ]

CKTClient().getConversationParticipants("CONVERSATION ID",
                                options: options) { (participants, error) in
 // Code goes here
}
```

Retrieve conversation participants using optional search criteria

Required OAuth2 scopes: READ_CONVERSATIONS or ALL

Option | Type | Criteria
--------- | ----------- | ---------
pageSize | number | Number of participants per page. Maximum is 100
includePresence | boolean | If set to true this will add the presence state of the user to the returned participant object. Default is false

Parameter | Type | Description
--------- | ----------- | ---------
convId | string | Conversation Id
options [optional] | dictionary | Options for search criteria
completion | callback | A completion block that takes either conversation participants or an error and returns void

## getDirectConversationWithUser:createIfNotExists:completion:

```objective_c
[client getDirectConversationWithUser:@"USER QUERY"
                    createIfNotExists: YES
                           completion:^(NSDictionary *conversation, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getDirectConversationWithUser("USER QUERY",
                        createIfNotExists: true) { (conversation, error) in
  // Code goes here
}
```

Get the direct conversation with a user by their user id or email address

Required OAuth2 scopes: READ_CONVERSATIONS or ALL

Parameter | Type | Description
--------- | ----------- | ---------
query | string | User id or user email address
createIfNotExists | boolean | Create conversation with user if not already existing. Default is FALSE
completion | callback | A completion block that takes either a conversation or an error and returns void

## getFlaggedItems:

```objective_c
[client getFlaggedItems:^(NSDictionary *items, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getFlaggedItems { (items, error) in
  // Code goes here
}
```

Get all flagged items

Required OAuth2 scopes: READ_CONVERSATIONS or ALL

Parameter | Type | Description
--------- | ----------- | ---------
completion | callback | A completion block that takes either all flagged items or an error and returns void

## getItemById:completionHandler:

```objective_c
[client getItemById:@"ITEM ID" completion:^(NSDictionary *item, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getItemById("ITEM ID") { (item, error) in
  // Code goes here
}
```

Returns a single item in JSON format by the given item id

Parameter | Type |  Description
--------- | ----------- | ---------
itemId | string | Item id for the item to retrieve
completion | callback | A completion block that takes either conversation item or an error and returns void

## getItemsById:completionHandler:

```objective_c

NSArray *itemIDs = @[@"bee98d40-7c7c-4246-b1e4-b29183728da1",
                     @"e2c20bc1-dd67-4dfb-a0c7-bc11676634b8",
                     @"1984c74e-0e77-4d36-a121-22c1c5a8cc70"];

[client getItemsById:itemIDs completion:^(NSDictionary *items, NSError *error) {
// Code goes here
}];
```

```swift
let itemsIds = ["bee98d40-7c7c-4241-b1e6-b29183728da1",
                "e2c20bc1-dd67-4dfb-a0c7-bc11672634b8",
                "1984c74e-0e77-4d36-a121-22c1c5a8cc70"]

CKTClient().getItemsById(itemsIds) { (items, error) in
// Code goes here
}
```
Retrieve multiple conversation items by their id

Required OAuth2 scopes: READ_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
itemIds | arrary | Conversation Item IDs
completion | callback | A completion block that takes either conversation item or an error and returns void

## getItemsByThread:threadId:options:completion:

```objective_c
NSDictionary *options = @{ @"modificationDate": @145694922,
                           @"creationDate": @329293948,
                           @"direction": @"BEFORE",
                           @"number": @-1
};

[client getItemsByThread:@"CONVERSATION ID"
                threadId:@"THREAD ID"
                 options: options
              completion:^(NSDictionary *items, NSError *error) {
  // Code goes here              
}];
```

```swift
let options = ["modificationDate": 145694922,
               "creationDate": 329293948,
               "direction": "BEFORE",
               "number": -1]

CKTClient().getItemsByThread("CONVERSATION ID",
                    threadId:"THREAD ID",
                     options:options) { (items, error) in
  // Code goes here
}
```

Retrieve conversation items of a thread

Required OAuth2 scopes: READ_CONVERSATIONS or ALL

Option | Type | Description
--------- | ----------- | ---------
modificationDate | number | Defines a date to compare with the last modification date of an item.
creationDate | number | Defines a date to compare with the creation date of an item. Defaults to current timestamp.
direction | string | Whether to get items BEFORE or AFTER a certain timestamp.
number | number | Maximum number of conversation items to retrieve. Default (-1) is to retrieve all items of a thread.

Parameter | Type |  Description
--------- | ----------- | ---------
convId | string | Conversation ID
threadId | string | Thread ID
options | dictionary | Dictionary containing specific options listed above
completion | callback | A completion block that takes either items or an error and returns void

## getMarkedConversations:

```objective_c
[client getMarkedConversations:^(NSDictionary *conversations, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getMarkedConversations { (conversations, error) in
  // Code goes here
}
```

Retrieve all marked (muted or favorited) conversation id's

Required OAuth2 scopes: READ_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
completion | callback | A completion block that takes either mark conversations or an error and returns void

## getSupportConversationId:

```objective_c
[client getSupportConversationId:^(NSString *conversationId, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getSupportConversationId { (conversationId, error) in
  // Code goes here
}
```

Get the special support conversation id. The support conversation is a special conversation the user can report problems with

Required OAuth2 scopes: READ_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
completion | callback | A completion block that takes either the support conversation id or an error and returns void

## getTelephonyConversationId:

```objective_c
[client getTelephonyConversationId:^(NSString *conversationId, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().getTelephonyConversationId { (conversationId, error) in
  // Code goes here
}
```

Get the special telephony conversation id. The telephony conversation is a special conversation the user has in case the tenant is enabled for telephony

Required OAuth2 scopes: READ_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
completion | callback | A completion block that takes either the support conversation id or an error and returns void

## likeItem:completion:

```objective_c
[client likeItem:@"ITEM ID"
      completion:^{
  // Code goes here
}];
```

```swift
CKTClient().likeItem("ITEM ID") {
  // Code goes here
}
```

Like an item. Likes will be seen by others

Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
itemID | string | ID of the liked item
completion | callback | A completion block that takes no arguments and returns void

## markItemAsRead:creationTime:completion:

```objective_c
[client markItemAsRead:@"CONVERSATION ID"
          creationTime:124858473
            completion:^{
  // Code goes here
}];
```

```swift
CKTClient().markItemAsRead("CONVERSATION ID",
              creationTime:124858473) {
  // Code goes here
}
```

Mark all items of the specified conversation, before a timestamp as read

Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
convId | string | Conversation id
creationTime | number | Items older than this timestamp are marked as read. Defaults to current time
completion | callback | A completion block that takes no arguments and returns void

## removeParticipant:userIds:completion:

```objective_c
[client removeParticipant:@"CONVERSATION ID"
                  userIds:@"USER ID"
               completion:^{
  // Code goes here
}];
```

```swift
CKTClient().removeParticipant("CONVERSATION ID",
                      userIds:"USER ID") {
  // Code goes here
}
```

Remove a participant from a group conversation or community

Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
convId | string | Conversation Id
userIds | any | Single user id as string or array of many user ids
completion | callback | A completion block that takes no arguments and returns void

## unflagItem:itemId:completion:

```objective_c
[client unflagItem:@"CONVERSATION ID"
            itemId:@"ITEM ID"
        completion:^{
  // Code goes here
}];
```

```swift
CKTClient().unflagItem("CONVERSATION ID", itemId: "ITEM ID") {
  // Code goes here
}
```

Clear the flag of an item

Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
convId | string | Conversation ID
itemId | string | ID of the flagged item to to unflag
completion | callback | A completion block that takes no arguments and returns void

## unlikeItem:completion:

```objective_c
[client unlikeItem:@"ITEM ID"
        completion:^{
  // Code goes here
}];
```

```swift
CKTClient().unlikeItem("ITEM ID") {
  // Code goes here
}
```

Unlike an item

Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
itemId | string | Id of the item to unlike
completion | callback | A completion block that takes no arguments and returns void

## updateTextItem:completion:

```objective_c
[client updateTextItem:options
            completion:^(NSDictionary *item, NSError *error) {
  // Code goes here
}];
```

```swift
CKTClient().updateTextItem(options) { (item, error) in
  // Code goes here
}
```

Update an existing text item

Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
content | dictionary | Item options and content. See addTextItem for options
completion | callback | A completion block that takes an item or an error and returns void

## updateConversation:attributesToChange:completion:

```objective_c

NSString convId =  @"3dab2b90-a3c4-402f-aa26-72238420c4e4";
NSDictionary *attributes = @{ @"topic" : @"New ConvTopic",
                              @"description" : @"Corp Community Conv" };


[self updateConversation:convId
                attributesToChange:attributes
                        completion:^(id item, NSError *error) {
// Code goes here
}];
```

```swift

let convId = "3dab2b90-a3c4-402f-aa26-72238420c4e4"
let attributes = ["topic": "New ConvTopic",
                  "description": "Corp Community Conv" ]

CKTClient().updateConversation(convId,
                attributesToChange: attributes) { (jsconv, error)
// Code goes here
}
```
Update a conversation or community

Required OAuth2 scopes: WRITE_CONVERSATIONS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
convId | string | Conversation ID
attributes | dictionary | Attributes to change, keys could be "topic" of conversation/community and "description" (only applicable to communities)
completion | callback | A completion block that takes an updated conversation or an error and returns void

## Response

CircuitKit responses are in JSON format

```jsonnet
{
    convId = "CONVERSATION ID";
    creationTime = CREATION TIME;
    creatorId = "CREATOR ID";
    creatorTenantId = "CREATORS TENANT ID";
    isDeleted = 0;
    lastItemModificationTime = LAST ITEM MODIFICATION TIME;
    modificationTime = MODIFICATION TIME;
    participants =     (
        "PARTICIPANT USER ID",
        "PARTICIPANT USER ID"
    );
    rtcSessionId = "RTC SESSION ID";
    topLevelItem = {
        convId = "CONVERSATION ID";
        creationTime = CREATION TIME;
        creatorId = "CREATOR ID";
        dataRetentionState = UNTOUCHED;
        includeInUnreadCount = 1;
        itemId = "ITEM ID";
        modificationTime = MODIFICATION TIME;
        system = {
            affectedParticipants = (
                "PARTICIPANT USER ID",
                "PARTICIPANT USER ID"
            );
            type = "CONVERSATION_CREATED";
        };
        type = SYSTEM;
    };
    topic = "";
    type = DIRECT;
    userData = {
        lastReadTimestamp = LAST READ TIMESTAMP;
        unreadItems = 0;
    };
}
```

Parameter | Type |  Description
--------- | ----------- | ---------
convId | string | Conversation id
creationTime | number | Conversation creation time
creatorId | string | Conversation creator's user id
creatorTenantId | string | Conversation creator's tenant id
isDeleted | bool | If the conversation is deleted or not
lastItemModificationTime | number | Modification time of the last item
modificationTime | number | Conversation modification time
participants | array | Conversation participants
rtcSessionId | string | ID of the current rtc session
topLevelItem | json | Most recent conversation item
topic | string | Conversation title
type | string | Conversation type can be DIRECT, OPEN, GROUP

### topLevelItem

Parameter | Type |  Description
--------- | ----------- | ---------
convId | string | Parent conversation id
creationTime | number | Item creation time
creatorId | string | Item creator user id
dataRetentionState | string | If the item was modified
includeInUnreadCount | bool | If this is an unread item or not
itemId | string | item id
modificationTime | number | Item modification time

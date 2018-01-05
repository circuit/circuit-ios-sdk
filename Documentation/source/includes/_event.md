# Event Handling

Event handling is already setup in the SDK. All you have to do to provide
event handling to your application is add some observers where you want to listen
to specific events.

Event | Type |  Description
--------- | ----------- | ---------
CKTNotificationBasicSearchResults | string | Asynchronous search results for startUserSearch or startBasicSearch
CKTNotificationConnectionStateChanged | string | Fired when the connection state changes
CKTNotificationConversationCreated | string | Fired when a new conversation is created for this user. This can be a brand new conversation, or being added to a conversation
CKTNotificationConversationUpdated | string | Fired when an existing conversation is updated
CKTNotificationItemAdded | string | Fired when a new conversation item is received. Note that the sender of an item will also receive this event
CKTNotificationItemUpdated | string | Fired when an existing conversation item is updated
CKTNotificationReconnectFailed | string | Fired when automatic reconnecting to the server fails
CKTNotificationRenewToken | string | Fired when token has been renewed after session expiry. Error included on failure
CKTNotificationSessionExpires | string | Fired when session expires
CKTNotificationUserPresenceChanged | string | Fired when the presence of a subscribed user changes
CKTNotificationUserSettingsChanged | string | Fired when one or more user settings for the logged on user change
CKTNotificationUserUpdated | string | Fired when the local user is updated. E.g. I change the jobTitle on my mobile device

## Adding Observers

```objective_c
[[NSNotificationCenter defaultCenter]
                       addObserver:self
                       selector:@selector(itemAddedToConversation)
                           name:CKTNotificationItemAdded object:nil];
```

```swift
 NSNotificationCenter.defaultCenter()
                     .addObserver(self,
                     selector:#selector(itemAddedToConversation),
                         name:CKTNotificationItemAdded, object: nil)

```

To listen for events you need to add observers to your application logic. You
do this using Apple's Notification Center if you have never used NotificationCenter
you can find more information on [NotificationCenter](https://developer.apple.com/documentation/foundation/notificationcenter)

In the example we are watching for an event called `CKTNotificationItemAdded` which when triggered
will fire a method called `itemAddedToConversation`

More on event types can be found in the section above.

# CKTClient+Call

## addParticipantToCall:to:completion:

```objective_c
[self addParticipantToCall:@"callId" to:@{"Dial out information"} completion:^{
// Code goes here
}];
```

```swift
client.addParticipant(toCall: "callId", to: ["Dial out information"], completion: {
// Code goes here
})
```

Add a participant to a call via dial out. The participant does not have to be a member of the conversation.
Dialing PSTN number is also supported.

Parameter | Type |  Description
--------- | ----------- | ---------
callId | string | Id of the current call
to | dictionary | Dictionary containing dial out information
completion | callback | A completion handler that takes no arguments and returns void

## addParticipantToRtcSession:to:completion:

```objective_c
[self addParticipantToRtcSession:@"callId" to:@{"Dial out information"} completion:^{
// Code goes here
}];
```
```swift
client.addParticipantToRtcSession(toCall: "callId", to: ["Dial out information"], completion: {
// Code goes here
})
```

Add a participant to an RTC Session via dial out. Unlike addParticipantToCall this API does not rely on a local  call to be present. The participant does not have to be a member of the conversation. Dialing PSTN number is also supported.

Parameter | Type |  Description
--------- | ----------- | ---------
callId | string | Id of the current call
to | dictionary | Dictionary containing dial out information
completion | callback | A completion handler that takes no arguments and returns void


## answerCall:mediaType:completionHandler:

```objective_c
NSDictionary *mediaType = @{@"audio": @"true", @"video": @"false"};
[self answerCall:@"callId" mediaType:mediaType
            completionHandler:^(NSDictionary *call, NSError *error){
// Code goes here
}];
```
```swift
let mediaType = ["audio": true, "video": false]
client?.answerCall("callId", mediaType: mediaType, completionHandler: { (call, error) in
// Code goes here
})
```

Answer an incoming call received in a callIncoming event

Parameter | Type |  Description
--------- | ----------- | ---------
callId | string |  callId of the call to answer
mediaType | dictionary | Object with boolean attributes: audio, video
completion | callback | A completion handler that takes either a call or an error and returns void

## dialNumber:completionHandler:

```objective_c
[self dialNumber:@"number" completionHandler:^(NSDictionary *call, NSError *error) {
// Code goes here
}];
```
```swift
client.dialNumber("number") { (call, error) in
// Code goes here
}
```



Start a telephony conversation

Parameter | Type |  Description
--------- | ----------- | ---------
number | string |  Dialable number, must match Circuit.Utils.PHONE_PATTERN
completion | callback | A completion that takes either a call or an error and returns void


## dialNumber:name:completionHandler:

```objective_c
[self dialNumber:@"number" name:@"name" completionHandler:^(NSDictionary *call, NSError *error) {
// Code goes here
}];
```
```swift
client.dialNumber("number", name: "name") { (call, error) in
// Code goes here
}
```

Start a telephony conversation

Parameter | Type |  Description
--------- | ----------- | ---------
number | string |  Dialable number, must match Circuit.Utils.PHONE_PATTERN
name | string | Display name of the number being dialed
completion | callback | A completion that takes either a call or an error and returns void

## endCall:completion:

```objective_c
[self endCall:@"callId" completion:^{
// Code goes here
}];
```
```swift
client.endCall("callId") {
// Code goes here
}
```
End a direct call or leave a group conference

Parameter | Type |  Description
--------- | ----------- | ---------
callId | string |  Call id of the call to leave
completion | callback | A completion block that takes no arguments and returns void


## endConference:completion:

```objective_c
[self endConference:@"callId" completion:^{
// Code goes here
}];
```
```swift
client.endConference("callId") {
// Code goes here
}
```
End a conference call. Disconnects all other participants as well

Parameter | Type |  Description
--------- | ----------- | ---------
callId | string |  Call id of the call to leave.
completion | callback | A completion block that takes no arguments and returns void


## leaveConference:completion:

```objective_c
[self leaveConference:@"callId" completion:^(NSError *error) {
// Code goes here
}];
```
```swift
client.leaveConference("callId") { (error) in
// Code goes here
}
```

Leave a conference call

Parameter | Type |  Description
--------- | ----------- | ---------
callId | string |  Call id of the call to leave.
completion | callback | A compleiton that takes no arguments and replying with an error

## findCall:completionHandler:

```objective_c
[self findCall:@"callId" completionHandler:^(NSDictionary *call, NSError *error) {
// Code goes here
}];
```
```swift
client.findCall("callId") { (call, error) in
// Code goes here
}
```
Find a call by its call Id. Call may be local or remote, active or non-active

Parameter | Type |  Description
--------- | ----------- | ---------
callId | string |  Call id of the call to leave
completion | callback | A completion handler that takes either a call or an error and returns void


## getActiveCall:

```objective_c
[self getActiveCall:^(NSDictionary *call, NSError *error) {
// Code goes here
}];
```
```swift
client.getActiveCall { (call, error) in
// Code goes here
}
```
Get local active call

Parameter | Type |  Description
--------- | ----------- | ---------
completion | callback | A completion handler that takes either a call or an error and returns void


## getActiveRemoteCalls:

```objective_c
[self getActiveRemoteCalls:^(NSDictionary *calls, NSError *error) {
// Code goes here
}];
```
```swift
client.getActiveRemoteCalls { (call, error) in
// Code goes here
}
```

Get remote active calls
Required OAuth2 scopes: CALLS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
completion | callback | A completion handler that takes either a call or an error and returns void

## getCalls:

```objective_c
[self getCalls:^(NSArray *calls, NSError *error) {
// Code goes here
}];
```
```swift
client.getCalls { (call, error) in
// Code goes here
}
```

Get all local and remote calls in progress

Parameter | Type |  Description
--------- | ----------- | ---------
completion | callback | A completion handler that takes either a call or an error and returns void

## getTelephonyData:

```objective_c
[self getTelephonyData:^(NSDictionary *data, NSError *error) {
// Code goes here
}];
```
```swift
client.getTelephonyData { (call, error) in
// Code goes here
}
```

Get the telephony data such as the connection state and default caller id

Parameter | Type |  Description
--------- | ----------- | ---------
completion | callback | A completion handler that takes either a call or an error and returns void


## makeCall:mediaType:completionHandler:


```objective_c
NSDictionary *mediaType = @{@"audio": @"true", @"video": @"false"};
[self makeCall:@"user" mediaType:mediaType completionHandler:^(NSDictionary *call, NSError *error) {
// Code goes here
}];
```
```swift
let mediaType = ["audio": true, "video": false]
client.makeCall("user", mediaType: mediaType) { (call, ERROR) in
// Code goes here
}
```

Start a direct call with a user by it's email address or user Id

Parameter | Type |  Description
--------- | ----------- | ---------
user | string | email or userId of the user to call
mediaType | dictionary | Object with boolean attributes: audio, video
completion | callback | A completion handler that takes either a call or an error and returns void


## makeCall:mediaType:createIfNotExist:completionHandler:


```objective_c
NSDictionary *mediaType = @{@"audio": @"true", @"video": @"false"};
[self makeCall:@"user" mediaType:mediaType createIfNotExists:YES completionHandler:^(NSDictionary *call, NSError *error) {
// Code goes here
}];
```
```swift
let mediaType = ["audio": true, "video": false]
client.makeCall("user", mediaType: mediaType, createIfNotExists: true) { (call, error) in
// Code goes here
}
```

Start a direct call with a user by it's email address or user Id

Parameter | Type |  Description
--------- | ----------- | ---------
user | string | email or userId of the user to call
mediaType | dictionary | Object with boolean attributes: audio, video
createIfNotExists | bool | Create a conversation with the user if not already existing, default is FALSE.
completion | callback | A completion handler that takes either a call or an error and returns void

## mute:completionHandler:

```objective_c
[self mute:@"callId" completionHandler:^{
// Code goes here
}];
```
```swift
client.mute("callId") {
// Code goes here
}
```

Mute an existing call

Parameter | Type |  Description
--------- | ----------- | ---------
calIId | string | callId callId of the call to mute
completion | callback | A completion handler that takes either a call or an error and returns void

## startConference:mediaType:completion:

```objective_c
NSDictionary *mediaType = @{@"audio": @"true", @"video": @"false"};
[self startConference:@"convId" mediaType:mediaType completion:^(NSDictionary *call, NSError *error) {
// Code goes here
}];
```
```swift
let mediaType = ["audio": true, "video": false]
client.startConference("callId", mediaType: mediaType) { (call, error) in
// Code goes here
}
```

StartConference a conference call
Required OAuth2 scopes: CALLS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
convId | string | Conversation ID
mediaType | dictionary | Object with boolean attributes: audio, video
completion | callback | A completion handler that takes either a call or an error and returns void

## joinConference:mediaType:clientId:completion:

```objective_c
NSDictionary *mediaType = @{@"audio": @"true", @"video": @"false"};
[self joinConference:@"calIId" mediaType:mediaType clientId:@"clientId" completion:^{
// Code goes here
}];
```
```swift
let mediaType = ["audio": true, "video": false]
client.joinConference("callId", mediaType: mediaType, clientId:"clientId") {
// Code goes here
}
```

Join a conference call from the current device, or optionally from another logged on device.

Required OAuth2 scopes: CALLS or ALL

Parameter | Type |  Description
--------- | ----------- | ---------
calIId | string | callId callId of the call to mute
mediaType | dictionary | Object with boolean attributes: audio, video
clientId | string | clientId of device where to join the call from
completion | callback | A completion handler that takes either a call or an error and returns void

## unmute:completionHandler

```objective_c
[self unmute:@"convId" completionHandler:^{
// Code goes here
}];
```
```swift
client.unmute("callId") {
// Code goes here
}
```

Unmute an existing call

Parameter | Type |  Description
--------- | ----------- | ---------
convId | string | Conversation ID
completion | callback | A completion handler that takes no arguments and returns void

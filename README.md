[![Build Status](https://travis-ci.org/circuit/circuit-ios-sdk.svg?branch=master)](https://travis-ci.org/circuit/circuit-ios-sdk)
[![GitHub release](https://img.shields.io/badge/JSSDK-v1.2.3704-blue.svg)](https://github.com/circuit/circuit-sdk/releases/tag/1.2.3704)
[![Version](https://img.shields.io/cocoapods/v/CircuitSDK.svg?style=flat)](http://cocoapods.org/pods/CircuitSDK)
[![License](https://img.shields.io/cocoapods/l/CircuitSDK.svg?style=flat)](http://cocoapods.org/pods/CircuitSDK)
[![Platform](https://img.shields.io/cocoapods/p/CircuitSDK.svg?style=flat)](http://cocoapods.org/pods/CircuitSDK)

# Circuit iOS SDK

## Introduction
Welcome to the Circuit iOS SDK. You can use the provided SDK to build a text or media mobile application for iOS.

## Prerequisites
* Developer account on circuitsandbox.net. Get it for free at [developer registration](https://circuit.github.io/).
* OAuth 2.0 `client_id` and optionally `client_secret`. Get if for free at [circuit.github.com/oauth](https://circuit.github.com/oauth).

## Installation
Get the WebRTC dependency (Source/libCKTNavigator.a) via:

```shell
curl -X GET -o "Source/libCKTNavigator.a" "https://www.googleapis.com/storage/v1/b/circuit-ios-sdk/o/libCKTNavigator.a?alt=media"
```

CircuitSDK is available through [CocoaPods](http://cocoapods.org).



You can easily try our sample app by running the following command in your terminal window:

```shell
pod try CircuitSDK
```

To use it simply add the following line to your Podfile:

```ruby
pod 'CircuitSDK'
```
## Example
You can find the sample application in the [iOS Sample App](https://github.com/circuit/circuit-ios-sdk/tree/master/Example) directory. If you try to run the application, you won’t be able to logon. You must add your client id and client secret and install pods. In the terminal navigate to the CircuitKit folder and run the following command:

```ruby
pod install
```

This will install the pods and create a CircuitKit.xcworkspace, open that file instaead of the CircuitKit.xcodeproj. In the Sample/Resources folder open AppDelegate.swift, here you can add your client id and client secret. Press the run button

## Authorization
If you do not have any client credentials first  sign up for a developer account [here](https://www.circuit.com/web/developers/registration)

Once your account is approved navigate to [Circuit App Registration](https://circuit.github.io/oauth.html) and follow the instructions to obtain the credentials

Once you receive them you are ready to run the sample application and create your own.

## Here are some snippets to get you started.

### initializeSDK
It's a good idea to initialize the SDK when the application launches,
this can be done in the AppDelegate file.

Application scope should be a comma delimited string that can contain any of
the following

| SCOPE               |
|---------------------|
| ALL                 |
| READ_USER_PROFILE   |
| WRITE_USER_PROFILE  |
| READ_CONVERSATIONS  |
| WRITE_CONVERSATIONS |
| READ_USER           |
| CALLS               |

We use a framework called AppAuth to help with OAuth 2.0 authentication.

AppAuth takes your client id and client secret and returns to you an access token,
you can the use this access token to logon.

See [AppAuth-iOS](https://github.com/openid/AppAuth-iOS) for examples using AppAuth

Remember to set your redirectURI you created when registering your application,
this redirectURI tells AppAuth how to get back to your application after
authentication has completed.

```objectivec
[client initializeSDK:@"ADD CLIENT_ID"
                    oAuthClientSecret:@"ADD CLIENT SECRET"
                    oAuthScope:@"ADD OAUTH SCOPE"];
```

```swift
CKTClient().initializeSDK("ADD CLIENT ID",
                            oAuthClientSecret:"ADD CLIENT SECRET",
                            oAuthScope:"ADD OAUTH SCOPE")
```

### Event Handling
Event handling is already setup in the SDK. All you have to do to provide
event handling to your application is add some observers where you want to listen
to specific events.

Event | Type |  Description
--------- | ----------- | ---------
CKTNotificationBasicSearchResults | string | Asynchronous search results for startUserSearch or startBasicSearch
CKTNotificationCallEnded | string | Fired when a call is terminated.
CKTNotificationCallIncoming | string | Fired when an incoming call is received.
CKTNotificationCallStatus | string | Fired when the call state, or any other call attribute of a local or remote call changes.
CKTNotificationConnectionStateChanged | string | Fired when the connection state changes.
CKTNotificationConversationCreated | string | Fired when a new conversation is created for this user. This can be a brand new conversation, or being added to a conversation.
CKTNotificationConversationUpdated | string | Fired when an existing conversation is updated.
CKTNotificationItemAdded | string | Fired when a new conversation item is received. Note that the sender of an item will also receive this event.
CKTNotificationItemUpdated | string | Fired when an existing conversation item is updated.
CKTNotificationReconnectFailed | string | Fired when automatic reconnecting to the server fails.
CKTNotificationRenewToken | string | Fired when token has been renewed after session expiry. Error included on failure.
CKTNotificationSessionExpires | string | Fired when session expires.
CKTNotificationUserPresenceChanged | string | Fired when the presence of a subscribed user changes.
CKTNotificationUserSettingsChanged | string | Fired when one or more user settings for the logged on user change.
CKTNotificationUserUpdated | string | Fired when the local user is updated.

### Adding Observers

```objective_c
[[NSNotificationCenter defaultCenter] addObserver:self
                                        selector:@selector(itemAddedToConversation)
                                        name:CKTNotificationItemAdded object:nil];
```

```swift
NSNotificationCenter.defaultCenter().addObserver(self,
                            selector:#selector(itemAddedToConversation),
                            name:CKTNotificationItemAdded, object: nil)

```

To listen for events you need to add observers to your application logic. You
do this using Apple's Notification Center if you have never used NSNotificationCenter
you can find more information on it [here](https://developer.apple.com/reference/foundation/nsnotificationcenter)

In the example we are watching for an event called CKTNotificationItemAdded which when triggered
will fire a method called itemAddedToConversation



## Terms of Use
By downloading and running this project, you agree to the license terms of the third party application software, Unify products, and components to be installed.

The third party software and products are provided to you by third parties. You are responsible for reading and accepting the relevant license terms for all software that will be installed. Unify grants you no rights to third party software.


## License
Unless otherwise mentioned, the samples are released under the Apache license.

```
Copyright 2017 Unify Software and Solutions GmbH & Co.KG.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

## Help us improve the SDK
Help us improve out samples by sending us a pull-request or opening a [GitHub Issue](https://github.com/circuit/circuit-ios-sdk/issues/new).


Copyright (c) Unify, Inc. All rights reserved.  Licensed under the Apache license. See LICENSE file in the project root for full license information.

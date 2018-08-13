# Change Log

## [1.4.0](https://github.com/circuit/circuit-ios-sdk/releases/tag/1.4.0)
### Added
* New API:
`getItemsById:completionHandler:`
`updateConversation:attributesToChange:completion:`
### Updated
* Documentation with the description of newly added API;

## [1.3.0](https://github.com/circuit/circuit-ios-sdk/releases/tag/1.3.0)
### Added
* Direct calls and Conference support into SampleApp;
* New API:
`getConversationById:completionHandler:`
`getUsersById:limited:completion:`
`leaveConference:completion:`
`setAudioSessionEnabled:`
### Updated
* Documentation with the description of newly added API;
### Fixed:
* Issue with notifications;
* Issue with the speech path;
* Wrong completion handler for:
`endConference:completion:`
`endCall:completion:`
`startConference:mediaType:completion:`

# [1.3.0.beta1](https://github.com/circuit/circuit-ios-sdk/releases/tag/1.3.0-beta.1)
### Added
* New API layer `CKTNavigator+Call` with related changes in CoreSDK.
* New Notifications:
`CKTNotificationCallEnded`
`CKTNotificationCallIncoming`
`CKTNotificationCallStatus`
* Static library `libCKTNavigator.a` with related header files.
### Updated
* Documentation with the description of newly added API;
### Known issues
* Not all notifications work as expected;
* There is no speech path;

## [1.2.0](https://github.com/circuit/circuit-ios-sdk/releases/tag/1.2.0)
* Added new API for [Resource Owner Password Credentials Grant](https://circuit.github.io/oauth.html#resource_owner) type supporting.
* JSSDK version updated to [1.2.2902](https://github.com/circuit/circuit-sdk/releases/tag/1.2.2902)

## [1.1.0](https://github.com/circuit/circuit-ios-sdk/releases/tag/1.1.0)
*  JSSDK version updated to [1.2.2701](https://github.com/circuit/circuit-sdk/releases/tag/1.2.2701)

## [1.0.1](https://github.com/circuit/circuit-ios-sdk/releases/tag/1.0.1)
* nokogiri is updated from 1.5.6 to 1.8.1
* removed duplicated description from Documentation

## [1.0.0](https://github.com/circuit/circuit-ios-sdk/releases/tag/1.0.0)
*  Added SampleApp
*  Added Documentation
*  JSSDK version updated to [1.2.2200](https://github.com/circuit/circuit-sdk/releases/tag/1.2.2200)

## [0.1.0](https://github.com/circuit/circuit-ios-sdk/releases/tag/0.1.0)

* Initial 0.1.0 Release

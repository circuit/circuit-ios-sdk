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
//  JSNotificationCenter.h
//  CircuitSDK
//
//

#import <Foundation/Foundation.h>

extern NSString *const CKTNotificationApplicationServiceLoaded;
extern NSString *const CKTNotificationBasicSearchResults;
extern NSString *const CKTNotificationCallEnded;
extern NSString *const CKTNotificationCallIncoming;
extern NSString *const CKTNotificationCallStatus;
extern NSString *const CKTNotificationConnectionStateChange;
extern NSString *const CKTNotificationConversationCreated;
extern NSString *const CKTNotificationConversationUpdated;
extern NSString *const CKTNotificationItemAdded;
extern NSString *const CKTNotificationItemUpdated;
extern NSString *const CKTNotificationReconnectFailed;
extern NSString *const CKTNotificationRenewToken;
extern NSString *const CKTNotificationSessionExpires;
extern NSString *const CKTNotificationUserPresenceChanged;
extern NSString *const CKTNotificationUserSettingsChanged;
extern NSString *const CKTNotificationUserUpdated;

// Notificaiton to WebRTC to mute / unmute the speaker
extern NSString *const NOTIFICATION_AUDIO_SESSION_MUTE_SPEAKER;
// Notificaiton from WebRTC that Video receive has been lost
extern NSString *const NOTIFICATION_VIDEO_RECEIVE_STREAM_LOST;
// WebRTC failed to setup AVAudioSession during call
extern NSString *const NOTIFICATION_AUDIO_SESSION_SETUP_FAILED;
extern NSString *const NOTIFICATION_AUDIO_SESSION_CHANGE_CATEGORY_REQUESTED;

extern NSString *const CKTKeyEmpty;
extern NSString *const KEY_EVENT_DATA;
extern NSString *const KEY_AUDIO_ACTIVATE;

@interface JSNotificationCenter : NSObject

+ (void)sendNotificationName:(NSString *)notificationName
                      object:(id)notificationSender
                    userInfo:(NSDictionary *)userInfo;

@end

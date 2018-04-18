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
//  JSNotificationCenter.m
//  CircuitSDK
//
//

#import "JSNotificationCenter.h"
#import "Log.h"

NSString *const CKTNotificationApplicationServiceLoaded = @"applicationServiceLoaded";
NSString *const CKTNotificationBasicSearchResults = @"basicSearchResults";
NSString *const CKTNotificationCallEnded = @"callEnded";
NSString *const CKTNotificationCallIncoming = @"callIncoming";
NSString *const CKTNotificationCallStatus = @"callStatus";
NSString *const CKTNotificationConnectionStateChange = @"connectionStateChanged";
NSString *const CKTNotificationConversationCreated = @"conversationCreated";
NSString *const CKTNotificationConversationUpdated = @"conversationUpdated";
NSString *const CKTNotificationItemAdded = @"itemAdded";
NSString *const CKTNotificationItemUpdated = @"itemUpdated";
NSString *const CKTNotificationReconnectFailed = @"reconnectFailed";
NSString *const CKTNotificationRenewToken = @"renewToken";
NSString *const CKTNotificationSessionExpires = @"sessionExpires";
NSString *const CKTNotificationUserPresenceChanged = @"userPresenceChanged";
NSString *const CKTNotificationUserSettingsChanged = @"userSettingsChanged";
NSString *const CKTNotificationUserUpdated = @"userUpdated";
// Notificaiton to WebRTC to mute / unmute the speaker
NSString *const NOTIFICATION_AUDIO_SESSION_MUTE_SPEAKER = @"circuitkit.notification.AUDIO_SESSION_MUTE_SPEAKER";
// Notificaiton from WebRTC that Video receive has been lost
NSString *const NOTIFICATION_VIDEO_RECEIVE_STREAM_LOST =
    @"circuitkit.notification.VIDEO_RECEIVE_STREAM_LOST";
// WebRTC failed to setup AVAudioSession during call
NSString *const NOTIFICATION_AUDIO_SESSION_SETUP_FAILED = @"circuitkit.notification.AUDIO_SESSION_SETUP_FAILED";
NSString *const NOTIFICATION_AUDIO_SESSION_CHANGE_CATEGORY_REQUESTED =
@"circuitkit.notification.NOTIFICATION_AUDIO_SESSION_CHANGE_CATEGORY_REQUESTED";

NSString *const CKTKeyEmpty = @"circuitkit.key.EMPTY";

// KEY_EVENT_DATA is used in the WebRTC library libWebRTC.a, we must use that same naming convention
NSString *const KEY_EVENT_DATA = @"circuitkit.key.DATA";
NSString *const KEY_AUDIO_ACTIVATE = @"circuitkit.key.AUDIO_ACTIVATE";


static NSString *LOG_TAG = @"[JSNotificationCenter]";

@implementation JSNotificationCenter

+ (void)sendNotificationName:(NSString *)notificationName
                      object:(id)notificationSender
                    userInfo:(NSDictionary *)userInfo
{
    LOGI(LOG_TAG, @"Sending notification %@", notificationName);
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                        object:notificationSender
                                                      userInfo:userInfo];
}

@end

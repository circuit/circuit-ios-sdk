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
//  ANSAudioSession.h
//  CKTNavigator
//
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface ANSAudioSession : NSObject

+ (instancetype)sharedInstance;

/**
 Get current Audio Session Category as AVAudioSessionCategory

 */
+ (NSString *)sessionCategory;

/**
 Get the current audio route
 */
+ (AVAudioSessionRouteDescription *)currentRoute;

/**
 Change the AudioSession catyegory to the specified one
 If the current category is different than the specififed category and WebRTC isn't still actively
 using audio session, the new category will be set to audio session.

 - Parameter category: new audio session category to be set
 */
+ (void)setAudioSessionCategory:(NSString *)category;

/**
 Change audio session category to default value, which is 'AVAudioSessionCategoryAmbient'
 */
+ (void)setAudioSessionCategoryToDefault;

/**
 activate/deactivate the audio session, if the audio session is not under by WebRTC.

 - Parameter activate: YES - activate the audio session
                       NO - deactivate the audio session
 */
+ (void)activateAudioSession:(BOOL)activate;

/**
 Change audio route to speaker

 - Returns: returns YES, if the it was able to override the audio output port to Speaker
 */
+ (BOOL)setAudioOnSpeaker;

/**
 Change audio route to earpeice

 - Returns: returns YES, if the it was able to override the audio output port to earpeice
 */
+ (BOOL)setAudioOnEarpiece;

/**
 Application can disable / enable the active WebRTC audio session. It is a system wide parameter.
 If application disabled WebRTC audio then it is the application's responsibility to enable back it again.
 Until this is enabled by application again, all the calls will have no speech path

 It is recommended that application shall use this property only upon events that indicate external
 usage of audio session e.g., cell call indication, CallKit.

 - Parameter enable: YES - WebRTC's active audio session will be enabled.
                      NO  - WebRTC's active audio session will be disabled.
 */
+ (void)setWebRTCAudioSessionEnabled:(BOOL)enable;

/**
 Check if the current audio session category matches with the given category

 - Returns: YES, if the given category matches with the current audio session category
 */
+ (BOOL)isAudioSessionCategory:(NSString *)category;

/**
 Check if the current audio session output port type matches with the given output port type

 - Returns: YES, if the given output port type matches with the current audio session output port type
 */
+ (BOOL)isAudioSessionOutputPort:(NSString *)portType;

/**
 Check if the given audio session route output port type matches with the given output port type

 - Returns: YES, if the given output port type matches with the given audio session route output port type
 */
+ (BOOL)isAudioSessionOutputPort:(NSString *)portType forRoute:(AVAudioSessionRouteDescription *)route;

/**
 Current audio session record permission is returned

 - Returns: Current audio session record permission
 */
+ (AVAudioSessionRecordPermission)recordPermission;

@end

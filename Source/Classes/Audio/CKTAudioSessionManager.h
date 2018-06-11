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
//  CKTAudioSessionManager.h
//  CircuitSDK
//
//

#import <Foundation/Foundation.h>

@interface CKTAudioSessionManager : NSObject

/**

 @brief Disable / Enable the active WebRTC audio session

 @discussion Application can disable / enable the active WebRTC audio session. It is a system wide parameter.
 If application disabled WebRTC audio then it is the application's responsibility to enable back it again.
 Until this is enabled by application again, all the calls will have no speech path

 It is recommended that application shall use this property only upon events that indicate external
 usage of audio session.

 @param enabled YES - WebRTC's active audio session will be enabled.
                 NO  - WebRTC's active audio session will be disabled.

 */
+ (void)setAudioSessionEnabled:(BOOL)enabled;

@end

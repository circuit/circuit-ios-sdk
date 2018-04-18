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
//  ANSMediaStreamUtils.h
//  CKTNavigator
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class ANEAGLVideoView;
@class RTCMediaStream;
@class RTCVideoTrack;

@interface ANSMediaStreamUtils : NSObject

/**
 Creates a RTC Media Stream and adds Audio and Video tracks based on the requested options

 - Returns: RTCMediaStream object, if it is created successfully
            nil, if any failure during stream creation, adding local audio track/video track.
 */
+ (RTCMediaStream *)createLocalMediaStreamWithOptions:(id)options;

/**
 Convert the string pointer to a RTC Video track object.
 */
+ (RTCVideoTrack *)getVideoTrackFromString:(NSString *)videoTrackString;

/**
 Toggle between front and rear camera used in a EAGL Video view.
 */
+ (void)switchVideoCamera:(ANEAGLVideoView *)videoView;

/**
 Get the current video capture device used by a video track.
 */
+ (AVCaptureDevice *)getCaptureDeviceFromVideoTrackId:(NSString *)localVideoTrackId;

@end

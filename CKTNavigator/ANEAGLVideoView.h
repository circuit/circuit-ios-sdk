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
//  ANEAGLVideoView.h
//  CKTNavigator
//
//

#import <UIKit/UIKit.h>
#import <WebRTC/RTCEAGLVideoView.h>

@class ANEAGLVideoView;
@class RTCVideoTrack;

@interface ANEAGLVideoView : RTCEAGLVideoView
@property (nonatomic, assign) CGSize streamSize;

- (void)setRendererFrame:(CGRect)frame;
- (void)setVideoTrackByString:(NSString *)videoTrackID;
- (RTCVideoTrack *)getRTCVideoTrack;
- (AVCaptureSession *)getAVCaptureSession;
- (BOOL)usingRearCamera;

@end

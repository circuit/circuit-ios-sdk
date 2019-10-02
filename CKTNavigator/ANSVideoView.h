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
//  ANSVideoView.h
//  CKTNavigator
//
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@class ANSVideoView;

@protocol ANSVideoViewDelegate<NSObject>

- (void)setVideoFrame:(ANSVideoView *)videoView;

@end

@class RTCVideoTrack;

typedef void (^CompletionBlockWithImage)(UIImage *image);

@interface ANSVideoView : NSObject

@property (nonatomic, weak) id<ANSVideoViewDelegate> delegate;

@property (nonatomic, readonly) UIView *view;
@property (nonatomic, assign) CGSize streamSize;
@property (nonatomic) BOOL usingLocalVideoSource;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

- (void)setRendererFrame:(CGRect)frame;
- (void)stopVideoRenderer;
- (void)setVideoTrackByString:(NSString *)videoTrackID;
- (RTCVideoTrack *)getRTCVideoTrack;

- (AVCaptureSession *)getAVCaptureSession;

// Capture the current snapshot of video stream as UIImage
// NOTE: The call back will run on main thread
- (void)getVideoStreamSnapshot:(CompletionBlockWithImage)completion;

@end

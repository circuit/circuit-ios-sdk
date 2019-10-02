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
//  ANSVideoSource.h
//  CKTNavigator
//
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

#import <WebRTC/RTCVideoSource.h>

@class RTCVideoCapturer;

@interface ANSVideoSource : RTCVideoSource

@property (nonatomic, strong) RTCVideoCapturer *capturer;

@property (nonatomic) BOOL useBackCamera;

@property (nonatomic) NSDictionary *mediaConstraints;

+ (AVCaptureDeviceFormat *)getCaptureWithMediaConstraints:(NSDictionary *)mediaConstriants
                                                 position:(AVCaptureDevicePosition)position;

- (void)updateCaptureFormat:(AVCaptureDevicePosition)position captureFormat:(AVCaptureDeviceFormat *)format;

- (BOOL)isCaptureFormatAvailable:(AVCaptureDevicePosition)position;

- (void)startCapture:(NSDictionary *)mediaConstraints;

- (void)stopCapture;

@end

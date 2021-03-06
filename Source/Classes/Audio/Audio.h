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
//  Audio.h
//  CircuitSDK
//
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class Audio;

@protocol AudioExport<JSExport>

+ (Audio *)createAudio:(NSString *)soundFile;
- (void)play;
- (void)pause;
+ (NSString *)getPlaybackDevice;
+ (NSString *)getRecordingDevice;
+ (NSString *)getVideoDevice;

@property (nonatomic) BOOL loop;
@property (nonatomic) BOOL vibrate;
@property (nonatomic, copy) NSString *playMode;

@end

@interface Audio : NSObject<AudioExport>

@end

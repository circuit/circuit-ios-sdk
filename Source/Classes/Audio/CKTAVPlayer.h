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
//  CKTAVPlayer.h
//  CircuitSDK
//
//

#import <AVFoundation/AVFAudio.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, CKTPlayingType) {
    CKTPlayingType_Default,
    CKTPlayingType_Ambient,
    CKTPlayingType_SoloAmbient,
    CKTPlayingType_PlayAndRecord,
    CKTPlayingType_Playback
};

@interface CKTAVPlayer : AVPlayer

@property (nonatomic, nullable) AVAudioPlayer *audioPlayer;
@property (nonatomic) CKTPlayingType type;
@property (nonatomic, nonnull) NSString *defaultCategory;
@property (nonatomic, nullable) NSString *previouslyCategory;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic) NSInteger numberOfLoops;

- (instancetype _Nonnull)init;
- (instancetype _Nullable)initWithAVPlayerItem:(nullable AVPlayerItem *)playerItem;
- (instancetype _Nullable)initWithAudioPlayerUrl:(nullable NSURL *)url;
- (void)requestCategoryChangeIfNeeded;
- (void)overrideOutputAudioPortIfNeeded;
- (void)play;
- (void)pause;
- (void)stop;

@end

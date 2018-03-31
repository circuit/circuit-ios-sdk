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
//  Audio.m
//  CircuitSDK
//
//

#import <AVFoundation/AVFoundation.h>
#import "Audio.h"
#ifdef CIRCUIT_IOS_REALTIME
#import "ANSAudioSession.h"
#import "ANSMediaStreamUtils.h"
#endif
#import "AVAudioSession+an.h"
#import "CKTAVPlayer.h"
#import "CKTLog.h"
#import "JSEngine.h"
#import "Vibrator.h"

@interface Audio ()<AVAudioPlayerDelegate>

@property (nonatomic) CKTAVPlayer *audioPlayer;
@property (nonatomic) NSString *soundFile;
@property (nonatomic) Vibrator *vibrator;

@end

@implementation Audio

@synthesize loop;
@synthesize vibrate;
@synthesize playMode;

// activePlayers and audioSessionProcessQueue are kept in static vars since Audio instance is created for every sound
// notification and promptly deallocated; we must keep track on audio players.
static NSMutableArray *activePlayers;
static dispatch_queue_t audioSessionProcessQueue;
static NSString *LOG_TAG = @"[Audio]";
static NSString *const kSoundFileRegEx = @".*/(.*)\\.ogg";
static NSString *const kIncomingSoundPattern = @"-incoming-call";
static NSString *const kAudioPlayModeSoloAmbient = @"soloAmbient";
static NSString *const kAudioPlayModePlayAndRecord = @"playAndRecord";
static NSString *const kAudioPlayModeAmbient = @"ambient";

+ (void)initialize
{
    if (self == [Audio class]) {
        activePlayers = [NSMutableArray array];

        // This queue is used for synchronising 'audio session manipulations' and not blocking the calling thread.
        audioSessionProcessQueue = dispatch_queue_create("com.unify.audio.processing", DISPATCH_QUEUE_SERIAL);
    }
}

+ (Audio *)createAudio:(NSString *)soundFile
{
    Audio *audioObj = [[Audio alloc] initWithSoundFile:soundFile];
    return audioObj;
}

- (Audio *)initWithSoundFile:(NSString *)soundFile
{
    if (self = [super init]) {
        LOGD(LOG_TAG, @"Init Audio soundFile = %@", soundFile);

        // The JavaScript code provides a fully-qualified filename for the sound including the directory
        // name and the "ogg" filename extension. Since iOS will use the "caf" format and doesn't need
        // the directory information, the filename is extracted and the "caf" extension is added later.
        NSRegularExpression *regex =
            [NSRegularExpression regularExpressionWithPattern:kSoundFileRegEx options:0 error:nil];
        NSAssert(regex, @"Error creating regular expression to parse sound file");
        NSArray *matches = [regex matchesInString:soundFile options:0 range:NSMakeRange(0, [soundFile length])];
        if ([matches count] > 0) {
            NSRange matchRange = [matches[0] rangeAtIndex:1];
            NSString *matchText = [soundFile substringWithRange:matchRange];
            self.soundFile = matchText;
            LOGD(LOG_TAG, @"Parsed sound file name = %@", matchText);
        } else {
            LOGE(LOG_TAG, @"Error parsing sound file - filename = %@", soundFile);
        }
    }
    return self;
}

- (void)play
{
    if (!self.soundFile) {
        LOGE(LOG_TAG, @"No sound file to play");
        return;
    }

    if ([self.soundFile rangeOfString:kIncomingSoundPattern].location != NSNotFound) {
        // Native iOS dialer plays the ring tone and/or vibrator
        LOGD(LOG_TAG, @"Skipping Incoming call sound with CallKit");
        return;
    }

    LOGD(LOG_TAG, @"Play sound: %@", self.soundFile);
    NSError *avPlayerError = nil;
    self.audioPlayer = [[CKTAVPlayer alloc]
        initWithAudioPlayerUrl:[[NSBundle mainBundle] URLForResource:self.soundFile withExtension:@"caf"]];

    if (avPlayerError) {
        LOGE(LOG_TAG, @"Error creating audio player: %@", [avPlayerError description]);
        return;
    }

    [self addPlayer:self.audioPlayer];

    if (self.loop) {
        self.audioPlayer.numberOfLoops = -1;  // play until stopped
    }

    if (self.vibrate) {
        // We only vibrate on incoming call events. Duration of vibration is controlled by
        // audio player.
        self.vibrator = [[Vibrator alloc] init];
        [self.vibrator vibrate];
    }

    if ([self.playMode isEqualToString:kAudioPlayModeSoloAmbient]) {
        self.audioPlayer.type = CKTPlayingType_SoloAmbient;
    } else if ([self.playMode isEqualToString:kAudioPlayModePlayAndRecord]) {
        self.audioPlayer.type = CKTPlayingType_PlayAndRecord;
    } else {
        self.audioPlayer.type = CKTPlayingType_SoloAmbient;
    }

    __weak typeof(self) weakSelf = self;
    dispatch_async(audioSessionProcessQueue, ^{
        [weakSelf.audioPlayer play];
        if (!weakSelf.audioPlayer.isPlaying) {
            LOGE(LOG_TAG, @"Error playing audio player");
            [weakSelf removeAudioPlayer];
        }
    });
}

- (void)pause
{
    LOGD(LOG_TAG, @"Pause playing sound");
    [self.audioPlayer stop];
    [self removeAudioPlayer];

    [self removeVibrator];
}

- (void)removeAudioPlayer
{
    [self removePlayer:self.audioPlayer];
    self.audioPlayer = nil;
}

- (void)removeVibrator
{
    [self.vibrator cancel];
    self.vibrator = nil;
}

- (void)dealloc
{
    [self pause];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self removeAudioPlayer];
    [self removeVibrator];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *__nullable)error
{
    LOGE(LOG_TAG, @"Decode error occured %@", error.description);
    [self removeAudioPlayer];
    [self removeVibrator];
}

#pragma mark - NSNotification

- (void)willEnterForeground:(NSNotification *)notification
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(audioSessionProcessQueue, ^{
        // As AVAudioSessionCategorySoloAmbient category is used we should resume audio playing after background mode
        LOGD(LOG_TAG, @"Resume playing audio player after background");
        [weakSelf.audioPlayer play];
    });
}

- (void)onAudioSessionInterruption:(NSNotification *)notification
{
    AVAudioSessionInterruptionType interruptionType =
        [notification.userInfo[AVAudioSessionInterruptionTypeKey] integerValue];
    NSNumber *interruptionOption = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    switch (interruptionType) {
        case AVAudioSessionInterruptionTypeBegan: {
            // Audio has stopped, already inactive
        } break;
        case AVAudioSessionInterruptionTypeEnded: {
            __weak typeof(self) weakSelf = self;
            dispatch_async(audioSessionProcessQueue, ^{
                if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume) {
                    // Continue playback
                    [weakSelf.audioPlayer play];
                } else {
                    // Just remove player
                    [weakSelf removeAudioPlayer];
                }
            });
        } break;
        default:
            break;
    }
}

#pragma mark - Device reporting

+ (NSString *)getPlaybackDevice
{
    return [[AVAudioSession sharedInstance] outputDeviceDescription];
}

+ (NSString *)getRecordingDevice
{
    return [[AVAudioSession sharedInstance] inputDeviceDescription];
}

+ (NSString *)getVideoDevice
{
    NSString *cameraID = @"";
    AVAuthorizationStatus videoCameraAccessStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((videoCameraAccessStatus == AVAuthorizationStatusRestricted ||
         videoCameraAccessStatus == AVAuthorizationStatusDenied)) {
        // No need to check further, returning
        return cameraID;
    }
    return cameraID;
}

#pragma mark - Private methods

+ (void)deactivateAudioSession
{
// The default audio category for Circuit application is AVAudioSessionCategorySoloAmbient. We have to reset it and
// be sure that session is not in use by WebRTC.
#ifdef CIRCUIT_IOS_REALTIME
    if (activePlayers.count == 0 && ![ANSAudioSession isAudioSessionCategory:AVAudioSessionCategoryPlayAndRecord]) {
        [ANSAudioSession activateAudioSession:NO];
        [ANSAudioSession setAudioSessionCategoryToDefault];
    }
#endif
}

- (void)addPlayer:(CKTAVPlayer *)player
{
    if (player) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onAudioSessionInterruption:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:nil];
        dispatch_async(audioSessionProcessQueue, ^{ [activePlayers addObject:player]; });
    }
}

- (void)removePlayer:(CKTAVPlayer *)player
{
    if (player) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        dispatch_async(audioSessionProcessQueue, ^{
            [activePlayers removeObject:player];

            if (activePlayers.count == 0) {
                // Deactivate audio session if there are no any active players at least for 1 sec.
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), audioSessionProcessQueue,
                               ^{ [Audio deactivateAudioSession]; });
            }
        });
    }
}

@end

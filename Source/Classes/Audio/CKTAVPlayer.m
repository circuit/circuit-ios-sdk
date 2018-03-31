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
//  CKTAVPlayer.m
//  CircuitSDK
//
//

#import "CKTAVPlayer.h"
#import "CKTLog.h"
#import "JSNotificationCenter.h"

@implementation CKTAVPlayer

static NSString *LOG_TAG = @"[JSRunLoop]";

- (BOOL)isPlaying
{
    return self.audioPlayer;
}

- (NSInteger)numberOfLoops
{
    return self.audioPlayer ? self.audioPlayer.numberOfLoops : -2;
}

- (void)setNumberOfLoops:(NSInteger)newNumberOfLoops
{
    if (self.audioPlayer) {
        self.audioPlayer.numberOfLoops = newNumberOfLoops;
    }
}

- (instancetype)init
{
    if (self = [super init]) {
        LOGI(LOG_TAG, @"Player init ...");
        // Initialize self
        self.type = CKTPlayingType_Default;
    }
    return self;
}

- (instancetype)initWithAVPlayerItem:(AVPlayerItem *)item
{
    if (item) {
        LOGI(LOG_TAG, @"Player initWithAVPlayerItem ...");

        self = [super initWithPlayerItem:item];
    } else {
        self = [super init];
    }
    return self;
}

- (instancetype)initWithAudioPlayerUrl:(NSURL *)url
{
    if (url) {
        LOGI(LOG_TAG, @"Player initWithAudioPlayerUrl ...");

        self = [super initWithURL:url];
    } else {
        self = [super init];
    }
    return self;
}

- (void)play
{
    LOGD(LOG_TAG, @"Calling play");
    self.previouslyCategory = [[AVAudioSession sharedInstance] category];
    [self requestCategoryChangeIfNeeded];
    [self overrideOutputAudioPortIfNeeded];

    if (self.audioPlayer) {
        if (self.audioPlayer.url.absoluteString) {
            LOGD(LOG_TAG, @"Using audioPlayer to play,URL = %@ numberOfLoops = %@", self.audioPlayer.url,
                 self.audioPlayer.numberOfLoops);
        }
        [self.audioPlayer play];
    } else {
        LOGD(LOG_TAG, @"Using AVPlayer to play");
        [super play];
    }
}

- (void)pause
{
    [self requestCategoryChange:CKTPlayingType_Default isActivated:NO];
    if (self.audioPlayer) {
        if (self.audioPlayer.url.absoluteString) {
            LOGD(LOG_TAG, @"Pausing audioPlayer for URL %@", self.audioPlayer.url);
        }
        [self.audioPlayer pause];
    } else {
        [super pause];
    }
}

- (void)stop
{
    [self requestCategoryChange:CKTPlayingType_Default isActivated:NO];
    if (self.audioPlayer) {
        if (self.audioPlayer.url.absoluteString) {
            LOGD(LOG_TAG, @"Stopping audioPlayer for URL %@", self.audioPlayer.url);
        }
        [self.audioPlayer stop];
    } else {
        [super pause];
    }
}

- (void)requestCategoryChangeIfNeeded
{
    switch (self.type) {
        case CKTPlayingType_SoloAmbient:
            [self requestCategoryChange:CKTPlayingType_SoloAmbient isActivated:YES];
            break;
        case CKTPlayingType_PlayAndRecord:
            [self requestCategoryChange:CKTPlayingType_PlayAndRecord isActivated:YES];
            break;
        case CKTPlayingType_Playback:
            [self requestCategoryChange:CKTPlayingType_Playback isActivated:YES];
            break;
        case CKTPlayingType_Ambient:
            [self requestCategoryChange:CKTPlayingType_Ambient isActivated:YES];
            break;
        case CKTPlayingType_Default:
            [self requestCategoryChange:CKTPlayingType_Default isActivated:YES];
            break;
        default:
            break;
    }
}

- (void)overrideOutputAudioPortIfNeeded
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    // Error handling
    BOOL success;
    NSError *error;

    switch (self.type) {
        case CKTPlayingType_SoloAmbient:
            // Valid because category is changed to PlayAndRecord for incoming call
            success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
            break;
        case CKTPlayingType_PlayAndRecord:
        case CKTPlayingType_Playback:
        case CKTPlayingType_Default:
            success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
            break;
        case CKTPlayingType_Ambient:
            // Do not disturb the Audio Route of current call, while playing the notification type of tones
            success = YES;
            break;
        default:
            break;
    }

    if (!success) {
        LOGE(LOG_TAG, @"Could not overrideOutputAudioPort for - %d", self.type);
    }
}

- (void)requestCategoryChange:(CKTPlayingType)category isActivated:(BOOL)activate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // To avoid the possibility of the app crashing on the following log statement (ANS-44983) the url is no
        // longer included since it is logged in calls to this method and the use of 'self' was eliminated.
        LOGD(LOG_TAG, @"Requesting category change: Category = %d ,activate = %d", category, activate);
        NSDictionary *dict = @{ KEY_EVENT_DATA : @(category), KEY_AUDIO_ACTIVATE : [NSNumber numberWithBool:activate] };
        [JSNotificationCenter sendNotificationName:NOTIFICATION_AUDIO_SESSION_CHANGE_CATEGORY_REQUESTED
                                            object:nil
                                          userInfo:dict];
    });
}

@end

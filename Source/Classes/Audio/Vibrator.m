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
//  Vibrator.m
//  CircuitSDK
//
//

#import <AudioToolbox/AudioToolbox.h>
#import "CKTLog.h"
#import "Vibrator.h"

static const NSTimeInterval kANSVibrationInterval = 2.0;

@interface Vibrator ()
@property (nonatomic) NSTimer *timer;
@property (assign) NSUInteger numberOfVibrations;
@end

@implementation Vibrator

static NSString *LOG_TAG = @"[Vibrator]";

- (instancetype)init
{
    if (self = [super init]) {
        LOGI(LOG_TAG, @"Vibrator init ...");
        self.timer = nil;
        self.numberOfVibrations = 0;
    }
    return self;
}

- (void)vibrate
{
    if (self.timer == nil) {
        LOGI(LOG_TAG, @"vibrate...");
        [self run:nil];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kANSVibrationInterval
                                                      target:self
                                                    selector:@selector(run:)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (void)scheduledVibrationsWithTimeInterval:(NSUInteger)timeInterval numberOfVibrations:(NSUInteger)numberOfVibrations
{
    if (self.timer == nil) {
        LOGI(LOG_TAG, @"vibrate (%d) times", numberOfVibrations);

        self.numberOfVibrations = numberOfVibrations;
        if (numberOfVibrations == 0)
            return;

        if (numberOfVibrations > 1)
            self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                          target:self
                                                        selector:@selector(run:)
                                                        userInfo:@(numberOfVibrations)
                                                         repeats:YES];
        else
            self.timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                          target:self
                                                        selector:@selector(run:)
                                                        userInfo:nil
                                                         repeats:NO];
    }
}

- (void)cancel
{
    LOGI(LOG_TAG, @"cancel.");
    [self.timer invalidate];
    self.timer = nil;  // ensures we never invalidate an already invalid Timer
}

- (void)run:(id)anArgument
{
    // Check if this timer was created using scheduledVibrationsWithTimeInterval:numberOfVibrations:
    if (self.timer.userInfo != nil) {
        if (self.numberOfVibrations > 0) {
            self.numberOfVibrations--;
            LOGI(LOG_TAG, @"vibrate... number of vibrations left (%d)", self.numberOfVibrations);
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        } else {
            [self.timer invalidate];
            self.timer = nil;
            LOGI(LOG_TAG, @"timer stopped");
        }
    } else {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

@end

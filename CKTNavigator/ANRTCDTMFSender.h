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
//  ANRTCDTMFSender.h
//  CKTNavigator
//
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

// To supress the warning:
//   “used as the name of the previous parameter rather than as part of the selector”
// Comes from some lines like this one
//   - (void)success:(NSString *)message:(NSString *)title
// It can be suppressed by adding spaces, but our code formatter will remove those
// spaces and re-introduce the warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-selector-name"

@protocol ANRTCDTMFSenderExport<JSExport>

// Attributes
@property (nonatomic, readonly) JSValue* canInsertDTMF;

// Event handlers
@property (nonatomic, assign) JSValue* ontonechange;

// Methods

// Queues a task that sends the DTMF |tones|. The |tones| parameter is treated
// as a series of characters. The characters 0 through 9, A through D, #, and
// * generate the associated DTMF tones. The characters a to d are equivalent
// to A to D. The character ',' indicates a delay of 2 seconds before
// processing the next character in the tones parameter.
// Unrecognized characters are ignored.
// The |duration| parameter indicates the duration in ms to use for each
// character passed in the |tones| parameter.
// The duration cannot be more than 6000 or less than 70.
// The |inter_tone_gap| parameter indicates the gap between tones in ms.
// The |inter_tone_gap| must be at least 50 ms but should be as short as
// possible.
// If InsertDtmf is called on the same object while an existing task for this
// object to generate DTMF is still running, the previous task is canceled.

- (void)insertDTMF:(JSValue*)tones:(JSValue*)duration:(JSValue*)inter_tone_gap;

@end
#pragma clang diagnostic pop

@class ANRTCDTMFSender;

// Protocol for receving dtmf tone change event.
@protocol ANRTCDTMFSenderDelegate<NSObject>

- (void)dtmfSender:(ANRTCDTMFSender*)dtmfSender onToneChanged:(NSString*)tone;

@end

@interface ANRTCDTMFSender : NSObject<ANRTCDTMFSenderExport> {
    // Garbage collected references
    JSManagedValue* _ontonechangeCallback;
}

// Delegate
@property (nonatomic, weak) id<ANRTCDTMFSenderDelegate> delegate;

@property (nonatomic, strong) NSThread* myThread;

// Constructor
- (instancetype)initWithDTMFSender:(void*)dtmfSender;

@end

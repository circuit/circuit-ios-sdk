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
//  Window.m
//  CircuitSDK
//
//

#import "Window.h"
#import "JSEngine.h"

// To supress the warning:
//   “used as the name of the previous parameter rather than as part of the
//   selector”
// Comes from some lines like this one
//   - (void)success:(NSString *)message:(NSString *)title
// It can be suppressed by adding spaces, but our code formatter will remove
// those
// spaces and re-introduce the warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-selector-name"

#define TIMER_INFO_CALLBACK @"CALLBACK"
#define TIMER_INFO_REQUEST_ID @"REQUEST_ID"
#define TIMER_INFO_TIMER_ID @"TIMER_ID"
#define TIMER_DURATION @"DURATION"
#define TIMER_IS_INTERVAL @"IS_INTERVAL"

@interface Window ()

@property (nonatomic, strong) NSMutableDictionary *timerCache;
@property (nonatomic, assign) NSUInteger lastTimerId;

@end

@implementation Window

@synthesize location = _location;

+ (Window *)sharedInstance
{
    static Window *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Window alloc] init];

    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _location = [[Location alloc] init];
        self.lastTimerId = 0;
        self.timerCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    [self clearAllTimeouts];
}

#pragma mark - Public Methods

- (void)alert:(NSString *)message;
{
}

- (NSUInteger)setTimeout:(JSValue *)callback:(NSTimeInterval)duration:(NSString *)requestId
{
    return [self setTimeoutCommon:callback duration:duration requestId:requestId isInterval:NO];
}

- (void)clearTimeout:(NSUInteger)timeoutId
{
    NSString *timerId = [NSString stringWithFormat:@"%tu", timeoutId];

    NSTimer *timer = [self.timerCache valueForKey:timerId];
    if (timer) {
        JSManagedValue *timoutCallback = [timer.userInfo valueForKey:TIMER_INFO_CALLBACK];
        [[JSEngine sharedInstance] removeManagedReference:timoutCallback];
        [timer invalidate];
        [self.timerCache removeObjectForKey:timerId];
    } else {
    }
}

- (NSUInteger)setInterval:(JSValue *)callback:(NSTimeInterval)interval
{
    return [self setTimeoutCommon:callback duration:interval requestId:nil isInterval:YES];
}

- (void)clearInterval:(NSUInteger)timeoutId
{
    [self clearTimeout:timeoutId];
}

- (void)clearAllTimeouts
{
    for (NSTimer *timer in self.timerCache.allValues) {
        JSManagedValue *timoutCallback = [timer.userInfo valueForKey:TIMER_INFO_CALLBACK];
        [[JSEngine sharedInstance] removeManagedReference:timoutCallback];
        [timer invalidate];
    }

    [self.timerCache removeAllObjects];
}

- (NSString *)btoa:(NSString *)encode
{
    NSString *encodedString;
    NSData *data = [encode dataUsingEncoding:NSUTF8StringEncoding];
    encodedString = [data base64EncodedStringWithOptions:0];
    return encodedString;
}

#pragma mark - Private Methods

//------------------------------------------------------------------------------
// If the duration is  less than 0, just call the callback.
// Otherwise, create a timer and store it in the cache. If the duration is 0, a
// timer with 0.1ms is created.
//------------------------------------------------------------------------------
- (NSUInteger)setTimeoutCommon:(JSValue *)callback
                      duration:(NSTimeInterval)duration
                     requestId:(NSString *)requestId
                    isInterval:(BOOL)isInterval
{
    if (duration < 0) {
        if (requestId)
            [callback callWithArguments:@[ requestId ]];
        else
            [callback callWithArguments:@[]];

        return 0;
    } else {
        @synchronized(self)
        {
            if (self.lastTimerId < NSUIntegerMax)
                self.lastTimerId++;
            else
                self.lastTimerId = 0;

            NSNumber *timerDuration = @(duration);

            NSString *timerId = [NSString stringWithFormat:@"%tu", self.lastTimerId];

            NSNumber *isIntervalIndicator = [NSNumber numberWithInt:isInterval];

            // Garbage collected references
            JSManagedValue *timoutCallback = [JSManagedValue managedValueWithValue:callback];
            [[JSEngine sharedInstance] addManagedReference:timoutCallback];

            // Do not use new dictionaty syntax here because requestId may be nil
            NSDictionary *timerInfo =
                [NSDictionary dictionaryWithObjectsAndKeys:timerId, TIMER_INFO_TIMER_ID, timoutCallback,
                                                           TIMER_INFO_CALLBACK, timerDuration, TIMER_DURATION,
                                                           isIntervalIndicator, TIMER_IS_INTERVAL, requestId,
                                                           TIMER_INFO_REQUEST_ID,  // requestId may be nil so put
                                                                                   // it last!
                                                           nil];

            NSTimer *timer = [NSTimer timerWithTimeInterval:duration / 1000
                                                     target:self
                                                   selector:@selector(timerPopped:)
                                                   userInfo:timerInfo
                                                    repeats:isInterval];

            [[JSEngine sharedInstance].runLoop addTimer:timer forMode:NSDefaultRunLoopMode];

            [self.timerCache setValue:timer forKey:timerId];

            return self.lastTimerId;
        }
    }
}

- (void)timerPopped:(NSTimer *)timer
{
    NSDictionary *userInfo = timer.userInfo;
    NSString *timerId = [userInfo valueForKey:TIMER_INFO_TIMER_ID];

    JSManagedValue *timeoutCallback = [userInfo valueForKey:TIMER_INFO_CALLBACK];
    NSString *requestId = [userInfo valueForKey:TIMER_INFO_REQUEST_ID];

    if (requestId)
        [timeoutCallback.value callWithArguments:@[ requestId ]];
    else
        [timeoutCallback.value callWithArguments:@[]];

    BOOL isInterval = [[userInfo valueForKey:TIMER_IS_INTERVAL] boolValue];

    // If it's not an interval timer, remove it from the list
    if (!isInterval) {
        [[JSEngine sharedInstance] removeManagedReference:timeoutCallback];
        [self.timerCache removeObjectForKey:timerId];
    }
}

@end

@implementation Location

@synthesize href = _href;
@synthesize host = _host;
@synthesize hostname = _hostname;
@synthesize port = _port;
@synthesize origin = _origin;

- (instancetype)initWithAddress:(NSString *)address;
{
    if (self = [super init]) {
        _href = _host = _hostname = _port = _origin = @"";
    }
    return self;
}

- (void)setHref:(NSString *)href
{
    if ([href hasPrefix:@"https://"]) {
        _href = [href copy];
    } else {
        _href = [NSString stringWithFormat:@"https://%@", href];
    }
    NSURL *url = [NSURL URLWithString:_href];
    if (url.port) {
        _host = [NSString stringWithFormat:@"%@:%@", url.host, url.port];
        _hostname = [url.host copy];
        _port = [url.port stringValue];
    } else {
        _host = [url.host copy];
        _hostname = [url.host copy];
        _port = @"";
    }
    _origin = [NSString stringWithFormat:@"https://%@", _host];
}

- (NSString *)toString
{
    return self.href;
}

@end
#pragma clang disagnostic pop

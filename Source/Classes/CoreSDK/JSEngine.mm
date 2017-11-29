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
//  JSEngine.m
//  CircuitSDK
//
//

#import "JSEngine.h"
#import "JSNotificationCenter.h"
#import "JSRunLoop.h"
#import "CKTLog.h"

@implementation JSEngine

static NSString *LOG_TAG = @"[JSEngine]";

/**
 *  A singleton of the JSEngine object
 *
 *  @return A shared JSEngine object
 */
+ (JSEngine *)sharedInstance
{
    static JSEngine *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInstance = [[JSEngine alloc] init]; });
    return sharedInstance;
}

/**
 *  Initializes and starts the run loop on a separate thread
 */
- (void)start
{
    if (self.jsThread == nil) {
        LOGI(LOG_TAG, @"Starting JS Engine on separate thread...");
        self.jsThread = [[JSRunLoop alloc] init];
        [self.jsThread start];
    }
}

/**
 *  Cancels the run loop
 */
- (void)stop
{
    LOGI(LOG_TAG, @"Stopping JS Engine...");
    [self.jsThread cancel];
    self.jsThread = nil;
}

- (void)sendNotification:(NSString *)notification userInfo:(NSDictionary *)data
{
    // Send notifications asynchronously otherwise the UI may freeze.
    dispatch_async(dispatch_get_main_queue(),
                   ^(void) { [JSNotificationCenter sendNotificationName:notification object:nil userInfo:data]; });
}

/**
 *  Executes a function on a specific thread.
 *
 *  @param service  The class where the function is to be called
 *  @param selector The function that is to be executed
 *  @param arg      Arguments that will be passed into the executing function
 *  @param wait     If we should wait or not on the execution to complete. Sync or Async
 */
- (void)performAction:(id)service selector:(SEL)selector withObject:(id)arg waitUntilDone:(BOOL)wait
{
    // Make sure jsThread is still running
    if (self.jsThread && [self.jsThread isExecuting]) {
        [service performSelector:selector onThread:self.jsThread withObject:arg waitUntilDone:wait];
    } else {
        LOGE(LOG_TAG, @"cannot execute %@ - jsThread has stopped running", NSStringFromSelector(selector));
    }
}

- (JSContext *)context
{
    return self.jsThread.context;
}

- (void)addManagedReference:(id)object
{
    [self.context.virtualMachine addManagedReference:object withOwner:self];
}

- (void)removeManagedReference:(id)object
{
    [self.context.virtualMachine removeManagedReference:object withOwner:self];
}

- (NSRunLoop *)runLoop
{
    return self.jsThread.runLoop;
}

@end

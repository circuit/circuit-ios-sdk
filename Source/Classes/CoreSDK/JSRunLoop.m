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
//  JSRunLoop.m
//  CircuitSDK
//
//

#import "Angular.h"
#import "Audio.h"
#import "CKTHttp.h"
#import "JSEngine.h"
#import "JSRunLoop.h"
#import "JSNotificationCenter.h"
#import "Log.h"
#import "Logger.h"
#import "Navigator.h"
#import "Promise.h"
#import "PubSubService.h"
// Not needed for audio
// #import "URL.h"
#import "WebSocketManager.h"
#import "Window.h"
#import "XMLHttpRequest.h"

NSString *const kJSRunloopName = @"JS Run Loop";

@interface JSRunLoop ()

@property (nonatomic, strong) PubSubService *pubSubService;

@end

@implementation JSRunLoop

static NSString *LOG_TAG = @"[JSRunLoop]";

/**
 *  Loads all required js scripts into the JSContext
 */
- (void)loadScripts
{
    NSArray const *scripts = @[ @"sdkInterfacePre", @"circuit", @"sdkInterface" ];

    NSError *error;

    NSBundle *circuitBundle = [NSBundle bundleForClass:self.classForCoder];
    NSURL *bundleURL = [[circuitBundle resourceURL] URLByAppendingPathComponent:@"CircuitSDK.bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithURL:bundleURL];

    for (NSString *name in scripts) {
        NSString *fileURL = [resourceBundle pathForResource:name ofType:@"js"];
        NSString *script = [NSString stringWithContentsOfFile:fileURL encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            LOGE(LOG_TAG, @"Error reading file: %@, error: %@", name, error.localizedDescription);
            return;
        }

        [self.context evaluateScript:script withSourceURL:[NSURL URLWithString:fileURL]];
    }

    self.context.exceptionHandler =
        ^(JSContext *ctx, JSValue *ex) { LOGE(LOG_TAG, @"JavaScript exception handler: %@\n%@", ex, [ex toObject]); };

    LOGI(LOG_TAG, @"All scripts loaded successfully");
}

/**
 *  Initializes the js enviroment, injects objective-c for js to callback
 */
- (void)initializeJSEnviroment
{
    if (self.context == nil) {
        self.context = [[JSContext alloc] init];

        // We insert the JSEngine into the global object (context) so that when we call
        // -addManagedReference:withOwner: we can use the JSEngine as the owner. In this
        // manner the JSEngine itself is reachable from within JavaScript. If we didn't
        // do this, the JSEngine wouldn't be reachable from JavaScript, and there wouldn't
        // be anything keeping the managed object alive.
        self.context[@"JSEngine"] = [JSEngine sharedInstance];
        self.context[@"Audio"] = [Audio class];
        [Navigator initWebRTCInJSContext:self.context];
        // self.context[@"URL"] = [URL sharedInstance];
        self.context[@"WebSocket"] = [WebSocketManager class];
        self.context[@"XMLHttpRequest"] = [XMLHttpRequest class];
        self.context[@"logger"] = [Logger sharedInstance];
        self.context[@"angular"] = [Angular sharedInstance];
        self.context[@"window"] = [Window sharedInstance];

        [self loadScripts];

        self.pubSubService = [[PubSubService alloc] init];
        [self.pubSubService subscribeAll];
        [[JSEngine sharedInstance] sendNotification:CKTNotificationApplicationServiceLoaded userInfo:nil];
    }
}

/**
 *  Clears out the js environment
 */
- (void)cleanJSEnvironment
{
    LOGI(LOG_TAG, @"Clearing out JS environment");
    [Window.sharedInstance clearAllTimeouts];
    self.context = nil;
}

- (void)main
{
    @autoreleasepool
    {
        LOGI(LOG_TAG, @"main - begin");

        [self initializeJSEnviroment];

        self.runLoop = [NSRunLoop currentRunLoop];

        // add dummy port to ensure that run loop won't exit immediately after
        // launch due to lack of input sources
        [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];

        while (![self isCancelled]) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }

        [self cleanJSEnvironment];

        LOGI(LOG_TAG, @"main - end");
    }
}

@end

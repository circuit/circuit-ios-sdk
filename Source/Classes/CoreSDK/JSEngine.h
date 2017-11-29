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
//  JSEngine.h
//  CircuitSDK
//
//

#import <Foundation/Foundation.h>
#import "JSRunLoop.h"

@class JSContext;

@interface JSEngine : NSObject

@property (nonatomic, strong) JSRunLoop *jsThread;

+ (JSEngine *)sharedInstance;

- (void)start;
- (void)stop;
- (void)sendNotification:(NSString *)notification userInfo:(NSDictionary *)data;
- (void)performAction:(id)service selector:(SEL)selector withObject:(id)arg waitUntilDone:(BOOL)wait;

// *** I M P O R T A N T ***
// Managed references should not be added directly using the context. Instead, the add/removeManagedReference
// methods should be used in order to appropriately handle the owner of the reference.
- (JSContext *)context;
- (void)addManagedReference:(id)object;
- (void)removeManagedReference:(id)object;

- (NSRunLoop *)runLoop;

@end

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
//  WebSocketManager.h
//  CircuitSDK
//
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class WebSocketManager;

@protocol WebSocketExport<JSExport>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) JSValue *onopen;
@property (nonatomic, assign) JSValue *onclose;
@property (nonatomic, assign) JSValue *onmessage;
@property (nonatomic, assign) JSValue *onerror;

+ (WebSocketManager *)createWebSocket:(NSString *)url;
- (void)close;
- (void)send:(NSString *)json;
- (void)ping;

// Debug functions - do not remove #ifdef
#ifdef DEBUG
+ (void)close;
#endif

@end

@interface WebSocketManager : NSObject<WebSocketExport> {
    // Garbage collected references
    JSManagedValue *_onopenCallback;
    JSManagedValue *_oncloseCallback;
    JSManagedValue *_onmessageCallback;
    JSManagedValue *_onerrorCallback;
}

@end

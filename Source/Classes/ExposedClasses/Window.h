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
//  Window.h
//  CircuitSDK
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

@class Location;
@class Document;

@protocol WindowExport<JSExport>

@property (nonatomic, strong, readonly) Location *location;
@property (nonatomic, strong, readonly) Document *document;

- (void)alert:(NSString *)message;
- (NSUInteger)setTimeout:(JSValue *)callback:(NSTimeInterval)duration:(NSString *)requestId;
- (void)clearTimeout:(NSUInteger)timeoutId;
- (NSUInteger)setInterval:(JSValue *)callback:(NSTimeInterval)interval;
- (void)clearInterval:(NSUInteger)timeoutId;
- (NSString *)btoa:(NSString *)encode;

@end

@interface Window : NSObject<WindowExport>

+ (Window *)sharedInstance;
- (void)clearAllTimeouts;

@end

// Not all Location methods are implemented, only those those thought
// necessary at this time
@protocol LocationExport<JSExport>

@property (nonatomic, copy) NSString *href;
@property (nonatomic, copy, readonly) NSString *host;
@property (nonatomic, copy, readonly) NSString *hostname;
@property (nonatomic, copy, readonly) NSString *port;
@property (nonatomic, copy, readonly) NSString *origin;

- (NSString *)toString;

@end

@interface Location : NSObject<LocationExport>

@end

#pragma clang diagnostic pop

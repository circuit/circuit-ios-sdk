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
//  Promise.h
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

@class Promise;

typedef void (^PromiseCallback)(JSValue *value);

@protocol PromiseExport<JSExport>

- (Promise *)then:(JSValue *)successCallback:(JSValue *)errorCallback;
- (Promise *) catch:(JSValue *)errorCallback;

@end

#pragma clang diagnostic pop

@interface Promise : NSObject<PromiseExport>

@property (nonatomic, assign) BOOL resolved;
@property (nonatomic, assign) BOOL rejected;

@end

@protocol DeferExport<JSExport>

@property (nonatomic, strong) Promise *promise;

- (void)resolve:(JSValue *)data;
- (void)reject:(JSValue *)error;

@end

@interface Defer : NSObject<DeferExport>

@end

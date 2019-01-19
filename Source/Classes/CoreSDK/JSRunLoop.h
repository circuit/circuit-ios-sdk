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
//  JSRunLoop.h
//  CircuitSDK
//
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

extern NSString *const kJSRunloopName;

@interface JSRunLoop : NSThread

@property (nonatomic, strong) JSContext *context;
@property (nonatomic, strong) NSRunLoop *runLoop;

- (void)initializeJSEnviroment;
- (void)cleanJSEnvironment;

@end
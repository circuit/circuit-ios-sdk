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
//  Logger.h
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

@protocol LoggerExport<JSExport>

- (int)getLevel;
- (void)setLevel:(int)level;
- (void)debug:(NSString *)text:(id)data;
- (void)info:(NSString *)text:(id)data;
- (void)warning:(NSString *)text:(id)data;
- (void)warn:(NSString *)text:(id)data;
- (void)error:(NSString *)text:(id)data;
- (void)msgSend:(NSString *)text:(JSValue *)msg;
- (void)msgRcvd:(NSString *)text:(JSValue *)msg;
- (void)show;
- (void)hide;
- (void)setUser:(NSString *)displayName;
- (void)setClientVersion:(NSString *)clientVersion;

@end

@interface Logger : NSObject<LoggerExport>

+ (Logger *)sharedInstance;

@end
#pragma clang diagnostic pop

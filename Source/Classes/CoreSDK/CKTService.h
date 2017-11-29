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
//  CKTService.h
//  CircuitSDK
//
//

#import <Foundation/Foundation.h>

@class JSValue;

// Completion and return blocks used in the services
typedef void (^CompletionBlock)(id, NSError *);
typedef void (^CompletionBlockWithDataOnly)(id);
typedef void (^CompletionBlockWithNoData)(void);
typedef void (^CompletionBlockWithErrorOnly)(NSError *);

@interface CKTService : NSObject

// Call JavaScript functions with and without arguments
- (JSValue *)callFunction:(NSString *)functionName withArguments:(NSArray *)arguments;
- (JSValue *)callFunction:(NSString *)functionName;

- (void)executeSync:(SEL)sel withObject:(id)object;
- (void)executeAsync:(SEL)sel withObject:(id)object;
- (BOOL)executeMyselfAsync:(SEL)me withObject:(id)object;

- (void)executeFunction:(NSString *)functionName
                   args:(NSArray *)args
      completionHandler:(void (^)(NSDictionary *jsData, NSError *error))completion;
- (void)executeFunction:(NSString *)functionName
                 withId:(NSString *)jsId
                   args:(NSArray *)args
      completionHandler:(void (^)(NSDictionary *jsData, NSError *error))completion;
- (void)executeFunction:(NSString *)functionName
                 withId:(NSString *)jsId
               threadId:(NSString *)jsThreadId
                   args:(NSArray *)args
             completion:(void (^)(NSDictionary *jsData, NSError *error))completion;

#define THROW_EXCEPTION(name, exception) [self throwException:name ofType:exception fromFunction:__PRETTY_FUNCTION__];
- (void)throwException:(NSExceptionName)name ofType:(NSString *)exception fromFunction:(const char *)function;

extern NSString *const kJSEngineBlockArgName;

@end

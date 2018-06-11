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
//  CKTService.m
//  CircuitSDK
//
//

#import <JavaScriptCore/JavaScriptCore.h>

#import "CKTService.h"
#import "JSEngine.h"
#import "Log.h"
#import "Promise.h"

NSString *const kJSEngineBlockArgName = @"block";

@implementation CKTService

static NSString *LOG_TAG = @"[CKTService]";

/**
 *  Calls the JavaScript function provided by the function name with arguments.
 *
 *  @param functionName Name of the JavaScript function to be called.
 *  @param arguments    Array of arguments to be passed to the function.
 *
 *  @return Result of the function call as a JSValue
 */

- (JSValue *)callFunction:(NSString *)functionName withArguments:(NSArray *)arguments;
{
    JSValue *circuit = [self getCircuitObject];
    JSValue *function = circuit[functionName];
    JSValue *result = [function callWithArguments:arguments];

    return result;
}

/**
 *  Helper method to call a JavaScript function without arguments.
 *
 *  @param functionName Name of the JavaScript function to be called.
 *
 *  @return The result of the function call as a JSValue
 */
- (JSValue *)callFunction:(NSString *)functionName
{
    return [self callFunction:functionName withArguments:nil];
}

/**
 *  Obtains the main Circuit object from the JavaScript context
 *
 *  @return Circuit object as a JSValue
 */
- (JSValue *)getCircuitObject
{
    JSContext *context = [JSEngine sharedInstance].context;
    JSValue *circuit = context[@"sdkClient"];
    return circuit;
}

/**
 *  Executes the selector synchronously
 *
 *  @param sel    Function to be executed
 *  @param object Argument to be passed into the executed function
 */
- (void)executeSync:(SEL)sel withObject:(id)object
{
    [[JSEngine sharedInstance] performAction:self selector:sel withObject:object waitUntilDone:YES];
}

/**
 *  Executes the selector asynchronously
 *
 *  @param sel    Function to be executed
 *  @param object Argument to be passed into the executed function
 */
- (void)executeAsync:(SEL)sel withObject:(id)object
{
    [[JSEngine sharedInstance] performAction:self selector:sel withObject:object waitUntilDone:NO];
}

/**
 *  Executes the function by calling performAction if you are not on the current
 *thread.
 *
 *  @param me     Function to be executed
 *  @param object Argument to be passed into the executed function
 *
 *  @return YES if the thread is not the current thread, NO if you are already
 *on the current thread
 */
- (BOOL)executeMyselfAsync:(SEL)me withObject:(id)object
{
    if ([NSThread currentThread] != [JSEngine sharedInstance].jsThread) {
        [[JSEngine sharedInstance] performAction:self selector:me withObject:object waitUntilDone:NO];

        return YES;
    }

    return NO;
}

- (void)executeFunction:(NSString *)functionName
                   args:(NSArray *)args
      completionHandler:(void (^)(NSDictionary *jsData, NSError *error))completion
{
    Promise *promise = [[Promise alloc] init];

    JSValue *jsPromise;

    jsPromise = [self callFunction:functionName withArguments:args];

    PromiseCallback successCallback = ^(JSValue *jsData) {
        if (![jsData isNull] && ![jsData isUndefined]) {
            NSDictionary *data = [jsData toObject];
            completion(data, nil);
        } else {
            completion(nil, nil);
        }
    };

    PromiseCallback errorCallback = ^(JSValue *jsError) {
        NSError *error = JS_SERVICE_NSERROR_FROM_JSERROR(jsError);
        LOGE(LOG_TAG, @"Error: %@", error);
        completion(nil, error);
    };

    JSValue *jsSuccessCallback = [JSValue valueWithObject:successCallback inContext:[JSEngine sharedInstance].context];

    JSValue *jsErrorCallback = [JSValue valueWithObject:errorCallback inContext:[JSEngine sharedInstance].context];

    JSValue *promiseDict = [jsPromise toObject];

    if ([promiseDict isKindOfClass:[NSDictionary class]]) {
        promise = [promiseDict valueForKey:@"__nativePromise"];
    } else {
        promise = [jsPromise toObject];
    }

    [promise then:jsSuccessCallback:jsErrorCallback];
}

- (void)executeFunction:(NSString *)functionName
                   args:(NSArray *)args
      completionHandlerWithErrorOnly:(void (^)(NSError *error))completion
{
    Promise *promise = [[Promise alloc] init];

    JSValue *jsPromise;

    jsPromise = [self callFunction:functionName withArguments:args];

    PromiseCallback successCallback = ^(JSValue *jsData) {
            completion(nil);
    };

    PromiseCallback errorCallback = ^(JSValue *jsError) {
        NSError *error = JS_SERVICE_NSERROR_FROM_JSERROR(jsError);
        LOGE(LOG_TAG, @"Error: %@", error);
        completion(error);
    };

    JSValue *jsSuccessCallback = [JSValue valueWithObject:successCallback inContext:[JSEngine sharedInstance].context];
    JSValue *jsErrorCallback = [JSValue valueWithObject:errorCallback inContext:[JSEngine sharedInstance].context];
    JSValue *promiseDict = [jsPromise toObject];

    if ([promiseDict isKindOfClass:[NSDictionary class]]) {
        promise = [promiseDict valueForKey:@"__nativePromise"];
    } else {
        promise = [jsPromise toObject];
    }

    [promise then:jsSuccessCallback:jsErrorCallback];
}

- (void)executeFunction:(NSString *)functionName
                 withId:(NSString *)jsId
                   args:(NSArray *)args
      completionHandler:(void (^)(NSDictionary *jsData, NSError *error))completion
{
    NSArray *tmp = @[ jsId ];
    NSArray *functionArgs = [tmp arrayByAddingObjectsFromArray:args];

    [self executeFunction:functionName args:functionArgs completionHandler:completion];
}

- (void)executeFunction:(NSString *)functionName
                 withId:(NSString *)jsId
               threadId:(NSString *)jsThreadId
                   args:(NSArray *)args
             completion:(void (^)(NSDictionary *, NSError *))completion
{
    NSArray *tmp = @[ jsId, jsThreadId ];
    NSArray *functionArgs = [tmp arrayByAddingObjectsFromArray:args];

    [self executeFunction:functionName args:functionArgs completionHandler:completion];
}

- (void)throwException:(NSExceptionName)name ofType:(NSString *)exception fromFunction:(const char *)function
{
    [NSException raise:name format:@"%s - %@", function, exception];
}

#pragma mark Helpers for error handling
// Use the macros to consistently log the function name and line number

- (NSError *)NSErrorFromException:(NSException *)exception fromFunction:(const char *)function andLine:(int)line;
{
    NSError *error = [NSError errorWithDomain:@"CircuitKit"
                                         code:0
                                     userInfo:@{NSLocalizedDescriptionKey : exception.debugDescription}];
    LOGE(LOG_TAG, @"%s-%d: exception %@", function, line, error);
    return error;
}

- (NSError *)NSErrorFromJSError:(JSValue *)jsError fromFunction:(const char *)function andLine:(int)line
{
    NSError *error;
    if ((jsError == nil) || [jsError isNull] || [jsError isUndefined]) {
        LOGD(LOG_TAG, @"%s-%d - operation successful", function, line);
    } else {
        NSString __block *localizedDescription;

        // If the error object we got from the business logic is a dictionary: try
        // to get description string from
        // the entries. Send it to the upper layer because some pieces of code use
        // it to test what the BL error was.
        NSDictionary *errorDictionary = [jsError toDictionary];
        if (errorDictionary) {
            [errorDictionary enumerateKeysAndObjectsUsingBlock:^(id key, NSString *obj, BOOL *stop) {
                if ([obj hasPrefix:@"message"]) {
                    localizedDescription = obj;
                    *stop = YES;
                }
            }];
        }

        // If we didn't find a message string use the error object itself
        if (localizedDescription == nil) {
            localizedDescription = [jsError toString];
        }

        error =
            [NSError errorWithDomain:@"CircuitKit" code:0
                            userInfo:@{NSLocalizedDescriptionKey : localizedDescription}];
        LOGE(LOG_TAG, @"%s-%d: JavaScript error %@", function, line, jsError);
    }

    return error;
}

- (void)logException:(NSException *)exception fromFunction:(const char *)function andLine:(int)line;
{
    LOGE(LOG_TAG, @"%s-%d: exception - name: %@\nreason: %@\nuser info: %@\ndebug description: %@", function, line,
         exception.name, exception.reason, exception.userInfo, exception.debugDescription);
}

@end

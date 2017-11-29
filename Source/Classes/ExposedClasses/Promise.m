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
//  Promise.m
//  CircuitSDK
//
//

#import "Promise.h"
#import "CKTLog.h"
#import "JSEngine.h"

@interface Promise () {
    // Note: There will either be a valid pointer or nil for these values i.e., no NSNull or undefined
    // as can be the case with JSValues received from JavaScript.
    JSManagedValue *_data;

    // For some reason NSBlock objects from native code are not reachable through the Objective-C or Swift object graph
    // using JSManagedValue wrapper. And as a result they can be released by JavaScript garbage collector at any point
    // of time. So for this just store such object as is since it doesn't create a retain cycle, keeping the JS context
    // from being deallocated.
    id _successCallback;
    id _errorCallback;

    Promise *_chainedPromise;
}

@property (nonatomic, assign) BOOL asynchronous;

- (void)resolve:(JSValue *)data;
- (void)reject:(JSValue *)data;

@end

@implementation Promise

static NSString *LOG_TAG = @"[Promise]";

- (instancetype)init
{
    if (self = [super init]) {
        self.resolved = NO;
        self.rejected = NO;
        self.asynchronous = NO;
    }
    return self;
}

- (Promise *)then: (JSValue *)successCallback :(JSValue *)errorCallback
{
    @synchronized(self)
    {
        _chainedPromise = [[Promise alloc] init];

        if (self.resolved) {
            [self invokeSuccessCallback:successCallback];
        } else if (self.rejected) {
            [self invokeErrorCallback:errorCallback];
        } else {
            // Store the callbacks to be called at a later time.
            if ([[successCallback toObject] isKindOfClass:NSClassFromString(@"NSBlock")]) {
                // We deal with ObjC block as callback so just store it inside promise object.
                _successCallback = [successCallback toObject];
            } else if (![successCallback isNull] && ![successCallback isUndefined]) {
                // We deal with JS function so we shoud use managed value to store this callback inside
                // promise object.
                _successCallback = [JSManagedValue managedValueWithValue:successCallback];
                [[JSEngine sharedInstance] addManagedReference:_successCallback];
            }

            if ([[errorCallback toObject] isKindOfClass:NSClassFromString(@"NSBlock")]) {
                // We deal with ObjC block as callback so just store it inside promise object.
                _errorCallback = [errorCallback toObject];
            } else if (![errorCallback isNull] && ![errorCallback isUndefined] && errorCallback) {
                // We deal with JS function so we shoud use managed value to store this callback inside
                // promise object.
                _errorCallback = [JSManagedValue managedValueWithValue:errorCallback];
                [[JSEngine sharedInstance] addManagedReference:_errorCallback];
            }

            self.asynchronous = YES;
        }

        return _chainedPromise;
    }
}

- (Promise *) catch:(JSValue *)errorCallback
{
    @synchronized(self)
    {
        _chainedPromise = [[Promise alloc] init];

        if (self.resolved) {
            // Simply resolve the chained promise
            [_chainedPromise resolve:_data ? _data.value : nil];
        } else if (self.rejected) {
            [self invokeErrorCallback:errorCallback];
        } else {
            // Store the error callback to be called at a later time
            if ([[errorCallback toObject] isKindOfClass:NSClassFromString(@"NSBlock")]) {
                // We deal with ObjC block as callback so just store it inside promise object.
                _errorCallback = [errorCallback toObject];
            } else if (![errorCallback isNull] && ![errorCallback isUndefined] && errorCallback) {
                // We deal with JS function so we shoud use managed value to store this callback inside
                // promise object.
                _errorCallback = [JSManagedValue managedValueWithValue:errorCallback];
                [[JSEngine sharedInstance] addManagedReference:_errorCallback];
            }
            self.asynchronous = YES;
        }

        return _chainedPromise;
    }
}

- (void)resolve:(JSValue *)data
{
    @synchronized(self)
    {
        [self setData:data];
        self.resolved = YES;
        if (self.asynchronous) {
            JSValue *successCallback;
            if ([_successCallback isKindOfClass:NSClassFromString(@"NSBlock")]) {
                successCallback =
                    [JSValue valueWithObject:_successCallback inContext:[JSEngine sharedInstance].context];
            } else {
                successCallback = _successCallback ? [(JSManagedValue *)_successCallback value] : nil;
            }
            [self invokeSuccessCallback:successCallback];
        }
    }
}

- (void)reject:(JSValue *)data
{
    @synchronized(self)
    {
        LOGE(LOG_TAG, @"Rejecting promise (%p), asynchronous (%d)", self, self.asynchronous);

        [self setData:data];
        self.rejected = YES;
        if (self.asynchronous) {
            JSValue *errorCallback;
            if ([_errorCallback isKindOfClass:NSClassFromString(@"NSBlock")]) {
                errorCallback = [JSValue valueWithObject:_errorCallback inContext:[JSEngine sharedInstance].context];
            } else {
                errorCallback = _errorCallback ? [(JSManagedValue *)_errorCallback value] : nil;
            }
            [self invokeErrorCallback:errorCallback];
        }
    }
}

#pragma mark - internal functions

- (void)setData:(JSValue *)value
{
    if (value && ![value isNull] && ![value isUndefined]) {
        _data = [JSManagedValue managedValueWithValue:value];
        [[JSEngine sharedInstance] addManagedReference:_data];
    } else {
        _data = nil;
    }
}

- (void)clearJSReferences
{
    // Clear all references to JS variables
    if (_data) {
        [[JSEngine sharedInstance] removeManagedReference:_data];
        _data = nil;
    }

    if ([_successCallback isKindOfClass:[JSManagedValue class]]) {
        [[JSEngine sharedInstance] removeManagedReference:_successCallback];
        _successCallback = nil;
    }
    if ([_errorCallback isKindOfClass:[JSManagedValue class]]) {
        [[JSEngine sharedInstance] removeManagedReference:_errorCallback];
        _errorCallback = nil;
    }
}

/**
 Calls the given JavaScript callback and handles the returned object appropriately depending
 upon if the returned object is a native promise, our exposed Promise class or not.

 - parameters:
 - callback: The JavaScript function to be invoked. Can not be nil, NSNull or undefined!
 */
- (void)invokeRegisteredCallback:(JSValue *)callback
{
    JSValue *arg = _data ? _data.value : [JSValue valueWithNullInContext:[JSEngine sharedInstance].context];
    if (arg == NULL) {
        LOGE(LOG_TAG, @"invokeRegisteredCallback - error during callback");
        return;
    }

    JSValue *cbResult = [callback callWithArguments:@[ arg ]];
    NSObject *resultObj = [cbResult toObject];
    if ([resultObj isKindOfClass:[NSDictionary class]] && ((NSDictionary *)resultObj)[@"__nativePromise"]) {
        resultObj = ((NSDictionary *)resultObj)[@"__nativePromise"];
    }
    if ([resultObj isKindOfClass:[Promise class]]) {
        // The callback returned a new promise
        Promise *returnedPromise = (Promise *)resultObj;
        // Wait for the returned promise to be resolved/rejected before
        // resolving/rejecting the chained promise.
        [returnedPromise then:[JSValue valueWithObject:^(JSValue *newData) { [_chainedPromise resolve:newData]; }
                                             inContext:[JSEngine sharedInstance].context
        ]:[JSValue valueWithObject:^(JSValue *error) { [_chainedPromise reject:error]; }
                                   inContext:[JSEngine sharedInstance].context]];
    } else {
        // The callback returned a simple object
        [_chainedPromise resolve:cbResult];
    }
}

/**
 Invokes the given JavaScript success callback if present. Called both internally and directly from
 JavaScript via the exported interface.

 - parameters:
 - callback: The JavaScript function to be invoked. May be nil if called internally or NSNull or
 undefined when called directly from JavaScript.
 */
- (void)invokeSuccessCallback:(JSValue *)callback
{
    if (callback && ![callback isNull] && ![callback isUndefined] &&
        ![[JSEngine sharedInstance].jsThread isCancelled]) {
        [self invokeRegisteredCallback:callback];
    } else {
        // We don't have a success callback registered. Simply resolve the chained promise.
        [_chainedPromise resolve:_data ? _data.value : nil];
    }
    [self clearJSReferences];
}

/**
 Invokes the given JavaScript error callback if present. Called both internally and directly from
 JavaScript via the exported interface.

 - parameters:
 - callback: The JavaScript function to be invoked. May be nil if called internally or NSNull or
 undefined when called directly from JavaScript.
 */
- (void)invokeErrorCallback:(JSValue *)callback
{
    LOGE(LOG_TAG, @"Promise (%p) has been rejected", self);
    if (callback && ![callback isNull] && ![callback isUndefined] &&
        ![[JSEngine sharedInstance].jsThread isCancelled]) {
        [self invokeRegisteredCallback:callback];
    } else {
        // We don't have an error callback registered. Simply reject the chained promise.
        [_chainedPromise reject:_data ? _data.value : nil];
    }
    [self clearJSReferences];
}

@end

@implementation Defer

@synthesize promise = _promise;

- (Promise *)promise
{
    return _promise;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.promise = [[Promise alloc] init];
    }
    return self;
}

- (void)resolve:(JSValue *)data
{
    [self.promise resolve:data];
}

- (void)reject:(JSValue *)error
{
    [self.promise reject:error];
}

@end

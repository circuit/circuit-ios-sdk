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
//  Angular.m
//  CircuitSDK
//
//

#import "Angular.h"
#import "JSEngine.h"

@implementation Angular

+ (Angular *)sharedInstance
{
    static Angular *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInstance = [[Angular alloc] init]; });
    return sharedInstance;
}

- (Angular *)init
{
    if (self = [super init]) {
    }
    return self;
}

- (Defer *)defer
{
    return [[Defer alloc] init];
}

- (id)fromJson:(NSString *)value
{
    JSValue *json = [JSEngine sharedInstance].context[@"JSON"];
    JSValue *function = json[@"parse"];
    JSValue *jObject = nil;

    if (value != nil)
        jObject = [function callWithArguments:@[ value ]];

    return [jObject toObject];
 }

- (NSString *)toJson:(id)value
{
    JSValue *json = [JSEngine sharedInstance].context[@"JSON"];
    JSValue *function = json[@"stringify"];
    JSValue *jString = [function callWithArguments:@[ value ]];
    return [jString toString];
}

- (BOOL)isNumber:(NSString *)number
{
    BOOL result = false;

    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    NSNumber *n = [f numberFromString:number];
    if (n) {
        result = true;
    }
    return result;
}

@end

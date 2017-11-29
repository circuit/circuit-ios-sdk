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
//  Logger.m
//  CircuitSDK
//
//

#import "Logger.h"
#import "CKTLog.h"

// To supress the warning:
//   “used as the name of the previous parameter rather than as part of the selector”
// Comes from some lines like this one
//   - (void)success:(NSString *)message:(NSString *)title
// It can be suppressed by adding spaces, but our code formatter will remove those
// spaces and re-introduce the warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-selector-name"

@implementation Logger

static NSString *LOG_TAG = @"[JS]";

+ (Logger *)sharedInstance
{
    static Logger *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInstance = [[Logger alloc] init]; });
    return sharedInstance;
}

- (void)debug:(NSString *)text:(id)data;
{
    if (data)
        LOGD(LOG_TAG, @"%@ %@", text, data);
    else
        LOGD(LOG_TAG, text);
}

- (void)info:(NSString *)text:(id)data
{
    if (data)
        LOGI(LOG_TAG, @"%@ %@", text, data);
    else
        LOGI(LOG_TAG, text);
}

- (void)warning:(NSString *)text:(id)data
{
    if (data)
        LOGW(LOG_TAG, @"%@ %@", text, data);
    else
        LOGW(LOG_TAG, text);
}

/* This is needed to avoid the following exception.
 *
 * 2014-01-22 08:21:39.199 iEvo[8080:6883] E PANS : [JS] [ClientApiHandler]:
 *Exception:  {
 *    line = 70;
 *    stack = "\nisResponseValid\n\n\n";
 * }
 */
- (void)warn:(NSString *)text:(id)data
{
    if (data)
        LOGW(LOG_TAG, @"%@ %@", text, data);
    else
        LOGW(LOG_TAG, text);
}

- (void)error:(NSString *)text:(id)data
{
    if (data)
        LOGE(LOG_TAG, @"%@ %@", text, data);
    else
        LOGE(LOG_TAG, text);
}

- (void)msgSend:(NSString *)text:(JSValue *)msg
{
    if ([msg isObject]) {
        NSError *error;
        // convert object to data
        NSData *jsonData =
            [NSJSONSerialization dataWithJSONObject:[msg toObject] options:NSJSONWritingPrettyPrinted error:&error];
        // log the data contents
        LOGD(LOG_TAG, @"SEND: %@\n%@", text, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    } else if ([msg isString]) {
        LOGD(LOG_TAG, @"SEND: %@ %@", text, [msg toString]);
    } else {
        LOGW(LOG_TAG, @"SEND: %@ unexpected message type!", text);
    }
}

- (void)msgRcvd:(NSString *)text:(JSValue *)msg
{
    if ([msg isObject]) {
        NSError *error;
        // convert object to data
        NSData *jsonData =
            [NSJSONSerialization dataWithJSONObject:[msg toObject] options:NSJSONWritingPrettyPrinted error:&error];
        // log the data contents
        LOGD(LOG_TAG, @"RECV: %@\n%@", text, [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
    } else if ([msg isString]) {
        LOGD(LOG_TAG, @"RECV: %@ %@", text, [msg toString]);
    } else {
        LOGW(LOG_TAG, @"RECV: %@ unexpected message type!", text);
    }
}

- (void)show
{
    // Not supported?
}

- (void)hide
{
    // Not supported?
}

- (void)setUser:(NSString *)displayName
{
    LOGD(LOG_TAG, @"setUser - %@", displayName);
}

- (void)setClientVersion:(NSString *)clientVersion
{
    LOGD(LOG_TAG, @"setClientVersion - %@", clientVersion);
}

@end

#pragma clang diagnostic pop

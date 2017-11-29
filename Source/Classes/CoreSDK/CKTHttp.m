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
//  CKTHttp.m
//  CircuitSDK
//
//

#import "CKTHttp.h"
#import "XMLHttpRequest.h"

#import <sys/utsname.h>

@implementation CKTHttp

/**
 *  Creates a NSURLSession with a default configurations
 *  We use a default configuration because it uses the disk-persisted global cache, credential and cookie storage
 * objects.
 */
- (void)createSession
{
    if (_session == nil) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.timeoutIntervalForRequest = 20;
        sessionConfig.timeoutIntervalForResource = 30;
        sessionConfig.HTTPMaximumConnectionsPerHost = 3;

        _session = [NSURLSession sessionWithConfiguration:sessionConfig];
    }

    [XMLHttpRequest setURLSession:_session];
}

+ (NSString *)userAgent
{
    static NSString *userAgent;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *deviceModel = @(systemInfo.machine);

        NSString *appVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];

        NSMutableArray *headers = [@[
            @"Unify",
            @"MOBILE",
            @"SDK",
            appVersion,
            @"Apple",
            deviceModel,
            [NSString stringWithFormat:@"iOS %@", [UIDevice currentDevice].systemVersion],
        ] mutableCopy];

        userAgent = [headers componentsJoinedByString:@" ;; "];
    });

    return userAgent;
}

@end

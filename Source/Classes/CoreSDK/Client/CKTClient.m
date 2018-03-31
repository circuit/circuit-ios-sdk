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
//  CKTClient.m
//  CircuitSDK
//
//

#import "CKTClient.h"
#import "CKTLog.h"

@implementation CKTClient

@synthesize clientID = _clientID;
@synthesize clientSecret = _clientSecret;
static NSString *LOG_TAG = @"[CKTClient]";

+ (CKTClient *)sharedInstance
{
    static CKTClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ sharedInstance = [[self alloc] init]; });

    return sharedInstance;
}

// All client methods are implemented in their respective extensions

@end

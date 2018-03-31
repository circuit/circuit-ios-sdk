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
//  CKTClient+Logon.m
//  CircuitSDK
//
//

#import "CKTClient+Logon.h"
#import "CKTHttp.h"

@implementation CKTClient (Logon)

- (void)logon:(NSString *)accessToken completion:(void (^)(NSDictionary *user, NSError *error))completion
{
    CKTHttp *http = [[CKTHttp alloc] init];
    [http createSession];

    if (!accessToken) {
        THROW_EXCEPTION(kCKTException, kCKTAccessTokenException);
    }

    NSDictionary *args = @{ @"accessToken" : accessToken, kJSEngineBlockArgName : completion };

#ifdef UNIT_TEST
    [self executeSync:@selector(loginToAccessServer:) withObject:args];
#else
    [self executeAsync:@selector(loginToAccessServer:) withObject:args];
#endif
}

- (void)logon:(NSString *)username password:(NSString *)password completion:(void (^)(NSDictionary *user, NSError *error))completion
{
    CKTHttp *http = [[CKTHttp alloc] init];
    [http createSession];

    if (!(username.length > 0 && password.length > 0)) {
         THROW_EXCEPTION(kCKTException, kCKTUserCredentialsException);
    }

    NSDictionary *args = @{ @"username" : username, @"password" : password, kJSEngineBlockArgName : completion };
    [self executeAsync:@selector(authenticateResourceOwner:) withObject:args];
}

- (void)logout:(void (^)(void))completion
{
    NSDictionary *args = @{kJSEngineBlockArgName : completion};

    [self executeAsync:@selector(logoutCompletion:) withObject:args];
}

#pragma mark - Private Methods

- (void)authenticateResourceOwner:(NSDictionary *)args
{
    NSDictionary *object = @{ @"username" : args[@"username"],
                              @"password" : args[@"password"] };
    NSArray *logonArgs = @[ object ];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    [self executeFunction:@"logon" args:logonArgs completionHandler:completion];
}

- (void)loginToAccessServer:(NSDictionary *)args
{
    NSDictionary *object = @{ @"accessToken" : args[@"accessToken"] };
    NSArray *logonArgs = @[ object ];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    [self executeFunction:@"logon" args:logonArgs completionHandler:completion];
}

- (void)logoutCompletion:(NSDictionary *)args
{
    CompletionBlock completion = args[kJSEngineBlockArgName];

    [self executeFunction:@"logout" args:nil completionHandler:completion];
}

@end

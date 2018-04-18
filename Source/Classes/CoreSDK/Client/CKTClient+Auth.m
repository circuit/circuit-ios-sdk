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
//  CKTClient+Auth.m
//  CircuitSDK
//
//

#import "CKTClient+Auth.h"
#import "JSEngine.h"
#import "JSNotificationCenter.h"
#import "Log.h"
#import "Navigator.h"

@implementation CKTClient (Auth)

static NSString *LOG_TAG = @"[CKTClient+Auth]";

- (void)initializeSDK:(NSString *)oAuthClientId
    oAuthClientSecret:(NSString *)oAuthClientSecret
           oAuthScope:(NSString *)oAuthScope
{
    LOGI(LOG_TAG, @"Starting SDK initialization...");

    // Check is we have a client id, this is a required param so throw an exception if it's nil.
    if (!oAuthClientId) {
        THROW_EXCEPTION(kCKTException, kCKTOAuthClientIdException);
    }

    if (!oAuthClientSecret) {
        THROW_EXCEPTION(kCKTException, kCKTOAuthClientSecretException);
    }

    // The scope is optional, even though we check for this later, when nil is passed ALL is used, so just set it now.
    if (oAuthScope == nil) {
        oAuthScope = @"ALL";
    }

    // Set the ID and secret for later use
    self.clientID = oAuthClientId;
    self.clientSecret = oAuthClientSecret;

    // This is the list of approved OAuth 2 scopes. We should check to make sure someone is trying to use an approved
    // scope.
    NSArray *scopeList = @[
        @"ALL",
        @"READ_USER_PROFILE",
        @"WRITE_USER_PROFILE",
        @"READ_CONVERSATIONS",
        @"WRITE_CONVERSATIONS",
        @"READ_USER",
        @"CALLS"
    ];

    // The user's passed in scope items
    NSArray *userScopeItems = [oAuthScope componentsSeparatedByString:@","];

    NSMutableArray *userScopeList = [[NSMutableArray alloc] init];

    // Check if any whitespace needs to be trimmed from delimited string
    // ex. ALL, READ_USER_PROFILE.. If there is no whitespace then no trimming should happen. ex. ALL,READ_USER_PROFILE
    for (NSUInteger i = 0; i < userScopeItems.count; i++) {
        // Check if whitespace is present, if so trim it
        NSRange whiteSpace = [userScopeItems[i] rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
        if (whiteSpace.location != NSNotFound) {
            NSString *trimmedScope =
                [userScopeItems[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            [userScopeList addObject:trimmedScope];
        } else {
            [userScopeList addObject:userScopeItems[i]];
        }
    }

    // Check the scope passed in and make sure every value in the delimited list is an approved scope
    for (NSUInteger i = 0; i < userScopeList.count; i++) {
        BOOL containsScope = [scopeList containsObject:userScopeList[i]];

        if (!containsScope) {
            THROW_EXCEPTION(kCKTException, kCKTOAuthScopeException);
        }
    }

    // Now that we have approved scope. Create the comma delimited string, and inject that into the JS.
    NSString *userScope = [userScopeList componentsJoinedByString:@","];

    // Start the JSEngine
    [[JSEngine sharedInstance] start];

    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [[NSNotificationCenter defaultCenter]
        addObserverForName:CKTNotificationApplicationServiceLoaded
                    object:nil
                     queue:mainQueue
                usingBlock:^(NSNotification *note) {

                    // Initialize the WebRTC framework
                    [[Navigator sharedInstance] initWebRTC];

                    // Set the OAuth credentials
                    [self setOAuthConfig:oAuthClientId clientSecret:oAuthClientSecret scope:userScope];
                }];
}

- (void)renewToken:(void (^)(NSString *, NSError *))completion
{
    NSDictionary *args = @{ @"function" : @"renewToken", kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(tokenCompletion:) withObject:args];
}

- (void)revokeToken:(NSString *)token completion:(void (^)(void))completion
{
    id accessToken = token ? token : [NSNull null];

    NSDictionary *args = @{ @"function" : @"revokeToken", @"token" : accessToken, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(tokenCompletion:) withObject:args];
}

- (void)setOAuthConfig:(NSString *)clientId clientSecret:(NSString *)clientSecret
{
    if (!clientId) {
        THROW_EXCEPTION(kCKTException, kCKTOAuthClientIdException);
    }

    if (!clientSecret) {
        THROW_EXCEPTION(kCKTException, kCKTOAuthClientSecretException);
    }

    [self setOAuthConfig:clientId clientSecret:clientSecret scope:nil];
}

- (void)setOAuthConfig:(NSString *)clientId clientSecret:(NSString *)clientSecret scope:(NSString *)scope
{
    LOGD(LOG_TAG, @"Set the OAuth credentials");
    id oAuthScope = scope ? scope : [NSNull null];

    NSDictionary *args = @{ @"client_id" : clientId, @"client_secret" : clientSecret, @"scope" : oAuthScope };

    [self executeAsync:@selector(setOAuthConfigCompletion:) withObject:args];
}

- (void)validateToken:(NSString *)accessToken completion:(void (^)(void))completion
{
    id token = accessToken ? accessToken : [NSNull null];

    NSDictionary *args = @{ @"function" : @"validateToken", @"token" : token, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(tokenCompletion:) withObject:args];
}

#pragma mark - Private Methods

- (void)tokenCompletion:(NSDictionary *)args
{
    NSString *function = args[@"function"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    if ([function isEqualToString:@"renewToken"]) {
        [self executeFunction:function args:nil completionHandler:completion];
    } else {
        id accessToken = args[@"token"];
        NSArray *tokenArgs = @[ accessToken ];

        [self executeFunction:function args:tokenArgs completionHandler:completion];
    }
}

- (void)setOAuthConfigCompletion:(NSDictionary *)args
{
    NSString *client_id = args[@"client_id"];
    id scope = args[@"scope"];

    NSDictionary *oAuthArgs = @{ @"client_id" : client_id, @"scope" : scope };

    NSArray *configArgs = @[ oAuthArgs ];

    [self executeFunction:@"setOauthConfig" args:configArgs completionHandler:nil];
}

@end

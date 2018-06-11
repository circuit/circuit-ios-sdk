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
//  CKTClient+User.m
//  CircuitSDK
//
//

#import "CKTClient+User.h"

@implementation CKTClient (User)

- (void)getLoggedOnUser:(CompletionBlock)completion;
{
    NSDictionary *args = @{kJSEngineBlockArgName : completion};

    [self executeAsync:@selector(getLoggedOnUserCompletion:) withObject:args];
}

- (void)getPresence:(NSArray *)userIds full:(BOOL)full completion:(CompletionBlock)completion
{
    if (!userIds) {
        THROW_EXCEPTION(kCKTException, kCKTUserException);
    }

    BOOL isFull = full;

    NSDictionary *args = @{ @"userIds" : userIds, @"full" : @(isFull), kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getPresenceCompletion:) withObject:args];
}

- (void)getUserById:(NSString *)userId completion:(CompletionBlock)completion;
{
    if (!userId) {
        THROW_EXCEPTION(kCKTException, kCKTUserException);
    }

    NSDictionary *args = @{@"userId" : userId, kJSEngineBlockArgName : completion};

    [self executeAsync:@selector(getUserByIdCompletion:) withObject:args];
}

- (void)getUsersById:(NSArray *)userIds completion:(CompletionBlock)completion
{
    if (!userIds) {
        THROW_EXCEPTION(kCKTException, kCKTUserException);
    }

    BOOL isLimited = YES;
    NSDictionary *args = @{ @"userIds" : userIds, @"limited" : @(isLimited), kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getUsersByIdCompletion:) withObject:args];
}

- (void)getUsersById:(NSArray *)userIds limited:(BOOL)limited completion:(CompletionBlock)completion
{
    if (!userIds) {
        THROW_EXCEPTION(kCKTException, kCKTUserException);
    }

    BOOL isLimited = limited;
    NSDictionary *args = @{ @"userIds" : userIds, @"limited" : @(isLimited), kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getUsersByIdCompletion:) withObject:args];
}

- (void)getUserByEmail:(NSString *)email completion:(CompletionBlock)completion
{
    if (!email) {
        THROW_EXCEPTION(kCKTException, kCKTUserException);
    }

    NSDictionary *args = @{ @"email" : email, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getUserByEmailCompletion:) withObject:args];
}

- (void)getUsersByEmail:(NSArray *)emails completion:(CompletionBlock)completion
{
    if (!emails) {
        THROW_EXCEPTION(kCKTException, kCKTUserException);
    }

    NSDictionary *args = @{ @"emails" : emails, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getUsersByEmailCompletion:) withObject:args];
}

- (void)getUserSettings:(CompletionBlock)completion
{
    NSDictionary *args = @{kJSEngineBlockArgName : completion};

    [self executeAsync:@selector(getUserSettingsCompletion:) withObject:args];
}

- (void)getStatusMessage:(CompletionBlock)completion
{
    NSDictionary *args = @{kJSEngineBlockArgName : completion};

    [self executeAsync:@selector(getStatusMessageCompletion:) withObject:args];
}

- (void)setStatusMessage:(NSString *)statusMessage completion:(CompletionBlockWithNoData)completion
{
    if (!statusMessage) {
        THROW_EXCEPTION(kCKTException, kCKTUserStatusException);
    }

    NSDictionary *args = @{ @"statusMessage" : statusMessage, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(setStatusMessageCompletion:) withObject:args];
}

- (void)getTenantUsers:(NSDictionary *)options completion:(CompletionBlock)completion
{
    id filterOptions = options ? options : [NSNull null];

    NSDictionary *args = @{ @"options" : filterOptions, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getTenantUsersCompletion:) withObject:args];
}

- (void)updateUser:(NSDictionary *)user completion:(CompletionBlockWithNoData)completion
{
    if (!user) {
        THROW_EXCEPTION(kCKTException, kCKTObjectException);
    }

    NSDictionary *args = @{ @"user" : user, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(updateUserCompletion:) withObject:args];
}

#pragma mark - Private Methods

- (void)getLoggedOnUserCompletion:(NSDictionary *)args
{
    CompletionBlock completion = args[kJSEngineBlockArgName];

    [self executeFunction:@"getLoggedOnUser" args:nil completionHandler:completion];
}

- (void)getPresenceCompletion:(NSDictionary *)args
{
    NSArray *userIds = args[@"userIds"];
    BOOL full = (BOOL)args[@"full"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *userArgs = @[ userIds, @(full) ];

    [self executeFunction:@"getPresence" args:userArgs completionHandler:completion];
}

- (void)getUserByIdCompletion:(NSDictionary *)args
{
    NSString *userId = args[@"userId"];
    CompletionBlock completion = args[kJSEngineBlockArgName];
    NSArray *userArgs = @[ userId ];

    [self executeFunction:@"getUserById" args:userArgs completionHandler:completion];
}

- (void)getUsersByIdCompletion:(NSDictionary *)args
{
    NSArray *userIds = args[@"userIds"];
    BOOL limited = (BOOL)args[@"limited"];
    CompletionBlock completion = args[kJSEngineBlockArgName];
    NSArray *userArgs = @[ userIds, @(limited) ];

    [self executeFunction:@"getUsersById" args:userArgs completionHandler:completion];
}

- (void)getUserByEmailCompletion:(NSDictionary *)args
{
    NSString *email = args[@"email"];
    NSArray *userArgs = @[ email ];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    [self executeFunction:@"getUserByEmail" args:userArgs completionHandler:completion];
}

- (void)getUsersByEmailCompletion:(NSDictionary *)args
{
    NSArray *emails = args[@"emails"];
    NSArray *usersArgs = @[ emails ];

    CompletionBlock completion = args[kJSEngineBlockArgName];

    [self executeFunction:@"getUsersByEmail" args:usersArgs completionHandler:completion];
}

- (void)getUserSettingsCompletion:(NSDictionary *)args
{
    CompletionBlock completion = args[kJSEngineBlockArgName];

    [self executeFunction:@"getUserSettings" args:nil completionHandler:completion];
}

- (void)getStatusMessageCompletion:(NSDictionary *)args
{
    CompletionBlock completion = args[kJSEngineBlockArgName];

    [self executeFunction:@"getStatusMessage" args:nil completionHandler:completion];
}

- (void)setStatusMessageCompletion:(NSDictionary *)args
{
    NSString *statusMessage = args[@"statusMessage"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *statusArgs = @[ statusMessage ];

    [self executeFunction:@"setStatusMessage" args:statusArgs completionHandler:completion];
}

- (void)getTenantUsersCompletion:(NSDictionary *)args
{
    id options = args[@"options"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *userArgs = @[ options ];

    [self executeFunction:@"getTenantUsers" args:userArgs completionHandler:completion];
}

- (void)updateUserCompletion:(NSDictionary *)args
{
    NSDictionary *userObject = args[@"user"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *userArgs = @[ userObject ];

    [self executeFunction:@"updateUser" args:userArgs completionHandler:completion];
}

@end

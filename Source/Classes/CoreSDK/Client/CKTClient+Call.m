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
//  CKTClient+Call.m
//  CircuitSDK
//
//

#import "CKTClient+Call.h"

@implementation CKTClient (Call)

- (void)addParticipantToCall:(NSString *)callId to:(NSDictionary *)to completion:(void (^)(void))completion
{
    if (!callId) {
        THROW_EXCEPTION(kCKTException, kCKTCallIdException);
    } else if (!to || !to[@"userId"] || !to[@"email"] || !to[@"number"]) {
        THROW_EXCEPTION(kCKTException, kCKTDialOutException);
    }

    NSDictionary *args = @{
        @"function" : @"addParticipantToCall",
        @"callId" : callId,
        @"to" : to,
        kJSEngineBlockArgName : completion
    };

    [self executeAsync:@selector(addParticipantToCallCompletion:) withObject:args];
}

- (void)addParticipantToRtcSession:(NSString *)callId to:(NSDictionary *)to completion:(void (^)(void))completion
{
    if (!callId) {
        THROW_EXCEPTION(kCKTException, kCKTCallIdException);
    } else if (!to || !to[@"userId"] || !to[@"email"] || !to[@"number"]) {
        THROW_EXCEPTION(kCKTException, kCKTDialOutException);
    }

    NSDictionary *args = @{
        @"function" : @"addParticipantToRtcSession",
        @"callId" : callId,
        @"to" : to,
        kJSEngineBlockArgName : completion
    };

    [self executeAsync:@selector(addParticipantToCallCompletion:) withObject:args];
}

- (void)answerCall:(NSString *)callId
            mediaType:(NSDictionary *)mediaType
    completionHandler:(CompletionBlockWithErrorOnly)completion
{
    if (!callId) {
        THROW_EXCEPTION(kCKTException, kCKTCallIdException);
    } else if (!mediaType) {
        THROW_EXCEPTION(kCKTException, kCKTMediaTypeException);
    }

    NSDictionary *args = @{ @"callId" : callId, @"mediaType" : mediaType, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(answerCallCompletion:) withObject:args];
}

- (void)dialNumber:(NSString *)number completionHandler:(void (^)(NSDictionary *, NSError *))completion
{
    [self dialNumber:number name:nil completionHandler:completion];
}

- (void)dialNumber:(NSString *)number
                 name:(NSString *)name
    completionHandler:(void (^)(NSDictionary *call, NSError *error))completion
{
    if (!number) {
        THROW_EXCEPTION(kCKTException, kCKTNumberException);
    }

    id calleeName = name ? name : [NSNull null];

    NSDictionary *args = @{ @"number" : number, @"name" : calleeName, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(dialNumberCompletion:) withObject:args];
}

- (void)endCall:(NSString *)callId completion:(CompletionBlockWithErrorOnly)completion
{
    if (!callId) {
        THROW_EXCEPTION(kCKTException, kCKTCallIdException);
    }

    NSDictionary *args = @{ @"callId" : callId, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(endCallCompletion:) withObject:args];
}

- (void)endConference:(NSString *)callId completion:(CompletionBlockWithErrorOnly)completion
{
    if (!callId) {
        THROW_EXCEPTION(kCKTException, kCKTCallIdException);
    }

    NSDictionary *args = @{ @"callId" : callId, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(endConferenceCompletion:) withObject:args];
}

- (void)leaveConference:(NSString *)callId completion:(CompletionBlockWithErrorOnly)completion
{
    if (!callId) {
        THROW_EXCEPTION(kCKTException, kCKTCallIdException);
    }

    NSDictionary *args = @{ @"callId" : callId, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(leaveConferenceCompletion:) withObject:args];
}

- (void)findCall:(NSString *)callId completionHandler:(void (^)(NSDictionary *, NSError *))completion
{
    if (!callId) {
        THROW_EXCEPTION(kCKTException, kCKTCallIdException);
    }

    NSDictionary *args = @{ @"callId" : callId, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(findCallCompletion:) withObject:args];
}

- (void)getActiveCall:(void (^)(NSDictionary *, NSError *))completion
{
    NSDictionary *args = @{ @"function" : @"getActiveCall", kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getCallDataCompletion:) withObject:args];
}

- (void)getActiveRemoteCalls:(void (^)(NSDictionary *, NSError *))completion
{
    NSDictionary *args = @{ @"function" : @"getActiveRemoteCalls", kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getCallDataCompletion:) withObject:args];
}

- (void)getCalls:(void (^)(NSArray *, NSError *))completion
{
    NSDictionary *args = @{ @"function" : @"getCalls", kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getCallDataCompletion:) withObject:args];
}

- (void)getTelephonyData:(void (^)(NSDictionary *, NSError *))completion
{
    NSDictionary *args = @{ @"function" : @"getTelephonyData", kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getCallDataCompletion:) withObject:args];
}

- (void)makeCall:(NSString *)user
            mediaType:(NSDictionary *)mediaType
    completionHandler:(void (^)(NSDictionary *, NSError *))completion
{
    [self makeCall:user mediaType:mediaType createIfNotExists:false completionHandler:completion];
}

- (void)makeCall:(NSString *)user
            mediaType:(NSDictionary *)mediaType
    createIfNotExists:(BOOL)createIfNotExists
    completionHandler:(void (^)(NSDictionary *, NSError *))completion
{
    if (!user) {
        THROW_EXCEPTION(kCKTException, kCKTUserException);
    } else if (!mediaType) {
        THROW_EXCEPTION(kCKTException, kCKTMediaTypeException);
    }

    id create = createIfNotExists ? @(createIfNotExists) : [NSNull null];

    NSDictionary *args = @{
        @"user" : user,
        @"mediaType" : mediaType,
        @"createIfNotExists" : create,
        kJSEngineBlockArgName : completion
    };

    [self executeAsync:@selector(makeCallCompletion:) withObject:args];
}

- (void)mute:(NSString *)callId completionHandler:(void (^)(void))completion
{
    if (!callId) {
        THROW_EXCEPTION(kCKTException, kCKTCallIdException);
    }

    NSDictionary *args = @{ @"callId" : callId, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(muteCompletion:) withObject:args];
}

- (void)startConference:(NSString *)convId
              mediaType:(NSDictionary *)mediaType
             completion:(CompletionBlockWithErrorOnly)completion
{
    if (!convId) {
        THROW_EXCEPTION(kCKTException, kCKTConversationIdException);
    } else if (!mediaType) {
        THROW_EXCEPTION(kCKTException, kCKTMediaTypeException);
    }

    NSDictionary *args = @{ @"convId" : convId, @"mediaType" : mediaType, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(startConferenceCompletion:) withObject:args];
}

- (void)joinConference:(NSString *)callId
             mediaType:(NSDictionary *)mediaType
              clientId:(NSString *_Nullable)clientId
            completion:(CompletionBlockWithNoData)completion
{
    if (!callId) {
        THROW_EXCEPTION(kCKTException, kCKTCallIdException);
    } else if (!mediaType) {
        THROW_EXCEPTION(kCKTException, kCKTMediaTypeException);
    }

    id clientID = clientId ? clientId : [NSNull null];

    NSDictionary *dict = @{
        @"callId" : callId,
        @"mediaType" : mediaType,
        @"clientId" : clientID,
        kJSEngineBlockArgName : completion
    };

    [self executeAsync:@selector(joinConference:) withObject:dict];
}

- (void)unmute:(NSString *)callId completionHandler:(void (^)(void))completion
{
    if (!callId) {
        THROW_EXCEPTION(kCKTException, kCKTCallIdException)
    }

    NSDictionary *args = @{ @"callId" : callId, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(unmuteCompletion:) withObject:args];
}

#pragma mark - Privtae Methods

- (void)addParticipantToCallCompletion:(NSDictionary *)args
{
    NSString *function = args[@"function"];
    NSString *callId = args[@"callId"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    id userId = args[@"userId"] ? args[@"userId"] : [NSNull null];
    id email = args[@"email"] ? args[@"email"] : [NSNull null];
    id number = args[@"number"] ? args[@"number"] : [NSNull null];
    id displayName = args[@"displayName"] ? args[@"displayName"] : [NSNull null];

    NSDictionary *options = @{ @"userId" : userId, @"email" : email, @"number" : number, @"displayName" : displayName };

    NSArray *participantArray = @[ options ];

    [self executeFunction:function withId:callId args:participantArray completionHandler:completion];
}

- (void)answerCallCompletion:(NSDictionary *)args
{
    NSString *callId = args[@"callId"];
    NSDictionary *mediaType = args[@"mediaType"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *callArgs = @[ callId, mediaType ];

    [self executeFunction:@"answerCall" args:callArgs completionHandler:completion];
}

- (void)dialNumberCompletion:(NSDictionary *)args
{
    NSString *number = args[@"number"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *tmp = @[ number ];
    NSArray *callArgs;

    if (args[@"name"]) {
        callArgs = [tmp arrayByAddingObject:args[@"name"]];
    } else {
        callArgs = tmp;
    }

    [self executeFunction:@"dialNumber" args:callArgs completionHandler:completion];
}

- (void)endCallCompletion:(NSDictionary *)args
{
    NSString *callId = args[@"callId"];
    CompletionBlockWithErrorOnly completion = args[kJSEngineBlockArgName];

    NSArray *callArgs = @[ callId ];

    [self executeFunction:@"endCall" args:callArgs completionHandlerWithErrorOnly:completion];
}

- (void)endConferenceCompletion:(NSDictionary *)args
{
    NSString *callId = args[@"callId"];
    CompletionBlockWithErrorOnly completion = args[kJSEngineBlockArgName];

    NSArray *conferenceArgs = @[ callId ];

    [self executeFunction:@"endConference" args:conferenceArgs completionHandlerWithErrorOnly:completion];
}

- (void)leaveConferenceCompletion:(NSDictionary *)args
{
    NSString *callId = args[@"callId"];
    CompletionBlockWithErrorOnly completion = args[kJSEngineBlockArgName];

    NSArray *conferenceArgs = @[ callId ];

    [self executeFunction:@"leaveConference" args:conferenceArgs completionHandlerWithErrorOnly:completion];
}

- (void)findCallCompletion:(NSDictionary *)args
{
    NSString *callId = args[@"callId"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *callArgs = @[ callId ];

    [self executeFunction:@"findCall" args:callArgs completionHandler:completion];
}

- (void)getCallDataCompletion:(NSDictionary *)args
{
    NSString *function = args[@"function"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    [self executeFunction:function args:nil completionHandler:completion];
}

- (void)makeCallCompletion:(NSDictionary *)args
{
    NSString *user = args[@"user"];
    NSDictionary *mediaType = args[@"mediaType"];

    NSArray *tmp = @[ user, mediaType ];
    NSArray *callArgs;

    CompletionBlock completion = args[kJSEngineBlockArgName];

    if (args[@"createIfNotExists"]) {
        callArgs = [tmp arrayByAddingObject:args[@"createIfNotExists"]];
    } else {
        callArgs = tmp;
    }

    [self executeFunction:@"makeCall" args:callArgs completionHandler:completion];
}

- (void)muteCompletion:(NSDictionary *)args
{
    NSString *callId = args[@"callId"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *callArgs = @[ callId ];

    [self executeFunction:@"mute" args:callArgs completionHandler:completion];
}

- (void)startConferenceCompletion:(NSDictionary *)args
{
    NSString *conversationId = args[@"convId"];
    NSDictionary *mediaType = args[@"mediaType"];
    CompletionBlockWithErrorOnly completion = args[kJSEngineBlockArgName];

    NSArray *conferenceArgs = @[ conversationId, mediaType ];

    [self executeFunction:@"startConference" args:conferenceArgs completionHandlerWithErrorOnly:completion];
}

- (void)joinConference:(NSDictionary *)args
{
    NSString *callId = args[@"callId"];
    NSDictionary *mediaType = args[@"mediaType"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *tmp = @[ callId, mediaType ];
    NSArray *callArgs;

    if (args[@"clientId"]) {
        callArgs = [tmp arrayByAddingObject:args[@"clientId"]];
    } else {
        callArgs = tmp;
    }

    [self executeFunction:@"joinConference" args:callArgs completionHandler:completion];
}

- (void)unmuteCompletion:(NSDictionary *)args
{
    NSString *callId = args[@"callId"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *callArgs = @[ callId ];

    [self executeFunction:@"unmute" args:callArgs completionHandler:completion];
}

@end

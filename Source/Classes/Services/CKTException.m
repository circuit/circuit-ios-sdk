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
//  CKTException.m
//  CircuitSDK
//
//

#import "CKTException.h"

// CircuitKit Exception
NSString *const kCKTException = @"CircuitKit Exception";

// OAuth Exceptions
NSString *const kCKTOAuthClientIdException = @"Attempted to configure OAuth with no client id.";
NSString *const kCKTOAuthClientSecretException = @"Attempted to configure OAuth with no client secret";
NSString *const kCKTOAuthScopeException =
    @"A non valid scope is trying to be used - See CircuitKit documentation on all approved scopes";

// Call Exceptions
NSString *const kCKTCallIdException = @"Call id was not provided.";
NSString *const kCKTDialOutException = @"Dial out information was not provided.";
NSString *const kCKTMediaTypeException = @"Media type was not provided.";
NSString *const kCKTNumberException = @"Number was not provided";

// Conversation Exceptions
NSString *const kCKTAttributesException = @"Attributes were not provided.";
NSString *const kCKTContentException = @"Content was not provided.";
NSString *const kCKTConversationIdException = @"Conversation id was not provided.";
NSString *const kCKTItemIdException = @"Item id was not provided.";
NSString *const kCKTItemsIdException = @"Items id was not provided.";
NSString *const kCKTParticipantIdException = @"Participant id was not provided.";
NSString *const kCKTThreadIdException = @"Thread id was not provided.";
NSString *const kCKTTopicException = @"Topic was not provided.";

// JSEngine Exceptions
NSString *const kCKTJSEngineException = @"Attempted to use the SDK without starting the JSEngine.";

// Logon Exceptions
NSString *const kCKTAccessTokenException = @"Attempted to logon without an access token.";
NSString *const kCKTUserCredentialsException = @"Attempted to login without username or password provided";

// User Exceptions
NSString *const kCKTUserException = @"User id(s) or User email(s) were not provided";
NSString *const kCKTUserOldPasswordException = @"User's old password was not provided.";
NSString *const kCKTUserNewPasswordException = @"User's new password was not provided.";
NSString *const kCKTUserStatusException = @"Status message was not provided.";

// Misc Exceptions
NSString *const kCKTObjectException = @"Object literal was not provided";

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
//  CKTException.h
//  CircuitSDK
//
//

#import <Foundation/Foundation.h>

// CircuitKit Exception
extern NSString *const kCKTException;

// OAuth exceptions
extern NSString *const kCKTOAuthClientIdException;
extern NSString *const kCKTOAuthClientSecretException;
extern NSString *const kCKTOAuthScopeException;

// Call Exceptions
extern NSString *const kCKTCallIdException;
extern NSString *const kCKTDialOutException;
extern NSString *const kCKTMediaTypeException;
extern NSString *const kCKTNumberException;

// Conversation Exceptions
extern NSString *const kCKTAttributesException;
extern NSString *const kCKTContentException;
extern NSString *const kCKTConversationIdException;
extern NSString *const kCKTItemIdException;
extern NSString *const kCKTItemsIdException;
extern NSString *const kCKTParticipantIdException;
extern NSString *const kCKTThreadIdException;
extern NSString *const kCKTTopicException;

// JSEngine Exceptions
extern NSString *const kCKTJSEngineException;

// Logon Exceptions
extern NSString *const kCKTAccessTokenException;
extern NSString *const kCKTUserCredentialsException;

// User Exceptions
extern NSString *const kCKTUserException;
extern NSString *const kCKTUserOldPasswordException;
extern NSString *const kCKTUserNewPasswordException;
extern NSString *const kCKTUserStatusException;

// Misc Exceptions
extern NSString *const kCKTObjectException;

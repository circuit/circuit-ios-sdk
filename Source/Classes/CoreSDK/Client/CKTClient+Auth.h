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
//  CKTClient+Auth.h
//  CircuitSDK
//
//

#import "CKTClient.h"

@interface CKTClient (Auth)

/*!

 @breif Initializes the SDK, by setting up the different environments.

 @param oAuthClientId Client id of your circuit credentials
 @param oAuthClientSecret Client secret of your circuit credentials
 @param oAuthScope Comma delimited set of permissions

 */
- (void)initializeSDK:(NSString *)oAuthClientId
    oAuthClientSecret:(NSString *)oAuthClientSecret
           oAuthScope:(NSString *)oAuthScope;

/*!

 @brief Renew the OAuth2 access token of the current user

 @discussion Required OAuth2 scopes: n/a

 @param completion A completion block that takes either an access token or an error and returns void.

 */
- (void)renewToken:(void (^)(NSString *token, NSError *error))completion;

/*!

 @brief Revoke the OAuth2 access token

 @discussion Required OAuth2 scopes: n/a

 @param token [optional] If omitted the internally used access token is revoked.
 @param completion A completion block that takes no arguments and returns void.

 */
- (void)revokeToken:(NSString *)token completion:(void (^)(void))completion;

/*!

 @brief Sets the configuration for OAuth Authentication without scope

 @discussion Use this method when you want the application to request all permissions

 @param clientId Application client_id
 @param clientSecret Application clientSecret

 */
- (void)setOAuthConfig:(NSString *)clientId clientSecret:(NSString *)clientSecret;

/*!

 @brief Sets the configuration for OAuth Authentication with scope

 @discussion Use this method when you want to determine which permissions the application requests.

 This could be any of the following in a comma deliminated string

 - ALL
 - READ_USER_PROFILE
 - WRITE_USER_PROFILE
 - READ_CONVERSATIONS
 - WRITE_CONVERSATION
 - READ_USER
 - CALLS

 @param clientId Client id of circuit credentials

 @param clientSecret Client secret of circuit credentials
 @param scope Application scope, default is ALL

 */
- (void)setOAuthConfig:(NSString *)clientId clientSecret:(NSString *)clientSecret scope:(NSString *)scope;

/*!

 @brief Validates the OAuth2 access token

 @discussion Required OAuth2 scopes: n/a

 @param accessToken If not provided, current access token of the client instance is validated.
 @param completion A completion block that takes no arguments and returns void.

 */
- (void)validateToken:(NSString *)accessToken completion:(void (^)(void))completion;

@end

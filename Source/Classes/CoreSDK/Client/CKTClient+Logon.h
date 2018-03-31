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
//  CKTClient+Logon.h
//  CircuitSDK
//
//

#import "CKTClient.h"

@interface CKTClient (Logon)

/*!

 @brief Logs user into server via given access token.
        OAuth2 accessToken logon.

 @param accessToken Token retrieved from OAuth
 @param completion A completion handler that takes either a user or an error and returns void.

 */
- (void)logon:(NSString *)accessToken completion:(void (^)(NSDictionary *user, NSError *error))completion;

/*!

 @brief Logs user into server via given credentials.
        OAuth2 Resource Owner Grant Type logon.

 @discussion This grant type should only be used if other flows
            are not viable. Also, it should only be used if the
            application is trusted by the user.

 @param username Username (email) for Resource Owner Grant Type
 @param password Password for Resource Owner Grant Type
 @param completion A completion handler that takes either a user or an error and returns void.

 */
- (void)logon:(NSString *)username password:(NSString *)password completion:(void (^)(NSDictionary *user, NSError *error))completion;

/*!

 @brief Logs user out of the server and ends the session

 @param completion A completion handler that takes no arguments and returns void.

 */
- (void)logout:(void (^)(void))completion;

@end

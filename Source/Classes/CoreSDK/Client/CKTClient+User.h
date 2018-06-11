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
//  CKTClient+User.h
//  CircuitSDK
//
//

#import "CKTClient.h"

@interface CKTClient (User)

/**

 @brief Returns the current logged on user in JSON format.

 @discussion Required OAuth2 scopes: READ_USER_PROFILE or ALL

 @param completion A completion block that takes either a user or an error and returns void.

 */

- (void)getLoggedOnUser:(void (^)(id user, NSError *error))completion;

/**

 @brief Get the presence for a list of user id's

 @discussion Required OAuth2 scopes: READ_USER or ALL

 @param userIds List of userIds
 @param full If true, detailed presence is returned which also includes long/lat, timezone, etc.
 @param completion A completion block that takes either presence or an error and returns void.

*/
- (void)getPresence:(NSArray *)userIds full:(BOOL)full completion:(void (^)(id presence, NSError *error))completion;

/**

 @brief Get the status message of the logged on user.

 @discussion Required OAuth2 scopes: READ_USER_PROFILE or ALL

 @param completion A completion block that takes either the status message or an error and returns void.

*/
- (void)getStatusMessage:(void (^)(id status, NSError *error))completion;

/**

 @brief Get the users for this tenant/domain. This API requires tenant admin privileges.

 @discussion Required OAuth2 scopes: ALL and only by tenant admins.

 @param options Filter options
 @param completion A completion block that takes either users or an error and returns void.

*/
- (void)getTenantUsers:(NSDictionary *)options completion:(void (^)(id users, NSError *error))completion;

/**

 @brief Returns the user in JSON format by the given user email.

 @param email Email address of the user data you want to retrieve.
 @param completion A completion handler that takes either a user or an error and returns void.

 */
- (void)getUserByEmail:(NSString *)email completion:(void (^)(id user, NSError *error))completion;

/**

 @brief Returns the user in JSON format by the given user id.

 @param userId User id of the user data you want to retrieve.
 @param completion A completion handler that takes either a user or an error and returns void.

 */
- (void)getUserById:(NSString *)userId completion:(void (^)(id user, NSError *error))completion;

/**

 @brief Returns a dictionary of users in JSON format by the array of user emails.

 @param emails Array of email addresses of the user data you want to retrieve.
 @param completion A completion handler that takes either a dictionary of  users or an error and returns void.

 */
- (void)getUsersByEmail:(NSArray *)emails completion:(void (^)(id user, NSError *error))completion;

/**

 @brief Returns users in JSON format by the array of user ids.

 @param userIds Array of userIds of the user data you want to retrieve.
 @param completion A completion handler that takes either a dictionary of  users or an error and returns void.

 */

- (void)getUsersById:(NSArray *)userIds completion:(void (^)(id user, NSError *error))completion;

/**

 @brief Returns users in JSON format by the array of user ids.

 @param userIds Array of userIds of the user data you want to retrieve.
 @param limited If true, a limited user object is retrurned with the most important attributes. Default is false.
 @param completion A completion handler that takes either a dictionary of  users or an error and returns void.

 */
- (void)getUsersById:(NSArray *)userIds limited:(BOOL)limited completion:(void (^)(id user, NSError *error))completion;

/**

 @brief Get all the user settings of the logged in user.

 @discussion Required OAuth2 scopes: READ_USER_PROFILE or ALL

 @param completion A completion handler that takes either user settings or an error and returns void.

*/
- (void)getUserSettings:(void (^)(id settings, NSError *error))completion;

/**

 @brief Set the status message of the logged on user. Fires userPresenceChnaged event to users on other logged on
 clients and to all other users that subscribe to this user's presence.

 @discussion Required OAuth2 scopes: WRITE_USER_PROFILE or ALL

 @param statusMessage Status message, set to empty string to clear status message.
 @param completion A completion block that takes no arguments and returns void.

 */
- (void)setStatusMessage:(NSString *)statusMessage completion:(void (^)(void))completion;

/**

 @brief Update the logged on user's own object.

 @discussion Required OAuth2 scopes: WRITE_USER_PROFILE or ALL

 @param user Dictionary containing the user attributes to update
 @param completion A completion block that takes no arguments and returns void.

*/
- (void)updateUser:(NSDictionary *)user completion:(void (^)(void))completion;

@end

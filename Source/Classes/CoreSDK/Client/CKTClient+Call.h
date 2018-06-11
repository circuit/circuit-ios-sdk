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
//  CKTClient+Call.h
//  CircuitSDK
//
//

#import "CKTClient.h"

@interface CKTClient (Call)

/*!

 @brief Add a participant to a call via dial out. The participant does not have to be a member of the conversation.
        Dialing PSTN number is also supported.

 @discussion Required OAuth2 scopes: WRITE_CONVERSATIONS or FULL

 @param callId Id of the current call.
 @param to  Dictionary containing dial out information.
 @param completion A completion handler that takes no arguments and returns void.

*/
- (void)addParticipantToCall:(NSString *)callId to:(NSDictionary *)to completion:(void (^)(void))completion;

/*!

 @brief Add a participant to an RTC Session via dial out. Unlike addParticipantToCall this API does not rely on a local
 call to be present. The participant does not have to be a member of the conversation. Dialing PSTN number is also
 supported

 @discussion Required OAuth2 scopes: WRITE_CONVERSATIONS or FULL

 @param callId Id of the current call.
 @param to Dictionary contaiing dial out information.
 @param completion A completion handler that takes no arguments and returns void.

*/
- (void)addParticipantToRtcSession:(NSString *)callId to:(NSDictionary *)to completion:(void (^)(void))completion;

/*!

 @brief Answer an incoming call received in a callIncoming event

 @param callId callId of the call to answer.
 @param mediaType Object with boolean attributes: audio, video.
 @param completion A completion handler that takes either a call or an error and returns void.

 */
- (void)answerCall:(NSString *)callId
            mediaType:(NSDictionary *)mediaType
    completionHandler:(void (^)(NSError *error))completion;

/*!

 @brief Start a telephony conversation

 @param number Dialable number, must match Circuit.Utils.PHONE_PATTERN.
 @param completion A completion that takes either a call or an error and returns void.

 */
- (void)dialNumber:(NSString *)number completionHandler:(void (^)(NSDictionary *call, NSError *error))completion;

/*!

 @brief Start a telephony conversation

 @param number Dialable number, must match Circuit.Utils.PHONE_PATTERN.
 @param name Display name of the number being dialed.
 @param completion A completion handler that takes either a call or an error and returns void.

 */
- (void)dialNumber:(NSString *)number
                 name:(NSString *)name
    completionHandler:(void (^)(NSDictionary *call, NSError *error))completion;

/*!

 @brief End a direct call or leave a group conference

 @param callId callId of the call to end.
 @param completion A completion that takes no arguments and replying with an error.

 */
- (void)endCall:(NSString *)callId completion:(void (^)(NSError *error))completion;

/*!

 @brief End a conference call. Disconnects all other participants as well.

 @discussion Requires OAuth2 scopes: CALLS or ALL

 @param callId Call id of the call to end.
 @param completion A compleiton that takes no arguments and replying with an error.

*/
- (void)endConference:(NSString *)callId completion:(void (^)(NSError *error))completion;

/*!
 @brief Leave a conference call.

 @discussion Requires OAuth2 scopes: CALLS or FULL

 @param callId Call id of the call to leave.
 @param completion A compleiton that takes no arguments and replying with an error.

 */

- (void)leaveConference:(NSString *)callId completion:(void (^)(NSError *error))completion;

/*!

 @brief Find a call by its call Id. Call may be local or remote, active or non-active

 @param callId CallId of the call to find.
 @param completion A completion handler that takes either a call or an error and returns void.

 */
- (void)findCall:(NSString *)callId completionHandler:(void (^)(NSDictionary *call, NSError *error))completion;

/*!

 @brief Get local active call

 @param completion A completion handler that takes either a call or an error and returns void.

 */
- (void)getActiveCall:(void (^)(NSDictionary *call, NSError *error))completion;

/*!

 @brief Get remote active calls.

 @discussion Required OAuth2 scopes: CALLS or ALL

 @param completion A completion block that takes active remote calls or an error and returns void.

*/
- (void)getActiveRemoteCalls:(void (^)(NSDictionary *calls, NSError *error))completion;

/*!

 @brief Get all local and remote calls in progress

 @param completion A completion handler that takes an array of calls or an error and returns void.

 */
- (void)getCalls:(void (^)(NSArray *calls, NSError *error))completion;

/*!

 @brief Get the telephony data such as the connection state and default caller id.

 @discussion Required OAuth2 scopes: READ_USER_PROFILE or ALL

 @param completion A completion block that takes either telephony data or an error and returns void.

*/
- (void)getTelephonyData:(void (^)(NSDictionary *data, NSError *error))completion;

/*!

 @brief Start a direct call with a user by it's email address or user Id

 @param user email or userId of the user to call.
 @param mediaType Object with boolean attributes: audio, video.
 @param completion A completion handler that takes either a call or an error and returns void.

 */
- (void)makeCall:(NSString *)user
            mediaType:(NSDictionary *)mediaType
    completionHandler:(void (^)(NSDictionary *call, NSError *error))completion;

/*!

 @brief Start a direct call with a user by it's email address or user Id

 @param user email or userId of the user to call.
 @param mediaType Object with boolean attributes: audio, video.
 @param createIfNotExists Create a conversation with the user if not already existing, default is FALSE.
 @param completion A completion handler that takes either a call or an error and returns void.

 */
- (void)makeCall:(NSString *)user
            mediaType:(NSDictionary *)mediaType
    createIfNotExists:(BOOL)createIfNotExists
    completionHandler:(void (^)(NSDictionary *call, NSError *error))completion;

/*!

 @brief Mute an existing call

 @param callId callId of the call to mute.
 @param completion A completion handler that takes no arguments and returns void.

 */
- (void)mute:(NSString *)callId completionHandler:(void (^)(void))completion;

/*!

 @brief StartConference a conference call.

 @discussion Required OAuth2 scopes: CALLS or ALL

 @param convId Conversation ID
 @param mediaType Dictionary with boolean attributes: audio, video
 @param completion A completion that takes no arguments and replying with an error.

*/
- (void)startConference:(NSString *)convId
              mediaType:(NSDictionary *)mediaType
             completion:(void (^)(NSError *error))completion;

/*!

 @brief Join a conference call from the current device, or optionally from another logged on device.

 @discussion Required OAuth2 scopes: CALLS or ALL

 @param callId callId callId of the call to join.
 @param mediaType mediaType Object with boolean attributes: audio, video
 @param clientId clientId of device where to join the call from

 @param completion A completion block that takes no arguments and returns void.

 */

- (void)joinConference:(NSString *)callId
             mediaType:(NSDictionary *)mediaType
              clientId:(NSString *)clientId
            completion:(CompletionBlockWithNoData)completion;

/*!

 @brief Unmute an existing call

 @param callId CallId of the call to unmute.
 @param completion A completion handler that takes no arguments and returns void.

 */
- (void)unmute:(NSString *)callId completionHandler:(void (^)(void))completion;

@end

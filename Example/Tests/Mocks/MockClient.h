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
//  MockClient.h
//  CircuitSDK
//
//

#import <CircuitSDK/CircuitSDK.h>

@interface MockClient : CKTClient

- (void)getLoggedOnUser:(void (^)(NSDictionary *data, NSError *error))completion;
- (void)getUserById:(NSString *)userId completionHandler:(void (^)(NSDictionary *data, NSError *error))completion;
- (void)getConversations:(void (^)(NSArray *data, NSError *error))completion;
- (void)getConversationsWithOptions:(NSDictionary *)options
                  completionHandler:(void (^)(NSArray *data, NSError *error))completion;
- (void)getConversationItems:(NSString *)convId completionHandler:(void (^)(NSArray *, NSError *))completion;
- (void)getConversationItemsWithOptions:(NSString *)convId
                            convOptions:(NSDictionary *)options
                      completionHandler:(void (^)(NSArray *, NSError *))completion;
- (void)getItemById:(NSString *)itemId completionHandler:(void (^)(NSDictionary *, NSError *))completion;
- (void)addTextItem:(NSString *)convId
          textContent:(id)content
    completionHandler:(void (^)(id convContent, NSError *error))completion;
- (void)createDirectConversation:(NSString *)participantId
               completionHandler:(void (^)(NSDictionary *, NSError *))completion;
- (void)createGroupConversation:(NSArray *)participantIds
                          title:(NSString *)title
              completionHandler:(void (^)(NSDictionary *, NSError *))completion;
- (void)createOpenConversation:(NSArray *)participantIds
                         title:(NSString *)title
                   description:(NSString *)description
             completionHandler:(void (^)(NSDictionary *, NSError *))completion;

@end

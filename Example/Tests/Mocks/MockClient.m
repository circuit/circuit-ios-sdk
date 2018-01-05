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
//  MockClient.m
//  CircuitSDK
//
//

#import "MockClient.h"

@implementation MockClient

- (void)getLoggedOnUser:(void (^)(NSDictionary *data, NSError *error))completion
{
    NSDictionary *user = @{ @"user" : @"Circuit User" };
    completion(user, nil);
}

- (void)getUserById:(NSString *)userId completionHandler:(void (^)(NSDictionary *, NSError *))completion
{
    NSString *mockUserId = @"8e44f0089b076e18a718eb9ca3d94674";

    NSDictionary *user = @{ @"user" : @"Circuit User" };

    if (userId == mockUserId) {
        completion(user, nil);
    } else {
        NSError *error = [[NSError alloc] init];
        completion(nil, error);
    }
}

- (void)getConversations:(void (^)(NSArray *, NSError *))completion
{
    NSArray *conversations = @[
        @{ @"convId" : @"382709be52359ffa14c26653f8e73834",
           @"topic" : @"Unify" },
        @{ @"convId" : @"d42410a28ae273e91bc0d057cf9f6b79",
           @"topic" : @"Unit tests" }
    ];

    completion(conversations, nil);
}

- (void)getConversationsWithOptions:(NSDictionary *)options completionHandler:(void (^)(NSArray *, NSError *))completion
{
    NSArray *conversations = @[
        @{ @"convId" : @"382709be52359ffa14c26653f8e73834",
           @"topic" : @"Conversation A" },
        @{ @"convId" : @"d42410a28ae273e91bc0d057cf9f6b79",
           @"topic" : @"Conversation B" },
        @{ @"convId" : @"b45cffe084dd3d20d928bee85e7b0f21",
           @"topic" : @"Conversation C" }
    ];

    completion(conversations, nil);
}

- (void)getConversationItems:(NSString *)convId completionHandler:(void (^)(NSArray *, NSError *))completion
{
    NSString *mockConvId = @"bed306cf766aac4f613e44e469abc285";

    NSArray *convItems = @[
        @{
            @"convId" : @"bed306cf766aac4f613e44e469abc285",
            @"user" : @"User A",
            @"content" : @"Sample content from A."
        },
        @{
            @"convId" : @"bed306cf766aac4f613e44e469ab4563",
            @"user" : @"User B",
            @"content" : @"Sample content from B."
        }
    ];

    if (convId == mockConvId) {
        completion(convItems, nil);
    } else {
        NSError *error = [[NSError alloc] init];
        completion(nil, error);
    }
}

- (void)getConversationItemsWithOptions:(NSString *)convId
                            convOptions:(NSDictionary *)options
                      completionHandler:(void (^)(NSArray *, NSError *))completion
{
    NSString *mockConvId = @"bed306cf766aac4f613e44e469abc285";

    NSArray *convItems = @[
        @{
            @"convId" : @"bed306cf766aac4f613e44e469abc285",
            @"user" : @"User A",
            @"content" : @"Sample content from A."
        },
        @{
            @"convId" : @"bed306cf766aac4f613e44e469ab4563",
            @"user" : @"User B",
            @"content" : @"Sample content from B."
        }
    ];

    if (convId == mockConvId && [options[@"numberOfItems"] isEqual:@2]) {
        completion(convItems, nil);
    } else {
        NSError *error = [[NSError alloc] init];
        completion(nil, error);
    }
}

- (void)getItemById:(NSString *)itemId completionHandler:(void (^)(NSDictionary *, NSError *))completion
{
    NSString *mockItemId = @"59a814aa020a1b32c4674a5887a35022";

    NSDictionary *item = @{ @"creationTime" : @1263267842, @"content" : @"Sample item content" };

    if (itemId == mockItemId) {
        completion(item, nil);
    } else {
        NSError *error = [[NSError alloc] init];
        completion(nil, error);
    }
}

- (void)addTextItem:(NSString *)convId
          textContent:(id)content
    completionHandler:(void (^)(id convContent, NSError *error))completion
{
    NSString *mockConvId = @"bed306cf766aac4f613e44e469abc285";

    if (convId == mockConvId && content) {
        completion(content, nil);
    } else {
        NSError *error = [[NSError alloc] init];
        completion(nil, error);
    }
}

- (void)createDirectConversation:(NSString *)participantId
               completionHandler:(void (^)(NSDictionary *, NSError *))completion
{
    if (participantId) {
        NSArray *userIds = @[ @"24c9e15e52afc47c225b757e7bee1f9d", participantId ];
        NSDictionary *mockConversation = @{
            @"participants" : userIds,
            @"conversationId" : @"382709be52359ffa14c26653f8e73834",
            @"type" : @"DIRECT",
            @"title" : @"Conversation Title",
            @"timestamp" : @145742589654,
            @"recentItem" : @"Conversation was created",
            @"avatarURL" : @"http://exampleurl.com/avatar"
        };

        completion(mockConversation, nil);
    } else {
        NSError *error = [[NSError alloc] init];
        completion(nil, error);
    }
}

- (void)createGroupConversation:(NSArray *)participantIds
                          title:(NSString *)title
              completionHandler:(void (^)(NSDictionary *, NSError *))completion
{
    if (participantIds) {
        NSDictionary *mockConversation = @{
            @"participants" : participantIds,
            @"conversationId" : @"382709be52359ffa14c26653f8e73834",
            @"type" : @"GROUP",
            @"title" : title,
            @"timestamp" : @145742589654,
            @"recentItem" : @"Conversation was created",
            @"avatarURL" : @"http://exampleurl.com/avatar"
        };
        completion(mockConversation, nil);
    } else {
        NSError *error = [[NSError alloc] init];
        completion(nil, error);
    }
}

- (void)createOpenConversation:(NSArray *)participantIds
                         title:(NSString *)title
                   description:(NSString *)description
             completionHandler:(void (^)(NSDictionary *, NSError *))completion
{
    if (participantIds) {
        NSDictionary *mockConversation = @{
            @"participants" : participantIds,
            @"conversationId" : @"382709be52359ffa14c26653f8e73834",
            @"type" : @"OPEN",
            @"title" : title,
            @"description" : description,
            @"timestamp" : @145742589654,
            @"recentItem" : @"Conversation was created",
            @"avatarURL" : @"http://exampleurl.com/avatar"
        };
        completion(mockConversation, nil);
    } else {
        NSError *error = [[NSError alloc] init];
        completion(nil, error);
    }
}

@end

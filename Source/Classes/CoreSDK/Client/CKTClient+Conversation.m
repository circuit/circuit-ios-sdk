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
//  CKTClient+Conversation.m
//  CircuitSDK
//
//

#import "CKTClient+Conversation.h"
#import "CKTException.h"

@implementation CKTClient (Conversation)

- (void)addParticipant:(NSString *)convId userIds:(NSArray *)userIds completion:(CompletionBlockWithNoData)completion
{
    if (!convId) {
        THROW_EXCEPTION(kCKTException, kCKTConversationIdException);
    } else if (!userIds) {
        THROW_EXCEPTION(kCKTException, kCKTUserException);
    }

    NSDictionary *args = @{ @"convId" : convId, @"userIds" : userIds, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(addParticipantCompletion:) withObject:args];
}

- (void)addTextItem:(NSString *)convId content:(id)content completionHandler:(CompletionBlock)completion
{
    if (!convId) {
        THROW_EXCEPTION(kCKTException, kCKTConversationIdException);
    } else if (!content) {
        THROW_EXCEPTION(kCKTException, kCKTContentException);
    }

    NSDictionary *args = @{ @"convId" : convId, @"content" : content, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(addTextItemCompletion:) withObject:args];
}

- (void)createCommunity:(NSArray *)participants
                  topic:(NSString *)topic
            description:(NSString *)description
             completion:(CompletionBlock)completion
{
    id communityParticipants = participants ? participants : [NSNull null];
    id communityTopic = topic ? topic : [NSNull null];
    id commintyDescription = description ? description : [NSNull null];

    NSDictionary *args = @{
        @"participants" : communityParticipants,
        @"topic" : communityTopic,
        @"description" : commintyDescription,
        kJSEngineBlockArgName : completion
    };

    [self executeAsync:@selector(createCommunityCompletion:) withObject:args];
}

- (void)createConferenceBridge:(NSString *)topic completion:(CompletionBlock)completion
{
    if (!topic) {
        THROW_EXCEPTION(kCKTException, kCKTTopicException);
    }

    NSDictionary *args = @{ @"topic" : topic, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(createCoferenceBridgeCompletion:) withObject:args];
}

- (void)createDirectConversation:(NSString *)participantId completionHandler:(CompletionBlock)completion
{
    if (!participantId) {
        THROW_EXCEPTION(kCKTException, kCKTParticipantIdException);
    }

    NSDictionary *args = @{
        @"function" : @"createDirectConversation",
        @"convArgs" : @[ participantId ],
        kJSEngineBlockArgName : completion
    };

    [self executeAsync:@selector(createConversationCompletion:) withObject:args];
}

- (void)createGroupConversation:(NSArray *)participantIds
                          title:(NSString *)title
              completionHandler:(CompletionBlock)completion
{
    if (!participantIds) {
        THROW_EXCEPTION(kCKTException, kCKTParticipantIdException);
    }

    NSDictionary *args = @{
        @"function" : @"createGroupConversation",
        @"convArgs" : @[ participantIds, title ],
        kJSEngineBlockArgName : completion
    };

    [self executeAsync:@selector(createConversationCompletion:) withObject:args];
}

- (void)flagItem:(NSString *)convId itemId:(NSString *)itemId completion:(CompletionBlockWithNoData)completion
{
    if (!convId) {
        THROW_EXCEPTION(kCKTException, kCKTConversationIdException);
    } else if (!itemId) {
        THROW_EXCEPTION(kCKTException, kCKTItemIdException);
    }

    NSDictionary *args = @{ @"convId" : convId, @"itemId" : itemId, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(flagItemCompletion:) withObject:args];
}

- (void)getConversations:(CompletionBlock)completion
{
    [self getConversations:nil completionHandler:completion];
}

- (void)getConversations:(NSDictionary *)options completionHandler:(CompletionBlock)completion
{
    NSMutableDictionary *args = options ? [options mutableCopy] : [[NSMutableDictionary alloc] init];

    [args setObject:completion forKey:kJSEngineBlockArgName];

    [self executeAsync:@selector(getConversationsWithOptionsCompletion:) withObject:args];
}

- (void)getConversationDetails:(NSString *)convId completion:(CompletionBlock)completion
{
    if (!convId) {
        THROW_EXCEPTION(kCKTException, kCKTConversationIdException);
    }

    NSDictionary *args = @{
        @"function" : @"getConversationDetails",
        @"convId" : convId,
        kJSEngineBlockArgName : completion
    };

    [self executeAsync:@selector(getConversationDataCompletion:) withObject:args];
}

- (void)getConversationFeed:(NSString *)convId options:(NSDictionary *)options completion:(CompletionBlock)completion
{
    if (!convId) {
        THROW_EXCEPTION(kCKTException, kCKTConversationIdException);
    }

    NSMutableDictionary *args = options ? [options mutableCopy] : [[NSMutableDictionary alloc] init];

    [args setObject:convId forKey:@"convId"];
    [args setObject:completion forKey:kJSEngineBlockArgName];

    [self executeAsync:@selector(getConversationFeedCompletion:) withObject:args];
}

- (void)getConversationItems:(NSString *)convId options:(NSDictionary *)options completion:(CompletionBlock)completion
{
    if (!convId) {
        THROW_EXCEPTION(kCKTException, kCKTConversationIdException);
    }

    NSMutableDictionary *args = options ? [options mutableCopy] : [[NSMutableDictionary alloc] init];

    [args setObject:convId forKey:@"convId"];
    [args setObject:completion forKey:kJSEngineBlockArgName];

    [self executeAsync:@selector(getConversationItemsCompletion:) withObject:args];
}

- (void)getConversationParticipants:(NSString *)convId
                            options:(NSDictionary *)options
                         completion:(CompletionBlock)completion
{
    if (!convId) {
        THROW_EXCEPTION(kCKTException, kCKTConversationIdException);
    }

    NSMutableDictionary *args = options ? [options mutableCopy] : [[NSMutableDictionary alloc] init];

    [args setObject:convId forKey:@"convId"];
    [args setObject:completion forKey:kJSEngineBlockArgName];

    [self executeAsync:@selector(getConversationParticipantsCompletion:) withObject:args];
}

- (void)getDirectConversationWithUser:(NSString *)query
                    createIfNotExists:(BOOL)createIfNotExists
                           completion:(CompletionBlock)completion
{
    if (!query) {
        THROW_EXCEPTION(kCKTException, kCKTUserException);
    }

    id create = @(createIfNotExists);

    NSDictionary *args = @{ @"query" : query, @"createIfNotExists" : create, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getDirectConversationWithUserCompletion:) withObject:args];
}

- (void)getFlaggedItems:(CompletionBlock)completion
{
    NSDictionary *args = @{ @"function" : @"getFlaggedItems", kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getConversationDataCompletion:) withObject:args];
}

- (void)getItemById:(NSString *)itemId completionHandler:(CompletionBlock)completion
{
    if (!itemId) {
        THROW_EXCEPTION(kCKTException, kCKTItemIdException);
    }

    NSDictionary *args = @{ @"itemId" : itemId, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getItemByIdCompletion:) withObject:args];
}

- (void)getItemsByThread:(NSString *)convId
                threadId:(NSString *)threadId
                 options:(NSDictionary *)options
              completion:(CompletionBlock)completion
{
    if (!convId) {
        THROW_EXCEPTION(kCKTException, kCKTConversationIdException);
    } else if (!threadId) {
        THROW_EXCEPTION(kCKTException, kCKTThreadIdException);
    }

    NSMutableDictionary *args = options ? [options mutableCopy] : [[NSMutableDictionary alloc] init];

    [args setObject:convId forKey:@"convId"];
    [args setObject:threadId forKey:@"threadId"];
    [args setObject:completion forKey:kJSEngineBlockArgName];

    [self executeAsync:@selector(getItemsByThreadCompletion:) withObject:args];
}

- (void)getMarkedConversations:(CompletionBlock)completion
{
    NSDictionary *args = @{ @"function" : @"getMarkedConversations", kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getConversationDataCompletion:) withObject:args];
}

- (void)getSupportConversationId:(CompletionBlock)completion
{
    NSDictionary *args = @{ @"function" : @"getSupportConversationId", kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getConversationDataCompletion:) withObject:args];
}

- (void)getTelephonyConversationId:(CompletionBlock)completion
{
    NSDictionary *args = @{ @"function" : @"getTelephonyConversationId", kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(getConversationDataCompletion:) withObject:args];
}

- (void)likeItem:(NSString *)itemId completion:(CompletionBlockWithNoData)completion
{
    if (!itemId) {
        THROW_EXCEPTION(kCKTException, kCKTItemIdException);
    }

    NSDictionary *args = @{ @"itemId" : itemId, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(likeItemCompletion:) withObject:args];
}

- (void)markItemAsRead:(NSString *)convId
          creationTime:(NSNumber *)creationTime
            completion:(CompletionBlockWithNoData)completion
{
    if (!convId) {
        THROW_EXCEPTION(kCKTException, kCKTConversationIdException);
    }

    id creation = creationTime ? creationTime : [NSNull null];

    NSDictionary *args = @{ @"convId" : convId, @"creationTime" : creation, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(markItemAsReadCompletion:) withObject:args];
}

- (void)removeParticipant:(NSString *)convId userIds:(id)userIds completion:(CompletionBlockWithNoData)completion
{
    if (!convId) {
        THROW_EXCEPTION(kCKTException, kCKTConversationIdException);
    } else if (!userIds) {
        THROW_EXCEPTION(kCKTException, kCKTUserException);
    }

    NSDictionary *args = @{ @"convId" : convId, @"userIds" : userIds, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(removeParticipantCompletion:) withObject:args];
}

- (void)unflagItem:(NSString *)convId itemId:(NSString *)itemId completion:(CompletionBlockWithNoData)completion
{
    if (!convId) {
        THROW_EXCEPTION(kCKTException, kCKTConversationIdException);
    } else if (!itemId) {
        THROW_EXCEPTION(kCKTException, kCKTItemIdException);
    }

    NSDictionary *args = @{ @"convId" : convId, @"itemId" : itemId, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(unflagItemCompletion:) withObject:args];
}

- (void)unlikeItem:(NSString *)itemId completion:(CompletionBlockWithNoData)completion
{
    if (!itemId) {
        THROW_EXCEPTION(kCKTException, kCKTItemIdException);
    }

    NSDictionary *args = @{ @"itemId" : itemId, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(unlikeItemCompletion:) withObject:args];
}

- (void)updateTextItem:(NSDictionary *)content completion:(CompletionBlock)completion
{
    if (!content) {
        THROW_EXCEPTION(kCKTException, kCKTContentException);
    } else if (!content[@"itemId"]) {
        THROW_EXCEPTION(kCKTException, kCKTItemIdException);
    }

    NSDictionary *args = @{ @"content" : content, kJSEngineBlockArgName : completion };

    [self executeAsync:@selector(updateTextItemCompletion:) withObject:args];
}

#pragma mark - Private Methods

- (void)addParticipantCompletion:(NSDictionary *)args
{
    NSString *conversationId = args[@"convId"];
    NSArray *userIds = args[@"userIds"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *participantArgs = @[ conversationId, userIds ];

    [self executeFunction:@"addParticipant" args:participantArgs completionHandler:completion];
}

- (void)addTextItemCompletion:(NSDictionary *)args
{
    NSString *convId = args[@"convId"];
    NSArray *content = @[ args[@"content"] ];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    [self executeFunction:@"addTextItem" withId:convId args:content completionHandler:completion];
}

- (void)createCommunityCompletion:(NSDictionary *)args
{
    NSArray *participants = args[@"participants"];
    NSString *topic = args[@"topic"];
    NSString *description = args[@"description"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *communityArgs = @[ participants, topic, description ];

    [self executeFunction:@"createCommunity" args:communityArgs completionHandler:completion];
}

- (void)createCoferenceBridgeCompletion:(NSDictionary *)args
{
    NSString *topic = args[@"topic"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *bridgeArgs = @[ topic ];

    [self executeFunction:@"createConferenceBridge" args:bridgeArgs completionHandler:completion];
}

- (void)createConversationCompletion:(NSDictionary *)args
{
    NSString *function = args[@"function"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *conversationArgs = args[@"convArgs"];

    [self executeFunction:function args:conversationArgs completionHandler:completion];
}

- (void)flagItemCompletion:(NSDictionary *)args
{
    NSString *convId = args[@"convId"];
    NSString *itemId = args[@"itemId"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *flagArgs = @[ itemId ];

    [self executeFunction:@"flagItem" withId:convId args:flagArgs completionHandler:completion];
}

- (void)getConversationsCompletion:(NSDictionary *)args
{
    CompletionBlock completion = args[kJSEngineBlockArgName];

    [self executeFunction:@"getConversations" args:nil completionHandler:completion];
}

- (void)getConversationsWithOptionsCompletion:(NSDictionary *)args
{
    id direction = args[@"direction"] ? args[@"direction"] : [NSNull null];
    id timestamp = args[@"timestamp"] ? args[@"timestamp"] : [NSNull null];
    id numberOfConversations = args[@"numberOfConversations"] ? args[@"numberOfConversations"] : [NSNull null];
    id numberOfParticipants = args[@"numberOfParticipants"] ? args[@"numberOfParticipants"] : [NSNull null];

    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSDictionary *options = @{
        @"direction" : direction,
        @"timestamp" : timestamp,
        @"numberOfConversations" : numberOfConversations,
        @"numberOfParticipants" : numberOfParticipants
    };

    NSArray *optionsArray = @[ options ];

    [self executeFunction:@"getConversations" args:optionsArray completionHandler:completion];
}

- (void)getConversationFeedCompletion:(NSDictionary *)args
{
    NSString *convId = args[@"convId"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    id timestamp = args[@"timestamp"] ? args[@"timestamp"] : [NSNull null];
    id minTotalItems = args[@"minTotalItems"] ? args[@"minTotalItems"] : [NSNull null];
    id maxTotalUnread = args[@"maxTotalUnread"] ? args[@"maxTotalUnread"] : [NSNull null];
    id commentsPerThread = args[@"commentsPerThread"] ? args[@"commentsPerThread"] : [NSNull null];
    id maxUnreadPerThread = args[@"maxUnreadPerThread"] ? args[@"maxUnreadPerThread"] : [NSNull null];

    NSDictionary *options = @{
        @"timestamp" : timestamp,
        @"minTotalItems" : minTotalItems,
        @"maxTotalUnread" : maxTotalUnread,
        @"commentsPerThread" : commentsPerThread,
        @"maxUnreadPerThread" : maxUnreadPerThread
    };

    NSArray *feedArgs = @[ options ];

    [self executeFunction:@"getConversationFeed" withId:convId args:feedArgs completionHandler:completion];
}

- (void)getConversationItemsCompletion:(NSDictionary *)args
{
    NSString *convId = args[@"convId"];

    id direction = args[@"direction"] ? args[@"direction"] : [NSNull null];
    id creationTime = args[@"creationTime"] ? args[@"creationTime"] : [NSNull null];
    id modificationDate = args[@"modificationDate"] ? args[@"modificationDate"] : [NSNull null];
    id numberOfItems = args[@"numberOfItems"] ? args[@"numberOfItems"] : [NSNull null];

    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSDictionary *options = @{
        @"direction" : direction,
        @"creationTime" : creationTime,
        @"modificationDate" : modificationDate,
        @"numberOfItems" : numberOfItems
    };

    NSArray *itemsOptions = @[ options ];

    [self executeFunction:@"getConversationItems" withId:convId args:itemsOptions completionHandler:completion];
}

- (void)getConversationParticipantsCompletion:(NSDictionary *)args
{
    NSString *convId = args[@"convId"];

    id searchCriterias = args[@"searchCriterias"] ? args[@"searchCriterias"] : [NSNull null];
    id searchPointer = args[@"searchPointer"] ? args[@"searchPointer"] : [NSNull null];
    id pageSize = args[@"pageSize"] ? args[@"pageSize"] : [NSNull null];
    id includePresence = args[@"includePresence"] ? args[@"includePresence"] : [NSNull null];

    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSDictionary *options = @{
        @"searchCriterias" : searchCriterias,
        @"searchPointer" : searchPointer,
        @"pageSize" : pageSize,
        @"includePresence" : includePresence
    };

    NSArray *participantArgs = @[ options ];

    [self executeFunction:@"getConversationParticipants"
                   withId:convId
                     args:participantArgs
        completionHandler:completion];
}

- (void)getConversationDataCompletion:(NSDictionary *)args
{
    NSString *function = args[@"function"];
    NSString *convId = args[@"convId"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    if (convId) {
        [self executeFunction:function withId:convId args:nil completionHandler:completion];
    } else {
        [self executeFunction:function args:nil completionHandler:completion];
    }
}

- (void)getDirectConversationWithUserCompletion:(NSDictionary *)args
{
    NSString *query = args[@"query"];
    id createIfNotExists = args[@"create"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *convArgs = @[ query, createIfNotExists ];

    [self executeFunction:@"getDirectConversationWithUser" args:convArgs completionHandler:completion];
}

- (void)getItemByIdCompletion:(NSDictionary *)args
{
    NSString *itemId = args[@"itemId"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    [self executeFunction:@"getItemById" withId:itemId args:nil completionHandler:completion];
}

- (void)getItemsByThreadCompletion:(NSDictionary *)args
{
    NSString *convId = args[@"convId"];
    NSString *threadId = args[@"threadId"];

    id modificationDate = args[@"modificationDate"] ? args[@"modificationDate"] : [NSNull null];
    id creationDate = args[@"creationDate"] ? args[@"creationDate"] : [NSNull null];
    id direction = args[@"direction"] ? args[@"direction"] : [NSNull null];
    id number = args[@"number"] ? args[@"number"] : [NSNull null];

    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSDictionary *options = @{
        @"modificationDate" : modificationDate,
        @"creationDate" : creationDate,
        @"direction" : direction,
        @"number" : number
    };

    NSArray *itemArgs = @[ options ];

    [self executeFunction:@"getItemsByThread" withId:convId threadId:threadId args:itemArgs completion:completion];
}

- (void)likeItemCompletion:(NSDictionary *)args
{
    NSString *itemId = args[@"itemId"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *itemArgs = @[ itemId ];

    [self executeFunction:@"likeItem" args:itemArgs completionHandler:completion];
}

- (void)markItemAsReadCompletion:(NSDictionary *)args
{
    NSString *convId = args[@"convId"];
    id creationTime = args[@"creationTime"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *itemArgs = @[ creationTime ];

    [self executeFunction:@"markItemAsRead" withId:convId args:itemArgs completionHandler:completion];
}

- (void)removeParticipantCompletion:(NSDictionary *)args
{
    NSString *convId = args[@"convId"];
    id userIds = args[@"userIds"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    if ([userIds isKindOfClass:[NSArray class]]) {
        [self executeFunction:@"removeParticipant" withId:convId args:userIds completionHandler:completion];
    } else {
        NSArray *participantArgs = @[ userIds ];
        [self executeFunction:@"removeParticipant" withId:convId args:participantArgs completionHandler:completion];
    }
}

- (void)unflagItemCompletion:(NSDictionary *)args
{
    NSString *convId = args[@"convId"];
    NSString *itemId = args[@"itemId"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSArray *itemArgs = @[ itemId ];

    [self executeFunction:@"unflagItem" withId:convId args:itemArgs completionHandler:completion];
}

- (void)unlikeItemCompletion:(NSDictionary *)args
{
    NSString *itemId = args[@"itemId"];
    CompletionBlock completion = args[kJSEngineBlockArgName];

    [self executeFunction:@"unlikeItem" withId:itemId args:nil completionHandler:completion];
}

- (void)updateTextItemCompletion:(NSDictionary *)args
{
    NSString *itemId = args[@"itemId"];

    id contentType = args[@"contentType"] ? args[@"contentType"] : [NSNull null];
    id subject = args[@"subject"] ? args[@"subject"] : [NSNull null];
    id content = args[@"content"] ? args[@"content"] : [NSNull null];
    id attachments = args[@"attachments"] ? args[@"attachments"] : [NSNull null];

    CompletionBlock completion = args[kJSEngineBlockArgName];

    NSDictionary *options = @{
        @"itemId" : itemId,
        @"contentType" : contentType,
        @"subject" : subject,
        @"content" : content,
        @"attachments" : attachments
    };

    NSArray *itemArgs = @[ options ];

    [self executeFunction:@"updateTextItem" args:itemArgs completionHandler:completion];
}

@end

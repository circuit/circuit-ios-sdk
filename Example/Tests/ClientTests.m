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
//  ClientTests.m
//  CircuitSDK
//
//

#import <XCTest/XCTest.h>
#import "MockClient.h"

@interface ClientTests : XCTestCase

@property (nonatomic, strong) MockClient *mockClient;

@end

@implementation ClientTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _mockClient = [[MockClient alloc] init];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    _mockClient = nil;
}

- (void)testGetLoggedOnUser
{
    [_mockClient getLoggedOnUser:^(NSDictionary *data, NSError *error) {
        BOOL hasData = hasData ? error : data;
        XCTAssert(hasData, @"User data was not returned.");
    }];
}

- (void)testGetUserById
{
    NSString *userId = @"8e44f0089b076e18a718eb9ca3d94674";

    [_mockClient getUserById:userId
           completionHandler:^(NSDictionary *data, NSError *error) {
               BOOL hasData = hasData ? error : data;
               XCTAssert(hasData, @"User data was not returned.");
           }];
}

- (void)testGetConversations
{
    [_mockClient getConversations:^(NSArray *data, NSError *error) {
        BOOL hasData = hasData ? error : data;
        XCTAssert(hasData, @"Conversations were not returned.");
    }];
}

- (void)testGetConversationsWithOptions
{
    NSDictionary *options = @{ @"direction" : @"BEFORE", @"numberOfConversations" : @3 };

    [_mockClient getConversationsWithOptions:options
                           completionHandler:^(NSArray *data, NSError *error) {
                               BOOL hasData = hasData ? error : data;
                               XCTAssert(hasData, @"Conversations with the options specified were not returned.");
                           }];
}

- (void)testGetConversationItems
{
    NSString *convId = @"bed306cf766aac4f613e44e469abc285";

    [_mockClient getConversationItems:convId
                    completionHandler:^(NSArray *data, NSError *error) {
                        BOOL hasData = hasData ? error : data;
                        XCTAssert(hasData, @"Conversation items were not returned.");
                    }];
}

- (void)testGetConversationItemsWithOptions
{
    NSString *convId = @"bed306cf766aac4f613e44e469abc285";

    NSDictionary *options = @{ @"numberOfItems" : @2 };

    [_mockClient getConversationItemsWithOptions:convId
                                     convOptions:options
                               completionHandler:^(NSArray *data, NSError *error) {
                                   BOOL hasData = hasData ? error : data;
                                   XCTAssert(hasData, @"Conversation items with the given options was not returned.");
                               }];
}

- (void)testGetItemById
{
    NSString *itemId = @"59a814aa020a1b32c4674a5887a35022";

    [_mockClient getItemById:itemId
           completionHandler:^(NSDictionary *data, NSError *error) {
               BOOL hasData = hasData ? error : data;
               XCTAssert(hasData, @"Item by the given id has not been returned.");
           }];
}

- (void)testAddTextItem
{
    NSString *convId = @"bed306cf766aac4f613e44e469abc285";
    NSString *content = @"Sample content to add to the conv.";

    [_mockClient addTextItem:convId
                 textContent:content
           completionHandler:^(id convContent, NSError *error) {
               BOOL hasContent = hasContent ? error : convContent;
               XCTAssert(hasContent, @"Content was not added to the conversation by the given id.");
           }];
}

- (void)testCreateDirectConversation
{
    NSString *participantId = @"7e58d63b60197ceb55a1c487989a3720";
    [_mockClient createDirectConversation:participantId
                        completionHandler:^(NSDictionary *conversation, NSError *error) {
                            BOOL hasConversation = hasConversation ? error : conversation;
                            XCTAssert(hasConversation, @"Direct conversation was not created");
                        }];
}

- (void)testCreateGroupConversation
{
    NSArray *participantIds = @[
        @"24c9e15e52afc47c225b757e7bee1f9d",
        @"7e58d63b60197ceb55a1c487989a3720",
        @"92877af70a45fd6a2ed7fe81e1236b78",
        @"3f02ebe3d7929b091e3d8ccfde2f3bc6"
    ];
    NSString *title = @"Test Group Conversation";
    [_mockClient createGroupConversation:participantIds
                                   title:title
                       completionHandler:^(NSDictionary *conversation, NSError *error) {
                           BOOL hasConversation = hasConversation ? error : conversation;
                           XCTAssert(hasConversation, @"Group conversation was not created");
                       }];
}

- (void)testCreateOpenConversation
{
    NSArray *participantIds = @[
        @"24c9e15e52afc47c225b757e7bee1f9d",
        @"7e58d63b60197ceb55a1c487989a3720",
        @"92877af70a45fd6a2ed7fe81e1236b78",
        @"3f02ebe3d7929b091e3d8ccfde2f3bc6"
    ];
    NSString *title = @"Test Open Conversation";
    NSString *description = @"Description for conversation";
    [_mockClient createOpenConversation:participantIds
                                  title:title
                            description:description
                      completionHandler:^(NSDictionary *conversation, NSError *error) {
                          BOOL hasConversation = hasConversation ? error : conversation;
                          XCTAssert(hasConversation, @"Open conversation was not created");
                      }];
}

@end

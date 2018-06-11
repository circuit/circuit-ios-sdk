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
//  PubSubService.m
//  CircuitSDK
//
//

#import "CKTService.h"
#import "JSEngine.h"
#import "JSNotificationCenter.h"
#import "JSValue+an.h"
#import "Log.h"
#import "PubSubEvents.h"
#import "PubSubResults.h"
#import "PubSubService.h"

typedef void (^EventCallbackZeroArg)(JSValue *value);
typedef void (^EventCallbackOneArg)(JSValue *value);
typedef void (^EventCallbackTwoArgs)(JSValue *value1, JSValue *value2);

@interface PubSubService ()

@property (nonatomic, strong) NSArray *eventCallbacks;

@end

@implementation PubSubService

static NSString *LOG_TAG = @"[PubSubService]";

#pragma mark - Public interface

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initEventCallbacks];
    }
    return self;
}

// Add event listener for all events in PubSubEvents.h
- (NSInteger)subscribeAll
{
    // This method should only be called on the js thread, assert if otherwise
    NSAssert([NSThread currentThread] == [JSEngine sharedInstance].jsThread,
             @"This method should only be called on the js thread!");

    LOGD(LOG_TAG, @"subscribeAll");

    for (NSInteger i = 1; i < JSEventNumberOfEvents; i++) {
        [self subscribe:i];
    }

    return JSSuccess;
}

- (NSInteger)unsubscribeAll
{
    LOGD(LOG_TAG, @"unsubscribeAll");
    for (NSInteger i = 0; i < JSEventNumberOfEvents; i++) {
        [self unsubscribe:i];
    }
    return JSSuccess;
}

#pragma mark - Process received events (called from the business logic)

- (void)processReceivedEvent:(JSEvent)event data:(JSValue *)value
{
    NSString *notificationEvent = [self topicStringFromPublishedEvent:event];
    LOGI(LOG_TAG, @"processReceivedEvent (one argument) - received event (%@)", notificationEvent);

    // This method should only be called on the js thread, assert if otherwise.
    [self validateCurrentThread];

    @try {
        NSDictionary *pubDict = @{ CKTKeyEmpty : @"" };

        id data = [value an_dataFromJSValue];
        if (data == nil) {
            LOGE(LOG_TAG, @"Event %@ is supposed to have data, but doesn't", notificationEvent);
            return;
        }

        switch (event) {
            case JSEventBasicSearchResults:
            case JSEventCallEnded:
            case JSEventCallStatus:
            case JSEventCallIncoming:
            case JSEventConnectionStateChanged:
            case JSEventConversationCreated:
            case JSEventConversationUpdated:
            case JSEventItemAdded:
            case JSEventItemUpdated:
            case JSEventReconnectFailed:
            case JSEventRenewToken:
            case JSEventSessionExpires:
            case JSEventUserPresenceChanged:
            case JSEventUserSettingsChanged:
            case JSEventUserUpdated: {
                pubDict = @{KEY_EVENT_DATA : data};
                break;
            }
            default: {
                LOGD(LOG_TAG, @"Unsupported event: %@", notificationEvent);
            }
        }

        // Send the event to the other handlers and then send the notification
        [self processEvent:event withData:data andNotification:notificationEvent];
    }
    @catch (NSException *exception)
    {
        LOGE(LOG_TAG, @"Exception: %@", exception);
    }
}

#pragma mark - Internal methods

// Used when processing received events to validate the current thread is the jsThread
- (void)validateCurrentThread
{
    if ([JSEngine sharedInstance].jsThread && ![NSThread currentThread].isCancelled) {
        NSAssert([NSThread currentThread] == [JSEngine sharedInstance].jsThread,
                 @"This method should only be called on the js thread!");
    } else {
        // This is done in case we receive an event during stop/start the JSEngine e.g., jsThread is nil but JSRunLoop
        // has not yet stopped or jsThread is present but currentThread was the previously cancelled thread.
        NSAssert([[NSThread currentThread].name isEqualToString:kJSRunloopName],
                 @"This method should only be called on the (%@)", kJSRunloopName);
    }
}

- (void)subscribe:(JSEvent)event
{
    NSString *eventTopic = [self topicStringFromPublishedEvent:event];
    [self callFunction:@"addEventListener" withArguments:@[ eventTopic, self.eventCallbacks[event] ]];
}

- (void)unsubscribe:(JSEvent)event
{
    NSString *eventTopic = [self topicStringFromPublishedEvent:event];

    NSDictionary *dict = @{ @"topic" : eventTopic, @"callback" : self.eventCallbacks[event] };
    [self executeAsync:@selector(unsubscribeInternal:) withObject:dict];
}

- (void)unsubscribeInternal:(NSDictionary *)args
{
    [self callFunction:@"removeEventListener" withArguments:@[ args[@"topic"], args[@"callback"] ]];
}

- (void)processEvent:(JSEvent)event withData:(NSDictionary *)dict andNotification:(NSString *)notification
{
    if (notification) {
        [[JSEngine sharedInstance] sendNotification:notification userInfo:dict];
    }
}

- (void)processReceivedEvent:(JSEvent)event data1:(JSValue *)value1 data2:(JSValue *)value2
{
    NSString *notificationEvent = [self topicStringFromPublishedEvent:event];
    LOGI(LOG_TAG, @"processReceivedEvent (two arguments) - received event (%@)", notificationEvent);

    // This method should only be called on the js thread, assert if otherwise.
    [self validateCurrentThread];

    @try {
        id data1 = [value1 an_dataFromJSValue];
        id data2 = [value2 an_dataFromJSValue];

        if (data1 == nil) {
            LOGE(LOG_TAG, @"Event %@ is supposed to have at least one piece data, but doesn't", notificationEvent);
            return;
        }

        NSDictionary *pubDict;

        // This section handles events that have an optional second piece of data
        if (event == JSEventCallEnded) {
            // Check if this is a replaced call (a 1-2-1 call changed to a group call)
            NSNumber *callReplaced = @NO;
            if (data2) {
                callReplaced = (NSNumber *)data2;
            }
            pubDict = @{KEY_CALL : data1, KEY_CALL_REPLACED : callReplaced};
        }
        // Send the event to the other handlers and then send the notification
        [self processEvent:event withData:pubDict andNotification:notificationEvent];
    }
    @catch (NSException *exception)
    {
        JS_SERVICE_LOG_EXCEPTION(exception);
    }
}

- (void)initEventCallbacks
{
    self.eventCallbacks = @[
        [[self zeroArgBlockForEvent:JSEventUnknown] copy],
        [[self oneArgBlockForEvent:JSEventBasicSearchResults] copy],
        [[self oneArgBlockForEvent:JSEventCallEnded] copy],
        [[self oneArgBlockForEvent:JSEventCallIncoming] copy],
        [[self oneArgBlockForEvent:JSEventCallStatus] copy],
        [[self oneArgBlockForEvent:JSEventConnectionStateChanged] copy],
        [[self oneArgBlockForEvent:JSEventConversationCreated] copy],
        [[self oneArgBlockForEvent:JSEventConversationUpdated] copy],
        [[self oneArgBlockForEvent:JSEventItemAdded] copy],
        [[self oneArgBlockForEvent:JSEventItemUpdated] copy],
        [[self oneArgBlockForEvent:JSEventReconnectFailed] copy],
        [[self oneArgBlockForEvent:JSEventRenewToken] copy],
        [[self oneArgBlockForEvent:JSEventSessionExpires] copy],
        [[self oneArgBlockForEvent:JSEventUserPresenceChanged] copy],
        [[self oneArgBlockForEvent:JSEventUserSettingsChanged] copy],
        [[self oneArgBlockForEvent:JSEventUserUpdated] copy]
    ];
}

- (NSString *)topicStringFromPublishedEvent:(JSEvent)publishedEvent
{
    static NSArray *topics;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        topics = @[
            @"UNKNOWN",
            CKTNotificationBasicSearchResults,
            CKTNotificationCallEnded,
            CKTNotificationCallIncoming,
            CKTNotificationCallStatus,
            CKTNotificationConnectionStateChange,
            CKTNotificationConversationCreated,
            CKTNotificationConversationUpdated,
            CKTNotificationItemAdded,
            CKTNotificationItemUpdated,
            CKTNotificationReconnectFailed,
            CKTNotificationRenewToken,
            CKTNotificationSessionExpires,
            CKTNotificationUserPresenceChanged,
            CKTNotificationUserSettingsChanged,
            CKTNotificationUserUpdated
        ];
    });

    if ((publishedEvent > 0) && (publishedEvent < JSEventNumberOfEvents)) {
        return topics[publishedEvent];
    }

    LOGE(LOG_TAG, @"Invalid event id: %d", publishedEvent);
    return nil;
}

#pragma mark - Callback block creation helpers

- (EventCallbackZeroArg)zeroArgBlockForEvent:(JSEvent)event
{
    return ^(JSValue *value) { [self processReceivedEvent:event data:nil]; };
}

- (EventCallbackZeroArg)oneArgBlockForEvent:(JSEvent)event
{
    return ^(JSValue *value) { [self processReceivedEvent:event data:value]; };
}

- (EventCallbackTwoArgs)twoArgBlockForEvent:(JSEvent)event
{
    return ^(JSValue *value1, JSValue *value2) { [self processReceivedEvent:event data1:value1 data2:value2]; };
}
@end

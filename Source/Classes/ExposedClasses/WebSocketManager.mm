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
//  WebSocketManager.h
//  CircuitSDK
//

#import "WebSocketManager.h"

#import "CKTHttp.h"
#import "JSEngine.h"
#import "CKTLog.h"
#import "SocketRocket/SRWebSocket.h"

static const double ANSSocketConnectionTimeout = 30.0;
static const double ANSSocketPingTimeout = 5.0;
static const int ANSPongFailuresCountMax = 3;

@interface WebSocketManager ()<SRWebSocketDelegate>

@property (nonatomic, strong) NSThread *myThread;
@property BOOL prototypeSocket;

@property (nonatomic) SRWebSocket *srWebSocket;
@property (nonatomic) BOOL isExecuting;  // 1. set to YES once the socket is started
                                         // 2. set to NO, once it fails to open or it has been closed
                                         // 3. send out ping only if this flag is set to YES.

@property (nonatomic) BOOL waitingForPong;               // 1. set to YES when user requests ping
                                                         // 2. reset to NO upon pong response / timeout
                                                         // 3. used to handle the ping timeout.
@property (nonatomic, readonly, retain) NSError *error;  // currently error info is not being used but still keep it.

// Pong failure handling:
// - we increment the outstanding responses as soon as we attempt to send out a ping
// - this counter is reset upon receiving a pong / JSON message.
@property (nonatomic) NSInteger outstandingPongResponses;

@property (nonatomic) BOOL retryAfter500Error;

@end

@implementation WebSocketManager

@synthesize url = _url;
@synthesize error = _error;

static NSString *LOG_TAG = @"[WebSocket]";

// Data usage statistics
// Saved as static to aggregate data from all sockets we used since app started
unsigned long bytesSent;         // number of bytes sent
unsigned long bytesReceived;     // number of bytes received
unsigned int messagesSent;       // number of messages sent
unsigned int messagesReceived;   // number of messages received
unsigned int timesSocketOpened;  // number of times we opened the socket (indication of re-logins)

// Debug functions and variables
// Do not remove "#ifdef DEBUG" - they are not supposed to be available in production mode
#ifdef DEBUG
static WebSocketManager *currentSocket;

+ (void)close
{
    [currentSocket close];
}

#endif

+ (WebSocketManager *)createWebSocket:(NSString *)url
{
    @synchronized(self)
    {
        WebSocketManager *socketManager = [[WebSocketManager alloc] initWithUrl:url];
        LOGD(LOG_TAG, @"createWebSocket - WebSocketManager:%p SRWebSocket:%p", socketManager,
             socketManager.srWebSocket);

#ifdef DEBUG
        currentSocket = socketManager;
#endif

        [socketManager start];

        return socketManager;
    }
}

- (WebSocketManager *)initWithUrl:(NSString *)url
{
    if (self = [super init]) {
        _url = url;
        _isExecuting = NO;
        _waitingForPong = NO;
        _outstandingPongResponses = 0;
        _retryAfter500Error = YES;

        LOGI(LOG_TAG, @"Opening socket to URL %@", url);

        // When we have access/mock server two websockets are created: 1)api 2)/prototype
        // To avoid two notifications being sent to the application raise the event only for api websocket
        // HACK
        _prototypeSocket = ([self.url rangeOfString:@"api"].location == NSNotFound);

        [self allocWebSocket];

        self.myThread = [NSThread currentThread];
    }

    return self;
}

- (void)dealloc
{
    @synchronized(self)
    {
        LOGD(LOG_TAG, @"[%p] dealloc WebSocket is prototype = [%d]", self, self.prototypeSocket);
        // Sometimes WebSocket object can get deleted earlier than usual (i.e. before the onCloseEvent from socket
        // layer).

        self.srWebSocket = nil;
        [self clearJSReferences];
    }
}

- (BOOL)isConcurrent
{
    return YES;
}

- (void)start
{
    [self.srWebSocket performSelector:@selector(open) onThread:self.myThread withObject:nil waitUntilDone:NO];
    self.isExecuting = YES;
}

#pragma mark - Exposed Properties (Javascript callback setters/getters)

- (void)setOnopen:(JSValue *)onopen
{
    _onopenCallback = [self addJSReference:onopen];
}

- (JSValue *)onopen
{
    return _onopenCallback.value;
}

- (void)setOnclose:(JSValue *)onclose
{
    _oncloseCallback = [self addJSReference:onclose];
}

- (JSValue *)onclose
{
    return _oncloseCallback.value;
}

- (void)setOnmessage:(JSValue *)onmessage
{
    _onmessageCallback = [self addJSReference:onmessage];
}

- (JSValue *)onmessage
{
    return _onmessageCallback.value;
}

- (void)setOnerror:(JSValue *)onerror
{
    _onerrorCallback = [self addJSReference:onerror];
}

- (JSValue *)onerror
{
    return _onerrorCallback.value;
}

#pragma mark - Exposed Methods

- (void)close
{
    @synchronized(self)
    {
        if (self.srWebSocket)
            [self.srWebSocket close];
        else {
            // Socket has been already been closed / failed but application is requesting to close again.
            // -  Just report to the Business logic that socket has been closed.
            LOGW(LOG_TAG, @"[%p] close - srWebSocket is already closed", self);
            [self.onclose callWithArguments:@[]];
        }
    }
}

- (void)send:(NSString *)json
{
    // CALL_LOGGING_OPTIMIZATION
    // LOGD(LOG_TAG, @"send - message= %@",json);

    [self updateStatistics:YES numberOfBytes:json.length];

    LOGD(LOG_TAG, @"send - send WebSocket message");
    if (self.srWebSocket)
        [self.srWebSocket send:json];
    else
        LOGE(LOG_TAG, @"[%p] send - srWebSocket is null!", self);
}

- (void)ping
{
    // CALL_LOGGING_OPTIMIZATION
    // LOGD(LOG_TAG, @"send - message= %@",json);

    // Note that to simplify we hard-code the size of the ping message (it's define elsewhere)
    [self updateStatistics:YES numberOfBytes:8];

    if (_isExecuting && self.srWebSocket.readyState == SR_OPEN) {
        _waitingForPong = YES;
        [self.srWebSocket sendPing:nil];

        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, ANSSocketPingTimeout * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            if (_waitingForPong) {
                [self performSelector:@selector(callOnPingTimeout)
                             onThread:self.myThread
                           withObject:nil
                        waitUntilDone:NO];
            }
        });
    } else {
        LOGW(LOG_TAG, @"[%p] ping - srWebSocket is null!", self);
    }

    _outstandingPongResponses++;
}

#pragma mark - Internal methods to invoke JS callbacks

/*
 * In order to prevent Javascript from crashing during Garbage Collection we need to call the JS callbacks
 * on the same thread they were set i.e., the same thread the WebSocket was created on.
 */
- (void)callOnOpen
{
    timesSocketOpened++;

    LOGD(LOG_TAG, @"[%p] callOnOpen - number of sockets opened so far = %u", self, timesSocketOpened);

    [self.onopen callWithArguments:@[]];
    // Send the Event back to the Application
}

- (void)callOnClose
{
    LOGD(LOG_TAG, @"[%p] callOnClose", self);
    // Send the onClose event for the currently opened socket
    [self.onclose callWithArguments:@[]];

    // Do not reference the current socket anymore
    self.srWebSocket = nil;
    [self clearJSReferences];
}

- (void)callOnError
{
    // Send the onError event for the currently opened socket
    [self.onerror callWithArguments:@[]];
}

- (void)callOnMessage:(NSString *)message
{
    LOGD(LOG_TAG, @"[%p] callOnMessage", self);

    [self updateStatistics:NO numberOfBytes:message.length];

    NSDictionary *dict = @{
        @"size" : [NSNumber numberWithInteger:message.length],
        @"data" : message,
        @"type" : @"message"
    };

    [self.onmessage callWithArguments:@[ dict ]];

    self.outstandingPongResponses = 0;
}

- (void)callOnPingTimeout
{
    LOGD(LOG_TAG, @"[%p] callOnPingTimeout, count=%d", self, self.outstandingPongResponses);
    _waitingForPong = NO;

    if (self.outstandingPongResponses >= ANSPongFailuresCountMax) {
        LOGE(LOG_TAG, @"Closing socket - ping timeout counter threshold exceeded");
        [self performSelector:@selector(close) onThread:self.myThread withObject:nil waitUntilDone:NO];
    }
}

#pragma mark - SRWebSocketDelegate call backs

// message will either be an NSString if the server is using text
// or NSData if the server is using binary.
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    [self performSelector:@selector(callOnMessage:) onThread:self.myThread withObject:message waitUntilDone:NO];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    [self performSelector:@selector(callOnOpen) onThread:self.myThread withObject:nil waitUntilDone:NO];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    _error = error;

    _isExecuting = NO;

    LOGE(LOG_TAG, @"webSocket:didFailWithError - error:%@ retryAfter500Error: %d errorCode: %d", error,
         self.retryAfter500Error, error.code);

    if (self.retryAfter500Error && [error.userInfo[SRHTTPResponseErrorKey] intValue] == 500) {
        // 500 response generally indicates a transient error from a network element. An immediate retry
        // attempt might establish the socket connection. For incoming calls received through push,
        // we need socket immediately.
        // Server side components unavailablity is seen with 503, 504 responses. An immediate retry would
        // less likely to establish socket. These errors are propagated to application layer run retry logic
        [self performSelector:@selector(retryConnectionAfter500Error)
                     onThread:self.myThread
                   withObject:nil
                waitUntilDone:NO];
    } else {
        [self performSelector:@selector(callOnError) onThread:self.myThread withObject:nil waitUntilDone:NO];

        self.srWebSocket.delegate = nil;
        self.srWebSocket = nil;
        [self clearJSReferences];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket
    didCloseWithCode:(NSInteger)code
              reason:(NSString *)reason
            wasClean:(BOOL)wasClean
{
    _isExecuting = NO;

    LOGI(LOG_TAG, @"webSocket:didCloseWithCode - code:%d reason:%@ clean:%d", code, reason, wasClean);

    [self performSelector:@selector(callOnClose) onThread:self.myThread withObject:nil waitUntilDone:NO];

    self.srWebSocket.delegate = nil;
    self.srWebSocket = nil;
    [self clearJSReferences];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    // CALL_LOGGING_OPTIMIZATION
    // LOGI(LOG_TAG, @"webSocket:didReceivePong");

    @synchronized(self)
    {
        _waitingForPong = NO;

        _outstandingPongResponses = 0;
    }
}

#pragma mark - internal functions

- (void)allocWebSocket
{
    NSURL *socketURL = [NSURL URLWithString:_url];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:socketURL
                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                          timeoutInterval:ANSSocketConnectionTimeout];

    urlRequest.networkServiceType = NSURLNetworkServiceTypeVoIP;

    NSString *userAgent = [CKTHttp userAgent];
    [urlRequest setValue:userAgent forHTTPHeaderField:@"User-Agent"];

    self.srWebSocket =
        [[SRWebSocket alloc] initWithURLRequest:urlRequest protocols:nil allowsUntrustedSSLCertificates:YES];
    self.srWebSocket.requestCookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
    self.srWebSocket.delegate = self;
}

// retry logic is coded for SocketRocket only. WebSocket++ sockets will not be retried
- (void)retryConnectionAfter500Error
{
    LOGD(LOG_TAG, @"retrying the WebSocket connection after 500 response");

    self.retryAfter500Error = NO;  // Allow only once to retry the connection

    // Simply de-couple the current socket w/o sending any notification to upper layer
    self.srWebSocket.delegate = nil;
    self.srWebSocket = nil;
    [self clearJSReferences];

    // allocate new socket
    [self allocWebSocket];

    [self start];
}

// Updates and logs data usage statistics
// Notes:
//  1) We don't log statistics for every message to save log space and CPU time
//  2) We log string.length (on the caller side) instead of cStringUsingEncoding because that one
//     returns a char*, which would require a call to strlen to calculate the length (more time consuming)
- (void)updateStatistics:(BOOL)sent numberOfBytes:(unsigned long)bytes
{
    if (sent) {
        messagesSent++;
        bytesSent += bytes;
    } else {
        messagesReceived++;
        bytesReceived += bytes;
    }

    if (((messagesReceived + messagesSent) % 5) == 0) {
        LOGD(LOG_TAG, @"Statistics: messages received = %u, sent = %u, bytes received = %lu, sent = %lu - socket "
             @"opened %u time(s)",
             messagesReceived, messagesSent, bytesReceived, bytesSent, timesSocketOpened);
    }
}

// Check if we have a callback to keep track of. If we do, track it as a managed reference and return that reference.
// If there is no callback, return |nil| because there is nothing to called back later.
- (JSManagedValue *)addJSReference:(JSValue *)jsCallback
{
    if ([jsCallback isNull] || [jsCallback isUndefined]) {
        return nil;
    } else {
        JSManagedValue *managedValue = [JSManagedValue managedValueWithValue:jsCallback];
        [[JSEngine sharedInstance] addManagedReference:managedValue];
        return managedValue;
    }
}

- (void)clearJSReferences
{
    LOGD(LOG_TAG, @"clearJSReferences");

    if (_onopenCallback) {
        [[JSEngine sharedInstance] removeManagedReference:_onopenCallback];
        _onopenCallback = nil;
    } else if (_oncloseCallback) {
        [[JSEngine sharedInstance] removeManagedReference:_oncloseCallback];
        _oncloseCallback = nil;
    } else if (_onmessageCallback) {
        [[JSEngine sharedInstance] removeManagedReference:_onmessageCallback];
        _onmessageCallback = nil;
    } else if (_onerrorCallback) {
        [[JSEngine sharedInstance] removeManagedReference:_onerrorCallback];
        _onerrorCallback = nil;
    }
}

@end

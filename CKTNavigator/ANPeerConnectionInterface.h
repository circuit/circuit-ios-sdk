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
//  ANPeerConnectionInterface.h
//  CKTNavigator
//
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class ANRTCDTMFSender;
@class RTCAudioTrack;
@class RTCMediaStream;
@class RTCPeerConnection;
@class RTCSessionDescription;

// To supress the warning:
//   “used as the name of the previous parameter rather than as part of the selector”
// Comes from some lines like this one
//   - (void)success:(NSString *)message:(NSString *)title
// It can be suppressed by adding spaces, but our code formatter will remove those
// spaces and re-introduce the warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-selector-name"

@protocol ANPeerConnectionInterface<JSExport>

// Event handlers - initialized by JS rtcPeerConnection.js::registerEvtHandlers(pc)
@property (nonatomic, assign) JSValue* onicecandidate;
@property (nonatomic, assign) JSValue* onaddstream;
@property (nonatomic, assign) JSValue* onnegotiationneeded;
@property (nonatomic, assign) JSValue* onsignalingstatechange;
@property (nonatomic, assign) JSValue* onremovestream;
@property (nonatomic, assign) JSValue* oniceconnectionstatechange;

// Attributes
@property (nonatomic, assign) JSValue* startTime;  // non-standard - part of mockPeerConnection

@property (nonatomic, strong) NSMutableArray<RTCMediaStream*>* remoteStreams;

@property (nonatomic, strong) NSThread* myThread;

// Constructor
+ (RTCPeerConnection*)createRTCPeerConnection:(NSDictionary*)configuration:(NSDictionary*)constraints;

// Methods
- (void)addStream:(RTCMediaStream*)stream;
- (void)removeStream:(RTCMediaStream*)stream;
- (void)close;
- (void)createAnswer:(JSValue*)successCallback:(JSValue*)errorCallback:(NSDictionary*)constrains;
- (void)createOffer:(JSValue*)successCallback:(JSValue*)errorCallback:(NSDictionary*)constrains;
- (void)setLocalDescription:(RTCSessionDescription*)sdp:(JSValue*)successCallback:(JSValue*)errorCallback;
- (void)setRemoteDescription:(RTCSessionDescription*)sdp:(JSValue*)successCallback:(JSValue*)errorCallback;
- (void)addIceCandidateJS:(NSDictionary*)sdp;
- (NSArray*)getRemoteStreams;
- (NSArray*)getLocalStreams;
- (void)getStats:(JSValue*)statsCallback;
- (ANRTCDTMFSender*)createDTMFSender:(RTCAudioTrack*)audioTrack;

- (JSValue*)getLocalDescriptionJS;
- (JSValue*)getRemoteDescriptionJS;
- (JSValue*)getSignalingStateJS;
- (JSValue*)getIceConnectionStateJS;
- (JSValue*)getIceGatheringStateJS;

@end

#pragma clang diagnostic pop

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
//  Call.swift
//  SampleApp
//
//

import UIKit

enum CallState: String {
    case idle = "Idle"
    // Outgoing call states
    case initiated = "Initiated"
    case connecting = "Connecting"
    case delivered = "Delivered"
    case busy = "Busy"
    case offered = "Offered"
    // Failed call states
    case failed = "Failed"
    case transferFailed = "TransferFailed"
    // Incoming call states
    case ringing = "Ringing"
    case extendedRinging = "ExtendedRinging"
    // Established call states
    case active = "Active"
    case held = "Held"
    case holding = "Holding"
    case holdOnHold = "HoldOnHold"
    case parked = "Parked"
    case conference = "Conference"
    case conferenceHolding = "ConferenceHolding"
    // Remote calls
    case started = "Started"
    case activeRemote = "ActiveRemote"
    // Call has been terminated
    case terminated = "Terminated"
}

enum ConvType: String {
    case direct = "DIRECT"
    case group = "GROUP"
    case large = "LARGE"
    case community = "COMMUNITY"
}

struct Call {
    /// Current call Id
    var callId: String
    /// Conversation id of the current call
    var convId: String
    /// Type of the conversation
    var convType: ConvType
    /// Call state. Can be one of CallState
    var state: CallState

    init(callId: String, convId: String, convType: ConvType, state: CallState) {
        self.callId = callId
        self.convId = convId
        self.convType = convType
        self.state = state
    }
}

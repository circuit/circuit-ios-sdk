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
//  CallScreenManager.swift
//  SampleApp
//
//

import UIKit

class CallScreenManager: NSObject {

    static let sharedInstance = CallScreenManager()

    func prepereCallViewControllerForIncomingCall(call: Call,
                                                  delegate: CallViewControllerDelegate) -> CallViewController {
        let callViewController = CallViewController()
        callViewController.callDirection = .incoming
        callViewController.call = call
        callViewController.delegate = delegate
        return callViewController
    }

    func prepareCallViewControllerForOutgoingCall(conversation: Conversation,
                                                  delegate: CallViewControllerDelegate) -> CallViewController {
        let callViewController = CallViewController()
        callViewController.conversation = conversation
        callViewController.callDirection = .outgoing
        if conversation.type == "DIRECT" {
            // Show waiting participant answer the call animation
            callViewController.showWaitingParticipantToAnswerAnimation(show: true)
        }
        callViewController.delegate = delegate
        return callViewController
    }
}

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
//  CallViewController.swift
//  SampleApp
//
//

import UIKit
import CircuitSDK

protocol CallViewControllerDelegate: class {
    func callViewControllerDidEndCall()
    func callViewControllerDidEndCall(withError error: Error?)
}

class CallViewController: UIViewController {

    static let kLogTag = "CallViewController"
    weak var delegate: CallViewControllerDelegate?
    var conversation: Conversation? {
        didSet {
            guard let conversation = conversation else {
                ANSLoge(CallViewController.kLogTag, "Conversation is not set")
                    return
            }
            callDataSource.loadConversationAvatar(conversation: conversation) { [weak self] (imageView) in
                self?.callView?.setConversationImage(imageView)
                self?.loadTitleForConversation(conversation) { title in
                    DispatchQueue.main.async {
                        self?.callView?.setConversationName(title)
                    }
                }
            }
        }
    }
    var callDirection: CallDirection? {
        didSet {
            guard let callDirection = callDirection else {
                ANSLoge(CallViewController.kLogTag, "Call type is not set")
                return
            }
            callView = CallView(frame: view.frame, callType: callDirection)
            guard let callView = callView else {
                ANSLoge(CallViewController.kLogTag, "Faild to initiate call view")
                return
            }
            view.addSubview(callView)
        }
    }
    var callId: String?
    var call: Call? {
        didSet {
            guard let call = call else {
                ANSLoge(CallViewController.kLogTag, "Conversation ID is not provided")
                return
            }
            fetchConversation(convId: call.convId)
            callId = call.callId
            isDirectCall = call.convType == .direct
        }
    }
    var isDirectCall = true
    fileprivate let callDataSource = CallDataSource.sharedInstance
    fileprivate let client = CKTClient.sharedInstance()
    fileprivate var callView: CallView?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundColor()
        addEventObservers()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .none
    }

    // MARK: - Notifications

    fileprivate func addEventObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleEndCall(_:)),
                                               name: NSNotification.Name(rawValue: CKTNotificationCallEnded), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCallStatusChanged(_:)),
                                               name: NSNotification.Name(rawValue: CKTNotificationCallStatus), object: nil)
    }

    @objc func handleEndCall(_ notification: Notification) {
        guard let jsCall = notification.userInfo as? [String: AnyObject],
            let call = CallDataSource.sharedInstance.callObjectFromJSCall(jsCall),
            call.state == .terminated else {
                ANSLogd(CallViewController.kLogTag, "Skip notification")
                return
        }
        if call.convType == .direct && isDirectCall && call.callId == self.callId {
            delegate?.callViewControllerDidEndCall()
        } else if call.convType == .group && !isDirectCall {
            delegate?.callViewControllerDidEndCall()
        }
    }

    @objc func handleCallStatusChanged(_ notification: Notification) {
        guard let reason = notification.userInfo?["reason"] as? String,
            reason == "callStateChanged" else {
                ANSLogd(CallViewController.kLogTag, "Skip notification")
                return
        }
        guard let jsCall = notification.userInfo as? [String: AnyObject],
            let call = CallDataSource.sharedInstance.callObjectFromJSCall(jsCall),
            call.state == .active else {
                ANSLogd(CallViewController.kLogTag, "Skip notification")
                return
        }
        CKTAudioSessionManager.setAudioSessionEnabled(true)
        callView?.updateUIForCallEstablished()
        self.showWaitingParticipantToAnswerAnimation(show: false)
    }

    func showWaitingParticipantToAnswerAnimation(show: Bool) {
        callView?.showWaitingParticipantToAnswer(show)
    }

    // MARK: - Private methods

    fileprivate func fetchConversation(convId: String) {
        ConversationDataSource.sharedInstance.getConversationById(convId: convId) { [weak self] (conversation, error) in
            guard error == nil else {
                ANSLoge(ConversationsTableViewController.kLogTag, "Failed to get conversations with error \(error.debugDescription)")
                return
            }
            if let conversation = conversation {
                DispatchQueue.main.async {
                    self?.conversation = conversation
                }
            }
        }
    }

    fileprivate func loadTitleForConversation(_ conversation: Conversation, completion: @escaping (_ convTitle: String) -> Void) {
        if conversation.type == "DIRECT" {
            if let participantIds = conversation.userIds {
                let userId = participantIds.filter {
                    $0 != UserDataSource.currentUser.userId
                }
                UserDataSource.sharedInstance.getUser(userId[0], completion: { (user) in
                    completion(user.displayName ?? "")
                })
            }
        } else {
            completion(conversation.title ?? " ")
        }
    }

}

extension CallViewController: CallViewDelegate {

    func handleAnswerCallButtonTappedAction() {
        guard let callId = call?.callId else {
            self.delegate?.callViewControllerDidEndCall()
            Utils.showAlertAsync(controller: self, title: "Call error",
                                 message: "No callId provided")
            return
        }
        client?.answerCall(callId, mediaType: callDataSource.mediaType,
                completionHandler: { (error) in
                    if let error = error {
                        self.delegate?.callViewControllerDidEndCall()
                        Utils.showAlertAsync(controller: self, title: "Call error",
                                             message: error.localizedDescription)
                    }
        })
    }

    func handleEndCallButtonTappedAction() {
        guard let callId = callId else {
            return
        }
        if call?.convType == .direct {
            client?.endCall(callId, completion: { (error) in
                DispatchQueue.main.async {
                    self.delegate?.callViewControllerDidEndCall(withError: error)
                }
            })
        } else if call?.convType == .group {
            client?.leaveConference(call?.callId, completion: { (error) in
                DispatchQueue.main.async {
                    self.delegate?.callViewControllerDidEndCall(withError: error)
                }
            })
        }
    }
}

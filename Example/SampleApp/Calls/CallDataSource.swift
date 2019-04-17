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
//  CallDataSource.swift
//  SampleApp
//
//

import UIKit
import CircuitSDK

enum FetchCallDataError: Error {
    case getCallByCallIdExeption
    case getCallsExeption
}

class CallDataSource: NSObject {

    static let kLogTag = "CallDataSource"
    static let sharedInstance = CallDataSource()
    let mediaType = ["audio": true, "video": false]
    typealias callCompletion =  (_ callId: String?, _ error: Error?) -> Void
    typealias conferenceCompletion = (_ call: Call?, _ error: Error?) -> Void

    func loadConversationAvatar(conversation: Conversation, completion: @escaping (_ imageView: UIImageView) -> Void) {
        if conversation.type == "DIRECT" {
            if let participantIds = conversation.userIds {
                let userId = participantIds.filter { $0 != UserDataSource.currentUser.userId }
                guard let firstUserId = userId.first else {
                    ANSLoge(CallDataSource.kLogTag, "UserId is not provided")
                    return
                }
                UserDataSource.sharedInstance.getUser(firstUserId, completion: { [weak self] (user) in
                    if let url = user.avatarURL {
                        DispatchQueue.main.async {
                            self?.fetchConversationAvatar(url: url, completion: completion)
                        }
                    }
                })
            }
        } else {
            if let url = conversation.avatarURL {
                DispatchQueue.main.async {
                    self.fetchConversationAvatar(url: url, completion: completion)
                }
            }
        }
    }

    func makeDirectCall(conversation: Conversation, completion: @escaping callCompletion) {
        if let userIds = conversation.userIds {
            UserDataSource.sharedInstance.getUsersEmailsByIds(userIds) { (userEmails, error) in
                guard error == nil, let emils = userEmails else {
                    ANSLoge(CallDataSource.kLogTag,
                            "Failed to get email address due to \(error?.localizedDescription ?? "unknown issue")")
                    return
                }
                let filtered = emils.filter {$0 != UserDataSource.currentUser.emailAddress}
                CKTClient.sharedInstance().makeCall(filtered.first, mediaType: self.mediaType,
                                                    createIfNotExists: true) { [weak self] (call, error) in
                    self?.processDirectCallCompletion(call: call, error: error, completion: completion)
                }
            }
        }
    }

    func makeConferenceCall(conversation: Conversation, completion: @escaping conferenceCompletion) {
        CKTClient.sharedInstance().startConference(conversation.convId, mediaType: mediaType) { (error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            CKTClient.sharedInstance().getCalls({ (calls, error) in
                guard let callsArray = calls as [Any]? else {
                    completion(nil, FetchCallDataError.getCallsExeption)
                    return
                }
                for item in callsArray {
                    if let call = item as? [String: AnyObject] {
                        if let callData = self.callObjectFromDictionary(call) {
                            if callData.convId == conversation.convId {
                                completion(callData, nil)
                                break
                            }
                        }
                    } else {
                        completion(nil, FetchCallDataError.getCallsExeption)
                    }
                }
            })
        }
    }

    func joinConference(callId: String, completion: @escaping () -> Void) {
        CKTClient.sharedInstance().joinConference(callId, mediaType: mediaType, clientId: nil) {
            completion()
        }
    }

    func callObjectFromJSCall(_ jsCall: [AnyHashable: Any]) -> Call? {
        guard let callDict = jsCall["call"] as? [String: AnyObject],
            let call = callObjectFromDictionary(callDict) else {
            ANSLoge(CallDataSource.kLogTag, "Failed to parce notification")
            return nil
        }
        return call
    }

    func callObjectFromDictionary(_ call: [String: AnyObject]) -> Call? {
        guard let callId = call["callId"] as? String,
        let convId = call["convId"] as? String,
        let convTypeRawValue = call["convType"] as? String,
        let stateRawValue = call["state"] as? String,
        let convType = ConvType(rawValue: convTypeRawValue),
        let state = CallState(rawValue: stateRawValue) else {
            ANSLoge(CallDataSource.kLogTag, "Failed to parce call dictionary")
            return nil
        }
        return Call(callId: callId, convId: convId, convType: convType, state: state)
    }

    // MARK: - Private methods

    fileprivate func fetchConversationAvatar(url: URL, completion: @escaping (_ imageView: UIImageView) -> Void) {
        let conversationAvatar = UIImageView()
        conversationAvatar.setImage(url: url) { (result) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    completion(conversationAvatar)
                }
            case .failure(let error):
                ANSLoge(CallDataSource.kLogTag, "Failed to fetch conversation avatar due to \(error.localizedDescription)")
            }
        }
    }

    fileprivate func processDirectCallCompletion(call: [AnyHashable: Any]?, error: Error?, completion: callCompletion) {
        guard error == nil else {
            ANSLoge(CallDataSource.kLogTag, "Failed to make a call due to \(error.debugDescription)")
            completion(nil, error)
            return
        }
        // Obtaining callId
        if let callId = call?[AnyHashable("callId")] as? String {
            completion(callId, nil)
        }
    }
}

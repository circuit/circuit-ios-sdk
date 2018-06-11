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
//  UserDataSource.swift
//  SampleApp
//
//

import UIKit
import CircuitSDK

class UserDataSource {

    typealias userCompletion = (_ user: User) -> Void
    typealias avatarCompletion = (_ avatar: UIImage?, _ id: String) -> Void

    static let sharedInstance = UserDataSource()

    // Cache for user objects
    static var users = [String: User]()

    // Current user that is logged in. This is used for creating the DIRECT conversations.
    static var currentUser = User()

    /**
     Returns a user object based on the user id.

     - parameter userId: Id of the user object to be retrieved

     - returns: User object
     */
    func getUser(_ userId: String, completion: @escaping userCompletion) {
        if UserDataSource.users[userId] != nil {
            completion(UserDataSource.users[userId]!)
        } else {
            CKTClient().getUserById(userId) { (jsUser, error) in
                if error == nil {
                    self.userObjectFromJSUser(jsUser as AnyObject, completion: { (user) in
                        if user.userId != UserDataSource.currentUser.userId {
                            UserDataSource.users[userId] = user
                        }
                        completion(user)
                    })
                }
            }
        }
    }

    /**
     Returns a user object from the js user object

     - parameter user: JS user object

     - returns: user object
     */
    func userObjectFromJSUser(_ jsUser: AnyObject, completion: (User) -> Void) {

        var user = User()

        guard let userId = jsUser["userId"] as? String,
            let displayName = jsUser["displayName"] as? String,
            let avatarURLString = jsUser["avatar"] as? String else {
            return
        }

        if let userEmail = jsUser["emailAddress"] as? String {
            user.emailAddress = userEmail
        }

        user.userId = userId

        let avatarURL = URL(string: avatarURLString)
        user.avatarURL = avatarURL

        if displayName == "VGTC VGTC" {
            user.displayName = "Phone Calls"
        } else {
            user.displayName = displayName
        }

        completion(user)
    }

    enum FetchUserDataError: Error {
        case contentException
        case userEmailException
        case userIdException

    }

    /**
     Returns an array of usersIds based on provided array of emails

     - parameter emails: array of the emails

     - returns: array of the Ids
     */
    func getUsersIdsByEmails(_ emails: [String], completion: @escaping(_ usersIds: [String]?, _ error: Error?) -> Void) {
        var error: FetchUserDataError?
        CKTClient().getUsersByEmail(emails) { (users, _) in
            guard let usersJson = users as? [[String: Any]] else {
                error = .contentException
                completion(nil, error)
                return
            }
            if usersJson.count != emails.count {
                error = .userEmailException
                completion(nil, error)
            }
            var usersIds: [String] = []
            for userJson in usersJson {
                UserDataSource.sharedInstance.userObjectFromJSUser(userJson as AnyObject, completion: { user in
                    if let userId = user.userId {
                        usersIds.append(userId)
                    }
                })
            }
            completion(usersIds, error)
        }
    }

    /**
     Returns an array of users emails based on provided array of userIds

     - parameter userIds: array of the userIds

     - returns: array of the user emails
     */
    func getUsersEmailsByIds (_ userIds: [String], completion: @escaping(_ usersIds: [String]?, _ error: Error?) -> Void) {
        var error: FetchUserDataError?
        // Fetch users
        CKTClient().getUsersById(userIds, limited: true) { (users, _) in
            guard let usersJson = users as? [[String: Any]] else {
                error = .contentException
                completion(nil, error)
                return
            }
            if usersJson.count != userIds.count {
                error = .userIdException
                completion(nil, error)
            }
            var usersEmails: [String] = []
            for userJson in usersJson {
                self.userObjectFromJSUser(userJson as AnyObject, completion: { user in
                    if let usersEmail = user.emailAddress {
                        usersEmails.append(usersEmail)
                    }
                })
            }
            completion(usersEmails, error)
        }
    }
}

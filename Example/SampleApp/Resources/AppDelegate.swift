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
//  AppDelegate.swift
//  SampleApp
//
//

import UIKit
import AppAuth
import CircuitSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var currentAuthorizationFlow: OIDExternalUserAgentSession?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let client = CKTClient.sharedInstance()
        let clientID = "ADD CLIENT ID"
        let clientSecret = "ADD CLIENT SECRET"
        let scope = "ALL"

        // The example needs to be configured with your own client details.
        // See: https://github.com/circuit/circuit-ios-sdk/blob/master/README.md

        assert(clientID != "ADD CLIENT ID", "Update clientID with your own client ID." +
            "Instructions: https://github.com/circuit/circuit-ios-sdk/tree/master/Documentation")

        assert(clientSecret != "ADD CLIENT SECRET", "Update clientSecret with your own client secret." +
            "Instructions: https://github.com/circuit/circuit-ios-sdk/tree/master/Documentation")

        client?.initializeSDK(clientID, oAuthClientSecret: clientSecret, oAuthScope: scope)
        return true
    }

    /*

     Handles inbound URLs. Checks if the URL matches the redirect URI for a pending
     AppAuth authorization request.

     */
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {

        if currentAuthorizationFlow?.resumeExternalUserAgentFlow(with: url) != nil {
            currentAuthorizationFlow = nil
            return true
        }

        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

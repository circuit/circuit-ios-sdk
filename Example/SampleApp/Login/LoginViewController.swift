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
//  LoginViewController.swift
//  SampleApp
//
//

import UIKit
import AppAuth
import CircuitSDK

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var userData = [NSObject: AnyObject]()

    var authState: OIDAuthState?

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.hidesWhenStopped = true
        createUI()
    }

    func createUI() {

        loginButton.layer.cornerRadius = 15
        activityIndicator.activityIndicatorViewStyle = .white
    }

    /*
        OAuth 2.0 is used for authentication, the library used is AppAuth,
        more information can be found here: https://github.com/openid/AppAuth-iOS
    */
    @IBAction func onLogonButtonPressed(_ sender: UIButton) {
        activityIndicator.startAnimating()

        guard let client = CKTClient.sharedInstance(), let clientId = client.clientID, let clientSecret = client.clientSecret else { return }

        let entrypoint = "https://circuitsandbox.net/oauth"

        let authorizationEndpoint = URL(string: "\(entrypoint)/authorize")
        let tokenEndpoint = URL(string: "\(entrypoint)/token")
        let redirectURL = URL(string: "com.circuitkit.app:/oauthredirect")

        let configuration = OIDServiceConfiguration(authorizationEndpoint: authorizationEndpoint!, tokenEndpoint: tokenEndpoint!)

        let request = OIDAuthorizationRequest(configuration: configuration, clientId: clientId, clientSecret: clientSecret, scopes: [ "ALL" ], redirectURL: redirectURL!, responseType: OIDResponseTypeCode, additionalParameters: nil)

        let appDelegate = UIApplication.shared.delegate as? AppDelegate

        appDelegate!.currentAuthorizationFlow = OIDAuthState.authState(byPresenting: request, presenting: self, callback: { (state, error) in

            if state != nil {

                let accessToken = state?.lastTokenResponse?.accessToken

                CKTClient().logon(accessToken) { (jsUser, error) in
                    if error == nil {
                        DispatchQueue.main.async {
                            UserDataSource().userObjectFromJSUser(jsUser as AnyObject, completion: { (user) in
                                UserDataSource.currentUser = user
                            })
                            self.activityIndicator.stopAnimating()
                            self.performSegue(withIdentifier: "ConversationsViewSegue", sender: self)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }

            } else {
                print("Authorization error: \(String(describing: error))")
            }

        })

    }

}

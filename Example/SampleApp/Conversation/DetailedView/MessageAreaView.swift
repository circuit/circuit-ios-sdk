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
//  MessageAreaView.swift
//  SampleApp
//
//

import UIKit

@objc protocol MessageAreaViewDelegate {
    func handleSendMessageAction ()
    func handleAudioCallAction ()
}

class MessageAreaView: UIView {

    weak var delegate: MessageAreaViewDelegate?
    lazy var textInputField: UITextField = {
        let view = UITextField()
        view.placeholder = "Type text message here.."
        return view
    }()

    // MARK: - Private variables

    fileprivate let separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()

    fileprivate lazy var sendButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icon-button-send-new-normal"), for: .normal)
        button.addTarget(self.delegate, action: #selector(self.delegate?.handleSendMessageAction), for: .touchUpInside)
        return button
    }()

    fileprivate lazy var callButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icon-calling-active-call"), for: .normal)
        button.addTarget(self.delegate, action: #selector(self.delegate?.handleAudioCallAction), for: .touchUpInside)
        return button
    }()

    // MARK: - Class initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods
    fileprivate func setupViews() {
        addSubview(self.separatorLine)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        self.separatorLine.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        self.separatorLine.bottomAnchor.constraint(equalTo: topAnchor).isActive = true
        self.separatorLine.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        self.separatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true

        addSubview(self.callButton)
        callButton.translatesAutoresizingMaskIntoConstraints = false
        self.callButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        self.callButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.callButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        self.callButton.widthAnchor.constraint(equalToConstant: 40).isActive = true

        addSubview(self.sendButton)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton.rightAnchor.constraint(equalTo: callButton.leftAnchor, constant: -8).isActive = true
        self.sendButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.sendButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        self.sendButton.widthAnchor.constraint(equalToConstant: 40).isActive = true

        addSubview(self.textInputField)
        textInputField.translatesAutoresizingMaskIntoConstraints = false
        self.textInputField.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        self.textInputField.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        self.textInputField.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        self.textInputField.rightAnchor.constraint(equalTo: self.sendButton.leftAnchor).isActive = true
    }
}

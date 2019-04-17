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
//  CallView.swift
//  SampleApp
//
//

import UIKit
import CircuitSDK

@objc protocol CallViewDelegate {
    func handleEndCallButtonTappedAction()
    func handleAnswerCallButtonTappedAction()
}

enum CallDirection {
    case incoming
    case outgoing
}

class CallView: UIView {

    weak var delegate: CallViewDelegate?

    // MARK: - Private variables

    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .charcoalColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 100
        return view
    }()

    private var avatarView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .charcoalColor()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 100
        view.clipsToBounds = true
        return view
    }()

    private lazy var endCallButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .darkRed()
        button.setImage(UIImage(named: "icon-call-end-call-white"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 30
        button.addTarget(self.delegate, action: #selector(self.delegate?.handleEndCallButtonTappedAction), for: .touchUpInside)
        return button
    }()

    private lazy var answerCallButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .darkGreenColor()
        button.setImage(UIImage(named: "icon-call-answer-call-white"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 30
        button.addTarget(self.delegate, action: #selector(self.delegate?.handleAnswerCallButtonTappedAction), for: .touchUpInside)
        return button
    }()

    private var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 100
        blurView.clipsToBounds = true
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.alpha = 0.5
        return blurView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView.init(style: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        return activityIndicator
    }()

    private let conversationNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = NSTextAlignment.center
        label.numberOfLines = 2
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private var endCallButtonCenterXAnchor = [NSLayoutConstraint]() {
        willSet {
            NSLayoutConstraint.deactivate(endCallButtonCenterXAnchor)
        }
        didSet {
            NSLayoutConstraint.activate(endCallButtonCenterXAnchor)
        }
    }

    var startingConstraints = [NSLayoutConstraint]()

    // MARK: - Class initialization

    convenience init(frame: CGRect, callType: CallDirection) {
        self.init(frame: frame)
        setupViews()
        setCallTypeRelatedButtons(type: callType)
    }

    // MARK: - Public methods

    func setConversationImage(_ imageView: UIImageView?) {
        if let conversationImageView = imageView {
            avatarView.image = conversationImageView.image
        } else {
            ANSLogd("Avatar image is not set...", "")
            avatarView.image = UIImage(named: "icon-general-default-avatar")
        }
    }

    func setConversationName(_ name: String) {
        conversationNameLabel.text = name
        self.addSubview(conversationNameLabel)
        conversationNameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        conversationNameLabel.topAnchor.constraint(equalTo: self.borderView.bottomAnchor, constant: 16).isActive = true
        conversationNameLabel.widthAnchor.constraint(equalToConstant: CGFloat(self.frame.width * 0.8)).isActive = true
    }

    func updateUIForCallEstablished () {
        endCallButtonCenterXAnchor = [endCallButton.centerXAnchor.constraint(equalTo: borderView.centerXAnchor)]
        UIView.animate(withDuration: 0.3, animations: {
            self.answerCallButton.alpha = 0
            self.layoutIfNeeded()
        }) { _ in
            self.answerCallButton.removeFromSuperview()
        }
    }

    func showWaitingParticipantToAnswer(_ show: Bool) {
        if show {
            self.addSubview(blurView)
            blurView.heightAnchor.constraint(equalToConstant: 200).isActive = true
            blurView.widthAnchor.constraint(equalToConstant: 200).isActive = true
            blurView.centerXAnchor.constraint(equalTo: borderView.centerXAnchor).isActive = true
            blurView.centerYAnchor.constraint(equalTo: borderView.centerYAnchor).isActive = true

            self.addSubview(activityIndicator)
            activityIndicator.heightAnchor.constraint(equalToConstant: 200).isActive = true
            activityIndicator.widthAnchor.constraint(equalToConstant: 200).isActive = true
            activityIndicator.centerXAnchor.constraint(equalTo: borderView.centerXAnchor).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: borderView.centerYAnchor).isActive = true
        } else {
            UIView.animate(withDuration: 0.5) {
                self.blurView.removeFromSuperview()
                self.activityIndicator.removeFromSuperview()
            }
        }
    }

    // MARK: - Private methods

    fileprivate func setupViews() {

        self.addSubview(borderView)
        borderView.heightAnchor.constraint(equalToConstant: 208).isActive = true
        borderView.widthAnchor.constraint(equalToConstant: 208).isActive = true
        borderView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        borderView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -(self.frame.height/5)).isActive = true

        self.addSubview(avatarView)
        avatarView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        avatarView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        avatarView.centerXAnchor.constraint(equalTo: borderView.centerXAnchor).isActive = true
        avatarView.centerYAnchor.constraint(equalTo: borderView.centerYAnchor).isActive = true
    }

    fileprivate func setCallTypeRelatedButtons(type: CallDirection) {
        self.addSubview(endCallButton)
        endCallButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        endCallButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        endCallButton.centerYAnchor.constraint(equalTo: borderView.centerYAnchor, constant: self.frame.height/2).isActive = true

        switch type {
        case .incoming:
            endCallButtonCenterXAnchor = [endCallButton.centerXAnchor.constraint(equalTo: borderView.centerXAnchor, constant: -60)]
            self.addSubview(answerCallButton)
            answerCallButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
            answerCallButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
            answerCallButton.centerXAnchor.constraint(equalTo: borderView.centerXAnchor, constant: 60).isActive = true
            answerCallButton.centerYAnchor.constraint(equalTo: borderView.centerYAnchor, constant: self.frame.height/2).isActive = true
        case .outgoing:
            endCallButtonCenterXAnchor = [endCallButton.centerXAnchor.constraint(equalTo: borderView.centerXAnchor)]
        }
    }
}

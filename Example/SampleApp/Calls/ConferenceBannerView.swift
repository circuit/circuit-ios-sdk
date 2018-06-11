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
//  ConferenceBannerView.swift
//  SampleApp
//
//

import UIKit

@objc protocol ConferenceBannerViewDelegate {
    func handleTapActionPerformed ()
}

class ConferenceBannerView: UIView {

    private weak var delegate: ConferenceBannerViewDelegate?

    private let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to join conference"
        label.textColor = .white
        return label
    }()

    init(frame: CGRect, delegate: ConferenceBannerViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    fileprivate func setupViews() {
        backgroundColor = .darkCharcoalColor()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleSwipeAction))
        addGestureRecognizer(tap)

        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    @objc fileprivate func handleSwipeAction(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            delegate?.handleTapActionPerformed()
        }
    }
}

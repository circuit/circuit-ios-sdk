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
//  UIColor+SampleApp.swift
//  SampleApp
//
//

import UIKit

extension UIColor {

    static func backgroundColor() -> UIColor {
        return UIColor.init(red: 21/255, green: 22/255, blue: 33/255, alpha: 1.0)
    }

    static func darkRed() -> UIColor {
        return UIColor(red: 194.0/255, green: 32/255, blue: 38/255, alpha: 1.0)
    }

    static func darkGreenColor() -> UIColor {
        return UIColor(red: 136/255, green: 197/255, blue: 65/255, alpha: 1.0)
    }

    static func charcoalColor() -> UIColor {
        return UIColor(red: 82/255, green: 84/255, blue: 89/255, alpha: 1.0)
    }

    static func darkCharcoalColor() -> UIColor {
        return UIColor(red: 73/255, green: 77/255, blue: 82/255, alpha: 1.0)
    }
}

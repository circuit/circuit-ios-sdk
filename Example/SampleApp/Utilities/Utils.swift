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
//  ConversationUtils.swift
//  SampleApp
//
//

import UIKit

class Utils {

    typealias imageCompletion = (_ id: String, _ image: UIImage?) -> Void

    // Cache for user/conversation avatar images with key as image URL
    static var avatars = [URL: UIImage]()

    var formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        return dateFormatter
    }()

    func createDateFromUTC(_ time: NSNumber) -> Date {
        let timeInterval = time.doubleValue
        let creationDate = Date(timeIntervalSince1970: timeInterval / 1000)
        return creationDate
    }

    func createTimestampFromDate(_ date: Date) -> String {
        let timestamp = formatter.string(from: date)
        return timestamp
    }

    func contentOfConversationItem(_ item: AnyObject) -> String {
        var content = ""
        if let text = item["text"] as? NSDictionary {

            if let textContent = text["content"] as? String, !textContent.isEmpty {
                content = stringByDecodingHTMLEntities(escapedHtmlString: textContent)
                content = convertHtmlAsciiToUnicode(inputHtmlString: content)
            } else {
                if text["state"] as? String == "DELETED" {
                    content = "Message Deleted"
                }
            }

        // In the real app that uses Circuit SDK you may handle system / WebRTC state messages as you wish.
        // For example purposes, we simply display raw system message. Details can be found in documentation
        // or conversation item objects received from JS logic.
        } else if item["type"] as? String == "SYSTEM" {
            if let systemDict = item["system"] as? NSDictionary,
                let typeContent = systemDict["type"] as? String {
                content = typeContent
            }
        } else if item["type"] as? String == "RTC" {
            if let systemDict = item["rtc"] as? NSDictionary,
                let typeContent = systemDict["type"] as? String {
                content = typeContent
            }
        }

        return content
    }

    func convertHtmlAsciiToUnicode(inputHtmlString: String) -> String {
        var messageText = inputHtmlString
        let newLineUnicode = "\u{2028}"
        let newParagraphUnicode = "\u{2029}"

        // Replace paragraph tag with the paragraph unicode
        messageText = messageText.replacingOccurrences(of: "<hr\\s?\\/?>",
                                                       with: newParagraphUnicode,
                                                       options: [.regularExpression, .caseInsensitive],
                                                       range: nil)
        // Replace line breaks with new line unicode
        // We have three cases to cover:
        //   - ASCII \r\n
        //   - ASCII \n seem in some case
        //   - HTML <br>, <br/> or <br />
        messageText = messageText.replacingOccurrences(of: "(\\r\\n)|\\n|(<br\\s?\\/?>)",
                                                       with: newLineUnicode,
                                                       options: [.regularExpression, .caseInsensitive],
                                                       range: nil)
        return messageText
    }

    private let characterEntities: [String: Character ] = [
        // XML predefined entities:
        "&quot;": "\"",
        "&amp;": "&",
        "&apos;": "'",
        "&lt;": "<",
        "&gt;": ">",
        // HTML character entity references:
        "&nbsp;": "\u{00a0}",
        // ...
        "&diams;": "♦"
        ]

    func stringByDecodingHTMLEntities(escapedHtmlString: String) -> String {

        // Get out as soon as possible if there is no encoded character to convert
        if !escapedHtmlString.contains("&") {
            return escapedHtmlString
        }

        // Code below is adapted from https://stackoverflow.com/a/1453142

        // ===== Utility functions =====

        // Convert the number in the string to the corresponding
        // Unicode character, e.g.
        //    decodeNumeric("64", 10)   --> "@"
        //    decodeNumeric("20ac", 16) --> "€"
        func decodeNumeric(string: String, base: Int) -> Character? {
            guard let code = UInt32(string, radix: base),
                let uniScalar = UnicodeScalar(code) else { return nil }
            return Character(uniScalar)
        }

        // Decode the HTML character entity to the corresponding
        // Unicode character, return `nil` for invalid input.
        //     decode("&#64;")    --> "@"
        //     decode("&#x20ac;") --> "€"
        //     decode("&lt;")     --> "<"
        //     decode("&foo;")    --> nil
        func decode(entity: String) -> Character? {

            if entity.hasPrefix("&#x") || entity.hasPrefix("&#X") {
                return decodeNumeric(string: entity.substring(with: entity.index(entity.startIndex, offsetBy: 3) ..< entity.index(entity.endIndex, offsetBy: -1)), base: 16)
            } else if entity.hasPrefix("&#") {
                return decodeNumeric(string: entity.substring(with: entity.index(entity.startIndex, offsetBy: 2) ..< entity.index(entity.endIndex, offsetBy: -1)), base: 10)
            } else {
                return characterEntities[entity]
            }
        }

        // ===== Method starts here =====

        var result = ""
        var position = escapedHtmlString.startIndex

        // Find the next '&' and copy the characters preceding it to `result`:
        while let ampRange = escapedHtmlString.range(of: "&", range: position ..< escapedHtmlString.endIndex) {
            result.append(escapedHtmlString[position ..< ampRange.lowerBound])
            position = ampRange.lowerBound

            // Find the next ';' and copy everything from '&' to ';' into `entity`
            if let semiRange = escapedHtmlString.range(of: ";", range: position ..< escapedHtmlString.endIndex) {
                let entity = escapedHtmlString[position ..< semiRange.upperBound]
                position = semiRange.upperBound

                if let decoded = decode(entity: entity) {
                    // Replace by decoded character:
                    result.append(decoded)
                } else {
                    // Invalid entity, copy verbatim:
                    result.append(entity)
                }
            } else {
                // No matching ';'.
                break
            }
        }
        // Copy remaining characters to `result`:
        result.append(escapedHtmlString[position ..< escapedHtmlString.endIndex])
        return result
    }

}

//
//  JSONPrettyPrinter.swift
//  iOS Example
//
//  Created by Christopher de Haan on 19/08/2026.
//
//  Copyright © 2016-2026 Christopher de Haan <contact@christopherdehaan.me>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// Pretty-prints any decoded CDYelpFusionKit response as a JSON blob for on-screen display.
///
/// CDYelpFusionKit's response models are intentionally `Decodable`-only (they're read-only API
/// responses), so there's no built-in way to re-encode them. This walks the value via `Mirror`
/// and rebuilds a JSON-serializable representation instead.
enum JSONPrettyPrinter {

    static func string(from value: Any) -> String {
        let object = jsonValue(from: value)
        let topLevelObject: Any = (object is [String: Any] || object is [Any]) ? object : ["value": object]
        guard JSONSerialization.isValidJSONObject(topLevelObject),
              let data = try? JSONSerialization.data(withJSONObject: topLevelObject, options: [.prettyPrinted, .sortedKeys]),
              let text = String(data: data, encoding: .utf8) else {
            return String(describing: value)
        }
        return text
    }
}

private extension JSONPrettyPrinter {

    static func jsonValue(from value: Any) -> Any {
        let mirror = Mirror(reflecting: value)

        if mirror.displayStyle == .optional {
            guard let unwrapped = mirror.children.first?.value else {
                return NSNull()
            }
            return jsonValue(from: unwrapped)
        }

        switch value {
        case let string as String:
            return string
        case let bool as Bool:
            return bool
        case let int as Int:
            return int
        case let double as Double:
            return double
        case let float as Float:
            return Double(float)
        case let dictionary as [String: Any]:
            var result: [String: Any] = [:]
            for (key, element) in dictionary {
                result[key] = jsonValue(from: element)
            }
            return result
        case let array as [Any]:
            return array.map { jsonValue(from: $0) }
        default:
            break
        }

        guard let displayStyle = mirror.displayStyle,
              displayStyle == .struct || displayStyle == .class else {
            return String(describing: value)
        }

        var result: [String: Any] = [:]
        for child in mirror.children {
            guard let label = child.label else { continue }
            result[label] = jsonValue(from: child.value)
        }
        return result
    }
}

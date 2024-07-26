//
//  JSONDecoder+Extensions.swift
//  Test R&M
//
//  Created by Michael Grigoryan on 23.07.24.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static let iso8601withOptionalFractionalSeconds = custom {
        let string = try $0.singleValueContainer().decode(String.self)
        do {
            return try .init(string, strategy: .iso8601withFractionalSeconds)
        } catch {
            return try .init(string, strategy: .iso8601)
        }
    }
}

extension ParseStrategy where Self == Date.ISO8601FormatStyle {
    static var iso8601withFractionalSeconds: Self { .init(includingFractionalSeconds: true) }
}

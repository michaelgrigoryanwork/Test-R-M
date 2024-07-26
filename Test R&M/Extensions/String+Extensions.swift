//
//  String+Extensions.swift
//  Test R&M
//
//  Created by Michael Grigoryan on 23.07.24.
//

import Foundation

extension String {
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}

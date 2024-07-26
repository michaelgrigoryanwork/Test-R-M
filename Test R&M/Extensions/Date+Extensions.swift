//
//  Date+Extensions.swift
//  Test R&M
//
//  Created by Michael Grigoryan on 23.07.24.
//

import Foundation

extension Date {
    func toString(dateFormat: DateFormat) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        return dateFormatter.string(from: self)
    }
}

extension Date {
    enum DateFormat: String {
        case created = "dd/MM/yyyy"
    }
}

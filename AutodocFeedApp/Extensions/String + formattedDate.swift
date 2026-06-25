//
//  String + formattedDate.swift
//  AutodocFeedApp
//
//  Created by nikita on 22.06.2026.
//

import Foundation

enum DateDisplayFormat {
    
    case userFormat

    fileprivate var formatter: DateFormatter {
        switch self {
        case .userFormat: return Self.userFormatter
        }
    }

    private static let userFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy 'г.'"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
}

extension String {

    private static let inputFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        return formatter
    }()

    func formattedDate(as format: DateDisplayFormat) -> String? {
        guard let date = String.inputFormatter.date(from: self)
        else { return nil }
        return format.formatter.string(from: date)
    }
}

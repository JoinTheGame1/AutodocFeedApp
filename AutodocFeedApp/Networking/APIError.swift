//
//  APIError.swift
//  AutodocFeedApp
//
//  Created by nikita on 21.06.2026.
//

import Foundation

enum APIError: Error {
    
    case invalidUrl
    case badResponse
    case serverError(statusCode: Int)
    
    var description: String {
        let defaultMessage = "Не удалось"
        let additionalMessage: String = {
            switch self {
            case .invalidUrl: " получить ссылку"
            case .badResponse: " получить данные"
            case .serverError(let statusCode): " получить ответ от сервера. Ошибка \(statusCode)"
            }
        }()
        
        return defaultMessage + additionalMessage
    }
}

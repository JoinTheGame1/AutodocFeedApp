//
//  NewsAPI.swift
//  AutodocFeedApp
//
//  Created by nikita on 20.06.2026.
//

import Foundation

enum NewsAPI {
    
    // MARK: - Properties
    static let baseUrl = URL(string: "https://webapi.autodoc.ru")
    
    // MARK: - Internal methods
    
    static func url(from urlString: String?) -> URL? {
        guard let urlString else { return nil }
        return URL(string: urlString)
    }
    
    static func fetchPage(page: Int, count: Int) -> URL? {
        baseUrl?.appending(path: "api/news/\(page)/\(count)")
    }
}

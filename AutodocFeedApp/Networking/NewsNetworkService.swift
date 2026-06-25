//
//  NewsNetworkService.swift
//  AutodocFeedApp
//
//  Created by nikita on 20.06.2026.
//

import Foundation
import Combine

protocol NewsNetworkServiceProtocol {
    func fetchNewsPage(page: Int, count: Int) async -> Result<NewsResponse, APIError>
}

final class NewsNetworkService: NewsNetworkServiceProtocol {
    
    // MARK: - Properties
    
    private let session: URLSession
    private let decoder: JSONDecoder = .init()
    
    // MARK: - Init
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    // MARK: - Internal methods
    
    func fetchNewsPage(
        page: Int,
        count: Int
    ) async -> Result<NewsResponse, APIError> {
        
        guard let url = NewsAPI.fetchPage(page: page, count: count)
        else { return .failure(.invalidUrl) }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let http = response as? HTTPURLResponse
            else { return .failure(.badResponse) }
            guard 200..<300 ~= http.statusCode
            else { return .failure(.serverError(statusCode: http.statusCode)) }
            
            let decoded = try decoder.decode(NewsResponse.self, from: data)
            return .success(decoded)
        } catch {
            return .failure(.badResponse)
        }
    }
}

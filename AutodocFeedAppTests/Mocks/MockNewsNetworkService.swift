//
//  MockNewsNetworkService.swift
//  AutodocFeedAppTests
//
//  Created by nikita on 25.06.2026.
//

import Testing
@testable import AutodocFeedApp

final class MockNewsNetworkService: NewsNetworkServiceProtocol {
    
    // MARK: - Properties
    
    var result: Result<NewsResponse, APIError> = .success(.init(news: [], totalCount: 0))
    private(set) var requestedPages: [Int] = []
    
    // MARK: - Methods
    
    func fetchNewsPage(
        page: Int,
        count: Int
    ) async -> Result<NewsResponse, APIError> {
        requestedPages.append(page)
        return result
    }
}

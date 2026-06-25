//
//  NewsViewModel.swift
//  AutodocFeedApp
//
//  Created by nikita on 22.06.2026.
//

import Foundation
import Combine

final class NewsViewModel {
    
    // MARK: - Properties
    
    private let networkService: NewsNetworkServiceProtocol
    
    @Published private(set) var news: [News] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: APIError?
    
    private var nextPage: Int = 1
    private let requestedPagesCount: Int = 15
    private var allPagesLoaded: Bool = false
    
    // MARK: - Init
    
    init(networkService: NewsNetworkServiceProtocol = NewsNetworkService()) {
        self.networkService = networkService
    }
    
    // MARK: - Internal methods
    
    func loadNextPage() {
        guard !isLoading, !allPagesLoaded else { return }
        
        isLoading = true
        Task {
            do {
                let response = try await networkService.fetchNewsPage(
                    page: nextPage,
                    count: requestedPagesCount
                )
                
                switch response {
                case .success(let data):
                    self.setNewPage(data)
                case .failure(let error):
                    self.error = error
                }
            } catch {
                self.error = .badResponse
            }
            
            isLoading = false
        }
    }
    
    // MARK: - Private methods
    
    private func setNewPage(_ page: NewsResponse) {
        self.news.append(contentsOf: page.news)
        self.nextPage += 1
        self.allPagesLoaded = self.news.count >= page.totalCount
    }
}

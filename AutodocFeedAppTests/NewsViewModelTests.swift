//
//  NewsViewModelTests.swift
//  AutodocFeedAppTests
//
//  Created by nikita on 20.06.2026.
//

import Testing
@testable import AutodocFeedApp

struct NewsViewModelTests {
    
    // MARK: - Static properties
    
    private static let asyncDefaultDelay: Duration = .milliseconds(50)
    private static let totalPagesCount: Int = 10
    
    // MARK: - Factory methods
    
    private func makeResponse(
        _ news: [News],
        totalCount: Int = Self.totalPagesCount
    ) -> NewsResponse {
        .init(news: news, totalCount: totalCount)
    }
    
    private func makeNews(id: Int) -> News {
        .init(
            id: id,
            title: "Jeep Cherokee Trailhawk: первый тизер",
            description: "Jeep продолжает постепенно раскрывать детали нового поколения Cherokee",
            url: "avto-novosti/jeep_trailhawk_teaser",
            fullUrl: "https://www.autodoc.ru/company/news/avto-novosti/jeep_trailhawk_teaser",
            category: "Автомобильные новости",
            imageUrl: "https://file.autodoc.ru/news/avto-novosti/3355565484_1.jpg",
            publishedDate: "2026-06-23T00:00:00"
        )
    }
    
    private func makeSUT(
        result: Result<NewsResponse, APIError>
    ) -> (viewModel: NewsViewModel, mock: MockNewsNetworkService) {
        let mock = MockNewsNetworkService()
        mock.result = result
        let viewModel = NewsViewModel(networkService: mock)
        return (viewModel, mock)
    }
    
    // MARK: - Tests
    
    @Test("Новости успешно загружаются")
    func loadsNewsOnSuccess() async throws {
        let result: Result<NewsResponse, APIError> = .success(makeResponse([makeNews(id: 0), makeNews(id: 1)]))
        let (viewModel, _) = makeSUT(result: result)
        viewModel.loadNextPage()
        try await Task.sleep(for: Self.asyncDefaultDelay)
        
        #expect(viewModel.news.count == 2)
        #expect(viewModel.isLoading == false)
    }
    
    @Test("Вторая страница корректно добавляется")
    func appendsSecondPage() async throws {
        let result: Result<NewsResponse, APIError> = .success(makeResponse([makeNews(id: 0)]))
        let (viewModel, mock) = makeSUT(result: result)
        viewModel.loadNextPage()
        try await Task.sleep(for: Self.asyncDefaultDelay)
        
        mock.result = .success(makeResponse([makeNews(id: 1)]))
        viewModel.loadNextPage()
        try await Task.sleep(for: Self.asyncDefaultDelay)

        #expect(viewModel.news.count == 2)
        #expect(mock.requestedPages == [1, 2])
    }

    @Test("Ошибка сети выставляет error и сбрасывает isLoading")
    func setsErrorOnFailure() async throws {
        let result: Result<NewsResponse, APIError> = .failure(.badResponse)
        let (viewModel, _) = makeSUT(result: result)

        viewModel.loadNextPage()
        try await Task.sleep(for: Self.asyncDefaultDelay)

        #expect(viewModel.error != nil)
        #expect(viewModel.isLoading == false)
    }

    @Test("Повторная загрузка после того, как был достигнут конец ленты, не делает запрос")
    func stopsWhenAllLoaded() async throws {
        let result: Result<NewsResponse, APIError> = .success(makeResponse(
            [makeNews(id: 0)],
            totalCount: 1
        ))
        let (viewModel, mock) = makeSUT(result: result)

        viewModel.loadNextPage()
        try await Task.sleep(for: Self.asyncDefaultDelay)
        viewModel.loadNextPage()
        try await Task.sleep(for: Self.asyncDefaultDelay)

        #expect(mock.requestedPages == [1])
        #expect(viewModel.news.count == 1)
    }
}

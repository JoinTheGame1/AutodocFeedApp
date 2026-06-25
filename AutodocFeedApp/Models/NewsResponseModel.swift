//
//  NewsResponseModel.swift
//  AutodocFeedApp
//
//  Created by nikita on 20.06.2026.
//

import Foundation

struct NewsResponse: Decodable {
    let news: [News]
    let totalCount: Int
}

struct News: Decodable, Hashable {
    
    let id: Int
    let title: String
    let description: String
    let url: String
    let fullUrl: String
    let category: String
    
    var publishedDate: String? { rawPublishedDate?.formattedDate(as: .userFormat) }
    var imageUrl: URL? { NewsAPI.url(from: rawImageUrl) }
    
    private let rawImageUrl: String?
    private let rawPublishedDate: String?
    
    init(
        id: Int,
        title: String,
        description: String,
        url: String,
        fullUrl: String,
        category: String,
        imageUrl: String?,
        publishedDate: String?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.url = url
        self.fullUrl = fullUrl
        self.category = category
        self.rawImageUrl = imageUrl
        self.rawPublishedDate = publishedDate
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, url, fullUrl
        case rawPublishedDate = "publishedDate"
        case rawImageUrl = "titleImageUrl"
        case category = "categoryType"
    }
}

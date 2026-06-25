//
//  ImageLoader.swift
//  AutodocFeedApp
//
//  Created by nikita on 22.06.2026.
//

import UIKit

actor ImageLoader {
    
    private enum CacheItem {
        case inProgress(Task<UIImage, Error>)
        case loaded(UIImage)
    }
    
    // MARK: - Properties
    
    static let shared: ImageLoader = .init()
    
    private let memoryCache = NSCache<NSURL, UIImage>()
    private let diskCache: DiskImageCache
    private var items: [URL: CacheItem] = [:]
    
    // MARK: - Init
    
    init(diskCache: DiskImageCache = .init()) {
        self.diskCache = diskCache
    }
    
    // MARK: - Internal methods
    
    func image(from url: URL) async throws -> UIImage {
        
        if let item = items[url] {
            switch item {
            case .inProgress(let task):
                return try await task.value
            case .loaded(let image):
                return image
            }
        }
        
        if let cached = memoryCache.object(forKey: url as NSURL) {
            items[url] = .loaded(cached)
            return cached
        }
        
        if let image = await diskCache.image(from: url) {
            store(image, for: url)
            return image
        }
        
        let task = Task<UIImage, Error> {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = UIImage(data: data)
            else { throw APIError.badResponse }
            
            await diskCache.store(data, for: url)
            return image
        }
        
        items[url] = .inProgress(task)
        
        do {
            let image = try await task.value
            store(image, for: url)
            return image
        } catch {
            items[url] = nil
            throw error
        }
    }
    
    // MARK: - Private methods
    
    private func store(_ image: UIImage, for url: URL) {
        memoryCache.setObject(image, forKey: url as NSURL)
        items[url] = .loaded(image)
    }
}

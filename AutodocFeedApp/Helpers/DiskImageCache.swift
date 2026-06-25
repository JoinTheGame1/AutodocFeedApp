//
//  DiskImageCache.swift
//  AutodocFeedApp
//
//  Created by nikita on 23.06.2026.
//

import UIKit
import CryptoKit

actor DiskImageCache {
    
    // MARK: - Properties
    
    private let directory: URL
    private let fileManager = FileManager.default
    
    // MARK: - Init
    
    init(folderName: String = "ImagesCache") {
        let fileManager = FileManager.default
        let caches = fileManager.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first ?? fileManager.temporaryDirectory
        self.directory = caches.appendingPathComponent(folderName, isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }
    
    // MARK: - Internal methods
    
    func image(from url: URL) -> UIImage? {
        let path = hashedFileUrl(url)
        guard let data = try? Data(contentsOf: path) else { return nil }
        return UIImage(data: data)
    }
    
    func store(_ data: Data, for url: URL) {
        try? data.write(to: hashedFileUrl(url))
    }
    
    // MARK: - Private methods
    
    private func hashedFileUrl(_ url: URL) -> URL {
        let hash = SHA256.hash(data: Data(url.absoluteString.utf8))
        let hashString = hash.map { String(format: "%02x", $0) }.joined()
        return directory.appendingPathComponent(hashString)
    }
}

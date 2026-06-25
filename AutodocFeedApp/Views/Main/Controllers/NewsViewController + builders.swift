//
//  NewsViewController + builders.swift
//  AutodocFeedApp
//
//  Created by nikita on 22.06.2026.
//

import UIKit

extension NewsViewController {
    func makeLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let isWide = layoutEnvironment.traitCollection.horizontalSizeClass == .regular
            let columns = isWide ? 2 : 1
            let horizontalPadding: CGFloat = isWide ? .small : .zero
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                heightDimension: .estimated(300)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = .init(
                top: .zero,
                leading: horizontalPadding,
                bottom: .zero,
                trailing: horizontalPadding
            )
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(300)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                repeatingSubitem: item,
                count: columns
            )
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = .medium
            
            return section
        }
    }
    
    func makeDataSource() -> DataSource {
        DataSource(
            collectionView: self.collectionView
        ) { [weak self] collectionView, indexPath, news in
            guard let self else { return UICollectionViewCell() }
            return collectionView.dequeueConfiguredReusableCell(
                using: self.cellRegistration,
                for: indexPath,
                item: news
            )
        }
    }
}

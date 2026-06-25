//
//  NewsViewController.swift
//  AutodocFeedApp
//
//  Created by nikita on 20.06.2026.
//

import UIKit
import Combine
import SafariServices

enum Section: Hashable {
    case main
}

final class NewsViewController: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, News>
    typealias CellRegistration = UICollectionView.CellRegistration<NewsCollectionViewCell, News>
    
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    private let viewModel = NewsViewModel()
    private let defaultTitle = "AUTODOC"
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: makeLayout()
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        return collectionView
    }()
    
    let cellRegistration: CellRegistration = .init { cell, _, news in
        cell.configure(with: news)
    }
    
    private lazy var dataSource: DataSource = makeDataSource()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribe()
        viewModel.loadNextPage()
    }

    // MARK: - Private methods
    
    private func setupUI() {
        title = defaultTitle
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func subscribe() {
        viewModel.$news
            .receive(on: DispatchQueue.main)
            .sink { [weak self] news in
                self?.updateNews(with: news)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.updateLoadingState(isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }
    
    private func updateNews(with news: [News]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, News>()
        snapshot.appendSections([.main])
        snapshot.appendItems(news, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    private func updateLoadingState(_ isLoading: Bool) {
        if isLoading, viewModel.news.isEmpty {
            self.loadingIndicator.startAnimating()
        } else {
            self.loadingIndicator.stopAnimating()
        }
    }
    
    private func showError(_ error: APIError) {
        let alert = UIAlertController(
            title: "Что-то пошло не так...",
            message: error.description,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.viewModel.loadNextPage()
        })
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
    
    private func openNews(_ news: News) {
        let remoteSchemes = ["http", "https"]
        guard let url = URL(string: news.fullUrl),
              let scheme = url.scheme,
              remoteSchemes.contains(scheme)
        else { return }
        
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let safari = SFSafariViewController(url: url, configuration: config)
        present(safari, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension NewsViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let news = dataSource.itemIdentifier(for: indexPath)
        else { return }
        openNews(news)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let threshold = viewModel.news.count - 5
        if indexPath.item >= threshold {
            viewModel.loadNextPage()
        }
    }
}

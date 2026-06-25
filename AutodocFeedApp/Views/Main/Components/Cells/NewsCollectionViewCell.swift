//
//  NewsCollectionViewCell.swift
//  AutodocFeedApp
//
//  Created by nikita on 22.06.2026.
//

import UIKit

final class NewsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    let labelMaxLines: Int = 2
    
    private lazy var containerView: UIView = makeBackgroundView()
    
    private lazy var contentStackView: UIStackView = makeStackView(
        subviews: [imageView, textStackView, bottomStackView]
    )
    
    private lazy var textStackView: UIStackView = makeStackView(
        subviews: [titleLabel, descriptionLabel],
        spacing: .small
    )
    
    private var imageTask: Task<Void, Never>?
    private lazy var imageView: UIImageView = makeImageView()
    private let imageAspectRatio: CGFloat = 9.0 / 16.0
    private let landscapeImageMaxHeight: CGFloat = 200
    private var imageMaxHeightConstraint: NSLayoutConstraint?
    private var imageAspectConstraint: NSLayoutConstraint?
    private let imagePlaceholder: UIImage? = .init(
        systemName: "photo",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .light)
    )
    
    private lazy var titleLabel: UILabel = makeLabel()
    private lazy var descriptionLabel: UILabel = makeLabel(
        textColor: .secondaryLabel,
        font: .systemFont(ofSize: 13, weight: .regular)
    )
    
    private lazy var bottomStackView: UIStackView = makeStackView(
        subviews: [categoryBadge, publishedDateLabel],
        axis: .horizontal,
        distribution: .equalSpacing,
    )
    
    private lazy var categoryBadge: PaddedLabel = makeBadge()
    
    private lazy var publishedDateLabel: UILabel = makeLabel(
        textColor: .secondaryLabel,
        font: .systemFont(ofSize: 13)
    )
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.15) {
                self.containerView.alpha = self.isHighlighted ? 0.6 : 1.0
                self.containerView.transform = self.isHighlighted
                ? CGAffineTransform(scaleX: 0.98, y: 0.98)
                : .identity
            }
        }
    }
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        showPlaceholder()
        imageTask?.cancel()
        imageTask = nil
        
        titleLabel.text = nil
        descriptionLabel.text = nil
        categoryBadge.text = nil
        publishedDateLabel.text = nil
    }
    
    override func traitCollectionDidChange(_ previous: UITraitCollection?) {
        super.traitCollectionDidChange(previous)
        updateImageHeightConstraint()
    }
    
    // MARK: - Internal methods
    
    func configure(with news: News) {
        
        showPlaceholder()
        if let imageUrl = news.imageUrl {
            loadImage(from: imageUrl)
        }
        
        let title = news.title
        let description = news.description
        titleLabel.text = title
        descriptionLabel.text = description
        categoryBadge.text = news.category
        
        if let publishedDate = news.publishedDate {
            publishedDateLabel.text = publishedDate
        }
    }
    
    // MARK: - Private methods
    
    private func setupCell() {
        contentView.addSubview(containerView)
        containerView.addSubview(contentStackView)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            contentStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: .big),
            contentStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: .big),
            contentStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -.big),
            contentStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -.big)
        ])
        
        imageAspectConstraint = imageView.heightAnchor.constraint(
            equalTo: imageView.widthAnchor,
            multiplier: imageAspectRatio
        )
        imageAspectConstraint?.priority = .defaultHigh
        imageAspectConstraint?.isActive = true

        imageMaxHeightConstraint = imageView.heightAnchor.constraint(lessThanOrEqualToConstant: landscapeImageMaxHeight)
        imageMaxHeightConstraint?.priority = .required
        
        let descriptionFixedHeight = descriptionLabel.font.lineHeight * CGFloat(labelMaxLines)
        let description = descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: descriptionFixedHeight)
        description.priority = .defaultHigh
        description.isActive = true
    }
    
    private func updateImageHeightConstraint() {
        let isWide = traitCollection.horizontalSizeClass == .regular
        imageMaxHeightConstraint?.isActive = !isWide
        imageAspectConstraint?.priority = isWide ? .required : .defaultHigh
    }
    
    private func showPlaceholder() {
        imageView.contentMode = .center
        imageView.image = imagePlaceholder
    }
    
    private func loadImage(from url: URL) {
        imageTask = Task { [weak self] in
            let image = try? await ImageLoader.shared.image(from: url)
            guard !Task.isCancelled else { return }
            self?.imageView.contentMode = .scaleAspectFill
            self?.imageView.image = image
        }
    }
}

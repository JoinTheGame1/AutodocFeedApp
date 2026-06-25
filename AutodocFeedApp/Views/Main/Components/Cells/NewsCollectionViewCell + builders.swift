//
//  NewsCollectionViewCell + builders.swift
//  AutodocFeedApp
//
//  Created by nikita on 23.06.2026.
//

import UIKit

extension NewsCollectionViewCell {
    
    func makeBackgroundView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = .big
        view.clipsToBounds = true
        return view
    }
    
    func makeStackView(
        subviews: [UIView],
        axis: NSLayoutConstraint.Axis = .vertical,
        distribution: UIStackView.Distribution = .fill,
        spacing: CGFloat = .medium
    ) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: subviews)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = axis
        stack.distribution = distribution
        stack.spacing = spacing
        return stack
    }
    
    func makeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = .big
        imageView.backgroundColor = .tertiarySystemFill
        imageView.tintColor = .secondaryLabel
        return imageView
    }
    
    func makeLabel(
        textColor: UIColor = .label,
        font: UIFont = .systemFont(ofSize: 17, weight: .medium)
    ) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = textColor
        label.textAlignment = .left
        label.font = font
        label.numberOfLines = labelMaxLines
        label.backgroundColor = .clear
        return label
    }
    
    func makeBadge() -> PaddedLabel {
        let badge = PaddedLabel()
        badge.textColor = .white
        badge.font = .systemFont(ofSize: 13, weight: .medium)
        badge.backgroundColor = .lightGray
        badge.isCapsule = true
        return badge
    }
}

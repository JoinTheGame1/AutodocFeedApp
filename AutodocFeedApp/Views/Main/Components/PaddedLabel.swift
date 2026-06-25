//
//  PaddedLabel.swift
//  AutodocFeedApp
//
//  Created by nikita on 23.06.2026.
//

import UIKit

final class PaddedLabel: UILabel {
    
    // MARK: - Properties
    
    var isCapsule = false
    var insets: UIEdgeInsets = .init(
        top: .small,
        left: .medium,
        bottom: .small,
        right: .medium
    )
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + insets.left + insets.right,
            height: size.height + insets.top + insets.bottom
        )
    }
    
    // MARK: - Life cycle
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isCapsule {
            layer.cornerRadius = bounds.height / 2
            clipsToBounds = true
        }
    }
}

//
//  StackView + Extension.swift
//  IChat
//
//  Created by macbook on 19.12.2022.
//

import UIKit

// MARK: - Extension

extension UIStackView {
    // MARK: - Init
    
    convenience init(arrangedSubviews: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat) {
        self.init(arrangedSubviews: arrangedSubviews)
        
        self.axis = axis
        self.spacing = spacing
    }
}

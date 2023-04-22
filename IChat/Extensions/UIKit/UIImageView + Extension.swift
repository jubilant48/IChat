//
//  UIImageView + Extension.swift
//  IChat
//
//  Created by macbook on 14.12.2022.
//

import UIKit

// MARK: - Extension

extension UIImageView {
    // MARK: - Init
    
    convenience init(image: UIImage?, contentMode: UIView.ContentMode) {
        self.init()
        
        self.image = image
        self.contentMode = contentMode
    }
    
    // MARK: - Methods
    
    func setupColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}

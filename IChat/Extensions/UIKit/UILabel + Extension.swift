//
//  UILabel + Extension.swift
//  IChat
//
//  Created by macbook on 14.12.2022.
//

import UIKit

// MARK: - Extension

extension UILabel {
    // MARK: - Init
    
    convenience init(text: String, font: UIFont? = .avenir20()) {
        self.init()
        
        self.text = text
        self.font = font
    }
}

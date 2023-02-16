//
//  EyeButton.swift
//  IChat
//
//  Created by macbook on 01.02.2023.
//

import UIKit

final class EyeButton: UIButton {
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupEyeButton()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods
    
    private func setupEyeButton() {
        setImage(UIImage(systemName: "eye.slash"), for: .normal)
        tintColor = .label
        isEnabled = false
        
        widthAnchor.constraint(equalToConstant: 40).isActive = true
    }
}

//
//  SectionHeader.swift
//  IChat
//
//  Created by macbook on 04.01.2023.
//

import UIKit

final class SectionHeader: UICollectionReusableView {
    // MARK: Properties
    
    static let reuseId = "SectionHeader"
    let title = UILabel()
   
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods
    
    func configure(text: String, font: UIFont?, textColor: UIColor) {
        title.textColor = textColor
        title.font = font
        title.text = text
    }
}

// MARK: - Setup constraints

extension SectionHeader {
    private func setupConstraints() {
        // Configure title
        title.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding subview
        addSubview(title)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: self.topAnchor),
            title.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            title.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

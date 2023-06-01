//
//  WaitingPlugCell.swift
//  IChat
//
//  Created by macbook on 31.03.2023.
//

import UIKit

final class WaitingPlugCell: UICollectionViewCell {
    // MARK: Properties
    
    static var reuseId = "WaitingPlugCell"
    let imageView = UIImageView()
    let label = UILabel()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .getBackgroundAppColor()
        self.clipsToBounds = true
        
        customizeElements()
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func customizeElements() {
        imageView.tintColor = .getPlugGrayColor()
        
        label.textColor = .getPlugGrayColor()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
    }
}

// MARK: - Setup constraints

extension WaitingPlugCell {
    private func setupConstraints() {
        // Configure imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        // Configure label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding subview
        addSubview(imageView)
        addSubview(label)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalToConstant: 65),
            imageView.widthAnchor.constraint(equalToConstant: 65)
        ])
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 3)
        ])
    }
}

// MARK: - Self configuring cell

extension WaitingPlugCell: SelfCongiguringCell {
    func configure<U>(with value: U) where U : Hashable {
        guard let text: String = value as? String else {
            fatalError("Unknown model object")
        }
        
        self.imageView.image = UIImage(systemName: "message")
        self.label.text = text
    }
}

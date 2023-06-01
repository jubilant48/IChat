//
//  WaitingChatCell.swift
//  IChat
//
//  Created by macbook on 04.01.2023.
//

import UIKit
import SDWebImage

final class WaitingChatCell: UICollectionViewCell {
    // MARK: Properties
    
    static var reuseId: String = "WaitingChatCell"
    let friendImageView =  UIImageView()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup constraints
 
extension WaitingChatCell {
    private func setupConstraints() {
        // Configure friendImageView
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        friendImageView.backgroundColor = .yellow
        friendImageView.layer.cornerRadius = 4
        friendImageView.clipsToBounds = true
        friendImageView.contentMode = .scaleAspectFill
        
        // Adding subviews
        addSubview(friendImageView)
 
        // Setup constraints
        NSLayoutConstraint.activate([
            friendImageView.topAnchor.constraint(equalTo: self.topAnchor),
            friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            friendImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            friendImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

// MARK: - Self configuring cell

extension WaitingChatCell: SelfCongiguringCell {
    func configure<U>(with value: U) where U : Hashable {
        guard let chat: MChat = value as? MChat else {
            fatalError("Unknown model object")
        }
        
        friendImageView.sd_setImage(with: URL(string: chat.friendAvatarStringURL))
    }
}

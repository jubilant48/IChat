//
//  UserCell.swift
//  IChat
//
//  Created by macbook on 05.01.2023.
//

import UIKit
import SDWebImage

final class UserCell: UICollectionViewCell, SelfCongiguringCell {
    // MARK: Properties
    
    static var reuseId: String = "UserCell"
    let userImageView = UIImageView()
    let userName = UILabel(text: "text", font: .laoSangamMN20())
    let containerView = UIView()
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        setupConstraints()
        
        self.layer.cornerRadius = 4
        
        self.layer.shadowColor = UIColor.getShadowColor().cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.containerView.layer.cornerRadius = 4
        self.containerView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        userImageView.image = nil
    }
    
    // MARK: Methods
    
    func configure<U>(with value: U) where U : Hashable {
        guard let user: MUser = value as? MUser else {
            fatalError("Unknown model object")
        }
        userName.text = user.username
        
        guard let url = URL(string: user.avatarStringUrl) else { return }
        userImageView.sd_setImage(with: url, completed: nil)
    }
}

// MARK: - Setup constraints

extension UserCell {
    private func setupConstraints() {
        // Configure uerImageView
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        userImageView.backgroundColor = .red
        userImageView.contentMode = .scaleAspectFill
        userImageView.clipsToBounds = true
        
        // Configure userName
        userName.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure containerView
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding subview
        addSubview(containerView)
        containerView.addSubview(userImageView)
        containerView.addSubview(userName)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            userImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            userImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            userImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            userImageView.heightAnchor.constraint(equalTo: containerView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            userName.topAnchor.constraint(equalTo: userImageView.bottomAnchor),
            userName.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            userName.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            userName.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        
    }
}

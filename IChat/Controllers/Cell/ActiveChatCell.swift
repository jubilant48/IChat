//
//  ActiveChatCell.swift
//  IChat
//
//  Created by macbook on 28.12.2022.
//

import UIKit

final class ActiveChatCell: UICollectionViewCell {
    // MARK: Property
    
    static var reuseId: String = "ActiveChatCell"
    let friendImageView = UIImageView()
    let friendName = UILabel(text: "User name", font: .laoSangamMN20())
    let lastMessage = UILabel(text: "How are you?", font: .laoSangamMN18())
    let gradientView = GradientView(from: .topTrailing, to: .bottomLeading, startColor: #colorLiteral(red: 0.7882352941, green: 0.631372549, blue: 0.9411764706, alpha: 1), endColor: #colorLiteral(red: 0.4784313725, green: 0.6980392157, blue: 0.9215686275, alpha: 1))
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
        setupConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup constraints
 
extension ActiveChatCell {
    private func setupConstraints() {
        // Configure friendImageView
        friendImageView.translatesAutoresizingMaskIntoConstraints = false
        friendImageView.backgroundColor = .red
        friendImageView.contentMode = .scaleAspectFill
        friendImageView.clipsToBounds = true
        
        // Configure gradientView
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure friendName
        friendName.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure lastMessage
        lastMessage.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding subviews
        addSubview(friendImageView)
        addSubview(friendName)
        addSubview(lastMessage)
        addSubview(gradientView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            friendImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            friendImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            friendImageView.heightAnchor.constraint(equalToConstant: 78),
            friendImageView.widthAnchor.constraint(equalToConstant: 78)
        ])
        
        NSLayoutConstraint.activate([
            friendName.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            friendName.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            friendName.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            lastMessage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:  -14),
            lastMessage.leadingAnchor.constraint(equalTo: friendImageView.trailingAnchor, constant: 16),
            lastMessage.trailingAnchor.constraint(equalTo: gradientView.leadingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            gradientView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 78),
            gradientView.widthAnchor.constraint(equalToConstant: 8)
        ])
    }
}

// MARK: - Self congiguring cell

extension ActiveChatCell: SelfCongiguringCell {
    func configure<U>(with value: U) where U : Hashable {
        guard let chat: MChat = value as? MChat else {
            fatalError("Unknown model object")
        }
        friendName.text = chat.friendUsername
        lastMessage.text = chat.lastMessageContent
        friendImageView.sd_setImage(with: URL(string: chat.friendAvatarStringURL))
    }
}

//
//  ChatRequestViewController.swift
//  IChat
//
//  Created by macbook on 08.01.2023.
//

import UIKit
import SDWebImage

final class ChatRequsetViewController: UIViewController {
    // MARK: Properties
    
    weak var delegate: WaitingChatsNavigation?
    
    let containerView = UIView()
    let imageView = UIImageView(image: UIImage(named: "Img7"), contentMode: .scaleAspectFill)
    let nameLabel = UILabel(text: "Peter Ben", font: .systemFont(ofSize: 20, weight: .light))
    let aboutMeLabel = UILabel(text: "You have the opporttunity to start a new chat!", font: .systemFont(ofSize: 16, weight: .light))
    let acceptButton = UIButton(title: "ACCEPT", titleColor: .white, backgroundColor: .black, font: .laoSangamMN20(), isShadow: false, cornerRadius: 10)
    let denyButton = UIButton(title: "Deny", titleColor: #colorLiteral(red: 0.8352941176, green: 0.2, blue: 0.2, alpha: 1), backgroundColor: .getBackgroundAppColor(), font: .laoSangamMN20(), isShadow: false, cornerRadius: 10)
    
    private var chat: MChat
    
    // MARK: Init
    
    init(chat: MChat) {
        self.chat = chat
        nameLabel.text = chat.friendUsername
        imageView.sd_setImage(with: URL(string: chat.friendAvatarStringURL))
        
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*,unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .getBackgroundAppColor()
        
        customizeElement()
        setupConstraints()
    }
    
    // MARK: Layout methods
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Configure acceptButton
        self.acceptButton.applyGradients(cornerRadius: 10)
    }
    
    // MARK: Actions
    
    @objc private func acceptButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.changeToActive(chat: self.chat)
        }
    }
    
    @objc private func denyButtonTapped() {
        self.dismiss(animated: true) {
            self.delegate?.removeWaitingChat(chat: self.chat)
        }
    }
    
    // MARK: Methods
    
    private func customizeElement() {
        // Configure containerView
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .getBackgroundAppColor()
        containerView.layer.cornerRadius = 30
        
        // Configure imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Confugure nameLabel
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure aboutMeLabel
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure acceptButton
        acceptButton.addTarget(self, action: #selector(acceptButtonTapped), for: .touchUpInside)
        
        // Configure denyButon
        denyButton.layer.borderWidth = 1.2
        denyButton.layer.borderColor = #colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 1)
        denyButton.addTarget(self, action: #selector(denyButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Setup constraints

extension ChatRequsetViewController {
    private func setupConstraints() {
        // Create stackView
        let buttonsStackView = UIStackView(arrangedSubviews: [acceptButton, denyButton], axis: .horizontal, spacing: 7)
        
        // Configure stackView
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.distribution = .fillEqually
        
        // Adding subviews
        view.addSubview(imageView)
        view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutMeLabel)
        containerView.addSubview(buttonsStackView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: 30)
        ])
        
        NSLayoutConstraint.activate([
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 206)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 35),
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant:  -24)
        ])
        
        NSLayoutConstraint.activate([
            aboutMeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            aboutMeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            aboutMeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant:  -24)
        ])
        
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 24),
            buttonsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            buttonsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant:  -24),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 56)
        ])
        
    }
}

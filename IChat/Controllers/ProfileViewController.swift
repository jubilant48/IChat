//
//  ProfileViewController.swift
//  IChat
//
//  Created by macbook on 08.01.2023.
//

import UIKit
import SDWebImage

final class ProfileViewController: UIViewController {
    // MARK: Enumeration
    
    enum State {
        case withTextField
        case withMessage
        case withButton
    }
    
    // MARK: Properties
    
    private let state: State
    
    private let containerView = UIView()
    private let imageView = UIImageView(image: UIImage(named: "Img7"), contentMode: .scaleAspectFill)
    private let nameLabel = UILabel(text: "Peter Ben", font: .systemFont(ofSize: 20, weight: .light))
    private let aboutMeLabel = UILabel(text: "You have the opporttunity to chat with the best man in  the world!", font: .systemFont(ofSize: 16, weight: .light))
    
    private lazy var myTextField = InsertableTextField()
    private lazy var requestLabel = UILabel(text: "Запрос отправлен!", font: .systemFont(ofSize: 20, weight: .light))
    private lazy var chatButton = UIButton(title: "Перейти к чату", titleColor: .white, backgroundColor: .black, font: .laoSangamMN20(), isShadow: false, cornerRadius: 10)
    
    private let user: MUser
    
    // MARK: Init
    
    init(user: MUser, state: State) {
        self.user = user
        self.nameLabel.text = user.username
        self.aboutMeLabel.text = user.description
        self.imageView.sd_setImage(with: URL(string: user.avatarStringUrl))
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        chatButton.applyGradients(cornerRadius: 10)
    }
    
    // MARK: Actions
    
    @objc func keyboardWillAppear(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        
        let difference = -keyboardSize.height + 30
        
        UIView.animate(withDuration: 0.015) {
            self.containerView.transform = CGAffineTransform(translationX: self.containerView.frame.origin.x, y: difference)
        }
    }
    
    @objc private func keyboardDisappear(notification: NSNotification) {
        UIView.animate(withDuration: 2.0) {
            self.containerView.transform = CGAffineTransform.identity
        }
    }
    
    @objc private func sendMessage() {
        guard let message = myTextField.text, message != "" else { return }
        dismiss(animated: true) {
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let viewController = scene!.windows[0].rootViewController
            
            FirestoreService.shared.createWaitingChat(message: message, receiver: self.user) { result in
                switch result {
                case .success():
                    UIApplication.getTopViewController(base: viewController)?.showAlert(with: "Успешно!", and: "Ваше сообщение для \(self.user.username) было отправленно.")
                case .failure(let error):
                    UIApplication.getTopViewController(base: viewController)?.showAlert(with: "Ошибка", and: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: Methods
    
    private func customizeElement() {
        // Configure imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        //Configure nameLabel
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure aboutLabel
        aboutMeLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutMeLabel.numberOfLines = 0
        
        // Configure state element
        switch state {
        case .withTextField:
            //Configure myTextField
            myTextField.translatesAutoresizingMaskIntoConstraints = false
            myTextField.delegate = self
            
            if let button = myTextField.rightView as? UIButton {
                button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
            }
        case .withMessage:
            // Configure requestLabel
            requestLabel.translatesAutoresizingMaskIntoConstraints = false
            requestLabel.textAlignment = .center
            requestLabel.layer.masksToBounds = true
            requestLabel.layer.cornerRadius = 10
            requestLabel.backgroundColor = .getGrayColor()
        case .withButton:
            // Configure chatButton
            chatButton.translatesAutoresizingMaskIntoConstraints = false
            chatButton.applyGradients(cornerRadius: 10)
        }
        
        // Configure containerView
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .getBackgroundAppColor()
        containerView.layer.cornerRadius = 30
    }
}

// MARK: - Setup constraints

extension ProfileViewController {
    private func setupConstraints() {
        // Adding subviews
        view.addSubview(imageView)
        view.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(aboutMeLabel)
        
        switch state {
        case .withTextField:
            containerView.addSubview(myTextField)
        case .withMessage:
            containerView.addSubview(requestLabel)
        case .withButton:
            containerView.addSubview(chatButton)
        }
        
        
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
        
        switch state {
        case .withTextField:
            setConstraints(for: myTextField)
        case .withMessage:
            setConstraints(for: requestLabel)
        case .withButton:
            setConstraints(for: chatButton)
        }
    }
    
    private func setConstraints(for view: UIView) {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: aboutMeLabel.bottomAnchor, constant: 25),
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant:  -24),
            view.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}
// MARK: - Text field delegate

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

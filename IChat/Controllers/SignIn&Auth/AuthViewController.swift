//
//  ViewController.swift
//  IChat
//
//  Created by macbook on 14.12.2022.
//

import UIKit

final class AuthViewController: UIViewController {
    // MARK: Properties
    
    private let logoImageView = UIImageView(image:  UIImage(named: "IChat-White"), contentMode: .scaleAspectFit)
    
    private let googleLabel = UILabel(text: "Get started with")
    private let emailLabel = UILabel(text: "Or sign up with")
    private let alreadyOnboardLabel = UILabel(text: "Already onboard?")
    
    private let googleButton = UIButton(title: "Google", titleColor: .black, backgroundColor: .white, isShadow: true)
    private let emailButton = UIButton(title: "Email", titleColor: .white, backgroundColor: .buttonDark())
    private let loginButton = UIButton(title: "Login", titleColor: .buttonRed(), backgroundColor: .white, isShadow: true)
    
    let signUpViewController = SignUpViewController()
    let loginViewController = LoginViewController()
    
    //MARK: Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleButton.customizeGoogleButton()
        configureView()
        setupConstraints()
        configureButtons()
    }
    
    // MARK: Actions
    
    @objc private func emailButtonTapped() {
        present(signUpViewController, animated: true)
    }
    
    @objc private func loginButtonTapped() {
        present(loginViewController, animated: true)
    }
    
    @objc private func googleButtonTapped() {
        AuthService.shared.signInGoogle(self) { result in
            switch result {
            case .success(let user):
                FirestoreService.shared.getUserData(user: user) { result in
                    switch result {
                    case .success(let mUser):
                        self.showAlert(with: "Успешно!", and: "Вы автаризованны!") {
                            let mainTabBarController = MainTabBarController(currentUser: mUser)
                            mainTabBarController.modalPresentationStyle = .fullScreen
                            
                            self.present(mainTabBarController, animated: true)
                        }
                    case .failure(_):
                        self.showAlert(with: "Успешно!", and: "Вы зарегестрированны!") {
                            self.present(SetupProfileViewController(currentUser: user), animated: true)
                        }
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }
    
    // MARK: Override methods
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch traitCollection.userInterfaceStyle {
        case .unspecified:
            break
        case .light:
            logoImageView.image = UIImage(named: "IChat-White")
        case .dark:
            logoImageView.image = UIImage(named: "IChat-Black")
        @unknown default:
            break
        }
    }
    
    // MARK: Methods
    
    private func configureView() {
        view.backgroundColor = .secondarySystemBackground
        
        let image = traitCollection.userInterfaceStyle == .light ? UIImage(named: "IChat-White") : UIImage(named: "IChat-Black")
        logoImageView.image = image
        
        // Configure delegate for signUpViewController and loginViewController
        signUpViewController.delegate = self
        loginViewController.delegate = self
    }
    
    private func configureButtons() {
        // Configure googleButton
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
        
        // Configure emailButton
        emailButton.addTarget(self, action: #selector(emailButtonTapped), for: .touchUpInside)
        
        // Configure loginButton
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
    }
}

// MARK: - Setup Constraints

extension AuthViewController {
    private func setupConstraints() {
        // Logo Image View
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // View for googleLabel and googleButton
        let googleView = ButtonFromView(label: googleLabel, button: googleButton)
        
        // View for emailLabel and emailButton
        let emailView = ButtonFromView(label: emailLabel, button: emailButton)
        
        // View for alreadyOnboardLabel and loginButton
        let loginView = ButtonFromView(label: alreadyOnboardLabel, button: loginButton)
        
        // Stack view for googleView, emailView and loginView
        let stackView = UIStackView(arrangedSubviews: [googleView, emailView, loginView], axis: .vertical, spacing: 40)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding subviews
        view.addSubview(logoImageView)
        view.addSubview(stackView)
        
        // Adding constrains for logoImageView and stackView
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(lessThanOrEqualTo: view.topAnchor, constant: 160),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: logoImageView.bottomAnchor, constant: 100),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -70)
        ])
    }
}

// MARK: - AuthNavigatingDelegate

extension AuthViewController: AuthNavigatingDelegate {
    func toLoginViewController() {
        present(loginViewController, animated: true)
    }
    
    func toSignUpViewController() {
        present(signUpViewController, animated: true)
    }
}

// MARK: - Display Canvas

import SwiftUI

struct AuthViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = AuthViewController()
        
        func makeUIViewController(context: Context) -> some AuthViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}

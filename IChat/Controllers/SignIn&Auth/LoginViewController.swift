//
//  LoginViewController.swift
//  IChat
//
//  Created by macbook on 19.12.2022.
//

import UIKit

final class LoginViewController: UIViewController {
    // MARK: Properties
    
    private let scrollView = UIScrollView()
    private var stackView = UIStackView()
    
    private let welcomeLabel = UILabel(text: "Welcome back!", font: .avenir25())
    
    private let loginWithLabel = UILabel(text: "Login with")
    private let orLabel = UILabel(text: "or")
    private let emailLabel = UILabel(text: "Email")
    private let passwordLabel = UILabel(text: "Password")
    private let needAnAccountLabel = UILabel(text: "Need an account?")
    
    private let googleButton = UIButton(title: "Google", titleColor: .black, backgroundColor: .white, isShadow: true)
    private let loginButton = UIButton(title: "Login", titleColor: .white, backgroundColor: .buttonDark())
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.buttonRed(), for: .normal)
        button.titleLabel?.font = .avenir20()
        button.contentHorizontalAlignment = .leading
        return button
    }()
    
    private let emailTextField = OneLineTextField(font: .avenir20())
    private let passwordTextField = OneLineTextField(font: .avenir20(), isSecure: true)
    
    weak var delegate: AuthNavigatingDelegate?
    
    private var isPrivate = true
    private var eyeButton = EyeButton()

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleButton.customizeGoogleButton()
        
        self.view.backgroundColor = .secondarySystemBackground
        
        setupConstraints()
        configureElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Actions
    
    @objc private func keyboardWillAppear(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let difference = keyboardSize.height - (self.view.frame.height - stackView.frame.origin.y - stackView.frame.size.height)
        
        let scrollPoint = CGPointMake(0, difference)
        
        self.scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    @objc private func keyboardDisappear() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @objc private func eyeButtonTapped() {
        let imageName = isPrivate ? "eye" : "eye.slash"
        
        passwordTextField.isSecureTextEntry.toggle()
        eyeButton.setImage(UIImage(systemName: imageName), for: .normal)
        isPrivate.toggle()
    }
    
    @objc private func googleButtonTapped() {
        AuthService.shared.signInGoogle(self) { result in
            switch result {
            case .success(let user):
                FirestoreService.shared.getUserData(user: user) { result in
                    switch result {
                    case .success(let mUser):                        
                        let mainTabBarController = MainTabBarController(currentUser: mUser)
                        mainTabBarController.modalPresentationStyle = .fullScreen
                        
                        self.present(mainTabBarController, animated: true)
                    case .failure(_):
                        self.present(SetupProfileViewController(currentUser: user), animated: true)
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }
    
    @objc private func loginButtonTapped() {
        AuthService.shared.login(email: emailTextField.text!, password: passwordTextField.text!) { result in
            switch result {
            case .success(let user):
                FirestoreService.shared.getUserData(user: user) { result in
                    switch result {
                    case .success(let mUser):
                        let mainTabBarController = MainTabBarController(currentUser: mUser)
                        mainTabBarController.modalPresentationStyle = .fullScreen
                        
                        self.present(mainTabBarController, animated: true)
                    case .failure(_):
                        self.present(SetupProfileViewController(currentUser: user), animated: true)
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }
    
    @objc func signUpButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.toSignUpViewController()
        }
    }
    
    // MARK: Methods
    
    private func configureElements() {
        // Configure scrollView
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        
        // Configure welcomeLabel
        welcomeLabel.textAlignment = .center
        
        // Configure googleButton
        googleButton.addTarget(self, action: #selector(googleButtonTapped), for: .touchUpInside)
        
        // Configure emailTextField
        emailTextField.delegate = self
        emailTextField.returnKeyType = .go
        emailTextField.keyboardType = .emailAddress

        // Configure passwordTextField
        passwordTextField.delegate = self
        eyeButton.addTarget(self, action: #selector(eyeButtonTapped), for: .touchUpInside)
        passwordTextField.rightView = eyeButton
        passwordTextField.rightViewMode = .always
        
        // Configure loginButton
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        // Configure signInButton
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
    }
    
}

// MARK: - Setup constraints

extension LoginViewController {
    private func setupConstraints() {
        // View for loginWithLabel and googleButton
        let loginWithView = ButtonFromView(label: loginWithLabel, button: googleButton)
        
        // Stack view for emailLabel and emailTextField
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField], axis: .vertical, spacing: 0)
        
        // Stack view for passwordLabel and passwordTextField
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField], axis: .vertical, spacing: 0)
        
        // Constrain for loginButton
        loginButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        // Stack view for loginWithView, orLabel, emailStackView, passwordStackView and loginButton
        let inputStackView = UIStackView(arrangedSubviews: [loginWithView, orLabel, emailStackView, passwordStackView, loginButton], axis: .vertical, spacing: 33)
        
        // Stack view for welcomeLabel and inputStackView
        let topStackView = UIStackView(arrangedSubviews: [welcomeLabel, inputStackView], axis: .vertical, spacing: 20)
        
        // Stack view for needAnAcountLabel and signInButton, and it aligment
        let bottomStackView = UIStackView(arrangedSubviews: [needAnAccountLabel, signUpButton], axis: .horizontal, spacing: 10)
        bottomStackView.alignment = .firstBaseline
        
        // Stack view for toStackView and bottomStackView
        let stackView = UIStackView(arrangedSubviews: [topStackView, bottomStackView], axis: .vertical, spacing: 17)
        
        // Setup srackView
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        
        // Adding subviews
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        // Setup scrollView and stackView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.contentLayoutGuide.topAnchor, constant: 90),
            stackView.centerXAnchor.constraint(lessThanOrEqualTo: scrollView.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, multiplier: 0.8),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, multiplier: 0.84)
        ])
        
        self.stackView = stackView
    }
}

// MARK: Text field delegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == passwordTextField {
            guard let text = textField.text else { return }
            eyeButton.isEnabled = !text.isEmpty
        }
    }
}

// MARK: - Display Canvas

import SwiftUI

struct LoginViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = LoginViewController()
        
        func makeUIViewController(context: Context) -> some LoginViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}

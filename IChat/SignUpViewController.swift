//
//  SignUpViewController.swift
//  IChat
//
//  Created by macbook on 19.12.2022.
//

import UIKit

final class SignUpViewController: UIViewController {
    // MARK: Properties
    
    private let scrollView = UIScrollView()
    private var stackView = UIStackView()
    
    private let welcomeLabel = UILabel(text: "Good to see you!", font: .avenir26())
    
    private let emailLabel = UILabel(text: "Email")
    private let passwordLabel = UILabel(text: "Password")
    private let confirmPasswordLabel = UILabel(text: "Confirm password")
    private let alreadyOnBoardLabel = UILabel(text: "Already onboard?")
    
    private let emailTextField = OneLineTextField(font: .avenir20())
    private let passwordTextField = OneLineTextField(font: .avenir20(), isSecure: true)
    private let confirmTextField = OneLineTextField(font: .avenir20(), isSecure: true)
    
    private let signUpButton = UIButton(title: "Sign Up", titleColor: .white, backgroundColor: .buttonDark(), cornerRadius: 4)
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.buttonRed(), for: .normal)
        button.titleLabel?.font = .avenir20()
        button.contentHorizontalAlignment = .leading
        return button
    }()
    
    weak var delegate: AuthNavigatingDelegate?
    
    private var isPrivatePasswordTextField = true
    private var eyeButtonForPasswodTextField = EyeButton()
    
    private var isPrivateConfirmTextField = true
    private var eyeButtonForConfirmTextField = EyeButton()
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .secondarySystemBackground
        setupConstraints()
        configureElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDisappear(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: Actions
    
    @objc func keyboardWillAppear(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size
        let difference = keyboardSize.height - (self.view.frame.height - stackView.frame.origin.y - stackView.frame.size.height)
        
        let scrollPoint = CGPointMake(0, difference)
        self.scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    @objc private func keyboardDisappear(notification: NSNotification) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @objc private func eyeButtonForPasswordTFTapped() {
        let imageName = isPrivatePasswordTextField ? "eye" : "eye.slash"
        
        passwordTextField.isSecureTextEntry.toggle()
        eyeButtonForPasswodTextField.setImage(UIImage(systemName: imageName), for: .normal)
        isPrivatePasswordTextField.toggle()
    }
    
    @objc private func eyeButtonForConfirmTFTapped() {
        let imageName = isPrivateConfirmTextField ? "eye" : "eye.slash"
        
        confirmTextField.isSecureTextEntry.toggle()
        eyeButtonForConfirmTextField.setImage(UIImage(systemName: imageName), for: .normal)
        isPrivateConfirmTextField.toggle()
    }
    
    @objc private func signUpButtonTapped() {
        AuthService.shared.register(email: emailTextField.text, password: passwordTextField.text, confirmPassword: confirmTextField.text) { result in
            switch result {
            case .success(let user):
                self.showAlert(with: "Успешно!", and: "Вы зарегестрированны!") {
                    self.present(SetupProfileViewController(currentUser: user), animated: true)
                }
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }
    
    @objc private func loginButtonTapped() {
        dismiss(animated: true) {
            self.delegate?.toLoginViewController()
        }
    }
    
    // MARK: Methods
    
    private func configureElements() {
        // Configure welcomeLabel
        welcomeLabel.textAlignment = .center
        
        // Configure emailTextField
        emailTextField.delegate = self
        emailTextField.returnKeyType = .go
        emailTextField.keyboardType = .emailAddress

        // Configure passwordTextField
        passwordTextField.delegate = self
        passwordTextField.returnKeyType = .go
        eyeButtonForPasswodTextField.addTarget(self, action: #selector(eyeButtonForPasswordTFTapped), for: .touchUpInside)
        passwordTextField.rightView = eyeButtonForPasswodTextField
        passwordTextField.rightViewMode = .always
        
        // Configure confirmTextField
        confirmTextField.delegate = self
        eyeButtonForConfirmTextField.addTarget(self, action: #selector(eyeButtonForConfirmTFTapped), for: .touchUpInside)
        confirmTextField.rightView = eyeButtonForConfirmTextField
        confirmTextField.rightViewMode = .always
        
        // Configure signUpButton
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        // Congigure loginButton
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Setup constraints

extension SignUpViewController {
    private func setupConstraints() {
        // Stack view for emailLabe and emailTextField
        let emailStackView = UIStackView(arrangedSubviews: [emailLabel, emailTextField], axis: .vertical, spacing: 0)
        
        // Stack view for passwordLabel and passwordTextField
        let passwordStackView = UIStackView(arrangedSubviews: [passwordLabel, passwordTextField], axis: .vertical, spacing: 0)
        
        // Stack view for confirmPasswordLabel and confirmTextField
        let confirmStackView = UIStackView(arrangedSubviews: [confirmPasswordLabel, confirmTextField], axis: .vertical, spacing: 0)
        
        // Setup constraints for signUpButton
        NSLayoutConstraint.activate([
            signUpButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Stack view for emailSackView, passwordStackView, confirmStackView and signUpButton
        let inputStackView = UIStackView(arrangedSubviews: [emailStackView, passwordStackView, confirmStackView, signUpButton], axis: .vertical, spacing: 40)
        
        // Stack view for welcomeLabel and inputStackView
        let topStackView = UIStackView(arrangedSubviews: [welcomeLabel, inputStackView], axis: .vertical, spacing: 55)
        
        // Stack view for alreadyOnBoardLabel and loginButton, and it aligment
        let bottomStackView = UIStackView(arrangedSubviews: [alreadyOnBoardLabel, loginButton], axis: .horizontal, spacing: 10)
        bottomStackView.alignment = .firstBaseline
        
        // Stack view for topStackView and bottomStackView
        let stackView = UIStackView(arrangedSubviews: [topStackView, bottomStackView], axis: .vertical, spacing: 20)
        
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
            stackView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.contentLayoutGuide.topAnchor, constant: 100),
            stackView.centerXAnchor.constraint(lessThanOrEqualTo: scrollView.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, multiplier: 0.8),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, multiplier: 0.77)
        ])
        
        self.stackView = stackView
    }
}

// MARK: - Text field delegate

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == passwordTextField {
            guard let text = textField.text else { return }
            eyeButtonForPasswodTextField.isEnabled = !text.isEmpty
        } else if textField == confirmTextField {
            guard let text = textField.text else { return }
            eyeButtonForConfirmTextField.isEnabled = !text.isEmpty
        }
    }
}

// MARK: - Display Canvas

import SwiftUI

struct SignUpViewControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        
        let viewController = SignUpViewController()
        
        func makeUIViewController(context: Context) -> some SignUpViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}

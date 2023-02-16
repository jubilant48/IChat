//
//  SetupProfileViewController.swift
//  IChat
//
//  Created by macbook on 19.12.2022.
//

import UIKit
import FirebaseAuth
import Photos
import SDWebImage

final class SetupProfileViewController: UIViewController {
    // MARK: Properties
    
    private let scrollView = UIScrollView()
    private var stackView = UIStackView()
    
    private let welcomeLabel = UILabel(text: "Set up profile!", font: .avenir25())
    
    private let fullImageView = AddPhotoView()
    
    private let fullNameLabel = UILabel(text: "Full name")
    private let aboutMeLabel = UILabel(text: "About me")
    private let sexLabel = UILabel(text: "Sex")
    
    private let fullNameTextField = OneLineTextField(font: .avenir20())
    private let aboutMeTextField = OneLineTextField(font: .avenir20())
    
    private let sexSegmentedControl = UISegmentedControl(first: "Male", second: "Femail")
    
    private let goToChatsButton = UIButton(title: "Go to chats!", titleColor: .white, backgroundColor: .buttonDark(), cornerRadius: 4)
    
    private let currentUser: User
    
    // MARK: Init
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        
        if let username = currentUser.displayName {
            fullNameTextField.text = username
        }
        
        if let photoURL = currentUser.photoURL {
            fullImageView.circleImageView.sd_setImage(with: photoURL)
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        customizeElements()
        setupConstraints()
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
        
        let scrollPoint = CGPointMake(0, difference + 10)
        self.scrollView.setContentOffset(scrollPoint, animated: true)
    }
    
    @objc private func keyboardDisappear() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    @objc private func plusButtonTapped() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        imagePickerController.sourceType = .photoLibrary
        
        present(imagePickerController, animated: true)
    }
    
    @objc private func goToChatsButtonTapped() {
        FirestoreService.shared.saveProfileWith(id: currentUser.uid,
                                                email: currentUser.email!,
                                                username: fullNameTextField.text,
                                                avaterImage: fullImageView.circleImageView.image,
                                                description: aboutMeTextField.text,
                                                sex: sexSegmentedControl.titleForSegment(at: sexSegmentedControl.selectedSegmentIndex)) { result in
            switch result {
            case .success(let mUser):                
                let mainTabBarController = MainTabBarController(currentUser: mUser)
                mainTabBarController.modalPresentationStyle = .fullScreen
                
                self.present(mainTabBarController, animated: true)
            case .failure(let error):
                self.showAlert(with: "Ошибка!", and: error.localizedDescription)
            }
        }
    }
    
    // MARK: Overrive methods
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch traitCollection.userInterfaceStyle {
        case .unspecified:
            break
        case .light:
            fullImageView.circleImageView.image =  UIImage(named: "avatar")
            fullImageView.plusButton.tintColor = .buttonDark()
        case .dark:
            fullImageView.circleImageView.image = UIImage(named: "avatar-white")
            fullImageView.plusButton.tintColor = .white
        @unknown default:
            break
        }
    }
    
    // MARK: Methods
    
    private func configureView() {
        view.backgroundColor = .secondarySystemBackground
        
        let avatar = traitCollection.userInterfaceStyle == .light ? UIImage(named: "avatar") : UIImage(named: "avatar-white")
        let tintColor = traitCollection.userInterfaceStyle == .light ? UIColor.buttonDark() : UIColor.white
        
        fullImageView.circleImageView.image = avatar
        fullImageView.plusButton.tintColor = tintColor
    }
    
    private func customizeElements() {
        // Configure welcomeLabel
        welcomeLabel.textAlignment = .center
        
        // Configure fullImageView
        fullImageView.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
        // Configure fullNameTextField
        fullNameTextField.delegate = self
        fullNameTextField.returnKeyType = .go
        
        // Configure aboutMeTextField
        aboutMeTextField.delegate = self
        
        // Configure goToChatsButton
        goToChatsButton.addTarget(self, action: #selector(goToChatsButtonTapped), for: .touchUpInside)
    }
    
}

// MARK: - Setup constraints

extension SetupProfileViewController {
    private func setupConstraints() {
        // Stack view for fullNameLabel and fullNameTextField
        let fullNameStackView = UIStackView(arrangedSubviews: [fullNameLabel, fullNameTextField], axis: .vertical, spacing: 0)
        
        // Stack view for aboutMeLabel and aboutMeTextField
        let aboutMeStackView = UIStackView(arrangedSubviews: [aboutMeLabel, aboutMeTextField], axis: .vertical, spacing: 0)
        
        // Stack view for sexLabel and sexSegmentadControl
        let sexStackView = UIStackView(arrangedSubviews: [sexLabel, sexSegmentedControl], axis: .vertical, spacing: 0)
        
        // Configure sexStackView
        sexStackView.distribution = .fillEqually
        
        // Constrain for goToChatsButton and fullImageView
        goToChatsButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        fullImageView.widthAnchor.constraint(equalToConstant: 146).isActive = true
        
        // Stack view for welcomeLabel and fillImageView
        let topStackView = UIStackView(arrangedSubviews: [welcomeLabel, fullImageView], axis: .vertical, spacing: 30)

        // Configure topStackView
        topStackView.alignment = .center
        topStackView.distribution = .fillProportionally
        
        // Stack view for fullNameStackView, aboutMeStackView, sexStackView and goToCharsButtton
        let bottomStackView = UIStackView(arrangedSubviews: [fullNameStackView, aboutMeStackView, sexStackView, goToChatsButton], axis: .vertical, spacing: 30)
        
        // Configure bottomStackView
        bottomStackView.distribution = .fillProportionally
        
        // Stack view for topStackView and bottomStackView
        let stackView = UIStackView(arrangedSubviews: [topStackView, bottomStackView], axis: .vertical, spacing: 30) // ***40
        
        // Configure srackView
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        
        // Setup for scrollView and stackView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding subviews
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: scrollView.contentLayoutGuide.topAnchor, constant: 70),
            stackView.centerXAnchor.constraint(lessThanOrEqualTo: scrollView.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, multiplier: 0.8),
            stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, multiplier: 0.82) // *** 0.80
        ])
        
        self.stackView = stackView
    }
}

// MARK: - UINavigationControllerDelegate and UIImagePickerControllerDelegate

extension SetupProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image =  info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        fullImageView.circleImageView.image = image
    }
}

// MARK: - Text field delegate

extension SetupProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fullNameTextField {
            aboutMeTextField.becomeFirstResponder()
        } else if textField == aboutMeTextField {
            aboutMeTextField.resignFirstResponder()
        }
        
        return true
    }
}


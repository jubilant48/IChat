//
//  ChatsViewController.swift
//  IChat
//
//  Created by macbook on 26.01.2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

final class ChatsViewController: MessagesViewController {
    // MARK: Properties
    
    private let user: MUser
    private var chat: MChat
    
    private var messages: [MMessage] = []
    private var messageListener: ListenerRegistration?
    
    // MARK: Init
    
    init(user: MUser, chat: MChat) {
        self.user = user
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        
        title = chat.friendUsername
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        messageListener?.remove()
    }
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = .label
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        configureMessageInputBar()
        configureMessagesCollectionView()
        
        addListeners()
    }
    
    // MARK: Actions
    
    @objc func keyboardWillAppear(notification: NSNotification) {
        messagesCollectionView.contentInset.bottom += 10
        messagesCollectionView.scrollToLastItem()
    }
    
    @objc private func cameraButtonPressed(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alertController = UIAlertController(title: "Chose Image Source", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { action in
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
                imagePicker.sourceType = .photoLibrary
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(photoLibraryAction)
        }
        
        alertController.popoverPresentationController?.sourceView = sender
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Methods
    
    private func addListeners() {
        messageListener = ListenerService.shared.messagesObserve(chat: chat) { result  in
            switch result {
            case .success(var message):
                if let url = message.downloadURL {
                    StorageService.shared.downloadImage(url: url) { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let image):
                            message.image = image
                            self.insertNewMessage(message: message, isImage: true)
                        case .failure(let error):
                            self.showAlert(with: "Ошибка", and: error.localizedDescription)
                        }
                    }
                } else {
                    self.insertNewMessage(message: message)
                }
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }
    
    private func insertNewMessage(message: MMessage, isImage: Bool = false) {
        guard !messages.contains(message) else { return }
        messages.append(message)
        messages.sort()
    
        if chat.lastMessageDate < message.sentDate {
            if isImage {
                FirestoreService.shared.updateLastMessageFor(chat: self.chat, message: "Изображение 🖼", lastDate: message.sentDate)
                chat.lastMessageDate = message.sentDate
            } else {
                FirestoreService.shared.updateLastMessageFor(chat: self.chat, message: message.content, lastDate: message.sentDate)
                chat.lastMessageDate = message.sentDate
            }
        }
        
        messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    private func sendImage(image: UIImage) {
        StorageService.shared.uploadImageMessage(photo: image, to: chat) { result in
            switch result {
            case .success(let url):
                var message = MMessage(user: self.user, image: image)
                message.downloadURL = url
                FirestoreService.shared.sendMessage(chat: self.chat, message: message) { result in
                    switch result {
                    case .success():
                        self.messagesCollectionView.scrollToLastItem()
                    case .failure(_):
                        self.showAlert(with: "Ошибка", and: "Изображение не доставлено")
                    }
                }
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }
    }
    
}

// MARK: - Configure message collection view

extension ChatsViewController {
    private func configureMessagesCollectionView() {
        // Configure messages collections view
        messagesCollectionView.backgroundColor = .getBackgroundAppColor()
        messagesCollectionView.showsVerticalScrollIndicator = false
        
        setupLayoutMessageCollectionView()
        
        // Adding delegates
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    private func setupLayoutMessageCollectionView() {
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
        }
    }
}

// MARK: - Configure message text field

extension ChatsViewController {
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = .getBackgroundAppColor()
        messageInputBar.inputTextView.backgroundColor = .getTextFieldColor()
        messageInputBar.inputTextView.placeholder = "Message"
        messageInputBar.inputTextView.placeholderTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.2470588235)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 14, left: 10, bottom: 14, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 36)
        messageInputBar.inputTextView.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.09803921569)
        messageInputBar.inputTextView.layer.borderWidth = 0.2
        messageInputBar.inputTextView.layer.cornerRadius = 18.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        
        messageInputBar.layer.shadowColor = UIColor.getShadowColor().cgColor
        messageInputBar.layer.shadowRadius = 5
        messageInputBar.layer.shadowOpacity = 0.3
        messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 4)
        
        configureSendButton()
        configureCamerIcon()
    }
    
    private func configureSendButton() {
        messageInputBar.sendButton.setImage(UIImage(named: "Sent"), for: .normal)
        messageInputBar.sendButton.applyGradients(cornerRadius: 10)
        messageInputBar.setRightStackViewWidthConstant(to: 56, animated: false)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 6, right: 30)
        messageInputBar.sendButton.setSize(CGSize(width: 48, height: 48), animated: false)
        messageInputBar.middleContentViewPadding.right = -38
    }
    
    private func configureCamerIcon() {
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = .getPurpleColor()
        
        let cameraImage =  UIImage(systemName: "camera")!
        cameraItem.image = cameraImage
        
        cameraItem.addTarget(self, action: #selector(cameraButtonPressed), for: .primaryActionTriggered)
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
    }
}

// MARK: - Image picker controller delegate

extension ChatsViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else { return }
        
        sendImage(image: selectedImage)
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Messages data source

extension ChatsViewController: MessagesDataSource {
    func currentSender() -> MessageKit.SenderType {
        return MSender(senderId: user.id, displayName: user.username)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.item]
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return 1
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let beforeIndex = indexPath.index(before: indexPath.item)
        
        if beforeIndex >= 0 {
            let beforeMessage = messages[beforeIndex]
            
            if !beforeMessage.sentDate.hasSame(.day, as: message.sentDate) {
                return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                    NSAttributedString.Key.foregroundColor: UIColor.darkGray
                ])
            }
        }
        return nil
    }
}

// MARK: - Messages layout delegate

extension ChatsViewController: MessagesLayoutDelegate {
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        let beforeIndex = indexPath.index(before: indexPath.item)
        
        if beforeIndex >= 0 {
            let beforeMessage = messages[beforeIndex]
            
            if !beforeMessage.sentDate.hasSame(.day, as: message.sentDate) {
                return 30
            }
        }
        
        return 0
    }
}

// MARK: - Messages display delegate

extension ChatsViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .getPurpleColor()
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .getBlackCustomColor() : .white
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
}

// MARK: - InputBar accessory view delegate

extension ChatsViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = MMessage(user: user, content: text)
        FirestoreService.shared.sendMessage(chat: chat, message: message) { result in
            switch result {
            case .success():
                self.messagesCollectionView.scrollToLastItem()
            case .failure(let error):
                self.showAlert(with: "Ошибка", and: error.localizedDescription)
            }
        }
        inputBar.inputTextView.text = ""
    }
}

// MARK: - Navigation controller delegate

extension ChatsViewController: UINavigationControllerDelegate { }



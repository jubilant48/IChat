//
//  FirestoreService.swift
//  IChat
//
//  Created by macbook on 14.01.2023.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

final class FirestoreService {
    // MARK: Properties
    
    static let shared = FirestoreService()
    
    let database = Firestore.firestore()
    
    private var usersReference: CollectionReference {
        return database.collection("users")
    }
    private var waitingChatsReference: CollectionReference {
        return database.collection(["users", currentUser.id, "waitingChats"].joined(separator: "/"))
    }
    private var activeChatsReference: CollectionReference {
        return database.collection(["users", currentUser.id, "activeChats"].joined(separator: "/"))
    }
    var currentUser: MUser!
    
    // MARK: Methods

    func saveProfileWith(id: String, email: String, username: String?, avaterImage: UIImage?, description: String?, sex: String?, completion: @escaping (Result<MUser, Error>) -> Void) {
        
        guard Validators.isFilled(username: username, description: description, sex: sex) else {
            completion(.failure(UserError.notFilled))
            return
        }
        
        guard avaterImage != UIImage(named: "avatar") else {
            completion(.failure(UserError.photoNotExist))
            return
        }
        
        var mUser = MUser(username: username!, email: email, avatarStringUrl: "not exist", description: description!, sex: sex!, id: id)
        
        StorageService.shared.upload(photo: avaterImage!) { result in
            
            switch result {
            case .success(let url):
                mUser.avatarStringUrl = url.absoluteString
                
                self.usersReference.document(mUser.id).setData(mUser.representaton) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(mUser))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
    
    func getUserData(user: User, completion: @escaping (Result<MUser, Error>) -> Void) {
        let documentReference = usersReference.document(user.uid)
        
        documentReference.getDocument { document, error in
            if let document = document, document.exists {
                guard let mUser = MUser(document: document) else {
                    completion(.failure(UserError.cannotUnwrapToMUser))
                    return
                }
                self.currentUser = mUser
                completion(.success(mUser))
            } else {
                completion(.failure(UserError.cannotGetUserInfo))
            }
        }
    }
    
    func createWaitingChat(message: String, receiver: MUser, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = database.collection(["users", receiver.id, "waitingChats"].joined(separator: "/"))
        let messageReference = reference.document(self.currentUser.id).collection("messages")
        
        let message = MMessage(user: currentUser, content: message, isViewed: false)
        let chat = MChat(friendUsername: currentUser.username, friendAvatarStringURL: currentUser.avatarStringUrl, lastMessageContent: message.content, friendId: currentUser.id, lastMessageDate: message.sentDate)
        
        reference.document(currentUser.id).setData(chat.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            messageReference.addDocument(data: message.representation) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(Void()))
            }
        }
    }
    
    func deleteWaitingChat(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        waitingChatsReference.document(chat.friendId).delete { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            self.deleteMessages(chat: chat, completion: completion)
        }
    }
    
    private func deleteMessages(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = waitingChatsReference.document(chat.friendId).collection("messages")
        
        getWaitingChatMessages(chat: chat) { result in
            switch result {
            case .success(let messages):
                for message in messages {
                    guard let documentId = message.id else { return }
                    let messageReference = reference.document(documentId)
                    
                    messageReference.delete { error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        completion(.success(Void()))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func getWaitingChatMessages(chat: MChat, completion: @escaping (Result<[MMessage], Error>) -> Void) {
        let reference = waitingChatsReference.document(chat.friendId).collection("messages")
        var messages = [MMessage]()
        
        reference.getDocuments { querySnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            for document in querySnapshot!.documents {
                guard let message = MMessage(document: document) else { return }
                messages.append(message)
            }
            
            completion(.success(messages))
        }
    }
    
    func changeToActive(chat: MChat, completion: @escaping (Result<Void, Error>) -> Void) {
        getWaitingChatMessages(chat: chat) { result in
            switch result {
            case .success(let messages):
                self.deleteWaitingChat(chat: chat) { result in
                    switch result {
                    case .success():
                        self.createActiveChat(chat: chat, messages: messages) { result in
                            switch result {
                            case .success():
                                completion(.success(Void()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func createActiveChat(chat: MChat, messages: [MMessage], completion: @escaping (Result<Void, Error>) -> Void) {
        let messageReference = activeChatsReference.document(chat.friendId).collection("messages")
        
        activeChatsReference.document(chat.friendId).setData(chat.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            for message in messages {
                messageReference.addDocument(data: message.representation) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    completion(.success(Void()))
                }
            }
        }
        
    }
    
    func sendMessage(chat: MChat, message: MMessage, completion: @escaping (Result<Void, Error>) -> Void) {
        let friendReference = usersReference.document(chat.friendId).collection("activeChats").document(currentUser.id)
        let friendMessageReference = friendReference.collection("messages")
        let myMessageReference = usersReference.document(currentUser.id).collection("activeChats").document(chat.friendId).collection("messages")
        
        let chatForFriend = MChat(friendUsername: currentUser.username, friendAvatarStringURL: currentUser.avatarStringUrl, lastMessageContent: message.content, friendId: currentUser.id, lastMessageDate: message.sentDate)
        
        friendReference.setData(chatForFriend.representation) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            friendMessageReference.addDocument(data: message.representation) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                myMessageReference.addDocument(data: message.representation) { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    completion(.success(Void()))
                }
            }
        }
        
    }
    
    func updateLastMessage(for chat: MChat, message: String, lastDate: Date) {
        let friendReference = usersReference.document(chat.friendId).collection("activeChats").document(currentUser.id)
        let myMessageReference = usersReference.document(currentUser.id).collection("activeChats").document(chat.friendId)

        let date = Timestamp(date: lastDate)

        friendReference.updateData([
            "lastMessage": message,
            "lastMessageDate": date
        ])

        myMessageReference.updateData([
            "lastMessage": message,
            "lastMessageDate": date
        ])
    }
    
    func updateViewedMessage(for senderId: String, friendId: String) {
        let messageReference = usersReference.document(currentUser.id).collection("activeChats").document(friendId).collection("messages").document(senderId)
        
        messageReference.updateData([
            "isViewed": true
        ])
    }
}

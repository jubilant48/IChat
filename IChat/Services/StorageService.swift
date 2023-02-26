//
//  StorageService.swift
//  IChat
//
//  Created by macbook on 19.01.2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

final class StorageService {
    // MARK: Properties
    
    static let shared = StorageService()
    
    let storageReference = Storage.storage().reference()
    
    private var avatarReference: StorageReference {
        return storageReference.child("avatars")
    }
    private var chatsReference: StorageReference {
        return storageReference.child("chats")
    }
    private var currentUserId: String {
        return Auth.auth().currentUser!.uid
    }
    
    // MARK: Methods
    
    func upload(photo: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let scaledImage = photo.scaledToSafeUploadSize,
              let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        avatarReference.child(currentUserId).putData(imageData, metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            
            self.avatarReference.child(self.currentUserId).downloadURL { url, error in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                
                completion(.success(downloadURL))
            }
        }
        
    }
    
    func uploadImageMessage(photo: UIImage, to chat: MChat, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let scaledImage = photo.scaledToSafeUploadSize,
              let imageData = scaledImage.jpegData(compressionQuality: 0.4) else { return }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let uid: String = Auth.auth().currentUser!.uid
        
        let chatName = [chat.friendId, uid].joined(separator: "|<>|")
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        
        self.chatsReference.child(chatName).child(imageName).putData(imageData, metadata: metadata) { metadata, error in
            guard let _ = metadata else {
                completion(.failure(error!))
                return
            }
            
            self.chatsReference.child(chatName).child(imageName).downloadURL { url, error in
                guard let downloadURL = url else {
                    completion(.failure(error!))
                    return
                }
                completion(.success(downloadURL))
            }
        }
        
    }
    
    func downloadImage(url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let reference = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)
        
        reference.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                completion(.failure(error!))
                return
            }
            completion(.success(UIImage(data: imageData)!))
        }
    }
    
}

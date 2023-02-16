//
//  MMessage.swift
//  IChat
//
//  Created by macbook on 23.01.2023.
//
import UIKit
import FirebaseFirestore
import MessageKit

struct MMessage: Hashable, Equatable, MessageType {
    // MARK: Properties
    
    let content: String
    var sentDate: Date
    let id: String?
    
    var sender: MessageKit.SenderType
    var messageId: String {
        return id ?? UUID().uuidString
    }
    var kind: MessageKit.MessageKind {
        if let image = image {
            let mediaItem = ImageItem(url: nil, image: nil, placeholderImage: image, size: image.size)
            
            return .photo(mediaItem)
        } else {
            return .text(content)
        }
    }
    
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    
    var representation: [String: Any] {
        var representation: [String: Any] = ["created": sentDate]
        representation["senderID"] = sender.senderId
        representation["senderName"] = sender.displayName
        
        if let url = downloadURL {
            representation["url"] = url.absoluteString
        } else {
            representation["content"] = content
        }
        
        return representation
    }
    
    
    // MARK: Init
    
    init(user: MUser, content: String) {
        self.content = content
        sender = Sender(senderId: user.id, displayName: user.username)
        sentDate = Date()
        id = nil
    }
    
    init(user: MUser, image: UIImage) {
        sender = Sender(senderId: user.id, displayName: user.username)
        self.image = image
        content = ""
        sentDate = Date()
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let sentDate = data["created"] as? Timestamp,
              let senderId = data["senderID"] as? String,
              let senderName = data["senderName"] as? String else { return nil }
        
        self.id = document.documentID
        self.sentDate = sentDate.dateValue()
        sender = Sender(senderId: senderId, displayName: senderName)
        
        if let content = data["content"] as? String {
            self.content = content
            self.downloadURL = nil
        } else if let urlString = data["url"] as? String,
                  let url = URL(string: urlString) {
            self.downloadURL = url
            self.content = ""
        } else {
            return nil
        }
    }
    
    // MARK: Methods
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(messageId)
    }
    
    static func == (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}

// MARK: - Comparable

extension MMessage: Comparable {
    static func < (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}

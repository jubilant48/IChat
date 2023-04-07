//
//  MChat.swift
//  IChat
//
//  Created by macbook on 05.01.2023.
//

import UIKit
import FirebaseFirestore

struct MChat: Hashable, Decodable {
    // MARK: Properties
    
    static let waitingPlugModel = MChat(friendUsername: "nil", friendAvatarStringURL: "0", lastMessageContent: "nil", friendId: "0", lastMessageDate: Date())
    static let activePlugModel = MChat(friendUsername: "nil", friendAvatarStringURL: "1", lastMessageContent: "nil", friendId: "1", lastMessageDate: Date())
    
    var friendUsername: String
    var friendAvatarStringURL: String
    var lastMessageContent: String
    var lastMessageDate: Date
    var friendId: String
    
    var representation: [String: Any] {
        var representation: [String: Any] = ["friendUsername": friendUsername]
        representation["friendAvatarStringURL"] = friendAvatarStringURL
        representation["friendId"] = friendId
        representation["lastMessage"] = lastMessageContent
        representation["lastMessageDate"] = lastMessageDate
        
        return representation
    }
    
    // MARK: Init
    
    init(friendUsername: String, friendAvatarStringURL: String, lastMessageContent: String, friendId: String, lastMessageDate: Date) {
        self.friendUsername = friendUsername
        self.friendAvatarStringURL = friendAvatarStringURL
        self.lastMessageContent = lastMessageContent
        self.lastMessageDate = lastMessageDate
        self.friendId = friendId
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        guard let friendUsername = data["friendUsername"] as? String,
              let friendAvatarStringURL = data["friendAvatarStringURL"] as? String,
              let friendId = data["friendId"] as? String,
              let lastMessageContent = data["lastMessage"] as? String,
              let lastMessageDate = data["lastMessageDate"] as? Timestamp else { return nil }
        
        self.friendUsername = friendUsername
        self.friendAvatarStringURL = friendAvatarStringURL
        self.friendId = friendId
        self.lastMessageContent = lastMessageContent
        self.lastMessageDate = lastMessageDate.dateValue()
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let friendUsername = data["friendUsername"] as? String,
              let friendAvatarStringURL = data["friendAvatarStringURL"] as? String,
              let friendId = data["friendId"] as? String,
              let lastMessageContent = data["lastMessage"] as? String,
              let lastMessageDate = data["lastMessageDate"] as? Timestamp else { return nil }
        
        self.friendUsername = friendUsername
        self.friendAvatarStringURL = friendAvatarStringURL
        self.friendId = friendId
        self.lastMessageContent = lastMessageContent
        self.lastMessageDate = lastMessageDate.dateValue()
    }
    
    // MARK: Methods
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.friendId == rhs.friendId
    }
    
    func contains(filter: String?) -> Bool {
        guard let filter = filter else { return true }
        
        if filter.isEmpty  {
            return true
        }
        
        let lowercasedFilter = filter.lowercased()
        
        return friendUsername.lowercased().contains(lowercasedFilter)
    }
}

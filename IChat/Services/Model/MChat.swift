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
    
    var friendUsername: String
    var friendAvatarStringURL: String
    var lastMessageContent: String
    var friendId: String
    
    var representation: [String: Any] {
        var representation = ["friendUsername": friendUsername]
        representation["friendAvatarStringURL"] = friendAvatarStringURL
        representation["friendId"] = friendId
        representation["lastMessage"] = lastMessageContent
        
        return representation
    }
    
    // MARK: Init
    
    init(friendUsername: String, friendAvatarStringURL: String, lastMessageContent: String, friendId: String) {
        self.friendUsername = friendUsername
        self.friendAvatarStringURL = friendAvatarStringURL
        self.lastMessageContent = lastMessageContent
        self.friendId = friendId
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let friendUsername = data["friendUsername"] as? String,
              let friendAvatarStringURL = data["friendAvatarStringURL"] as? String,
              let friendId = data["friendId"] as? String,
              let lastMessageContent = data["lastMessage"] as? String else { return nil }
        
        self.friendUsername = friendUsername
        self.friendAvatarStringURL = friendAvatarStringURL
        self.friendId = friendId
        self.lastMessageContent = lastMessageContent
    }
    
    // MARK: Methods
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(friendId)
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.friendId == rhs.friendId
    }
}

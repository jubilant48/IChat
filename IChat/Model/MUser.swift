//
//  MUser.swift
//  IChat
//
//  Created by macbook on 05.01.2023.
//

import UIKit
import FirebaseFirestore

struct MUser: Hashable, Decodable {
    // MARK: Properties
    
    var username: String
    var email: String
    var avatarStringUrl: String
    var description: String
    var sex: String
    var id: String
    
    var representaton: [String: Any] {
        var representation = ["username": username]
        
        representation["email"] = email
        representation["avatarStringUrl"] = avatarStringUrl
        representation["description"] = description
        representation["sex"] = sex
        representation["uid"] = id
        
        return representation
    }
    
    // MARK: Init
    
    init(username: String, email: String, avatarStringUrl: String, description: String, sex: String, id: String) {
        self.username = username
        self.email = email
        self.avatarStringUrl = avatarStringUrl
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data() else { return nil }
        
        guard let username = data["username"] as? String,
              let email = data["email"] as? String,
              let avatarStringUrl = data["avatarStringUrl"] as? String,
              let description = data["description"] as? String,
              let sex = data["sex"] as? String,
              let id = data["uid"] as? String else { return nil }
        
        self.username = username
        self.email = email
        self.avatarStringUrl = avatarStringUrl
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let username = data["username"] as? String,
              let email = data["email"] as? String,
              let avatarStringUrl = data["avatarStringUrl"] as? String,
              let description = data["description"] as? String,
              let sex = data["sex"] as? String,
              let id = data["uid"] as? String else { return nil }
        
        self.username = username
        self.email = email
        self.avatarStringUrl = avatarStringUrl
        self.description = description
        self.sex = sex
        self.id = id
    }
    
    // MARK: Methods
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MUser, rhs: MUser) -> Bool {
        return lhs.id == rhs.id
    }
    
    func contains(filter: String?) -> Bool {
        guard let filter = filter else { return true }
        
        if filter.isEmpty  {
            return true
        }
        
        let lowercasedFilter = filter.lowercased()
        
        return username.lowercased().contains(lowercasedFilter)
    }
}

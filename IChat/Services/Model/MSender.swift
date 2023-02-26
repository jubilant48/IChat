//
//  MSender.swift
//  IChat
//
//  Created by macbook on 26.02.2023.
//

import UIKit
import MessageKit

class MSender: SenderType {
    // MARK: Properties
    
    var senderId: String
    var displayName: String
    
    // MARK: Init
    
    init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
}

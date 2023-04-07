//
//  WaitingChatsNavigation.swift
//  IChat
//
//  Created by macbook on 23.01.2023.
//

import UIKit

// MARK: - Protocol

protocol WaitingChatsNavigation: AnyObject {
    // MARK: - Methods
    
    func removeWaitingChat(chat: MChat)
    func changeToActive(chat: MChat)
}

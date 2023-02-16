//
//  WaitingChatsNavigation.swift
//  IChat
//
//  Created by macbook on 23.01.2023.
//

import UIKit

protocol WaitingChatsNavigation: AnyObject {
    func removeWaitingChat(chat: MChat)
    func changeToActive(chat: MChat)
}

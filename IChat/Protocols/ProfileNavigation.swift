//
//  ProfileNavigation.swift
//  IChat
//
//  Created by macbook on 07.04.2023.
//

import UIKit

// MARK: - Protocol

protocol ProfileNavigation: AnyObject {
    // MARK: - Methods
    
    func show(_ chat: MChat, for user: MUser) 
}

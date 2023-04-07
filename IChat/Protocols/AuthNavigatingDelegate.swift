//
//  AuthNavigatingDelegate.swift
//  IChat
//
//  Created by macbook on 11.01.2023.
//

import UIKit

// MARK: - Protocol

protocol AuthNavigatingDelegate : AnyObject {
    // MARK: - Methods
    
    func toLoginViewController()
    func toSignUpViewController()
}

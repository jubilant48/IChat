//
//  AuthNavigatingDelegate.swift
//  IChat
//
//  Created by macbook on 11.01.2023.
//

import UIKit

protocol AuthNavigatingDelegate : AnyObject {
    func toLoginViewController()
    func toSignUpViewController()
}

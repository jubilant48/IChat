//
//  SelfCongiguringCell.swift
//  IChat
//
//  Created by macbook on 04.01.2023.
//

import UIKit

protocol SelfCongiguringCell {
    static var reuseId: String { get }
    
    func configure<U: Hashable>(with value: U)
}

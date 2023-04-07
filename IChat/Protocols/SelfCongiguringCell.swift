//
//  SelfCongiguringCell.swift
//  IChat
//
//  Created by macbook on 04.01.2023.
//

import UIKit

// MARK: - Protocol

protocol SelfCongiguringCell {
    // MARK: - Properties
    
    static var reuseId: String { get }
    
    // MARK: - Methods
    
    func configure<U: Hashable>(with value: U)
}

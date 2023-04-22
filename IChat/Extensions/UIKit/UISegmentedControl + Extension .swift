//
//  SegmentedControl + Extension .swift
//  IChat
//
//  Created by macbook on 22.12.2022.
//

import UIKit

// MARK: - Extension

extension UISegmentedControl {
    // MARK: - Init
    
    convenience init(first: String, second: String) {
        self.init()
        
        self.insertSegment(withTitle: first, at: 0, animated: true)
        self.insertSegment(withTitle: second, at: 1, animated: true)
        
        self.selectedSegmentIndex = 0
    }
}

//
//  UIScrollView + Extension .swift
//  IChat
//
//  Created by macbook on 26.01.2023.
//

import UIKit

// MARK: - Extension

extension UIScrollView {
    // MARK: - Properties
    
    var isAtBottom: Bool {
        return contentOffset.y >= verticalOffsetForBottom
    }
    var verticalOffsetForBottom: CGFloat {
        let scrollViewHeight = bounds.height
        let scrollContentSizeHeight = contentSize.height
        let bottomInset = contentInset.bottom
        let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
        return scrollViewBottomOffset
    }
}

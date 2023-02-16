//
//  UIImage + Extension.swift
//  IChat
//
//  Created by macbook on 19.01.2023.
//

import UIKit

extension UIImage {
    // MARK: Properties
    
    var scaledToSafeUploadSize: UIImage? {
        let maxImageSideLenght: CGFloat = 480
        
        let largerSide: CGFloat = max(size.width, size.height)
        let ratioScale: CGFloat = largerSide > maxImageSideLenght ? largerSide / maxImageSideLenght : 1
        let newImageSize = CGSize(width: size.width / ratioScale, height: size.height / ratioScale)
        
        return image(scaledTo: newImageSize)
    }
    
    // MARK: Methods
    
    func image(scaledTo size: CGSize) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    
}

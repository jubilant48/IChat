//
//  ImageItem.swift
//  IChat
//
//  Created by macbook on 29.01.2023.
//

import UIKit
import MessageKit

struct ImageItem: MediaItem {
    // MARK: Properties
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

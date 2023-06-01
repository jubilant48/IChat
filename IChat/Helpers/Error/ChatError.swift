//
//  ChatError.swift
//  IChat
//
//  Created by macbook on 25.03.2023.
//

import UIKit

// MARK: - Enumeration

enum ChatError {
    case cannotUnwrapToMChat
}

// MARK: - Extension

extension ChatError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .cannotUnwrapToMChat:
            return NSLocalizedString("Невозможно конвертировать в MChat", comment: "")
        }
    }
}



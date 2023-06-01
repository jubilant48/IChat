//
//  UserError.swift
//  IChat
//
//  Created by macbook on 14.01.2023.
//

import UIKit

// MARK: - Enumerations

enum UserError {
    case notFilled
    case photoNotExist
    case cannotGetUserInfo
    case cannotUnwrapToMUser
}

// MARK: - Extension

extension UserError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Заполните все поля", comment: "")
        case .photoNotExist:
            return NSLocalizedString("Отсутствует фото", comment: "")
        case .cannotGetUserInfo:
            return NSLocalizedString("Невозможно загрузить информацию о User из Firebase", comment: "")
        case .cannotUnwrapToMUser:
            return NSLocalizedString("Невозможно конвертировать MUser из User", comment: "")
        }
    }
}

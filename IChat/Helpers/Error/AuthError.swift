//
//  AuthError.swift
//  IChat
//
//  Created by macbook on 11.01.2023.
//

import UIKit

// MARK: - Enumerations

enum AuthError {
    case notFilled
    case invalidEmail
    case passwordsNotMatched
    case uknownError
    case serverError
    case clientIdNotFound
    case tokenIdNotFound
}

// MARK: - Extension

extension AuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFilled:
            return NSLocalizedString("Заполните все поля", comment: "")
        case .invalidEmail:
            return NSLocalizedString("Формат почты не является доступным", comment: "")
        case .passwordsNotMatched:
            return NSLocalizedString("Пароли не совпадают", comment: "")
        case .uknownError:
            return NSLocalizedString("Неизвестная ошибка", comment: "")
        case .serverError:
            return NSLocalizedString("Ошибка сервера", comment: "")
        case .clientIdNotFound:
            return NSLocalizedString("Ошибка получения clientID", comment: "")
        case .tokenIdNotFound:
            return NSLocalizedString("Ошибка получения idToken", comment: "")
        }
    }
}

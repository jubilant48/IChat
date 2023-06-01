//
//  DateFormatter.swift
//  IChat
//
//  Created by macbook on 24.05.2023.
//

import UIKit

// MARK: - Class

final class DateHelper {
    // MARK: - Enumeration
    
    enum LocaleID: String {
        // MARK: - Cases
        
        case ru = "ru_RU"
        
        // MARK: - Properties
        
        var value: String { rawValue }
    }
    
    // MARK: - Methods
    
    static func format(for date: Date) -> String {
        let helper = DateHelper()
        let dateString: String
        
        let diff = date.distance(from: Date(), only: .day)
        
        switch diff {
        case 0:
            dateString = helper.time(from: date)
        case 1...7:
            dateString = helper.dayOfWeek(from: date)
        case 8...365:
            dateString = helper.format("dd.MM", from: date)
        case 366...:
            dateString = helper.format("dd.MM.yyyy", from: date)
        default:
            dateString = "Error"
        }
        
        return dateString
    }
    
    private func time(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: LocaleID.ru.value)
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: date)
    }
    
    private func dayOfWeek(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: LocaleID.ru.value)
        dateFormatter.dateFormat = "EEE"
        
        return dateFormatter.string(from: date)
    }
    
    private func format(_ format: String, from date: Date) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: LocaleID.ru.value)
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)
    }
    
}

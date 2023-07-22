//
//  Calendar + Extension.swift
//  IChat
//
//  Created by macbook on 02.06.2023.
//

import Foundation

// MARK: - Extension

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        
        return numberOfDays.day!
    }
}

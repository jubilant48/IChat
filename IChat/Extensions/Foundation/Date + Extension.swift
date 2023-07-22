//
//  Date.swift
//  IChat
//
//  Created by macbook on 26.02.2023.
//

import Foundation

// MARK: - Extension

extension Date {
    // MARK: - Methods

    func fullDistance(from date: Date, resultIn component: Calendar.Component, calendar: Calendar = .current) -> Int? {
        calendar.dateComponents([component], from: self, to: date).value(for: component)
    }

    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        print(days1)
        let days2 = calendar.component(component, from: date)
        print(days2)
        return days1 - days2
    }

    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        distance(from: date, only: component) == 0
    }
}

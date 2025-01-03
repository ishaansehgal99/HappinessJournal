//
//  DateExtensions.swift
//  HappinessJournal
//
//  Created by Ishaan Sehgal on 1/2/25.
//

import Foundation

extension Date {
    /// Returns the number of full days between the current date and the given date.
    func days(from date: Date) -> Int {
        let calendar = Calendar.current
        let startOfSelf = calendar.startOfDay(for: self)
        let startOfDate = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: startOfDate, to: startOfSelf)
        return components.day ?? 0
    }
}

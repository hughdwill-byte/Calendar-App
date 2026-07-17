//
//  FreeTimeModel.swift
//  Calendar App
//
//  Created by Minh Thu Nguyen on 13/7/2026.
//

import Foundation
struct TimeBlock: Hashable {
    let startHour: Int
    let endHour: Int
}
struct DayPlan: Identifiable {
    let id = UUID()
    let date: Date
    let events: [TimeBlock]
    let dynamicCardMessage: String
}
func makeDate(year: Int, month: Int, day: Int, hour: Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    return Calendar.current.date(from: components) ?? Date()
}

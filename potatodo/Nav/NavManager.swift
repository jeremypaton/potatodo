//
//  DateManager.swift
//  potatodo
//
//  Created by Jeremy Paton on 12/5/2025.
//

import Foundation
import SwiftUI

enum DateInterval: String, Codable {
    case day
    case week
    case month
}


@MainActor
class NavManager: ObservableObject {
    @Published private(set) var interval: DateInterval = .day
    @Published private(set) var currentDate: Date = Date()
    
    init() {
    }
    
    func setDate(_ date: Date) {
        currentDate = date
    }
    
    func setInterval(_ interval: DateInterval) {
        self.interval = interval
    }
    
    func _move(by direction: Int) {
        let (component, value): (Calendar.Component, Int)
        switch interval {
        case .day:
            component = .day
            value = 1 * direction
        case .week:
            component = .day
            value = 7 * direction
        case .month:
            component = .month
            value = 1 * direction
        }
        if let newDate = Calendar.current.date(byAdding: component, value: value, to: currentDate) {
            currentDate = newDate
        }
    }

    func moveNext() {
        _move(by: 1)
    }

    func movePrev() {
        _move(by: -1)
    }
    
    func moveToToday() {
        currentDate = Date()
        setInterval(.day)
    }
    
    func moveToMonth() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        if let monthStart = calendar.date(from: components) {
            currentDate = monthStart
        }
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(currentDate)
    }
    
    var title : String {
        switch interval {
        case .day:
            if isToday {
                return "TODAY"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                return formatter.string(from: currentDate).uppercased()
            }
        case .week:
            let calendar = Calendar.current
            let today = Date()
            let currentWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
            let nextWeekStart = calendar.date(byAdding: .day, value: 7, to: currentWeekStart)!
            let lastWeekStart = calendar.date(byAdding: .day, value: -7, to: currentWeekStart)!
            
            if calendar.isDate(currentDate, equalTo: currentWeekStart, toGranularity: .weekOfYear) {
                return "THIS WEEK"
            } else if calendar.isDate(currentDate, equalTo: nextWeekStart, toGranularity: .weekOfYear) {
                return "NEXT WEEK"
            } else if calendar.isDate(currentDate, equalTo: lastWeekStart, toGranularity: .weekOfYear) {
                return "LAST WEEK"
            } else {
                return "WEEK"
            }
        case .month:
            return "MONTH"
        }
    }
    
    var weekStart: Date {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: currentDate)
        let daysToSubtract = (weekday + 5) % 7
        if let weekStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: currentDate) {
            return weekStart
        }
        return currentDate
    }

    var subtitle : String  {
        let formatter = DateFormatter()
        
        switch interval {
            case .day:
                formatter.dateFormat = "MMM d yyyy"
            case .week:
                let weekEnd =  Calendar.current.date(byAdding: .day, value: 7, to: weekStart)
            
                let startFormatter = DateFormatter()
                startFormatter.dateFormat = "MMM d yyyy"
                let endFormatter = DateFormatter()
                endFormatter.dateFormat = "MMM d yyyy"
            
                let startStr = startFormatter.string(from: weekStart)
                let endStr = endFormatter.string(from: weekEnd!)
                return "\(startStr) - \(endStr)"

            case .month:
                formatter.dateFormat = "MMMM yyyy"
        }
        return formatter.string(from: currentDate).uppercased()
            
        }
        
}

#Preview {
    let navManager: NavManager = NavManager()
    VStack {
        TopNav_V(
            navManager: navManager
        )
        
        Spacer()
        Text("time: \(navManager.currentDate.formatted())")
        Spacer()
        
        BottomNav_V(
            navManager: navManager
        )
    }
    .background(Color(.green))
}

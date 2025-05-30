//
//  ReminderUtils.swift
//  potatodo
//
//  Created by Jeremy Paton on 25/5/2025.
//

import Foundation
import UserNotifications
import UIKit

struct ReminderUtils {
    private static var lastRecalcTime: Date?
    private static let minimumRecalcInterval: TimeInterval = 1.0 // 1 second minimum between recalculations
    static var reminderSummary : String = ""
    
    static func requestPermissions() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("Error requesting notification permissions: \(error)")
            return false
        }
    }
    
    static func removeAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        reminderSummary = ""
    }
    
    static func recalcReminders(userSettings : UserSettings, tasks: [Task]) async {
        // Check if we've recalculated too recently
        if let lastRecalc = lastRecalcTime,
           Date().timeIntervalSince(lastRecalc) < minimumRecalcInterval {
            print("Skipping reminder recalculation - too soon since last update")
            return
        }
        
        lastRecalcTime = Date()
        removeAllReminders()
        
        if !userSettings.notificationsEnabled || userSettings.profile.name == "DEBUG" || userSettings.profile.name == "TEST" {
            print("aborting reminder recalculation - notifications disabled or in debug / test mode")
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Get next 7 days starting from tomorrow
        let nextWeek = (1...7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: today)
        }
        
        for date in nextWeek {
            let tasksForDate = tasks.filter { task in
                if let taskDate = task.date {
                    return calendar.isDate(taskDate, inSameDayAs: date)
                }
                return false
            }
            
            let weekday = calendar.component(.weekday, from: date)
            let weekdayName = calendar.weekdaySymbols[weekday - 1]
            
            var reminderTitle: String
            var reminderText = ""
            
            if !tasksForDate.isEmpty {
                reminderTitle = "today's priorities:"
                for (index, task) in tasksForDate.enumerated() {
                    if(index != 0) {
                        reminderText += "\n"
                    }
                    reminderText += "🥔\(index + 1). \(task.title.lowercased())"
                }
            } else {
                reminderTitle = "time to plan your day!"
                reminderText = "🥔1. ?\n🥔2. ?\n🥔3. ?"
            }
            
            reminderSummary += "Weekday: \(weekdayName)\n"
            reminderSummary += "Reminder Title: \(reminderTitle)\n"
            reminderSummary += "Reminder Text: \(reminderText)\n\n"
            
            // Create notification content
            let content = UNMutableNotificationContent()
            content.title = reminderTitle
            content.body = reminderText
            content.sound = .default
            
            // Create date components for the trigger
            var dateComponents = calendar.dateComponents([.hour, .minute], from: userSettings.notificationTime)
            dateComponents.day = calendar.component(.day, from: date)
            dateComponents.month = calendar.component(.month, from: date)
            dateComponents.year = calendar.component(.year, from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: "reminder_\(date.timeIntervalSince1970)",
                content: content,
                trigger: trigger
            )
            
            // Schedule the notification
            do {
                try await UNUserNotificationCenter.current().add(request)
            } catch {
                print("Error scheduling reminder for \(weekdayName): \(error)")
            }
        }
//        print(reminderSummary)
    }
    
    static func setBadgeCount(_ count: Int) {
        print("Setting badge count to: \(count)") // Debug print
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }
    
}


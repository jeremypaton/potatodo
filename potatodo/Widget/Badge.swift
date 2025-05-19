//
//  Badge.swift
//  potatodo
//
//  Created by Jeremy Paton on 19/5/2025.
//

import SwiftUI
import UserNotifications

@MainActor
class BadgeManager: ObservableObject {
    static var shared: BadgeManager?
    private let taskManager: TaskManager
    private let notificationCenter = UNUserNotificationCenter.current()
    
    init(taskManager: TaskManager) {
        self.taskManager = taskManager
        setupObservers()
    }
    
    private func setupObservers() {
        // Observe task changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTaskChange),
            name: NSNotification.Name("TaskDidChange"),
            object: nil
        )
        
        // Initial badge update
        handleTaskChange()
    }
    
    @objc private func handleTaskChange() {
        let incompleteCount = countIncompleteTasksForToday()
        notificationCenter.setBadgeCount(incompleteCount) { error in
            if let error = error {
                print("Failed to update badge: \(error.localizedDescription)")
            }
        }
    }
    
    private func countIncompleteTasksForToday() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return taskManager.tasks.filter { task in
            calendar.isDate(task.date, inSameDayAs: today) && !task.isCompleted
        }.count
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


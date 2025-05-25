//import Foundation
//import UserNotifications
//import Combine
//import UIKit
//
//class NotificationsManager: ObservableObject {
//    @Published var defaultReminderText: String = "🥔 Time to plan your day!"
//    @Published var pendingNotifications: [UNNotificationRequest] = []
//    
//    private let notificationCenter = UNUserNotificationCenter.current()
//    private let dailyReminderIdentifier = "dailyReminder"
//    private var cancellables = Set<AnyCancellable>()
//    private let appDataStore: AppDataStore
//    
//    init(appDataStore: AppDataStore) {
//        self.appDataStore = appDataStore
//        
//        // Observe changes to notification settings
//        appDataStore.userSettings.$notificationsEnabled
//            .sink { [weak self] enabled in
//                self?.updateRemindersIfNeeded()
//            }
//            .store(in: &cancellables)
//        
//        appDataStore.userSettings.$notificationTime
//            .sink { [weak self] time in
//                self?.updateRemindersIfNeeded()
//            }
//            .store(in: &cancellables)
//        
//        // Observe changes to tasks to update badge count
//        appDataStore.taskData.$tasks
//            .sink { [weak self] tasks in
//                self?.updateBadgeCount(tasks: tasks)
//            }
//            .store(in: &cancellables)
//        
//        // Observe app lifecycle to update badge count when app becomes active
//        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
//            .sink { [weak self] _ in
//                self?.updateBadgeCount(tasks: self?.appDataStore.taskData.tasks ?? [])
//            }
//            .store(in: &cancellables)
//        
//        updatePendingNotifications()
//    }
//    
//    // MARK: - Badge Management
//    
//    private func updateBadgeCount(tasks: [Task]) {
//        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date())
//        
//        // Count incomplete tasks for today
//        let incompleteTasksCount = tasks.filter { task in
//            guard let taskDate = task.date else { return false }
//            return !task.isCompleted && calendar.isDate(taskDate, inSameDayAs: today)
//        }.count
//        
//        // Update badge count
//        DispatchQueue.main.async {
//            UIApplication.shared.applicationIconBadgeNumber = incompleteTasksCount
//            print("Updated badge count to: \(incompleteTasksCount)") // Debug log
//        }
//    }
//    
//    // MARK: - Permission Management
//    
//    func requestPermissions() {
////        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
////            DispatchQueue.main.async {
////                self?.appDataStore.userSettings.notificationsEnabled = granted
////                if granted {
////                    self?.updateRemindersIfNeeded()
////                    // Update badge count after permissions granted
////                    if let tasks = self?.appDataStore.taskData.tasks {
////                        self?.updateBadgeCount(tasks: tasks)
////                    }
////                } else {
////                    self?.removeAllReminders()
////                    // Clear badge count if notifications disabled
////                    UIApplication.shared.applicationIconBadgeNumber = 0
////                }
////            }
////        }
//    }
//    
//    // MARK: - Daily Reminder Management
//    
//    private func updateRemindersIfNeeded() {
//        if appDataStore.userSettings.notificationsEnabled {
//            scheduleDailyReminder()
//        } else {
//            removeAllReminders()
//        }
//    }
//    
//    func scheduleDailyReminder() {
//        guard appDataStore.userSettings.notificationsEnabled else { return }
//        
//        // Remove existing daily reminder
//        notificationCenter.removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
//        
//        // Create new daily reminder
//        let content = UNMutableNotificationContent()
//        content.title = "Daily Reminder"
//        content.body = defaultReminderText
//        content.sound = .default
//        
//        // Get hour and minute from notificationTime
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.hour, .minute], from: appDataStore.userSettings.notificationTime)
//        
//        // Create trigger for daily notification
//        var triggerComponents = DateComponents()
//        triggerComponents.hour = components.hour
//        triggerComponents.minute = components.minute
//        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
//        
//        // Create request
//        let request = UNNotificationRequest(
//            identifier: dailyReminderIdentifier,
//            content: content,
//            trigger: trigger
//        )
//        
//        // Schedule notification
//        notificationCenter.add(request) { [weak self] error in
//            if let error = error {
//                print("Error scheduling daily reminder: \(error.localizedDescription)")
//            }
//            self?.updatePendingNotifications()
//        }
//    }
//    
//    // MARK: - Specific Day Reminder Management
//    
//    func setReminderText(for date: Date, text: String) {
//        let identifier = getIdentifier(for: date)
//        
//        // Remove existing reminder for this date
//        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
//        
//        // Create new reminder
//        let content = UNMutableNotificationContent()
//        content.title = "Reminder"
//        content.body = text
//        content.sound = .default
//        
//        // Create trigger for specific date using the daily time
//        let calendar = Calendar.current
//        var components = calendar.dateComponents([.year, .month, .day], from: date)
//        let dailyComponents = calendar.dateComponents([.hour, .minute], from: appDataStore.userSettings.notificationTime)
//        components.hour = dailyComponents.hour
//        components.minute = dailyComponents.minute
//        
//        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
//        
//        // Create request
//        let request = UNNotificationRequest(
//            identifier: identifier,
//            content: content,
//            trigger: trigger
//        )
//        
//        // Schedule notification
//        notificationCenter.add(request) { [weak self] error in
//            if let error = error {
//                print("Error scheduling reminder: \(error.localizedDescription)")
//            }
//            self?.updatePendingNotifications()
//        }
//    }
//    
//    func getReminderText(for date: Date, completion: @escaping (String?) -> Void) {
//        let identifier = getIdentifier(for: date)
//        
//        notificationCenter.getPendingNotificationRequests { requests in
//            if let request = requests.first(where: { $0.identifier == identifier }) {
//                completion(request.content.body)
//            } else {
//                completion(nil)
//            }
//        }
//    }
//    
//    func removeReminder(for date: Date) {
//        let identifier = getIdentifier(for: date)
//        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
//        updatePendingNotifications()
//    }
//    
//    func addReminder(for date: Date, text: String) {
//        setReminderText(for: date, text: text)
//    }
//    
//    // MARK: - Task-specific Reminder Management
//    
//    func updateRemindersForDay(_ date: Date, tasks: [Task]) {
//        let calendar = Calendar.current
//        let dayStart = calendar.startOfDay(for: date)
//        
//        // Remove any existing reminder for this day
//        removeReminder(for: dayStart)
//        
//        // If there are incomplete tasks, create a new reminder
//        let incompleteTasks = tasks.filter { !$0.isCompleted }
//        if !incompleteTasks.isEmpty {
//            let reminderText = incompleteTasks.map { "🥔 \($0.title)" }.joined(separator: "\n")
//            setReminderText(for: dayStart, text: reminderText)
//            updatePendingNotifications()
//        }
//    }
//    
//    // MARK: - Private Helpers
//    
//    private func getIdentifier(for date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
//        return "reminder-\(formatter.string(from: date))"
//    }
//    
//    func removeAllReminders() {
//        notificationCenter.removeAllPendingNotificationRequests()
//        updatePendingNotifications()
//        // Clear badge count when removing all reminders
//        UIApplication.shared.applicationIconBadgeNumber = 0
//    }
//    
//    func updatePendingNotifications() {
//        notificationCenter.getPendingNotificationRequests { [weak self] requests in
//            DispatchQueue.main.async {
//                self?.pendingNotifications = requests
//            }
//        }
//    }
//} 

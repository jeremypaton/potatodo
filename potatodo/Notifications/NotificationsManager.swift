import Foundation
import UserNotifications

class NotificationsManager: ObservableObject {
    @Published var isEnabled: Bool = false
    @Published var dailyTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
    @Published var defaultReminderText: String = "🥔 Time to plan your day!"
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let dailyReminderIdentifier = "dailyReminder"
    
    init() {
        // Load saved settings
        loadSettings()
        updatePendingNotifications()
    }
    
    // MARK: - Permission Management
    
    func requestPermissions() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isEnabled = granted
                if granted {
                    self.saveSettings()
                    self.scheduleDailyReminder()
                }
            }
        }
    }
    
    // MARK: - Settings Management
    
    func setDailyTime(_ time: Date) {
        dailyTime = time
        saveSettings()
        if isEnabled {
            scheduleDailyReminder()
        }
    }
    
    func setDefaultReminderText(_ text: String) {
        defaultReminderText = text
        saveSettings()
    }
    
    func enableNotifications() {
        isEnabled = true
        saveSettings()
        scheduleDailyReminder()
    }
    
    func disableNotifications() {
        isEnabled = false
        saveSettings()
        removeAllReminders()
    }
    
    // MARK: - Daily Reminder Management
    
    func scheduleDailyReminder() {
        guard isEnabled else { return }
        
        // Remove existing daily reminder
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
        
        // Create new daily reminder
        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = defaultReminderText
        content.sound = .default
        
        // Get hour and minute from dailyTime
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: dailyTime)
        
        // Create trigger for daily notification
        var triggerComponents = DateComponents()
        triggerComponents.hour = components.hour
        triggerComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: dailyReminderIdentifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error.localizedDescription)")
            }
            self.updatePendingNotifications()
        }
    }
    
    // MARK: - Specific Day Reminder Management
    
    func setReminderText(for date: Date, text: String) {
        let identifier = getIdentifier(for: date)
        
        // Remove existing reminder for this date
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // Create new reminder
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = text
        content.sound = .default
        
        // Create trigger for specific date
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling reminder: \(error.localizedDescription)")
            }
            self.updatePendingNotifications()
        }
    }
    
    func getReminderText(for date: Date, completion: @escaping (String?) -> Void) {
        let identifier = getIdentifier(for: date)
        
        notificationCenter.getPendingNotificationRequests { requests in
            if let request = requests.first(where: { $0.identifier == identifier }) {
                completion(request.content.body)
            } else {
                completion(nil)
            }
        }
    }
    
    func removeReminder(for date: Date) {
        let identifier = getIdentifier(for: date)
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        updatePendingNotifications()
    }
    
    func addReminder(for date: Date, text: String) {
        setReminderText(for: date, text: text)
    }
    
    // MARK: - Task-specific Reminder Management
    
    func updateRemindersForDay(_ date: Date, tasks: [Task]) {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        
        print("Updating reminders for date: \(dayStart)")
        print("Number of tasks: \(tasks.count)")
        
        // Remove any existing reminder for this day
        removeReminder(for: dayStart)
        
        // If there are incomplete tasks, create a new reminder
        let incompleteTasks = tasks.filter { !$0.isCompleted }
        print("Number of incomplete tasks: \(incompleteTasks.count)")
        
        if !incompleteTasks.isEmpty {
            let reminderText = incompleteTasks.map { "🥔 \($0.title)" }.joined(separator: "\n")
            print("Setting reminder text: \(reminderText)")
            setReminderText(for: dayStart, text: reminderText)
            // Ensure we update the pending notifications list
            updatePendingNotifications()
        }
    }
    
    // MARK: - Private Helpers
    
    private func getIdentifier(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "reminder-\(formatter.string(from: date))"
    }
    
    func removeAllReminders() {
        notificationCenter.removeAllPendingNotificationRequests()
        updatePendingNotifications()
    }
    
    func updatePendingNotifications() {
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            DispatchQueue.main.async {
                self?.pendingNotifications = requests
                print("Updated pending notifications. Count: \(requests.count)")
                for request in requests {
                    print("Pending notification: \(request.identifier) - \(request.content.body)")
                }
            }
        }
    }
    
    // MARK: - Persistence
    
    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(isEnabled, forKey: "notificationsEnabled")
        defaults.set(dailyTime, forKey: "dailyNotificationTime")
//        defaults.set(defaultReminderText, forKey: "defaultReminderText")
    }
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        isEnabled = defaults.bool(forKey: "notificationsEnabled")
        if let savedTime = defaults.object(forKey: "dailyNotificationTime") as? Date {
            dailyTime = savedTime
        }
//        if let savedText = defaults.string(forKey: "defaultReminderText") {
//            defaultReminderText = savedText
//        }
    }
} 

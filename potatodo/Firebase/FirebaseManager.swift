import Foundation
import FirebaseCore
import FirebaseAnalytics
import Network

class FirebaseManager {
    static let shared = FirebaseManager()
    private let networkMonitor = NWPathMonitor()
    private var isNetworkAvailable = false
    
    private init() {
        setupNetworkMonitoring()
        
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Enable analytics debug mode
        Analytics.setAnalyticsCollectionEnabled(true)
        #if DEBUG
        Analytics.setAnalyticsCollectionEnabled(true)
        print("Firebase Analytics initialized with debug mode enabled")
        #endif
        
        // Log a test event to verify analytics is working
        logTestEvent()
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            self?.isNetworkAvailable = path.status == .satisfied
            print("Network status changed: \(path.status)")
        }
        networkMonitor.start(queue: DispatchQueue.global())
    }
    
    private func logTestEvent() {
        if isNetworkAvailable {
            Analytics.logEvent("app_launch", parameters: [
                "debug_mode": true,
                "timestamp": Date().timeIntervalSince1970,
                "network_available": true
            ])
            print("Test analytics event logged")
        } else {
            print("Network not available, skipping test event")
        }
    }
    
    // MARK: - Page View Tracking
    
    func trackPageView(_ pageName: String) {
        if isNetworkAvailable {
            Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                AnalyticsParameterScreenName: pageName,
                AnalyticsParameterScreenClass: pageName
            ])
            print("Tracked page view: \(pageName)")
        } else {
            print("Network not available, skipping page view tracking for: \(pageName)")
        }
    }
    
    // MARK: - Task Action Tracking
    
    func trackAddTask() {
        if isNetworkAvailable {
            Analytics.logEvent("add_task", parameters: nil)
            print("Tracked add task event")
        }
    }
    
    func trackEditTask() {
        if isNetworkAvailable {
            Analytics.logEvent("edit_task", parameters: nil)
            print("Tracked edit task event")
        }
    }
    
    func trackDeleteTask() {
        if isNetworkAvailable {
            Analytics.logEvent("delete_task", parameters: nil)
            print("Tracked delete task event")
        }
    }
    
    func trackSwapTask() {
        if isNetworkAvailable {
            Analytics.logEvent("swap_task", parameters: nil)
            print("Tracked swap task event")
        }
    }
    
    // MARK: - Task Count Tracking
    
    func trackTaskCount(_ count: Int) {
        if isNetworkAvailable {
            Analytics.logEvent("task_count", parameters: [
                "count": count
            ])
            print("Tracked task count: \(count)")
        }
    }
    
    // MARK: - Settings Tracking
    
    func trackNotificationTimeChange(_ time: Date) {
        if isNetworkAvailable {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let timeString = formatter.string(from: time)
            
            Analytics.logEvent("notification_time_change", parameters: [
                "time": timeString
            ])
            print("Tracked notification time change: \(timeString)")
        }
    }
    
    func trackNotificationsEnabled(_ enabled: Bool) {
        if isNetworkAvailable {
            Analytics.logEvent("notifications_enabled", parameters: [
                "enabled": enabled
            ])
            print("Tracked notifications enabled: \(enabled)")
        }
    }
    
    deinit {
        networkMonitor.cancel()
    }
} 
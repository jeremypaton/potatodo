import Foundation
import FirebaseCore
import FirebaseAnalytics
import Network

class FirebaseManager {
    static let shared = FirebaseManager()
    private let networkMonitor = NWPathMonitor()
    private var isNetworkAvailable = false
    
    #if DEBUG || TEST
    private let isAnalyticsEnabled = false
    #else
    private let isAnalyticsEnabled = true
    #endif
    
    private init() {
        setupNetworkMonitoring()
        
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Set analytics collection based on build configuration
        Analytics.setAnalyticsCollectionEnabled(isAnalyticsEnabled)
        print("Firebase Analytics \(isAnalyticsEnabled ? "enabled" : "disabled")")
        
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
        if isAnalyticsEnabled && isNetworkAvailable {
            Analytics.logEvent("app_launch", parameters: [
                "debug_mode": !isAnalyticsEnabled,
                "timestamp": Date().timeIntervalSince1970,
                "network_available": true
            ])
            print("Test analytics event logged")
        } else {
            print("Analytics disabled or network not available, skipping test event")
        }
    }
    
    // MARK: - Page View Tracking
    
    func trackPageView(_ pageName: String) {
        if isAnalyticsEnabled && isNetworkAvailable {
            Analytics.logEvent(AnalyticsEventScreenView, parameters: [
                AnalyticsParameterScreenName: pageName,
                AnalyticsParameterScreenClass: pageName
            ])
            print("Tracked page view: \(pageName)")
        } else {
            print("Analytics disabled or network not available, skipping page view tracking for: \(pageName)")
        }
    }
    
    // MARK: - Task Action Tracking
    
    func trackAddTask() {
        if isAnalyticsEnabled && isNetworkAvailable {
            Analytics.logEvent("add_task", parameters: nil)
            print("Tracked add task event")
        }
    }
    
    func trackEditTask() {
        if isAnalyticsEnabled && isNetworkAvailable {
            Analytics.logEvent("edit_task", parameters: nil)
            print("Tracked edit task event")
        }
    }
    
    func trackDeleteTask() {
        if isAnalyticsEnabled && isNetworkAvailable {
            Analytics.logEvent("delete_task", parameters: nil)
            print("Tracked delete task event")
        }
    }
    
    func trackSwapTask() {
        if isAnalyticsEnabled && isNetworkAvailable {
            Analytics.logEvent("swap_task", parameters: nil)
            print("Tracked swap task event")
        }
    }
    
    // MARK: - Task Count Tracking
    
    func trackTaskCount(_ count: Int) {
        if isAnalyticsEnabled && isNetworkAvailable {
            Analytics.logEvent("task_count", parameters: [
                "count": count
            ])
            print("Tracked task count: \(count)")
        }
    }
    
    // MARK: - Settings Tracking
    
    func trackNotificationTimeChange(_ time: Date) {
        if isAnalyticsEnabled && isNetworkAvailable {
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
        if isAnalyticsEnabled && isNetworkAvailable {
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

import Foundation
import FirebaseCore
import FirebaseAnalytics
import Network

class FirebaseManager {
    static let shared = FirebaseManager()
    private let networkMonitor = NWPathMonitor()
    private var isNetworkAvailable = false
    private var isFirebaseConfigured = false
    
    #if DEBUG || TEST
    private let isAnalyticsEnabled = false
    #else
    private let isAnalyticsEnabled = true
    #endif
    
    private init() {
        setupNetworkMonitoring()
        
        // Initialize Firebase only if GoogleService-Info.plist exists and is valid
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let apiKey = plist["API_KEY"] as? String,
           !apiKey.contains("YOUR_") {
            do {
                FirebaseApp.configure()
                Analytics.setAnalyticsCollectionEnabled(isAnalyticsEnabled)
                isFirebaseConfigured = true
                print("Firebase Analytics \(isAnalyticsEnabled ? "enabled" : "disabled")")
                logTestEvent()
            } catch {
                print("⚠️ Firebase configuration failed: \(error). App will run without analytics.")
                isFirebaseConfigured = false
            }
        } else {
            print("⚠️ Firebase not configured: GoogleService-Info.plist not found or invalid. App will run without analytics.")
            isFirebaseConfigured = false
        }
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
        if isFirebaseConfigured && isAnalyticsEnabled && isNetworkAvailable {
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
        if isFirebaseConfigured && isAnalyticsEnabled && isNetworkAvailable {
            Analytics.logEvent("add_task", parameters: nil)
            print("Tracked add task event")
        }
    }
    
    func trackEditTask() {
        if isFirebaseConfigured && isAnalyticsEnabled && isNetworkAvailable {
            Analytics.logEvent("edit_task", parameters: nil)
            print("Tracked edit task event")
        }
    }
    
    func trackDeleteTask() {
        if isFirebaseConfigured && isAnalyticsEnabled && isNetworkAvailable {
            Analytics.logEvent("delete_task", parameters: nil)
            print("Tracked delete task event")
        }
    }
    
    func trackSwapTask() {
        if isFirebaseConfigured && isAnalyticsEnabled && isNetworkAvailable {
            Analytics.logEvent("swap_task", parameters: nil)
            print("Tracked swap task event")
        }
    }
    
    // MARK: - Task Count Tracking
    
    func trackTaskCount(_ count: Int) {
        if isFirebaseConfigured && isAnalyticsEnabled && isNetworkAvailable {
            Analytics.logEvent("task_count", parameters: [
                "count": count
            ])
            print("Tracked task count: \(count)")
        }
    }
    
    // MARK: - Settings Tracking
    
    func trackNotificationTimeChange(_ time: Date) {
        if isFirebaseConfigured && isAnalyticsEnabled && isNetworkAvailable {
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
        if isFirebaseConfigured && isAnalyticsEnabled && isNetworkAvailable {
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

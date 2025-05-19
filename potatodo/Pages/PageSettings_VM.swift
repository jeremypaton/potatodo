import SwiftUI

struct PageSettings_VM: View {
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var notificationsManager: NotificationsManager
    @State private var notificationTime = Date()
    
    var body: some View {
        Form {
            Toggle("Enable Notifications", isOn: $settings.notificationsEnabled)
                .onChange(of: settings.notificationsEnabled) { oldValue, newValue in
                    if newValue {
                        notificationsManager.requestPermissions()
                    }
                }
            
            if settings.notificationsEnabled {
                DatePicker("Daily Reminder Time",
                         selection: $notificationTime,
                         displayedComponents: .hourAndMinute)
                    .onChange(of: notificationTime) { oldValue, newValue in
                        settings.notificationTime = newValue
                        notificationsManager.setDailyTime(newValue)
                    }
            }
        }
        .onAppear {
            notificationTime = settings.notificationTime
        }
    }
}

#Preview {
    let settings = Settings()
    let notificationsManager = NotificationsManager()
    return PageSettings_VM()
        .environmentObject(settings)
        .environmentObject(notificationsManager)
} 

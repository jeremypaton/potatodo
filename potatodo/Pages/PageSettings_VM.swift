import SwiftUI

struct PageSettings_VM: View {
    @ObservedObject var appManager: AppManager
    @State private var notificationTime = Date()
    
    var body: some View {
        Form {
            Text("TODO")
//            Toggle("Enable Notifications", isOn: $appManager.settings.notificationsEnabled)
//                .onChange(of: appManager.settings.notificationsEnabled) { oldValue, newValue in
//                    if newValue {
//                        appManager.notificationsManager.requestPermissions()
//                    }
//                }
//            
//            if appManager.settings.notificationsEnabled {
//                DatePicker("Daily Reminder Time",
//                         selection: $notificationTime,
//                         displayedComponents: .hourAndMinute)
//                    .onChange(of: notificationTime) { oldValue, newValue in
//                        appManager.settings.notificationTime = newValue
//                        appManager.notificationsManager.setDailyTime(newValue)
//                    }
//            }
        }
        .onAppear {
            notificationTime = appManager.appDataStore.userSettings.notificationTime
        }
    }
}

#Preview {
    let appManager = AppManager()
    return PageSettings_VM(appManager: appManager)
} 

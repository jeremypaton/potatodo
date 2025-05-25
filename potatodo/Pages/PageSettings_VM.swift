import SwiftUI

struct PageSettings_VM: View {
    @ObservedObject var appManager: AppManager
    @State private var notificationTime = Date()
    @State private var selectedBadgeCount = 0
    
    var body: some View {
        Form {
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: Binding(
                    get: { appManager.appDataStore.userSettings.notificationsEnabled },
                    set: { wantEnabled in
                        if wantEnabled {
                            let enabled = ReminderUtils.requestPermissions()
                            appManager.setNotificationsEnabled(enabled)
                        } else {
                            ReminderUtils.removeAllReminders()
                        }
                    }
                ))
                
                if appManager.appDataStore.userSettings.notificationsEnabled {
                    DatePicker("Daily Reminder Time",
                             selection: Binding(
                                get: { appManager.appDataStore.userSettings.notificationTime },
                                set: { newValue in
                                    ReminderUtils.recalcReminders(appManager: appManager)
                                }
                             ),
                             displayedComponents: .hourAndMinute)
                
                }
                
                Picker("Badge Count", selection: $selectedBadgeCount) {
                    Text("0").tag(0)
                    Text("1").tag(1)
                    Text("2").tag(2)
                    Text("3").tag(3)
                    Text("4").tag(4)
                    Text("5").tag(5)
                }
                .onChange(of: selectedBadgeCount) { oldValue, newValue in
                    ReminderUtils.setBadgeCount(newValue)
                }
            }
            
            Section(header: Text("Profile")) {
                Picker("Profile", selection: Binding(
                    get: { appManager.appDataStore.userSettings.profile.name },
                    set: { newValue in
                        appManager.setProfileByName(newValue)
                    }
                )) {
                    Text("DEBUG").tag("DEBUG")
                    Text("TEST").tag("TEST")
                    Text("defaultUser").tag("defaultUser")
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
        .onAppear {
            notificationTime = appManager.appDataStore.userSettings.notificationTime
            // Initialize badge count picker with current value
            selectedBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        }
    }
}

#Preview {
    let appManager = AppManager()
    return PageSettings_VM(appManager: appManager)
} 



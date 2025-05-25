import SwiftUI

struct PageSettings_VM: View {
    @ObservedObject var appManager: AppManager
    @State private var notificationTime = Date()
    
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
        }
    }
}

#Preview {
    let appManager = AppManager()
    return PageSettings_VM(appManager: appManager)
} 



import SwiftUI

struct PageSettings_VM: View {
    @ObservedObject var appManager: AppManager
    @State private var notificationTime = Date()
    @State private var selectedBadgeCount = 0
    
    var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }

    var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
    }
    
    var body: some View {
        Form {
            Section(header: Text("About")) {
                Text("Version: \(version)")
                Text("Build: \(build)")
                #if DEBUG
                Text("Config: DEBUG")
                #elseif TEST
                Text("Config: TEST")
                #else
                Text("Config: RELEASE")
                #endif
            }
            
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: Binding(
                    get: { appManager.appDataStore.userSettings.notificationsEnabled },
                    set: { wantEnabled in
                        if wantEnabled {
                            _Concurrency.Task {
                                let enabled = await ReminderUtils.requestPermissions()
                                appManager.setNotificationsEnabled(enabled)
                                
                                _Concurrency.Task {
                                    await ReminderUtils.recalcReminders(
                                        userSettings: appManager.appDataStore.userSettings,
                                        tasks: appManager.getTasks()
                                    )
                                }
                            }
                        } else {
                            appManager.setNotificationsEnabled(false)
                            
                            _Concurrency.Task {
                                await ReminderUtils.recalcReminders(
                                    userSettings: appManager.appDataStore.userSettings,
                                    tasks: appManager.getTasks()
                                )
                            }
                        }
                    }
                ))
                
                if appManager.appDataStore.userSettings.notificationsEnabled {
                    DatePicker("Daily Reminder Time",
                             selection: Binding(
                                get: { appManager.appDataStore.userSettings.notificationTime },
                                set: { newValue in
                                    appManager.setNotificationTime(newValue)
                                    _Concurrency.Task {
                                        await ReminderUtils.recalcReminders(
                                            userSettings: appManager.appDataStore.userSettings,
                                            tasks: appManager.getTasks()
                                        )
                                    }
                                }
                             ),
                             displayedComponents: .hourAndMinute)
                }
                
//                Picker("Badge Count", selection: $selectedBadgeCount) {
//                    Text("0").tag(0)
//                    Text("1").tag(1)
//                    Text("2").tag(2)
//                    Text("3").tag(3)
//                    Text("4").tag(4)
//                    Text("5").tag(5)
//                }
//                .onChange(of: selectedBadgeCount) { oldValue, newValue in
//                    ReminderUtils.setBadgeCount(newValue)
//                }
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
            
            Section(header: Text("Intro")) {
                Toggle("Show Intro", isOn: Binding(
                    get: { appManager.appDataStore.userSettings.showIntro },
                    set: { newValue in
                        appManager.setShowIntro(newValue)
                    }
                ))
                
                if appManager.appDataStore.userSettings.newUser {
                    Text("New User: Yes")
                        .foregroundColor(.gray)
                }
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



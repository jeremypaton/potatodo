import SwiftUI
import UserNotifications

struct PageSettings_VM: View {
    @ObservedObject var appManager: AppManager
    @State private var notificationTime = Date()
    @State private var selectedBadgeCount = 0
    @State private var selectedTab: SettingsTab = .main
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    
    enum SettingsTab: String, CaseIterable {
        case main = "Main"
        case debug = "Debug"
    }
    
    var version: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }

    var build: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title and Subtitle
            VStack(spacing: 4) {
                Text("SETTINGS")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .background(Color.clear)
                Text("app preferences")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
            .padding(10)
            
            // Tab Picker
            Picker("Settings Tab", selection: $selectedTab) {
                ForEach(SettingsTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // Content based on selected tab
            if selectedTab == .main {
                mainSettingsView
            } else {
                debugSettingsView
            }
        }
        .task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            notificationStatus = settings.authorizationStatus
        }
    }
    
    var mainSettingsView: some View {
        Form {
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
            }
            
            Section(header: Text("Profile")) {
                Picker("User Profile", selection: Binding(
                    get: { appManager.appDataStore.userSettings.profile.name },
                    set: { newValue in
                        appManager.setProfileByName(newValue)
                    }
                )) {
                    Text("defaultUser").tag("defaultUser")
                    Text("potatoUser").tag("potatoUser")
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            Section("Intro") {
                Button("Replay Intro") {
                    appManager.setShowIntro(true)
                }
            }
        }
    }
    
    func string(from status: UNAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .denied: return "Denied"
        case .authorized: return "Authorized"
        case .provisional: return "Provisional"
        case .ephemeral: return "Ephemeral"
        @unknown default: return "Unknown"
        }
    }
    
    var debugSettingsView: some View {
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
                Text("notificationStatus: \(string(from:notificationStatus))")
            }
            
            Section(header: Text("Debug Tools")) {
                Button("Open Debug View") {
                    withAnimation {
                        appManager.toggleDebugView()
                    }
                }
            }
            
            Section(header: Text("All Profiles")) {
                Picker("All Profiles", selection: Binding(
                    get: { appManager.appDataStore.userSettings.profile.name },
                    set: { newValue in
                        appManager.setProfileByName(newValue)
                    }
                )) {
                    Text("DEBUG").tag("DEBUG")
                    Text("TEST").tag("TEST")
                    Text("defaultUser").tag("defaultUser")
                    Text("potatoUser").tag("potatoUser")
                }
                .pickerStyle(MenuPickerStyle())
            }
        }
    }
}

#Preview {
    let appManager = AppManager()
    return PageSettings_VM(appManager: appManager)
} 



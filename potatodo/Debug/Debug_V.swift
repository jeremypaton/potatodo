//
//  Debug_V.swift
//  potatodo
//
//  Created by Jeremy Paton on 16/5/2025.
//

import SwiftUI

// MARK: - Task Debug View
struct TaskDebugView: View {
    let tasks: [Task]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(tasks) { task in
                    TaskDebugItemView(task: task)
                }
            }
            .padding()
        }
    }
}

struct TaskDebugItemView: View {
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("ID: \(task.id)")
            Text("Title: \(task.title)")
            Text("Completed: \(task.isCompleted ? "Yes" : "No")")
            Text("Color: \(task.color.rawValue)")
            if let date = task.date {
                Text("Date: \(date.formatted())")
            } else {
                Text("Date: Unscheduled")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Message Debug View
struct MessageDebugView: View {
    @ObservedObject var messageManager: MessageManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("All Messages")
                    .font(.headline)
                ForEach(messageManager.messages.indices, id: \.self) { index in
                    MessageDebugItemView(message: messageManager.messages[index])
                }
                
                Text("Recent Messages")
                    .font(.headline)
                    .padding(.top)
                ForEach(messageManager.recentMessages, id: \.self) { message in
                    Text(message)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

struct MessageDebugItemView: View {
    let message: Message
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Level: \(message.level)")
            Text("Text: \(message.text)")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Notifications Debug View
struct NotificationsDebugView: View {
//    @ObservedObject var notificationsManager: NotificationsManager
    
    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 10) {
//                NotificationsSettingsView(notificationsManager: notificationsManager)
//                PendingNotificationsView(notifications: notificationsManager.pendingNotifications)
//            }
//            .padding()
//        }
    }
}

struct NotificationsSettingsView: View {
//    @ObservedObject var notificationsManager: NotificationsManager
//    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Settings")
                .font(.headline)
//            Text("Notifications Enabled: \(notificationsManager.isEnabled ? "Yes" : "No")")
//            Text("Daily Time: \(notificationsManager.dailyTime.formatted(date: .omitted, time: .shortened))")
//            Text("Default Reminder Text: \(notificationsManager.defaultReminderText)")
        }
    }
}

struct PendingNotificationsView: View {
    let notifications: [UNNotificationRequest]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pending Notifications")
                .font(.headline)
                .padding(.top)
            ForEach(notifications, id: \.identifier) { notification in
                NotificationDebugItemView(notification: notification)
            }
        }
    }
}

struct NotificationDebugItemView: View {
    let notification: UNNotificationRequest
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("ID: \(notification.identifier)")
            Text("Title: \(notification.content.title)")
            Text("Body: \(notification.content.body)")
            if let trigger = notification.trigger as? UNCalendarNotificationTrigger {
                Text("Next Trigger: \(trigger.nextTriggerDate()?.formatted() ?? "Unknown")")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Settings Debug View
struct SettingsDebugView: View {
    @ObservedObject var appManager: AppManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("App Settings")
                    .font(.headline)
                
                VStack(alignment: .leading) {
                    Text("Profile")
                        .font(.subheadline)
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
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
        }
    }
}

// MARK: - Main Debug View
struct Debug_V: View {
    @State private var selectedTab = 0
    @ObservedObject var appManager: AppManager
//    @ObservedObject var messageManager: MessageManager
//    @ObservedObject var notificationsManager: NotificationsManager
//    @ObservedObject var taskManager: TaskManager
    
    init(appManager: AppManager) {
        self.appManager = appManager
//        self._messageManager = ObservedObject(wrappedValue: appManager.getMessageManagerForMessageView())
//        self._notificationsManager = ObservedObject(wrappedValue: appManager.getNotificationsManagerForNotificationsView())
//        self._taskManager = ObservedObject(wrappedValue: appManager.getTaskManagerForTaskView())
    }
    
    var body: some View {
        VStack {
            CloseButton(appManager: appManager)
            
            Picker("View", selection: $selectedTab) {
                Text("Tasks").tag(0)
                Text("Messages").tag(1)
                Text("Notifications").tag(2)
                Text("Settings").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            TabView(selection: $selectedTab) {
                TaskDebugView(tasks: appManager.getTasks())
                    .tag(0)
                
                MessageDebugView(messageManager: appManager.getMessageManagerForMessageView())
                    .tag(1)
                
                NotificationsDebugView()
                    .tag(2)
                
                SettingsDebugView(appManager: appManager)
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .background(Color(.systemBackground))
//        .onAppear {
//            notificationsManager.updatePendingNotifications()
//        }
    }
}

struct CloseButton: View {
    let appManager: AppManager
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: { appManager.hideDebugView() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            .padding(.trailing)
        }
    }
}

#Preview {
    let appManager = AppManager()
    return Debug_V(appManager: appManager)
}


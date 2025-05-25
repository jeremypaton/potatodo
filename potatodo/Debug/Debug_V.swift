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
            Text("Title: \(task.title)")
                .font(.system(size: 20))
                .bold()
            Text("Completed: \(task.isCompleted ? "Yes" : "No")")
                .font(.system(size: 14))
            Text("Color: \(task.color.rawValue)")
                .font(.system(size: 14))
            if let date = task.date {
                Text("Date: \(date.formatted())")
                    .font(.system(size: 14))
            } else {
                Text("Date: Unscheduled")
                    .font(.system(size: 14))
            }
            Text("ID: \(task.id)")                .font(.system(size: 10))
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
                ForEach(Array(messageManager.messages.grouped(by: { $0.level }).keys.sorted()), id: \.self) { level in
                    VStack(alignment: .leading) {
                        Text("Level: \(level)")
                            .font(.subheadline)
                            .padding(.bottom, 4)
                        ForEach(messageManager.messages.filter { $0.level == level }, id: \.text) { message in
                            Text(message.text)
                                .padding(.leading, 8)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
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

// MARK: - Helper Extension
extension Array {
    func grouped<T: Hashable>(by key: (Element) -> T) -> [T: [Element]] {
        var result: [T: [Element]] = [:]
        for element in self {
            let keyValue = key(element)
            if result[keyValue] == nil {
                result[keyValue] = []
            }
            result[keyValue]?.append(element)
        }
        return result
    }
}

// MARK: - Notifications Debug View
struct NotificationsDebugView: View {
    @State private var pendingNotifications: [UNNotificationRequest] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Pending Notifications")
                    .font(.headline)
                    .padding(.top)
                
                ForEach(pendingNotifications, id: \.identifier) { notification in
                    NotificationDebugItemView(notification: notification)
                }
            }
            .padding()
        }
        .onAppear {
            updatePendingNotifications()
        }
    }
    
    private func updatePendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                self.pendingNotifications = requests
            }
        }
    }
}

struct NotificationDebugItemView: View {
    let notification: UNNotificationRequest
    
    private var formattedDate: String? {
        guard let trigger = notification.trigger as? UNCalendarNotificationTrigger,
              let date = Calendar.current.date(from: trigger.dateComponents) else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private var formattedTime: String? {
        guard let trigger = notification.trigger as? UNCalendarNotificationTrigger,
              let date = Calendar.current.date(from: trigger.dateComponents) else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(notification.content.title)")
            Text("---")
            Text("\(notification.content.body)")
            if let date = formattedDate {
                Text("Date: \(date)")
            }
            if let time = formattedTime {
                Text("Time: \(time)")
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
//        ScrollView {
//            VStack(alignment: .leading, spacing: 10) {
//                Text("App Settings")
//                    .font(.headline)
//                
//                VStack(alignment: .leading) {
//                    Text("Profile")
//                        .font(.subheadline)
//                    Picker("Profile", selection: Binding(
//                        get: { appManager.appDataStore.userSettings.profile.name },
//                        set: { newValue in
//                            appManager.setProfileByName(newValue)
//                        }
//                    )) {
//                        Text("DEBUG").tag("DEBUG")
//                        Text("TEST").tag("TEST")
//                        Text("defaultUser").tag("defaultUser")
//                    }
//                    .pickerStyle(MenuPickerStyle())
//                }
//                .padding()
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(8)
//            }
//            .padding()
//        }
    }
}

// MARK: - Main Debug View
struct Debug_V: View {
    @State private var selectedTab = 2  // Start with notifications tab
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


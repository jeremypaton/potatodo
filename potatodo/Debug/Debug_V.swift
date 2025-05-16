//
//  Debug_V.swift
//  potatodo
//
//  Created by Jeremy Paton on 16/5/2025.
//

import SwiftUI

struct Debug_V: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var messageManager: MessageManager
    @ObservedObject var notificationsManager: NotificationsManager
    @EnvironmentObject var settings: Settings
    @State private var selectedTab = 0
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .padding(.trailing)
            }
            
            Picker("View", selection: $selectedTab) {
                Text("Tasks").tag(0)
                Text("Messages").tag(1)
                Text("Notifications").tag(2)
                Text("Settings").tag(3)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            TabView(selection: $selectedTab) {
                // Tasks Tab
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(taskManager.tasks) { task in
                            VStack(alignment: .leading) {
                                Text("ID: \(task.id)")
                                Text("Title: \(task.title)")
                                Text("Completed: \(task.isCompleted ? "Yes" : "No")")
                                Text("Color: \(task.color.rawValue)")
                                Text("Date: \(task.date.formatted())")
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                }
                .tag(0)
                
                // Messages Tab
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("All Messages")
                            .font(.headline)
                        ForEach(messageManager.messages.indices, id: \.self) { index in
                            let message = messageManager.messages[index]
                            VStack(alignment: .leading) {
                                Text("Level: \(message.level)")
                                Text("Text: \(message.text)")
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
                .tag(1)
                
                // Notifications Tab
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Settings")
                            .font(.headline)
                        Text("Notifications Enabled: \(notificationsManager.isEnabled ? "Yes" : "No")")
                        Text("Daily Time: \(notificationsManager.dailyTime.formatted(date: .omitted, time: .shortened))")
                        Text("Default Reminder Text: \(notificationsManager.defaultReminderText)")
                        
                        Text("Pending Notifications")
                            .font(.headline)
                            .padding(.top)
                        ForEach(notificationsManager.pendingNotifications, id: \.identifier) { notification in
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
                    .padding()
                }
                .tag(2)
                
                // Settings Tab
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("App Settings")
                            .font(.headline)
                        
                        VStack(alignment: .leading) {
                            Text("Profile")
                                .font(.subheadline)
                            Picker("Profile", selection: $settings.profile) {
                                Text("Debug").tag(Profile.debug)
                                Text("Test").tag(Profile.test)
                                Text("Production").tag(Profile.prod)
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: settings.profile) { oldValue, newValue in
                                taskManager.loadTasks()
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding()
                }
                .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .background(Color(.systemBackground))
        .onAppear {
            notificationsManager.updatePendingNotifications()
        }
    }
}

#Preview {
    let settings = Settings()
    
    let taskManager = TaskManager()
    let messageManager = MessageManager()
    let notificationsManager = NotificationsManager()
    
    return Debug_V(
        taskManager: taskManager,
        messageManager: messageManager,
        notificationsManager: notificationsManager,
        isPresented: .constant(true)
    )
    .environmentObject(settings)
}


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
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            Picker("Debug View", selection: $selectedTab) {
                Text("Tasks").tag(0)
                Text("Messages").tag(1)
                Text("Notifications").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            TabView(selection: $selectedTab) {
                // Tasks Tab
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(taskManager.tasks) { task in
                            VStack(alignment: .leading) {
                                Text("ID: \(task.id)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("Title: \(task.title)")
                                Text("Completed: \(task.isCompleted ? "Yes" : "No")")
                                Text("Color: \(task.color.rawValue)")
                                Text("Date: \(task.date.formatted())")
                                Divider()
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .tag(0)
                
                // Messages Tab
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(messageManager.messages, id: \.text) { message in
                            VStack(alignment: .leading) {
                                Text("Level: \(message.level)")
                                Text("Text: \(message.text)")
                                Divider()
                            }
                            .padding(.horizontal)
                        }
                        
                        Text("Recent Messages:")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(messageManager.recentMessages, id: \.self) { message in
                            Text(message)
                                .padding(.horizontal)
                            Divider()
                        }
                    }
                }
                .tag(1)
                
                // Notifications Tab
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notifications Enabled: \(notificationsManager.isEnabled ? "Yes" : "No")")
                        Text("Daily Time: \(notificationsManager.dailyTime.formatted())")
                        Text("Default Reminder Text: \(notificationsManager.defaultReminderText)")
                    }
                    .padding()
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .background(Color(.systemBackground))
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
        notificationsManager: notificationsManager
    )
    .environmentObject(settings)
}


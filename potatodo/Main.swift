//
//  ContentView.swift
//  potatodo
//
//  Created by Jeremy Paton on 12/5/2025.
//

import SwiftUI
import UserNotifications

struct Main: View {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var navManager = NavManager()
    @StateObject private var potatoManager = PotatoManager()
    @StateObject private var notificationsManager = NotificationsManager()
    @StateObject private var taskEditOverlay = TaskEditOverlay()
    @State private var showSplash = true
    
    
    var body: some View {
        ZStack {
            if showSplash {
                Splash(showingSplash: $showSplash)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                            withAnimation {
                                showSplash = false
                                notificationsManager.requestPermissions()
                            }
                        }
                    }
            } else {
                PageManager(
                    taskManager: taskManager,
                    navManager: navManager,
                    potatoManager: potatoManager
                )
            }
            
            if taskEditOverlay.isShowing {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        taskEditOverlay.hide()
                    }
                
                VStack(spacing: 16) {
                    Text("Task name")
                        .font(.headline)
                        .padding(.top)
                    
                    TextField("Task description", text: $taskEditOverlay.editedTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        Button {
                            if let taskId = taskEditOverlay.taskId,
                               let task = taskManager.tasks.first(where: { $0.id == taskId }) {
                                taskManager.deleteTask(task)
                            }
                            taskEditOverlay.hide()
                        } label: {
                            Text("Delete")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        
                        Button {
                            taskEditOverlay.hide()
                        } label: {
                            Text("Cancel")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        
                        Button {
                            if let taskId = taskEditOverlay.taskId,
                               let task = taskManager.tasks.first(where: { $0.id == taskId }) {
                                var updatedTask = task
                                updatedTask.title = taskEditOverlay.editedTitle
                                taskManager.updateTask(updatedTask)
                            }
                            taskEditOverlay.hide()
                        } label: {
                            Text("Save")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 20)
                .padding(.horizontal, 20)
            }
        }
        .environmentObject(taskEditOverlay)
    }
}

#Preview {
    Main()
}

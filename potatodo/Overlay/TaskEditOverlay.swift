//
//  Overlay_V.swift
//  potatodo
//
//  Created by Jeremy Paton on 15/5/2025.
//

import SwiftUI

class TaskEditOverlay: ObservableObject {
//class OverlayTaskManager: ObservableObject {
    @Published var isShowing = false
    @Published var taskId: UUID?
    @Published var editedTitle = ""
    
    func show(for taskId: UUID, title: String) {
        self.taskId = taskId
        self.editedTitle = title
        self.isShowing = true
    }
    
    func hide() {
        self.isShowing = false
        self.taskId = nil
        self.editedTitle = ""
    }
}

struct TaskEditOverlay_V: View {
    @EnvironmentObject var overlayManager: OverlayManager
    
    var body: some View {
        ZStack {
            if overlayManager.taskEditOverlay.isShowing {
                Color.gray.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        overlayManager.taskEditOverlay.hide()
                        overlayManager.objectWillChange.send()
                    }
                
                VStack(spacing: 16) {
                    Text("Task name")
                        .font(.headline)
                        .padding(.top)
                    
                    TextField("Task description", text: Binding(
                        get: { overlayManager.taskEditOverlay.editedTitle },
                        set: { newValue in
                            overlayManager.taskEditOverlay.editedTitle = newValue
                            overlayManager.objectWillChange.send()
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        Button {
                            if let taskId = overlayManager.taskEditOverlay.taskId,
                               let task = overlayManager.taskManager.tasks.first(where: { $0.id == taskId }) {
                                overlayManager.taskManager.deleteTask(task)
                            }
                            overlayManager.taskEditOverlay.hide()
                            overlayManager.objectWillChange.send()
                        } label: {
                            Text("Delete")
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        
                        Button {
                            overlayManager.taskEditOverlay.hide()
                            overlayManager.objectWillChange.send()
                        } label: {
                            Text("Cancel")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        
                        Button {
                            if let taskId = overlayManager.taskEditOverlay.taskId,
                               let task = overlayManager.taskManager.tasks.first(where: { $0.id == taskId }) {
                                var updatedTask = task
                                updatedTask.title = overlayManager.taskEditOverlay.editedTitle
                                overlayManager.taskManager.updateTask(updatedTask)
                            }
                            overlayManager.taskEditOverlay.hide()
                            overlayManager.objectWillChange.send()
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
    }
}

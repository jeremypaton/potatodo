//
//  Overlay_V.swift
//  potatodo
//
//  Created by Jeremy Paton on 15/5/2025.
//

import SwiftUI

class TaskEditOverlay: ObservableObject {
    @Published var isShowing = false
    @Published var taskId: UUID?
    @Published var editedTitle = ""
    @Published var selectedColor: TaskColor = .green
    
    func show(for taskId: UUID, title: String, color: TaskColor = .green) {
        self.taskId = taskId
        self.editedTitle = title
        self.selectedColor = color
        self.isShowing = true
        objectWillChange.send()
    }
    
    func hide() {
        self.isShowing = false
        self.taskId = nil
        self.editedTitle = ""
        self.selectedColor = .green
        objectWillChange.send()
    }
}

struct TaskEditOverlay_V: View {
    @EnvironmentObject var overlayManager: OverlayManager
    
    private var taskColor: Color {
        switch overlayManager.taskEditOverlay.selectedColor {
        case .green: return .green
        case .blue: return .blue
        case .yellow: return .yellow
        case .purple: return .purple
        case .red: return .red
        case .gray: return .gray
        }
    }
    
    private var tasksForCurrentDay: [Task] {
        overlayManager.taskManager.tasks
            .filter { task in
                Calendar.current.isDate(task.date, inSameDayAs: overlayManager.navManager.currentDate)
            }
            .sorted { $0.position < $1.position }
    }
    
    var body: some View {
        if overlayManager.taskEditOverlay.isShowing {
            Color.gray.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    overlayManager.taskEditOverlay.hide()
                    overlayManager.objectWillChange.send()
                }
            
            VStack(spacing: 16) {
                // Color selection stars
                HStack(spacing: 12) {
                    ForEach([TaskColor.green, .blue, .yellow, .purple, .red, .gray], id: \.self) { color in
                        Button {
                            overlayManager.taskEditOverlay.selectedColor = color
                            overlayManager.objectWillChange.send()
                        } label: {
                            Image(systemName: "star.fill")
                                .foregroundColor(TaskStyle.fullColor(for: Task(title: "", color: color)))
                                .font(.system(size: 36))
                        }
                    }
                }
                .padding(.top)
                
                Text("Task name")
                    .font(.headline)
                
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
                            updatedTask.color = overlayManager.taskEditOverlay.selectedColor
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
            .background(TaskStyle.blendColor(.white, with: taskColor, by: 0.5))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(taskColor, lineWidth: 3)
            )
            .shadow(radius: 20)
            .padding(.horizontal, 20)
        }
    }
}

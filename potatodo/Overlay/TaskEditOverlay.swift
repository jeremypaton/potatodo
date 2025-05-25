//
//  Overlay_V.swift
//  potatodo
//
//  Created by Jeremy Paton on 15/5/2025.
//

// TaskEditOverlay.swift
// Manages the state and UI for editing tasks in the application
// This overlay appears when a user wants to edit an existing task or create a new one

import SwiftUI

/// Manages the state for the task editing overlay
/// This class is responsible for maintaining the state of the editing interface
/// and coordinating with AppManager for task updates
class TaskEditOverlay: ObservableObject {
    // MARK: - Published Properties
    
    /// Controls the visibility of the overlay
    @Published var isShowing = false
    
    /// The ID of the task being edited, nil if creating a new task
    @Published var taskId: UUID?
    
    /// The current text content of the task being edited
    @Published var editedTitle = ""
    
    /// The currently selected color for the task
    @Published var selectedColor: TaskColor = .green
    
    /// The optional date associated with the task
    @Published var selectedDate: Date?
    
    // MARK: - Public Methods
    
    /// Shows the overlay for editing an existing task
    /// - Parameters:
    ///   - taskId: The UUID of the task to edit
    ///   - title: The current title of the task
    ///   - color: The current color of the task
    ///   - date: The current date of the task (optional)
    func show(task : Task) {
        self.taskId = task.id
        self.editedTitle = task.title
        self.selectedColor = task.color
        self.selectedDate = task.date
        self.isShowing = true
    }
    
    /// Hides the overlay and resets all state
    func hide() {
        self.isShowing = false
        self.taskId = nil
        self.editedTitle = ""
        self.selectedColor = .green
        self.selectedDate = nil
    }
}


// MARK: - Task Edit View Components

/// Color selection component for tasks
//struct TaskColorPicker: View {
//    let appManager: AppManager
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            ForEach([TaskColor.green, .blue, .yellow, .purple, .red, .gray], id: \.self) { color in
//                Button {
//                    overlayManager.taskEditOverlay.selectedColor = color
//                    overlayManager.objectWillChange.send()
//                } label: {
//                    Image(systemName: "star.fill")
//                        .foregroundColor(TaskStyle.fullColor(for: Task(title: "", color: color)))
//                        .font(.system(size: 36))
//                }
//            }
//        }
//        .padding(.top)
//    }
//}

/// Action buttons for the task edit overlay
struct TaskEditButtons: View {
    let appManager: AppManager
    
    var body: some View {
        HStack(spacing: 20) {
            // Delete button
            Button(action: {
//                Task { @MainActor in
                appManager.deleteTaskEditOverlay()
//                appManager.hideEditOverlay()

//                }
            }) {
                Text("Delete")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            
            // Cancel button
            Button(action: {
//                Task { @MainActor in
                    appManager.hideTaskEditOverlay()
//                }
            }) {
                Text("Cancel")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            
            // Save button
            Button(action: {
//                Task { @MainActor in
                appManager.saveTaskEditOverlay()
//                appManager.hideEditOverlay()

//                }
            }) {
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
}

/// The SwiftUI view for the task editing overlay
/// This view is responsible for rendering the editing interface and handling user interactions
struct TaskEditOverlay_V: View {
    // MARK: - Properties
    
    /// Reference to the AppManager for accessing shared application state
    @ObservedObject var appManager: AppManager
    @ObservedObject var overlayManager: OverlayManager

    
    /// Handles all task editing actions
    
    init(appManager: AppManager) {
        self.appManager = appManager
        self.overlayManager = appManager.getOverlayManagerForOverlayView()
    }
    
    /// Computed property that converts the selected TaskColor to a SwiftUI Color
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
//
//    /// Computed property that filters tasks for the current day
//    /// Used for context-aware task editing
//    private var tasksForCurrentDay: [Task] {
//        appManager.taskManager.tasks
//            .filter { task in
//                if let taskDate = task.date {
//                    return Calendar.current.isDate(taskDate, inSameDayAs: appManager.navManager.currentDate)
//                }
//                return false
//            }
//            .sorted { $0.position < $1.position }
//    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Only show the overlay when isShowing is true
            if overlayManager.taskEditOverlay.isShowing {
                // Semi-transparent background overlay
                Color.gray.opacity(0.8)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
//                        Task { @MainActor in
                            overlayManager.taskEditOverlay.hide()
                            overlayManager.objectWillChange.send()
//                        }
                    }
                
                // Main editing interface
                VStack(spacing: 16) {
                    // Color selection
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
                    
                    // Task title text field
                    TextField("Task description", text: Binding(
                        get: { overlayManager.taskEditOverlay.editedTitle },
                        set: { newValue in
//                            Task { @MainActor in
                                overlayManager.taskEditOverlay.editedTitle = newValue
                                overlayManager.objectWillChange.send()
//                            }
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    
                    // Action buttons
                    TaskEditButtons(appManager: appManager)
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
}

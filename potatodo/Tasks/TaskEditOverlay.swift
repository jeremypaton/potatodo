import SwiftUI

class TaskEditOverlay: ObservableObject {
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
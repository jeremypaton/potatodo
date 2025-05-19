import SwiftUI

struct PageBacklog_VM: View {
    @ObservedObject var taskManager: TaskManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(taskManager.unscheduledTasks) { task in
                    Task_V(taskManager: taskManager, taskId: task.id, isCompact: false)
                }
            }
            .padding()
        }
    }
}

#Preview {
    let taskManager = TaskManager()
    return PageBacklog_VM(taskManager: taskManager)
} 
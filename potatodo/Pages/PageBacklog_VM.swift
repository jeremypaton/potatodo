import SwiftUI

struct PageBacklog_VM: View {
    @ObservedObject var appManager: AppManager
    
    private var unscheduledTasks: [Task] {
        appManager.getTasks().filter { $0.date == nil }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Backlog")
                .font(.title)
                .bold()
            
            // Task list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(unscheduledTasks) { task in
                        Task_V(appManager: appManager, task: task, isCompact: false)
                    }
                    
                    // Add task button
                    AddTaskButton_V(appManager: appManager, isCompact: false, date: nil)
                }
                .padding()
            }
        }
    }
}

#Preview {
    let appManager = AppManager()
    return PageBacklog_VM(appManager: appManager)
} 

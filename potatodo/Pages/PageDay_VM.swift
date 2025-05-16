import SwiftUI

struct PageDay_VM: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var navManager: NavManager
    @ObservedObject var potatoManager: PotatoManager
    @State private var previousCompletedCount = 0
    
    private var tasksForCurrentDay: [Task] {
        taskManager.tasks.filter { task in
            Calendar.current.isDate(task.date, inSameDayAs: navManager.currentDate)
        }
    }
    
    private var completedTasksCount: Int {
        tasksForCurrentDay.filter { $0.isCompleted }.count
    }
    
    var body: some View {
        TopNav_V(navManager: navManager)
        
        if navManager.isToday {
            Potato_V(potatoManager: potatoManager)
        }

        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { index in
                if index < tasksForCurrentDay.count {
                    Task_V(taskManager: taskManager, taskId: tasksForCurrentDay[index].id, isCompact: false)
                } else if index == 2 {
                    AddTaskButton_V(taskManager: taskManager, isCompact: false, date: navManager.currentDate)
                }
            }
        }
        .padding(.horizontal)
        .onChange(of: completedTasksCount) { oldCount, newCount in
            // Update potato level based on completed tasks
            potatoManager.setLevel(newCount)
            
            // Celebrate if we've completed more tasks than before
            if newCount > oldCount {
                potatoManager.celebrateLevel(newCount)
            }
            
            // Update previous count
            previousCompletedCount = newCount
        }
        .onAppear {
            // Initialize previous count and set initial level
            previousCompletedCount = completedTasksCount
            potatoManager.setLevel(completedTasksCount)
        }
    }
}

#Preview {
    let taskManager = TaskManager()
    let navManager = NavManager()
    let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
    let potatoManager = PotatoManager(overlayManager: overlayManager)
    
    return ZStack {
        VStack {
            PageDay_VM(taskManager: taskManager,
                       navManager: navManager,
                       potatoManager: potatoManager)
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
        
        Overlay_V()
    }
    .environmentObject(overlayManager)
    .environmentObject(Settings())
}


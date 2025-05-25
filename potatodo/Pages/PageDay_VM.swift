import SwiftUI

struct PageDay_VM: View {
    @ObservedObject var appManager: AppManager

    @State private var previousCompletedCount = 0
    
    private var tasksForCurrentDay: [Task] {
        appManager.getTasks().filter { task in
            if let date = task.date {
                return Calendar.current.isDate(date, inSameDayAs: appManager.getCurrentDate())
            }
            return false
        }
    }
    
    private var completedTasksCount: Int {
        tasksForCurrentDay.filter { $0.isCompleted }.count
    }
    
    var body: some View {
        TopNav_V(appManager: appManager)
        
        if appManager.isToday() {
            Potato_V(appManager: appManager)
        }

        VStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { index in
                if index < tasksForCurrentDay.count {
                    Task_V(appManager: appManager, taskId: tasksForCurrentDay[index].id, isCompact: false)
                } else if index == 2 {
                    AddTaskButton_V(appManager: appManager, isCompact: false, date: appManager.getCurrentDate())
                }
            }
        }
        .padding(.horizontal)
        .onChange(of: completedTasksCount) { oldCount, newCount in
            // Update potato level based on completed tasks
            appManager.setLevel(newCount)
            
            // Celebrate if we've completed more tasks than before
            if newCount > oldCount {
                appManager.celebrateLevel(newCount)
            }
            
            // Update previous count
            previousCompletedCount = newCount
        }
        .onAppear {
            // Initialize previous count and set initial level
            previousCompletedCount = completedTasksCount
            appManager.setLevel(completedTasksCount)
        }
    }
}

#Preview {
    let appManager = AppManager()
    ZStack {
        VStack {
            PageDay_VM(appManager: appManager)
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
        
        Overlay_V(appManager: appManager)
    }
}


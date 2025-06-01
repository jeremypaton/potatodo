import SwiftUI

struct PageDay_VM: View {
    @ObservedObject var appManager: AppManager
    @State private var previousCompletedCount = 0
    
    private var tasksForCurrentDay: [Task] {
        appManager.getTasks()
            .filter { task in
                if let taskDate = task.date {
                    return Calendar.current.isDate(taskDate, inSameDayAs: appManager.getCurrentDate())
                }
                return false
            }
            .sorted { $0.position < $1.position }
    }
    
    private var completedTasksCount: Int {
        tasksForCurrentDay.filter { $0.isCompleted }.count
    }
    
    var body: some View {
        TopNav_V(appManager: appManager)
        
        ZStack {
            Potato_V(appManager: appManager).padding(.bottom,10)
            VStack {
                Spacer()
                Text("DAY PRIORITIES:").font(.title3).underline(false, color: Color.black)
            }
        }

        VStack {
            VStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { index in
                    if index < tasksForCurrentDay.count {
                        Task_V(appManager: appManager, task: tasksForCurrentDay[index], isCompact: false)
                    } else if index == 2 {
                        Spacer()
                        AddTaskButton_V(appManager: appManager, isCompact: false, date: appManager.getCurrentDate())
                    }
                }
            }
            .padding(.horizontal,10)
            Spacer()
        }
        .onChange(of: completedTasksCount) { oldCount, newCount in
            // Update potato level based on completed tasks
            appManager.setLevel(newCount)
            
            // Only celebrate if we've completed more tasks than before AND we're not just initializing
            if newCount > oldCount {//}&& oldCount != 0 {
                appManager.celebrateLevel(newCount)
            }
            
            // Update previous count
            previousCompletedCount = newCount
        }
        .onAppear {
            // Initialize previous count and set initial level without celebration
            previousCompletedCount = completedTasksCount
            appManager.setLevel(completedTasksCount)
            appManager.potatoWave()
        }
    }
}

#Preview {
    let appManager = AppManager()
    ZStack {
        VStack {
            PageDay_VM(appManager: appManager)
            BottomNav_V(appManager: appManager)
        }
        .background(Color(.systemGroupedBackground))
        
        Overlay_V(appManager: appManager)
    }
}


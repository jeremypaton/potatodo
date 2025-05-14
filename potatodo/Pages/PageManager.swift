import SwiftUI

struct PageManager: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var navManager: NavManager
    @ObservedObject var potatoManager: PotatoManager
    @State private var showPotatoRain = false
    @State private var isSinglePotato = false
    
    private var tasksForCurrentDay: [Task] {
        taskManager.tasks.filter { task in
            Calendar.current.isDate(task.date, inSameDayAs: navManager.currentDate)
        }
    }
    
    private var allTasksCompleted: Bool {
        tasksForCurrentDay.count == 3 && tasksForCurrentDay.allSatisfy { $0.isCompleted }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Main content area
                Group {
                    switch navManager.interval {
                    case .day:
                        PageDay_VM(taskManager: taskManager, navManager: navManager,
                        potatoManager: potatoManager)
                    case .week:
                        PageWeek_VM(taskManager: taskManager, navManager: navManager)
                    case .month:
                        PageMonth_VM(taskManager: taskManager, navManager: navManager)
                    }
                }
                Spacer()
                // Bottom navigation
                BottomNav_V(navManager: navManager, onPotatoClick: {
                    potatoManager.showRandomMessage()
                    if allTasksCompleted {
                        isSinglePotato = false
                        showPotatoRain = true
                    }
                })
            }
            .background(Color(.systemGroupedBackground))
            
            if showPotatoRain {
                PotatoRain_V(isVisible: $showPotatoRain, isSinglePotato: isSinglePotato)
            }
        }
    }
}

#Preview {
    let taskManager = TaskManager()
    let navManager = NavManager()
    let potatoManager = PotatoManager()
    
    return PageManager(taskManager: taskManager, navManager: navManager,
                          potatoManager: potatoManager)
}

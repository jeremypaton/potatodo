import SwiftUI

struct PageManager_VM: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var navManager: NavManager
    @ObservedObject var potatoManager: PotatoManager

    
    var body: some View {
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
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
            Spacer()
            // Bottom navigation
            BottomNav_V(navManager: navManager, onPotatoClick: {
                potatoManager.showRandomMessage()
            })
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    let taskManager = TaskManager()
    let navManager = NavManager()
    let potatoManager = PotatoManager()

    
    // Add some test tasks
    taskManager.loadCSVTestTasks()
    
    return PageManager_VM(taskManager: taskManager, navManager: navManager,
                          potatoManager: potatoManager)
}

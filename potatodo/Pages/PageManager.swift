import SwiftUI

struct PageManager: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var navManager: NavManager
    @ObservedObject var potatoManager: PotatoManager
    
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
                BottomNav_V(navManager: navManager, onPotatoClick: {
                    potatoManager.showRandomMessage()
                })
            }
            .background(Color(.systemGroupedBackground))
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

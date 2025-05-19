import SwiftUI

struct PageManager: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var navManager: NavManager
    @ObservedObject var potatoManager: PotatoManager
    @EnvironmentObject var settings: Settings
    @EnvironmentObject var notificationsManager: NotificationsManager
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Main content area
                Group {
                    switch navManager.currentPage {
                    case .backlog:
                        PageBacklog_VM(taskManager: taskManager)
                    case .day:
                        PageDay_VM(taskManager: taskManager, navManager: navManager,
                        potatoManager: potatoManager)
                    case .week:
                        PageWeek_VM(taskManager: taskManager, navManager: navManager)
                    case .month:
                        PageMonth_VM(taskManager: taskManager, navManager: navManager)
                    case .settings:
                        PageSettings_VM()
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
    let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
    let potatoManager = PotatoManager(overlayManager: overlayManager)
    let settings = Settings()
    let notificationsManager = NotificationsManager()
    
    return PageManager(taskManager: taskManager,
                       navManager: navManager,
                       potatoManager: potatoManager)
        .environmentObject(settings)
        .environmentObject(notificationsManager)
}

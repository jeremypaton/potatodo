import SwiftUI

struct PageManager: View {
    @ObservedObject var taskManager: TaskManager
    @ObservedObject var navManager: NavManager
    @ObservedObject var potatoManager: PotatoManager
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TopNav_V(navManager: navManager)
                
                // Main content area
                ZStack {
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
                .offset(x: dragOffset)
                
                Spacer()
                BottomNav_V(navManager: navManager, onPotatoClick: {
                    potatoManager.showRandomMessage()
                })
            }
            .background(Color(.systemGroupedBackground))
        }
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    dragOffset = gesture.translation.width
                }
                .onEnded { gesture in
                    let threshold: CGFloat = 50
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        if gesture.translation.width > threshold {
                            navManager.movePrev()
                            dragOffset = 0
                        } else if gesture.translation.width < -threshold {
                            navManager.moveNext()
                            dragOffset = 0
                        } else {
                            dragOffset = 0
                        }
                    }
                }
        )
    }
}

#Preview {
    let taskManager = TaskManager()
    let navManager = NavManager()
    let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
    let potatoManager = PotatoManager(overlayManager: overlayManager)
    
    PageManager(taskManager: taskManager,
                       navManager: navManager,
                       potatoManager: potatoManager)
}

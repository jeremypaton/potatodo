import SwiftUI

struct PageManager: View {
    @ObservedObject var appManager: AppManager

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Main content area
                Group {
                    switch appManager.getCurrentPage() {
                    case .backlog:
                        PageBacklog_VM(appManager: appManager)
                    case .day:
                        PageDay_VM(appManager: appManager)
                    case .week:
                        PageWeek_VM(appManager: appManager)
                    case .month:
                        PageMonth_VM(appManager: appManager)
                    case .settings:
                        PageSettings_VM(appManager: appManager)
                    }
                }
                .onChange(of: appManager.getCurrentPage()) { oldValue, newValue in
                    print("🎯 PageManager: Page changed from \(oldValue) to \(newValue)")
                }
                Spacer()
                BottomNav_V(appManager: appManager)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    let appManager = AppManager()
    return PageManager(appManager: appManager)
}

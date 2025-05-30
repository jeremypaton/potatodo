import SwiftUI

struct BottomNav_V: View {
    @ObservedObject var navManager: NavManager
    @ObservedObject var appManager: AppManager
    var onPotatoClick: () -> Void = {}
    
    init(appManager: AppManager){
        self.navManager = appManager.getNavManagerForNavView()
        self.appManager = appManager
    }
    
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                // Backlog button
                Button(action: {
                    appManager.setPage(.backlog)
                }) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 30))
                        .foregroundColor(navManager.currentPage == .backlog ? .blue : .gray)
                }
                Spacer()
                
                // Week button
                Button(action: {
                    appManager.setPage(.week)
                }) {
                    Text("W")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(navManager.currentPage == .week ? .blue : .gray)
                }
                Spacer()
                
                // Empty space for potato button
                Spacer()
                Spacer()
                Spacer()
                Spacer()

                // Month button
                Button(action: {
                    appManager.setPage(.month)
                }) {
                    Text("M")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(navManager.currentPage == .month ? .blue : .gray)
                }
                Spacer()
                
                // Settings button
                Button(action: {
                    appManager.setPage(.settings)
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 30))
                        .foregroundColor(navManager.currentPage == .settings ? .blue : .gray)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            // Floating potato button
            Button(action: {
                navManager.setPage(.day)
                navManager.moveToToday()
                appManager.potatoWave()
                onPotatoClick()
            }) {
                Text("🥔")
                    .font(.system(size: 55))
                    .frame(width: 80, height: 80)
                    .background(Color.white)
                    .clipShape(Circle())
//                    .overlay(
//                        Circle()
//                            .stroke(Color.blue.opacity(0.3), lineWidth:
//                                         navManager.currentPage == .day ? 6 : 0)
//                    )
                    .shadow(color: navManager.currentPage == .day ? Color.blue.opacity(0.6) :  Color.black.opacity(0.3), radius: 6, x: 0, y: 2)
            }
            .offset(y: -10)
        }
        .background(Color.white)
//        .edgesIgnoringSafeArea(.bottom)
//        .offset(y: 30)
    }
}

//#Preview {
//    VStack {
////        Spacer()
//        
//        .safeAreaInset(edge: .bottom) {
//            BottomNav_V(appManager: appManager)
//        }
//    }
//    .background(Color(.green))
//}

#Preview {
    VStack {
        Spacer()
        Text("Content above")
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .background(Color.blue.opacity(0.2))
        
    }
    .safeAreaInset(edge: .bottom) {
        BottomNav_V(
            appManager: AppManager()
        )
    }
    .background(Color(.systemGroupedBackground))
}

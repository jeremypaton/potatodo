import SwiftUI

struct BottomNav_V: View {
    @ObservedObject var navManager: NavManager
    var onPotatoClick: () -> Void = {}
    
    init(appManager: AppManager){
        self.navManager = appManager.getNavManagerForNavView()
    }
    
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                // Backlog button
                Button(action: {
                    navManager.setPage(.backlog)
                }) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 24))
                        .foregroundColor(navManager.currentPage == .backlog ? .blue : .gray)
                }
                Spacer()
                
                // Week button
                Button(action: {
                    navManager.setPage(.week)
                }) {
                    Text("W")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(navManager.currentPage == .week ? .blue : .gray)
                }
                Spacer()
                
                // Empty space for potato button
                Spacer()
                Spacer()
                Spacer()
                
                // Month button
                Button(action: {
                    navManager.setPage(.month)
                }) {
                    Text("M")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(navManager.currentPage == .month ? .blue : .gray)
                }
                Spacer()
                
                // Settings button
                Button(action: {
                    navManager.setPage(.settings)
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 24))
                        .foregroundColor(navManager.currentPage == .settings ? .blue : .gray)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            // Floating potato button
            Button(action: {
                navManager.setPage(.day)
                navManager.moveToToday()
                onPotatoClick()
            }) {
                Text("🥔")
                    .font(.system(size: 45))
                    .frame(width: 80, height: 80)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: navManager.currentPage == .day ? Color.blue.opacity(0.6) : Color.black.opacity(0.3), radius: 6, x: 0, y: 2)
            }
            .offset(y: -10)
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
        .offset(y: 30)
    }
}

#Preview {
    VStack {
        Spacer()
        
        BottomNav_V(
            appManager: AppManager()
        )
    }
    .background(Color(.green))
}

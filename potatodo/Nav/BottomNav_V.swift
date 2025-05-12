import SwiftUI

struct BottomNav_V: View {
    @ObservedObject var navManager: NavManager
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Button(action: {
                    navManager.setInterval(.week)
                }) {
                    Text("W")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(navManager.interval == .week ? .blue : .gray)
                }
                Spacer()
                // Empty space for potato button
                Spacer()
                Button(action: {
                    navManager.setInterval(.month)
                }) {
                    Text("M")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(navManager.interval == .month ? .blue : .gray)
                }
                Spacer()
            }
            
            // Floating potato button
            Button(action: {
                navManager.moveToToday()
            }) {
                Text("🥔")
                    .font(.system(size: 45))
                    .frame(width: 80, height: 80)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color:
                                navManager.interval == .day ? Color.blue.opacity(0.6) : Color.black.opacity(0.3), radius: 6, x: 0, y: 2)
        
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
            navManager: NavManager()
        )
    }
    .background(Color(.systemGray6))
}

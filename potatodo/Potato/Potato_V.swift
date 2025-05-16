import SwiftUI

struct Potato_V: View {
    @ObservedObject var potatoManager: PotatoManager
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width - 4, height: geometry.size.width - 4)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                Image(potatoManager.isCelebrating ? "potato_celebrate" : "potato_\(potatoManager.level)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width - 24, height: geometry.size.width - 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                    )
                
                VStack {
                    Message_V(messageManager: potatoManager.messageManager)
                        .padding(.top, geometry.size.width * 0.1)
                    Spacer()
                }
            }
        }
        .frame(height: UIScreen.main.bounds.width - 12)
    }
}

#Preview {
    let taskManager = TaskManager()
    let navManager = NavManager()
    let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
    let potatoManager = PotatoManager(overlayManager: overlayManager)

    VStack(spacing: 20) {
        Potato_V(potatoManager: potatoManager)
        
        HStack{
            ForEach(0..<4) { level in
                Button(action: {
                    potatoManager.celebrateLevel(level)
                }) {
                    Text("Level \(level)")
                }
            }
        }
        Overlay_V()
    }
    .padding()
    .background(Color(.green))
    .environmentObject(overlayManager)
}

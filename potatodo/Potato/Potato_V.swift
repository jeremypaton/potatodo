import SwiftUI

struct Potato_V: View {
//    @ObservedObject var potatoManager: PotatoManager
    @ObservedObject var appManager: AppManager

    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width - 4, height: geometry.size.width - 4)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                if appManager.isToday() {
                    
                    let imageName = appManager.appDataStore.uiState.isCelebrating ? "potato_celebrate" : "potato_\(appManager.appDataStore.uiState.level)"
                    //                print("Attempting to load image: \(imageName)")
                    
                    if let _ = UIImage(named: imageName) {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width - 24, height: geometry.size.width - 24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                            )
                    } else {
                        Text("Image not found: \(imageName)")
                            .foregroundColor(.red)
                    }
                }
                VStack {
                    Message_V(messageManager: appManager.getMessageManagerForMessageView())
                        .padding(.top, geometry.size.width * 0.1)
                    Spacer()
                }
            }
        }
        .frame(height: UIScreen.main.bounds.width - 24)
    }
}

#Preview {
    let appManager = AppManager()
//    let navManager = NavManager()
//    let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
//    let potatoManager = PotatoManager(overlayManager: overlayManager)

    VStack(spacing: 20) {
        Potato_V(appManager: appManager)
        
        HStack{
            ForEach(0..<4) { level in
                Button(action: {
                    appManager.celebrateLevel(level)
                }) {
                    Text("Level \(level)")
                }
            }
        }
        Overlay_V(appManager: appManager)
    }
    .padding()
    .background(Color(.green))
}

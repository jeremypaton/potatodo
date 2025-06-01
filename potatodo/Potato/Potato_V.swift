import SwiftUI
import Combine

struct Potato_V: View {
//    @ObservedObject var potatoManager: PotatoManager
    @ObservedObject var appManager: AppManager
    @State private var celebrationFrame = 1
    @State private var danceFrame = 1
    @State private var waveFrame = 1
    @State private var talkFrame = 1
    @State private var goldBackgroundOpacity = 0.0

    private var currentImageName: String {
        if appManager.appDataStore.uiState.isCelebrating {
            if appManager.appDataStore.uiState.level == 3 {
                return "potato_celebrate-\(celebrationFrame)"
            } else {
                return "potato_dance-\(danceFrame)"
            }
        } else if appManager.appDataStore.uiState.isWaving {
            return "potato_wave-\(waveFrame)"
        } else if appManager.appDataStore.uiState.isTalking {
            return "potato_talk-\(talkFrame)"
        } else {
            return "potato_levels-\(appManager.appDataStore.uiState.level)"
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(width: geometry.size.width - 4, height: geometry.size.width - 4)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Gold background effect
                if appManager.appDataStore.uiState.isCelebrating && appManager.appDataStore.uiState.level == 3{
                    Rectangle()
                        .fill(Color.yellow.opacity(0.8))
                        .frame(width: geometry.size.width - 4, height: geometry.size.width - 4)
                        .cornerRadius(12)
                        .opacity(goldBackgroundOpacity)
                }
                
                if appManager.isToday() {
                    let scale = 0.4
                    if let _ = UIImage(named: currentImageName) {
                        Image(currentImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: (geometry.size.width - 24)*scale, height: (geometry.size.width - 24)*scale)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(Color.gray.opacity(0.3), lineWidth: 3)
//                            )
                    } else {
                        Text("Image not found: \(currentImageName)")
                            .foregroundColor(.red)
                    }
                    
                    VStack {
                                        Message_V(messageManager: appManager.getMessageManagerForMessageView())
                                            .padding(.top, geometry.size.width * 0.1)
                                        Spacer()
                                    }
                }
//                VStack {
//                    Message_V(messageManager: appManager.getMessageManagerForMessageView())
//                        .padding(.top, geometry.size.width * 0.1)
//                    Spacer()
//                }
            }
        }
        .frame(height: UIScreen.main.bounds.width - 24)
        .onChange(of: appManager.appDataStore.uiState.isCelebrating) { isCelebrating in
            if isCelebrating {
                celebrationFrame = 1
                danceFrame = 1
                // Animate gold background
//                withAnimation(.easeIn(duration: 1.5)) {
//                    goldBackgroundOpacity = 1.0
//                }
                goldBackgroundOpacity = 1.0
                withAnimation(.spring(duration: 2.5)) {
                    goldBackgroundOpacity = 0.0
                }
                if appManager.appDataStore.uiState.level == 3 {
                    animateCelebration()
                } else {
                    animateDance()
                }
            } else {
                celebrationFrame = 1
                danceFrame = 1
                // Fade out gold background
                withAnimation(.easeOut(duration: 0.5)) {
                    goldBackgroundOpacity = 0.0
                }
            }
        }
        .onChange(of: appManager.appDataStore.uiState.isWaving) { isWaving in
            if isWaving {
                waveFrame = 1
                animateWave()
            } else {
                waveFrame = 1
            }
        }
        .onChange(of: appManager.appDataStore.uiState.isTalking) { isTalking in
            if isTalking {
                talkFrame = 1
                animateTalk()
            } else {
                talkFrame = 1
            }
        }
    }
    
    private func animateCelebration() {
        guard appManager.appDataStore.uiState.isCelebrating else { return }
        celebrationFrame = (celebrationFrame % 4) + 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animateCelebration()
        }
    }
    
    private func animateDance() {
        guard appManager.appDataStore.uiState.isCelebrating else { return }
        danceFrame = (danceFrame % 10) + 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            animateDance()
        }
    }
    
    private func animateWave() {
        guard appManager.appDataStore.uiState.isWaving else { return }
        waveFrame = (waveFrame % 5) + 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animateWave()
        }
    }
    
    private func animateTalk() {
        guard appManager.appDataStore.uiState.isTalking else { return }
        talkFrame = (talkFrame % 3) + 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animateTalk()
        }
    }
}

#Preview {
    let appManager = AppManager()
//    let navManager = NavManager()
//    let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
//    let potatoManager = PotatoManager(overlayManager: overlayManager)
    
    VStack(spacing: 20) {
        ZStack {
            VStack{
                
                Potato_V(appManager: appManager)
                
                VStack(spacing: 10) {
                    Text("set:")
                        .font(.title)
                    HStack(spacing: 10) {
                        
                        ForEach(0..<4) { level in
                            Button("\(level)") {
                                appManager.setLevel(level)
                            }
                            .padding(8)
                            .foregroundColor(.black)
                            .font(.title)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    Text("---------")
                    Text("celebrate:")
                        .font(.title)
                    HStack(spacing: 10) {
                        
                        ForEach(0..<4) { level in
                            Button("! \(level)") {
                                appManager.celebrateLevel(level)
                            }
                            .padding(8)
                            .background(Color.yellow.opacity(1.0))
                            .foregroundColor(.black)
                            .font(.title)
                            .cornerRadius(8)
                        }
                    }
                    Text("---------")
                    HStack(spacing: 10) {
                        Button("Wave") {
                            appManager.potatoWave()
                        }
                        .padding(8)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.black)
                        .font(.title)
                        .cornerRadius(8)
                        
                        Button("Talk") {
                            appManager.potatoTalk()
                        }
                        .padding(8)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.black)
                        .font(.title)
                        .cornerRadius(8)
                    }
                }
                .padding()
                
            }
                    Overlay_V(appManager: appManager)

        }
//        Overlay_V(appManager: appManager)
    }
    .padding()
//    .background(Color(.grey))
}

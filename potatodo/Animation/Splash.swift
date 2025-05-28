import SwiftUI

struct Splash: View {
    @State private var opacity1 = 0.0
    @State private var opacity2 = 0.0
    @State private var opacity3 = 0.0
    @State private var opacity4 = 0.0
    @State private var backgroundOpacity = 1.0
    @State private var textBackgroundOpacity = 0.0
    @State private var potatoes: [(id: UUID, x: CGFloat, y: CGFloat, rotation: Double, creationTime: Date)] = []
    @State private var timer: Timer?
    @State private var spawnTimer: Timer?
    @State private var isSpawning = true
//    @Binding var showingSplash: Bool
    
    @ObservedObject var appManager: AppManager

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .opacity(backgroundOpacity)
                
                // Potato Rain
                ForEach(potatoes, id: \.id) { potato in
                    Text("🥔")
                        .font(.system(size: 40))
                        .rotationEffect(.degrees(potato.rotation))
                        .position(x: potato.x, y: potato.y)
                }
                
                // Text Background
                Color.black
                    .opacity(textBackgroundOpacity)
                    .edgesIgnoringSafeArea(.all)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Splash Text
                VStack(spacing: 20) {
                    Text("POTATO")
                        .font(.system(size: 40, weight: .bold))
                        .opacity(opacity1)
                    Text("POTATO")
                        .font(.system(size: 40, weight: .bold))
                        .opacity(opacity2)
                    Text("POTATO")
                        .font(.system(size: 40, weight: .bold))
                        .opacity(opacity3)
                }
                .foregroundColor(.white)
                
//                VStack(spacing: 20) {
//                    Spacer()
//                    Text("[EARLY ACCESS]")
//                        .font(.system(size: 20, weight: .bold))
////                        .opacity(opacity4)
//                        .foregroundColor(.red)
////                        .fontWeight(.thin)
//                }
//                .foregroundColor(.white)
            }
            .onTapGesture {
                withAnimation {
                    appManager.endSplash()
                }
            }
            .onAppear {
                startPotatoRain(screenSize: geometry.size)
                
                // Fade in text sequentially
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        opacity1 = 1.0
                        textBackgroundOpacity = 0.5
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.25) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        opacity2 = 1.0
                        textBackgroundOpacity = 0.7
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        opacity3 = 1.0
                        textBackgroundOpacity = 1.0
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                    withAnimation(.easeIn(duration: 0.5)) {
                        opacity4 = 1.0
                        textBackgroundOpacity = 1.0
                    }
                }
                
                // Fade out everything after 5.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        opacity1 = 0.0
                        opacity2 = 0.0
                        opacity3 = 0.0
                        backgroundOpacity = 0.0
                        textBackgroundOpacity = 0.0
                    }
                }
            }
            .onDisappear {
                timer?.invalidate()
                spawnTimer?.invalidate()
            }
        }
    }
    
    private func startPotatoRain(screenSize: CGSize) {
        isSpawning = true
        
        // Initial batch of potatoes at random heights
        for _ in 0..<15 {
            let newPotato = (
                id: UUID(),
                x: CGFloat.random(in: 0...screenSize.width),
                y: CGFloat.random(in: 0...screenSize.height),
                rotation: Double.random(in: 0...360),
                creationTime: Date()
            )
            potatoes.append(newPotato)
        }
        
        // Spawn new potatoes
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            if isSpawning {
                let newPotato = (
                    id: UUID(),
                    x: CGFloat.random(in: 0...screenSize.width),
                    y: CGFloat(-20),
                    rotation: Double.random(in: 0...360),
                    creationTime: Date()
                )
                potatoes.append(newPotato)
            }
        }
        
        // Stop spawning after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isSpawning = false
            self.spawnTimer?.invalidate()
        }
        
        // Animate existing potatoes
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            for i in 0..<potatoes.count {
                potatoes[i].y += 6 // Move potatoes down
                potatoes[i].rotation += 2 // Rotate potatoes
            }
            
            // Remove potatoes that are off screen
            potatoes = potatoes.filter { $0.y < screenSize.height + 100 }
        }
    }
}

#Preview {
    let appManager = AppManager()
    Splash(appManager: appManager)
}


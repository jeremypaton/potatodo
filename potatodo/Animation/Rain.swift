import SwiftUI

struct PotatoRain_V: View {
    // MARK: - Types
    
    struct Star: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var rotation: Double
        let creationTime: Date
    }
    
    // MARK: - Properties
    
    @State private var stars: [Star] = []
    @State private var timer: Timer?
    @State private var spawnTimer: Timer?
    @State private var isSpawning = true
    @Binding var isVisible: Bool
    var isSinglePotato: Bool = false
    
    // MARK: - Constants
    
    private enum Constants {
        static let starSize: CGFloat = 40
        static let fallSpeed: CGFloat = 6
        static let rotationSpeed: Double = 2
        static let spawnInterval: TimeInterval = 0.2
        static let animationInterval: TimeInterval = 0.016
        static let spawnDuration: TimeInterval = 3
        static let starLifetime: TimeInterval = 10
        static let hideDelay: TimeInterval = 0.5
        static let screenBuffer: CGFloat = 100
    }
    
    // MARK: - Body
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(stars) { star in
                    Text("🥔")
                        .font(.system(size: Constants.starSize))
                        .rotationEffect(.degrees(star.rotation))
                        .position(x: star.x, y: star.y)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                startAnimation(screenSize: geometry.size)
            }
            .onDisappear {
                cleanup()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Private Methods
    
    private func startAnimation(screenSize: CGSize) {
        stars = []
        isSpawning = true
        
        if isSinglePotato {
            spawnSinglePotato(screenSize: screenSize)
        } else {
            spawnMultiplePotatoes(screenSize: screenSize)
        }
        
        startAnimationTimer(screenSize: screenSize)
    }
    
    private func spawnSinglePotato(screenSize: CGSize) {
        let screenWidth = screenSize.width
        let middleThirdStart = screenWidth / 3
        let middleThirdEnd = screenWidth * 2 / 3
        
        let isLeftSide = Bool.random()
        let x = isLeftSide ?
            CGFloat.random(in: 0...middleThirdStart) :
            CGFloat.random(in: middleThirdEnd...screenWidth)
        
        let newStar = Star(
            x: x,
            y: CGFloat(-20),
            rotation: Double.random(in: 0...360),
            creationTime: Date()
        )
        stars.append(newStar)
        isSpawning = false
    }
    
    private func spawnMultiplePotatoes(screenSize: CGSize) {
        spawnTimer = Timer.scheduledTimer(withTimeInterval: Constants.spawnInterval, repeats: true) { _ in
            if isSpawning {
                let newStar = Star(
                    x: CGFloat.random(in: 0...screenSize.width),
                    y: CGFloat(-20),
                    rotation: Double.random(in: 0...360),
                    creationTime: Date()
                )
                stars.append(newStar)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.spawnDuration) {
            self.isSpawning = false
            self.spawnTimer?.invalidate()
        }
    }
    
    private func startAnimationTimer(screenSize: CGSize) {
        timer = Timer.scheduledTimer(withTimeInterval: Constants.animationInterval, repeats: true) { _ in
            updateStars(screenSize: screenSize)
        }
    }
    
    private func updateStars(screenSize: CGSize) {
        let now = Date()
        
        // Update positions
        for i in 0..<stars.count {
            stars[i].y += Constants.fallSpeed
            stars[i].rotation += Constants.rotationSpeed
        }
        
        // Remove off-screen or expired stars
        stars = stars.filter { star in
            let timeAlive = now.timeIntervalSince(star.creationTime)
            return star.y < screenSize.height + Constants.screenBuffer &&
                   timeAlive < Constants.starLifetime
        }
        
        // Hide view when animation is complete
        if !isSpawning && stars.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.hideDelay) {
                isVisible = false
            }
        }
    }
    
    private func cleanup() {
        timer?.invalidate()
        spawnTimer?.invalidate()
    }
}

#Preview ("all"){
    ZStack {
        Color(.systemGray6)
            .edgesIgnoringSafeArea(.all)
        
        VStack {
            PotatoRain_V(
                isVisible: .constant(true),
                isSinglePotato: false
            )
        }
    }
}

#Preview ("one"){
    ZStack {
        Color(.systemGray6)
            .edgesIgnoringSafeArea(.all)
        
        VStack {
            PotatoRain_V(
                isVisible: .constant(true),
                isSinglePotato: true
            )
        }
    }
}


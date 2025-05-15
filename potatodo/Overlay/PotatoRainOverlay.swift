import SwiftUI

class PotatoRainOverlay: ObservableObject {
    // MARK: - Types
    
    struct Star: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var rotation: Double
        let creationTime: Date
    }
    
    // MARK: - Properties
    
    @Published private(set) var activePotatoes: [Star] = []
    @Published var isVisible = false
    private var timer: Timer?
    private var spawnTimer: Timer?
    private var isSpawning = true
    
    // MARK: - Constants
    
    private enum Constants {
        static let starSize: CGFloat = 40
        static let fallSpeed: CGFloat = 6
        static let rotationSpeed: Double = 2
        static let spawnInterval: TimeInterval = 0.2
        static let animationInterval: TimeInterval = 0.016
        static let spawnDuration: TimeInterval = 3
        static let starLifetime: TimeInterval = 10
        static let screenBuffer: CGFloat = 100
    }
    
    // MARK: - Initialization
    
    init() {
        print("🎯 PotatoRainOverlay initialized")
    }
    
    deinit {
        print("🎯 PotatoRainOverlay deinitialized")
        cleanup()
    }
    
    // MARK: - Public Interface
    
    func spawnPotato(isSinglePotato: Bool = false) {
        print("🎯 Spawning potato, isSinglePotato: \(isSinglePotato)")
        isVisible = true
        isSpawning = true
        startAnimation()
        
        if isSinglePotato {
            spawnSinglePotato()
        } else {
            spawnMultiplePotatoes()
        }
    }
    
    // MARK: - View
    
    var view: some View {
        Group {
            if isVisible {
                ZStack {
                    // Debug background
                    Color.clear
                        .edgesIgnoringSafeArea(.all)
                    
                    // Potatoes
                    ForEach(self.activePotatoes) { star in
                        Text("🥔")
                            .font(.system(size: Constants.starSize))
                            .rotationEffect(.degrees(star.rotation))
                            .position(x: star.x, y: star.y)
                            .shadow(color: .black, radius: 5, x: 0, y: 0)
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func spawnSinglePotato() {
        let screenWidth = UIScreen.main.bounds.width
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
        activePotatoes.append(newStar)
        isSpawning = false
    }
    
    private func spawnMultiplePotatoes() {
        spawnTimer = Timer.scheduledTimer(withTimeInterval: Constants.spawnInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.isSpawning {
                let screenWidth = UIScreen.main.bounds.width
                let newStar = Star(
                    x: CGFloat.random(in: 0...screenWidth),
                    y: CGFloat(-20),
                    rotation: Double.random(in: 0...360),
                    creationTime: Date()
                )
                self.activePotatoes.append(newStar)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.spawnDuration) { [weak self] in
            self?.isSpawning = false
            self?.spawnTimer?.invalidate()
        }
    }
    
    private func startAnimation() {
        print("🎯 Starting animation")
        if timer == nil {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.timer = Timer.scheduledTimer(withTimeInterval: Constants.animationInterval, repeats: true) { [weak self] _ in
                    guard let self = self else { return }
                    self.updateStars()
                    self.objectWillChange.send()
                }
                RunLoop.current.add(self.timer!, forMode: .common)
                print("🎯 Timer started")
            }
        }
    }
    
    private func updateStars() {
        let now = Date()
        let screenHeight = UIScreen.main.bounds.height
        
        // Update positions
        for i in 0..<activePotatoes.count {
            activePotatoes[i].y += Constants.fallSpeed
            activePotatoes[i].rotation += Constants.rotationSpeed
        }
        
        // Remove off-screen or expired stars
        let oldCount = activePotatoes.count
        activePotatoes = activePotatoes.filter { star in
            let timeAlive = now.timeIntervalSince(star.creationTime)
            return star.y < screenHeight + Constants.screenBuffer &&
                   timeAlive < Constants.starLifetime
        }
        
        if oldCount != activePotatoes.count {
            print("🎯 Updated potatoes, count: \(activePotatoes.count)")
        }
        
        // Hide overlay if no more potatoes and not spawning
        if activePotatoes.isEmpty && !isSpawning {
            isVisible = false
            cleanup()
        }
    }
    
    private func cleanup() {
        print("🎯 Cleaning up animation")
        timer?.invalidate()
        timer = nil
        spawnTimer?.invalidate()
        spawnTimer = nil
    }
}

// Test view
struct PotatoRainTestView: View {
    @StateObject private var overlay = PotatoRainOverlay()
    
    var body: some View {
        ZStack {
            overlay.view
            
            VStack {
                Spacer()
                HStack {
                    Button("Spawn One 🥔") {
                        overlay.spawnPotato(isSinglePotato: true)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Spawn Many 🥔") {
                        overlay.spawnPotato(isSinglePotato: false)
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
        }
    }
}

#Preview {
    PotatoRainTestView()
} 

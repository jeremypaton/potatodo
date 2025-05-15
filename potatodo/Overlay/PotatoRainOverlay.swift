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
    private var timer: Timer?
    
    // MARK: - Constants
    
    private enum Constants {
        static let starSize: CGFloat = 60
        static let fallSpeed: CGFloat = 2
        static let rotationSpeed: Double = 1
        static let animationInterval: TimeInterval = 0.05
        static let starLifetime: TimeInterval = 10
        static let screenBuffer: CGFloat = 100
    }
    
    // MARK: - Initialization
    
    init() {
        print("🎯 PotatoRainOverlay initialized")
        startAnimation()
    }
    
    deinit {
        print("🎯 PotatoRainOverlay deinitialized")
        cleanup()
    }
    
    // MARK: - Public Interface
    
    func spawnPotato(isSinglePotato: Bool = false) {
        print("🎯 Spawning potato, isSinglePotato: \(isSinglePotato)")
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // Always spawn in the middle of the screen
        let newPotato = Star(
            x: screenWidth / 2,
            y: screenHeight / 2,
            rotation: Double.random(in: 0...360),
            creationTime: Date()
        )
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activePotatoes.append(newPotato)
            print("🎯 Added potato, total count: \(self.activePotatoes.count)")
            self.objectWillChange.send()
        }
    }
    
    // MARK: - View
    
    var view: some View {
        ZStack {
            // Debug background
            Color.red.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            // Test text to verify view is visible
            Text("TEST VIEW")
                .font(.largeTitle)
                .foregroundColor(.white)
            
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
    
    // MARK: - Private Methods
    
    private func startAnimation() {
        print("🎯 Starting animation")
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
    }
    
    private func cleanup() {
        print("🎯 Cleaning up animation")
        timer?.invalidate()
        timer = nil
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
                .padding(.bottom, 100)
            }
        }
    }
}

#Preview {
    PotatoRainTestView()
} 

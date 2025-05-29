import SwiftUI

struct ScrollingBanner: View {
    let direction: Bool // true for left, false for right
    let speed: Double
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let baseText = "POTATODO - PRIVATE ALPHA - "
            let repeatedText = String(repeating: baseText, count: 100)
            let textWidth = geometry.size.width * 3
            
            HStack(spacing: 0) {
                Text(repeatedText)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(width: textWidth)
            .offset(x: offset)
            .onAppear {
                offset = direction ? 0 : -textWidth + geometry.size.width
                withAnimation(Animation.linear(duration: speed).repeatForever(autoreverses: false)) {
                    offset = direction ? -textWidth + geometry.size.width : 0
                }
            }
        }
        .frame(height: 30)
        .background(Color.black)
    }
}

struct RedTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .overlay(
                Text("PRIVATE ALPHA")
                    .foregroundColor(.red)
                    .font(.system(size: 16, weight: .bold))
                    .offset(x: 0)
            )
    }
}

enum IntroImageMode {
    case autoplay
    case button
    case launch
}

struct IntroImageConfig {
    let imageName: String
    let duration: Double
    let mode: IntroImageMode
}

class IntroViewModel: ObservableObject {
    @Published var currentImageIndex: Int = 0
    @Published var showNextButton: Bool = false
    @Published var isLastImage: Bool = false
    
    private var timer: Timer?
    let introConfigs: [IntroImageConfig] = [
        IntroImageConfig(imageName: "intro_1", duration: 1.5, mode: .autoplay),
        IntroImageConfig(imageName: "intro_2", duration: 1.5, mode: .button),
        IntroImageConfig(imageName: "intro_3", duration: 2.0, mode: .autoplay),
        IntroImageConfig(imageName: "intro_4", duration: 3.0, mode: .autoplay),
        IntroImageConfig(imageName: "intro_5", duration: 3.0, mode: .autoplay),
        IntroImageConfig(imageName: "intro_6", duration: 1.0, mode: .button),
        IntroImageConfig(imageName: "intro_7", duration: 2.0, mode: .autoplay),
        IntroImageConfig(imageName: "intro_8", duration: 2.0, mode: .autoplay),
        IntroImageConfig(imageName: "intro_9", duration: 2.0, mode: .autoplay),
        IntroImageConfig(imageName: "intro_10", duration: 2.0, mode: .autoplay),
        IntroImageConfig(imageName: "intro_11", duration: 2.0, mode: .button),
        IntroImageConfig(imageName: "intro_12", duration: 2.0, mode: .autoplay),
        IntroImageConfig(imageName: "intro_13", duration: 2.0, mode: .launch)
    ]
    
    init() {
        startTimer()
    }
    
    func reset() {
        currentImageIndex = 0
        isLastImage = false
        startTimer()
    }
    
    func startTimer() {
        showNextButton = false
        timer?.invalidate()
        
        let config = introConfigs[currentImageIndex]
        if config.mode == .autoplay {
            timer = Timer.scheduledTimer(withTimeInterval: config.duration, repeats: false) { [weak self] _ in
                self?.nextImage()
            }
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: config.duration, repeats: false) { [weak self] _ in
                withAnimation(.easeIn(duration: 0.3)) {
                    self?.showNextButton = true
                }
            }
        }
    }
    
    func nextImage() {
        if currentImageIndex < introConfigs.count - 1 {
            currentImageIndex += 1
            startTimer()
        } else {
            isLastImage = true
        }
    }
    
    var currentConfig: IntroImageConfig {
        introConfigs[currentImageIndex]
    }
}

struct PageIntro: View {
    @StateObject private var viewModel = IntroViewModel()
    @State private var imageOpacity: Double = 0
    @State private var previousImageIndex: Int = 0
    @State private var glowOpacity: Double = 0.5
    private let bannerSpeed: Double = 20.0
    @ObservedObject var appManager: AppManager
    
    var body: some View {
        ZStack {
            if !viewModel.isLastImage {
                ZStack {
                    Color.black
                        .edgesIgnoringSafeArea(.all)
                    
                    // Previous image
                    if previousImageIndex != viewModel.currentImageIndex {
                        Image(viewModel.introConfigs[previousImageIndex].imageName)
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.all)
                    }
                    
                    // Current image
                    Image(viewModel.currentConfig.imageName)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .opacity(imageOpacity)
                }
                .onAppear {
                    withAnimation(.easeIn(duration: 0.5)) {
                        imageOpacity = 1
                    }
                }
                .onChange(of: viewModel.currentImageIndex) { oldValue, newValue in
                    previousImageIndex = oldValue
                    imageOpacity = 0
                    withAnimation(.easeIn(duration: 0.5)) {
                        imageOpacity = 1
                    }
                }
                
                VStack(spacing: 0) {
                    // Top banner - only show if not on launch page
                    if viewModel.currentConfig.mode != .launch {
                        ScrollingBanner(direction: true, speed: bannerSpeed)
                            .zIndex(1)
                    }
                    
                    Spacer()
                    
                    if viewModel.showNextButton {
                        Button(action: {
                            // Trigger potato rain based on button type
                            if viewModel.currentConfig.mode == .launch {
                                appManager.getOverlayManagerForOverlayView().showPotatoRain(isSinglePotato: false)
                            } else {
                                appManager.getOverlayManagerForOverlayView().showPotatoRain(isSinglePotato: true)
                            }
                            viewModel.nextImage()
                        }) {
                            Text(viewModel.currentConfig.mode == .launch ? "LET'S DO THIS!" : "NEXT")
                                .font(.title)
                                .foregroundColor(.black)
                                .frame(width: 300)
                                .padding(.vertical, 20)
                                .background(viewModel.currentConfig.mode == .launch ? Color.yellow : Color.blue)
                                .cornerRadius(10)
                                .fontWeight(.bold)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10.0)
                                        .stroke(Color.black, lineWidth: 4)
                                )
                                .shadow(
                                    color: viewModel.currentConfig.mode == .launch ? Color.yellow.opacity(glowOpacity) : Color.clear,
                                    radius: 20,
                                    x: 0,
                                    y: 0
                                )
                                .onAppear {
                                    if viewModel.currentConfig.mode == .launch {
                                        withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                            glowOpacity = 1.0
                                        }
                                    }
                                }
                        }
                        .padding(.bottom, 50)
                    }
                    
                    // Bottom banner - only show if not on launch page
                    if viewModel.currentConfig.mode != .launch {
                        ScrollingBanner(direction: false, speed: bannerSpeed)
                            .zIndex(1)
                    }
                }
                
                // Top right reset button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            viewModel.reset()
                        }) {
                            Text("RESET")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5.0)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        }
                        .padding()
                    }
                    Spacer()
                }
                .zIndex(2)
                
                // Top left skip button
                VStack {
                    HStack {
                        Button(action: {
                            // Trigger multi potato rain for skip
                            appManager.getOverlayManagerForOverlayView().showPotatoRain(isSinglePotato: false)
                            viewModel.isLastImage = true
                        }) {
                            Text("SKIP")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(5)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5.0)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                        }
                        .padding()
                        Spacer()
                    }
                    Spacer()
                }
                .zIndex(2)
            }
            
            // Add overlay for potato rain effects
            Overlay_V(appManager: appManager)
                .zIndex(3)
        }
    }
}

#Preview {
    PageIntro(appManager: AppManager())
} 

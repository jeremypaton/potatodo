//
//  OverlayManager.swift
//  potatodo
//
//  Created by Jeremy Paton on 15/5/2025.
//
import SwiftUI
import Combine

@MainActor
final class OverlayManager: ObservableObject {
    let taskEditOverlay = TaskEditOverlay()
    let potatoRainOverlay = PotatoRainOverlay()
    private var cancellables = Set<AnyCancellable>()
    
    init(){
        // Observe potato rain overlay changes
        potatoRainOverlay.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func showTaskEdit(for taskId: UUID, title: String) {
        taskEditOverlay.show(for: taskId, title: title)
        objectWillChange.send()
    }
    
    func showPotatoRain(isSinglePotato: Bool = false) {
        print("🎯 OverlayManager: Showing potato rain")
        potatoRainOverlay.spawnPotato(isSinglePotato: isSinglePotato)
        objectWillChange.send()
    }
}

struct Overlay_V: View {
    @ObservedObject var appManager: AppManager
    @ObservedObject var overlayManager: OverlayManager
    
    init(appManager: AppManager) {
        self.appManager = appManager
        self.overlayManager = appManager.getOverlayManagerForOverlayView()
    }
    
    var body: some View {
        ZStack {
            // Background layer
            Color.clear
                .edgesIgnoringSafeArea(.all)
            
            // Task edit overlay
            TaskEditOverlay_V(appManager: appManager)
            
            // Potato rain overlay
            overlayManager.potatoRainOverlay.view
                .zIndex(1) // Ensure it's on top
        }
    }
}

#Preview {
    let appManager = AppManager()
    return Overlay_V(appManager: appManager)
}
            

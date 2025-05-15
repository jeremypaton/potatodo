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
    @ObservedObject var taskManager: TaskManager
    private var cancellables = Set<AnyCancellable>()
    
    init(taskManager: TaskManager) {
        self.taskManager = taskManager
        
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
    @EnvironmentObject var overlayManager: OverlayManager
    
    var body: some View {
        ZStack {
            // Background layer
            Color.clear
                .edgesIgnoringSafeArea(.all)
            
            // Task edit overlay
            TaskEditOverlay_V()
            
            // Potato rain overlay
            overlayManager.potatoRainOverlay.view
                .zIndex(1) // Ensure it's on top
            
//            // Test buttons
//            VStack {
//                Spacer()
//                HStack {
//                    Button("Spawn One 🥔") {
//                        print("🎯 Button: Spawn One")
//                        overlayManager.showPotatoRain(isSinglePotato: true)
//                    }
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                    
//                    Button("Spawn Many 🥔") {
//                        print("🎯 Button: Spawn Many")
//                        overlayManager.showPotatoRain(isSinglePotato: false)
//                    }
//                    .padding()
//                    .background(Color.green)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                }
//                .padding(.bottom, 100)
//            }
//            .zIndex(2) // Ensure buttons are on top
        }
    }
}

#Preview {
    let taskManager = TaskManager()
    let overlayManager = OverlayManager(taskManager: taskManager)
    
    return ZStack {
        // Background content
        VStack {
            Text("Main Content")
                .font(.largeTitle)
                .padding()
            
            Button("Show Task Edit") {
                overlayManager.showTaskEdit(for: UUID(), title: "Test Task")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Button("Show Potato Rain") {
                overlayManager.showPotatoRain(isSinglePotato: true)
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        
                    // Test buttons
                    VStack {
                        Spacer()
                        HStack {
                            Button("Spawn One 🥔") {
                                print("🎯 Button: Spawn One")
                                overlayManager.showPotatoRain(isSinglePotato: true)
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
        
                            Button("Spawn Many 🥔") {
                                print("🎯 Button: Spawn Many")
                                overlayManager.showPotatoRain(isSinglePotato: false)
                            }
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding(.bottom, 100)
                    }
                    .zIndex(2) // Ensure buttons are on top
        
        // Overlays
        Overlay_V()
    }
    .environmentObject(overlayManager)
}
            

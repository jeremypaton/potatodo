//
//  potatodoApp.swift
//  potatodo
//
//  Created by Jeremy Paton on 12/5/2025.
//

import SwiftUI

enum Profile: String, Codable {
    case debug
    case test
    case prod
}

class Settings: ObservableObject {
    @Published var profile : Profile = .test
}

@main
struct potatodoApp: App {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var navManager = NavManager()
    @StateObject private var overlayManager: OverlayManager
    @StateObject private var potatoManager: PotatoManager
    @StateObject private var badgeManager: BadgeManager
    
    init() {
        let taskManager = TaskManager()
        let navManager = NavManager()
        let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
        let potatoManager = PotatoManager(overlayManager: overlayManager)
        let badgeManager = BadgeManager(taskManager: taskManager)
        
        // Set up the shared instance
        BadgeManager.shared = badgeManager
        
        _taskManager = StateObject(wrappedValue: taskManager)
        _navManager = StateObject(wrappedValue: navManager)
        _overlayManager = StateObject(wrappedValue: overlayManager)
        _potatoManager = StateObject(wrappedValue: potatoManager)
        _badgeManager = StateObject(wrappedValue: badgeManager)
    }
    
    var body: some Scene {
        WindowGroup {
            Main()
        }
    }
}

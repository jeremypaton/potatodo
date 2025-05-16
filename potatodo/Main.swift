//
//  ContentView.swift
//  potatodo
//
//  Created by Jeremy Paton on 12/5/2025.
//

import SwiftUI
import UserNotifications

struct Main: View {
    @StateObject private var taskManager = TaskManager()
    @StateObject private var navManager = NavManager()
    @StateObject private var notificationsManager = NotificationsManager()
    @StateObject private var overlayManager: OverlayManager
    @StateObject private var potatoManager: PotatoManager
    @State private var showSplash = true
    
    init() {
        let taskManager = TaskManager()
        _taskManager = StateObject(wrappedValue: taskManager)
        let navManager = NavManager()
        _navManager = StateObject(wrappedValue: navManager)
        let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
        _overlayManager = StateObject(wrappedValue: overlayManager)
        _potatoManager = StateObject(wrappedValue: PotatoManager(overlayManager: overlayManager))
    }
    
    var body: some View {
        ZStack {
            if showSplash {
                Splash(showingSplash: $showSplash)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                            withAnimation {
                                showSplash = false
                                notificationsManager.requestPermissions()
                            }
                        }
                    }
            } else {
                PageManager(
                    taskManager: taskManager,
                    navManager: navManager,
                    potatoManager: potatoManager
                )
            }
            
            Overlay_V()
        }
        .environmentObject(overlayManager)
    }
}

#Preview {
    Main()
}

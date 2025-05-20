//
//  ContentView.swift
//  potatodo
//
//  Created by Jeremy Paton on 12/5/2025.
//

import SwiftUI
import UserNotifications

struct Main: View {
    @StateObject private var appService: AppService
    @StateObject private var taskManager: TaskManager
    @StateObject private var navManager: NavManager
    @StateObject private var notificationsManager: NotificationsManager
    @StateObject private var overlayManager: OverlayManager
    @StateObject private var potatoManager: PotatoManager
    @State private var showSplash = true
    @State private var showDebugView = false
    
    init() {
        let settings = Settings()
        _appService = StateObject(wrappedValue: AppService(settings: settings))
        
        // Initialize managers for backward compatibility
        let taskManager = TaskManager(settings: settings)
        _taskManager = StateObject(wrappedValue: taskManager)
        
        let navManager = NavManager()
        _navManager = StateObject(wrappedValue: navManager)
        
        let overlayManager = OverlayManager(taskManager: taskManager, navManager: navManager)
        _overlayManager = StateObject(wrappedValue: overlayManager)
        
        let potatoManager = PotatoManager(overlayManager: overlayManager)
        _potatoManager = StateObject(wrappedValue: potatoManager)
        
        let notificationsManager = NotificationsManager()
        _notificationsManager = StateObject(wrappedValue: notificationsManager)
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
                .onTapGesture(count: 3) {
                    withAnimation {
                        showDebugView.toggle()
                    }
                }
            }
            
            Overlay_V()
            
            if showDebugView {
                Debug_V(
                    taskManager: taskManager,
                    messageManager: potatoManager.messageManager,
                    notificationsManager: notificationsManager,
                    isPresented: $showDebugView
                )
                .transition(.move(edge: .bottom))
                .zIndex(2)
                .environmentObject(appService.settings)
            }
        }
        .environmentObject(overlayManager)
        .environmentObject(appService.settings)
        .environmentObject(notificationsManager)
        .environmentObject(appService)
    }
}

#Preview {
    Main()
}

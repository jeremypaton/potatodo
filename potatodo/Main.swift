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
    @StateObject private var potatoManager = PotatoManager()
    @StateObject private var notificationsManager = NotificationsManager()
    @State private var showSplash = true
    
    
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
        }
    }
}

#Preview {
    Main()
}

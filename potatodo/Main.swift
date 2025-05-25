//
//  ContentView.swift
//  potatodo
//
//  Created by Jeremy Paton on 12/5/2025.
//

import SwiftUI
import UserNotifications

struct Main: View {
    @StateObject private var appManager = AppManager()
    
    init() {
    }
    
    var body: some View {
        ZStack {
            if appManager.appDataStore.uiState.showSplash {
                Splash(appManager: appManager)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                            withAnimation {
                                appManager.endSplash()
                                appManager.requestPermissions()
                            }
                        }
                    }
            } else {
                PageManager(
                    appManager: appManager
                )
                .onTapGesture(count: 3) {
                    withAnimation {
                        appManager.toggleDebugView()
                    }
                }
            }
            
            Overlay_V(appManager: appManager)
            
            if appManager.appDataStore.uiState.showDebugView {
                Debug_V(
                    appManager: appManager
                )
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
    }
}

#Preview {
    Main()
}

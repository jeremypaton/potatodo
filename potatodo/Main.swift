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
            if appManager.shouldShowIntro() {
                PageIntro(appManager: appManager)
//                    .onAppear {
////                        _Concurrency.Task {
////                            await appManager.requestPermissions()
////                        }
//                    }
            } else if appManager.appDataStore.uiState.showSplash {
                Splash(appManager: appManager)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                            withAnimation {
                                appManager.endSplash()
                                _Concurrency.Task {
                                    await appManager.requestPermissions()
                                }
                            }
                        }
                    }
                // ask f
            } else {
                PageManager(
                    appManager: appManager
                )
                .onTapGesture(count: 3) {
                    withAnimation {
                        // Switch between defaultUser and potatoUser
                        let currentProfile = appManager.appDataStore.userSettings.profile.name
                        let newProfile = currentProfile == "defaultUser" ? "potatoUser" : "defaultUser"
                        appManager.setProfileByName(newProfile)
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
            
            NameIndicator(appManager: appManager)
                .zIndex(3)
        }
    }
}

struct NameIndicator: View {
    
    @ObservedObject var appManager: AppManager
    
//    var version: String {
//        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
//    }
//
//    var build: String {
//        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
//    }
//    
    var backgroundColor: Color {
        let name = appManager.appDataStore.userSettings.profile.name
        switch name {
        case "DEBUG":
            return .red
        case "TEST":
            return .yellow
        case "defaultUser":
            return .green
        case "potatoUser":
            return .orange
        default:
            return .clear
        }
    }
    
    var body: some View {
        VStack {
//            Text(appManager.appDataStore.userSettings.profile.name)
//                .font(.system(size: 12))
//                .background(backgroundColor)
            Text(appManager.appDataStore.userSettings.profile.name)
                .font(.system(size: 12))
                .background(backgroundColor)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    Main()
}

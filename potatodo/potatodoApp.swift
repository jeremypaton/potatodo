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
    @Published var profile: Profile = .prod
    @Published var notificationsEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled")
        }
    }
    @Published var notificationTime: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date() {
        didSet {
            UserDefaults.standard.set(notificationTime, forKey: "notificationTime")
        }
    }
    
    init() {
        // Load saved settings
        if let savedTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date {
            notificationTime = savedTime
        }
        notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }
}

@main
struct potatodoApp: App {
    var body: some Scene {
        WindowGroup {
            Main()
        }
    }
}

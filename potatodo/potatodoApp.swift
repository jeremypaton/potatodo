//
//  potatodoApp.swift
//  potatodo
//
//  Created by Jeremy Paton on 12/5/2025.
//

import SwiftUI

enum AppMode: String, Codable {
    case debug
    case test
    case prod
}

class Settings: ObservableObject {
    @Published var mode : AppMode = .test
}

@main
struct potatodoApp: App {
    var body: some Scene {
        WindowGroup {
            Main()
        }
    }
}

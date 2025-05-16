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
    @Published var profile : Profile = .prod
}

@main
struct potatodoApp: App {
    var body: some Scene {
        WindowGroup {
            Main()
        }
    }
}

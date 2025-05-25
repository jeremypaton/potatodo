//
//  PotatoManager.swift
//  potatodo
//
//  Created by Jeremy Paton on 13/5/2025.
//
import SwiftUI

class PotatoManager: ObservableObject {
    @Published var messageManager: MessageManager
    
    init() {
        self.messageManager = MessageManager()
        self.messageManager.loadMessages()
    }
    
    func showRandomMessageForLevel(level: Int) {
        // Get all messages and pick a random one
        if messageManager.messages.randomElement() != nil {
            messageManager.showMessageForCompletionLevel(level)
        }
    }
}

#Preview {
    let appManager = AppManager()

    ZStack{
        VStack(spacing: 20) {
            Potato_V(appManager: appManager)
            
            HStack{
                ForEach(0..<4) { level in
                    Button(action: {
                        appManager.celebrateLevel(level)
                    }) {
                        Text("Level \(level)")
                    }
                }
            }
        }
        Overlay_V(appManager: appManager)
    }
    .padding()
    .background(Color(.green))
}

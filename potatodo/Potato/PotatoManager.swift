//
//  PotatoManager.swift
//  potatodo
//
//  Created by Jeremy Paton on 13/5/2025.
//
import SwiftUI

class PotatoManager: ObservableObject {
    @Published var level: Int = 0
    @Published var isCelebrating: Bool = false
    @Published var messageManager: MessageManager = MessageManager()
    
    init() {
        messageManager.loadMessages()
    }
    
    func celebrateLevel(_ newLevel: Int) {
        messageManager.showMessageForCompletionLevel(newLevel)
        
        if newLevel == 3 {
            isCelebrating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.isCelebrating = false
                self?.level = newLevel
            }
        } else {
            level = newLevel
        }
    }
    
    func showRandomMessage() {
        // Get all messages and pick a random one
        if let randomMessage = messageManager.messages.randomElement() {
            messageManager.showMessageForCompletionLevel(randomMessage.level)
        }
    }
}

#Preview {
    let potatoManager = PotatoManager()

    return VStack(spacing: 20) {
        Potato_V(potatoManager: potatoManager)
        
        HStack{
            ForEach(0..<4) { level in
                Button(action: {
                    potatoManager.celebrateLevel(level)
                }) {
                    Text("Level \(level)")
                }
            }
        }
    }
//    .padding()
    .background(Color(.green))
}

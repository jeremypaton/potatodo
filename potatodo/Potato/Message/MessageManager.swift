import SwiftUI

struct Message {
    var text : String
    var level : Int
}

class MessageManager: ObservableObject {
    @Published var displayedText = ""
    @Published var isShowingMessage = false
    @Published var messages: [Message] = []
    @Published var recentMessages: [String] = []
    
    private var messageTimer: Timer?
    
    init() {
        loadMessages()
    }
    
    private func getMessageForLevel(_ level: Int) -> Message? {
        let levelMessages = messages.filter { message in
            message.level == level
        }
        return levelMessages.randomElement()
    }
    
    func showMessageForCompletionLevel(_ level: Int) {
        guard let message = getMessageForLevel(level) else { return }
//        print("🎯 Selected message: \(message)")
        
        // Show message bubble and start animation immediately
        DispatchQueue.main.async {
            self.isShowingMessage = true
            self.displayedText = ""
        }
        
        // Animate the text
        var charIndex = 0
        let typingTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            if charIndex < message.text.count {
                let startIndex = message.text.startIndex
                let endIndex = message.text.index(startIndex, offsetBy: charIndex + 1)
                let substring = message.text[startIndex..<endIndex]
                
                DispatchQueue.main.async {
                    self.displayedText = String(substring)
                }
                charIndex += 1
            } else {
                timer.invalidate()
                self.messageTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        withAnimation(.easeOut(duration: 0.3)) {
                            self.isShowingMessage = false
                        }
                    }
                }
            }
        }
    }
    
    func addMessage(_  messageText: String, messageLevel: Int) {
        messages.append(Message(text: messageText, level: messageLevel))
    }
    
    func loadMessages() {
//        print("🔄 Loading messages...")
        loadTestMessages()
    }
    
    func loadTestMessages(){
        if let csvPath = Bundle.main.path(forResource: "test_messages", ofType: "csv") {
            loadMessagesFromPath(csvPath)
        }
    }
    
    private func loadMessagesFromPath(_ csvPath: String) {
        do {
            let csvString = try String(contentsOfFile: csvPath, encoding: .utf8)
            let rows = csvString.components(separatedBy: .newlines)
//            print("📄 Found \(rows.count) rows in CSV")
//            print("📄 First few rows: \(rows.prefix(3))")
                        
            // Skip header row
            for row in rows.dropFirst() where !row.isEmpty {
                let columns = row.components(separatedBy: ",")
                if columns.count >= 2 {
                    // Get the message part (second column) and trim any quotes
                    let message = columns[1].trimmingCharacters(in: CharacterSet(charactersIn: "\""))
                    let level = Int(columns[0]) ?? -1
                    addMessage(message, messageLevel: level)
//                    print("✅ Added message: \(level):\(message)")
                } else {
//                    print("⚠️ Invalid row format: \(row)")
                }
            }
//            print("✅ Finished loading \(messages.count) messages")
            
        } catch {
//            print("❌ Error loading CSV: \(error)")
        }
    }
    
    func cleanup() {
        messageTimer?.invalidate()
    }
    
    func clear() {
        isShowingMessage = false
        displayedText = ""
        messageTimer?.invalidate()
        messageTimer = nil
    }
}


#Preview("Hardcoded Messages") {
    let messageManager = MessageManager()
    
    // Add some test messages for each level
    messageManager.addMessage("Level 0: Keep going!", messageLevel: 0)
    messageManager.addMessage("Level 1: You're doing great!", messageLevel: 1)
    messageManager.addMessage("Level 2: Amazing progress!", messageLevel: 2)
    messageManager.addMessage("Level 3: You're unstoppable!", messageLevel: 3)
    
    return VStack(spacing: 20) {
        Message_V(messageManager: messageManager)
        
        HStack{
            ForEach(0..<4) { level in
                Button(action: {
                    messageManager.showMessageForCompletionLevel(level)
                }) {
                    Text("Level \(level)")
                }
            }
        }
    }
    .padding()
    .background(Color(.green))
}

#Preview("CSV Messages") {
    let messageManager = MessageManager()
    messageManager.loadMessages() // This will load messages from test_messages.csv
    
    return VStack(spacing: 20) {
        Message_V(messageManager: messageManager)
        
        HStack{
            ForEach(0..<4) { level in
                Button(action: {
                    messageManager.showMessageForCompletionLevel(level)
                }) {
                    Text("Level \(level)")
                }
            }
        }
    }
    .padding()
    .background(Color(.green))
}

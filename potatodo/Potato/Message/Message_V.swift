import SwiftUI

struct Message_V: View {
    @ObservedObject var messageManager: MessageManager
    
    
    var body: some View {
        if messageManager.isShowingMessage {
            VStack {
                Text(messageManager.displayedText)
                    .font(.system(size: 26, weight: .light))
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .stroke(Color.black, lineWidth: 2)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                )
            }
            .transition(.opacity)
        }
    }
}

#Preview {
    let messageManager = MessageManager()
    messageManager.addMessage("Test message", messageLevel: 0)
    messageManager.showMessageForCompletionLevel(0)
    
    return VStack {
        Spacer()
        Message_V(messageManager: messageManager)
        Spacer()
    }.background(.green)
}

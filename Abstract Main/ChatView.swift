import SwiftUI
import SwiftData
import Combine

struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var messages: [Message]
    
    @State private var messageText: String = ""

    var body: some View {
        VStack {
            List {
                ForEach(Array(messages), id: \.id) { message in
                    HStack(alignment: .top) {
                        Text(message.sender)
                            .font(.caption)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(message.text)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            Text(message.timestamp, style: .time)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            HStack {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    sendMessage()
                }
            }
            .padding()
        }
        .navigationTitle("Messaging")
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        withAnimation {
            let newMessage = Message(text: messageText, sender: "You")
            modelContext.insert(newMessage)
            messageText = ""
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView()
        }
        .modelContainer(for: Message.self, inMemory: true)
    }
}

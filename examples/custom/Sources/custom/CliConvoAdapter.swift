import Foundation
import Combine
import NeuronKit

// MARK: - Example: Custom CLI-style ConvoUI Adapter

/// This example shows how to create a custom ConvoUI adapter that wraps a CLI component
/// The adapter bridges between the CLI component and NeuronKit
class CliConvoAdapter: BaseConvoUIAdapter {

  // Reference to your UI component (in a real app, this would be a SwiftUI view model or UIKit controller)
  private let chatViewModel: ChatViewModel
  private var interactiveTask: Task<Void, Never>?
  private var displayedMessageIds: Set<UUID> = []

  init(chatViewModel: ChatViewModel) {
    self.chatViewModel = chatViewModel
    super.init()
  }

  // Override to handle message display - update your CLI component
  override func handleMessages(_ messages: [NeuronMessage]) {
    // In a real SwiftUI app, you'd update @Published properties
    DispatchQueue.main.async {
        self.chatViewModel.messages = messages
    }

    // Filter for any new messages that haven't been displayed yet
    let newMessages = messages.filter { !displayedMessageIds.contains($0.id) }

    if newMessages.isEmpty { return }

    // Clear the current line and move cursor up to overwrite the `> ` prompt
    // This makes the output look like a clean, real-time chat log
    print("\r\u{1B}[1A\u{1B}[K", terminator: "")

    for message in newMessages {
        let prefix = (message.sender == .user) ? "👤 [You]" : "🤖 [Agent]"
        print("\(prefix) \(message.content)")
        displayedMessageIds.insert(message.id)
    }
    
    // Re-print the input prompt for the next message
    print("> ", terminator: "")
    fflush(stdout) // Ensure the prompt is displayed immediately
  }

  override func handleStreamingChunk(_ chunk: InboundStreamChunk) {
    let previewText = String(decoding: chunk.data, as: UTF8.self)
    guard !previewText.isEmpty else { return }

    DispatchQueue.main.async {
      self.chatViewModel.updateStreamingPreview(id: chunk.messageId ?? UUID(uuidString: chunk.streamId) ?? UUID(),
                                                text: previewText,
                                                isFinal: chunk.isFinal)
    }

    // CLI output
    print("\r\u{1B}[1A\u{1B}[K", terminator: "")
    print("💬 [stream] \(previewText)")
    print("> ", terminator: "")
    fflush(stdout)
  }

  // Override to show consent UI - integrate with your UI framework
  override func handleConsentRequest(proposalId: UUID, sessionId: UUID, feature: String, args: [String: Any]) {
    let separator = String(repeating: "=", count: 50)
    print("\n" + separator)
    print("🔐 CONSENT REQUEST")
    print(separator)
    print("Feature: \(feature)")
    if !args.isEmpty { 
      print("Arguments:")
      for (key, value) in args {
        print("  • \(key): \(value)")
      }
    }
    print(separator)
    print("The agent wants to use this feature. Do you approve?")
    print("Approve? [y/N]: ", terminator: "")
    
    let answer = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? "n"
    let approved = (answer == "y" || answer == "yes")
    context?.userProvidedConsent(messageId: proposalId, approved: approved)
    
    if approved {
      print("✅ CONSENT APPROVED - Feature will execute")
    } else {
      print("❌ CONSENT DENIED - Feature execution blocked")
    }
    print(separator + "\n")
  }

  // Override to handle system notifications
  override func handleSystemMessage(_ text: String) {
    // Clear the current line and move cursor up to overwrite the `> ` prompt
    print("\r\u{1B}[1A\u{1B}[K", terminator: "")
    
    print("[CLI] 📢 System: \(text)")
    
    // Re-print the input prompt
    print("> ", terminator: "")
    fflush(stdout)

    // In a real app, you might show a toast or banner
    DispatchQueue.main.async {
      self.chatViewModel.showSystemNotification(text)
    }
  }

  // Called after binding - set up any additional subscriptions
  override func didBind(sessionId: UUID) {
    print("[CLI] ✅ Bound to session: \(sessionId)")

    // In a real app, you might set up additional UI state
    chatViewModel.isConnected = true

    // Start interactive input loop
    interactiveTask?.cancel()
    interactiveTask = Task { [weak self] in
        self?.printHelp()
        
        // Create an asynchronous stream of lines from standard input
        let lines = AsyncStream(String.self) { continuation in
            Task.detached {
                while let line = readLine() {
                    continuation.yield(line)
                }
                continuation.finish()
            }
        }

        // Process each line from the stream asynchronously
        for await line in lines {
            guard let self = self, !Task.isCancelled else { break }
            
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { 
                print("> ", terminator: ""); fflush(stdout)
                continue
            }

            if trimmed == "/quit" || trimmed == "/exit" || trimmed == ":q" {
                print("[CLI] exiting... bye!")
                fflush(stdout)
                exit(0)
            }
            if trimmed == "/help" { 
                self.printHelp()
                print("> ", terminator: ""); fflush(stdout)
                continue
            }

            // Send the message and wait for the operation to complete
            // The loop will suspend here and only resume when sendMessage is done.
            await self.handleUserInput(trimmed)
        }
        print("[CLI] exiting input loop (press Ctrl+C to quit the app)")
    }
  }

  // Helper to centralize message sending from the UI
  private func handleUserInput(_ text: String) async {
    do {
        try await sendMessage(text)
    } catch {
        print("[CLI] send error: \(error)")
        // Re-print prompt after an error
        print("> ", terminator: ""); fflush(stdout)
    }
  }

  // Called before unbinding - clean up resources
  override func didUnbind() {
    print("[CLI] 🔌 Unbound from session")
    chatViewModel.isConnected = false
    interactiveTask?.cancel()
    interactiveTask = nil
  }

  private func printHelp() {
    print("""
    
    🎯 CLI Demo Controls:
      /help    show this help
      /quit    exit demo
      /exit    exit demo
    
    📝 Try these example messages:
      "I want to pay for something"     → triggers payment feature
      "Take a photo"                    → triggers camera feature  
      "Show my contacts"                → triggers contacts feature
      "Where am I?"                     → triggers location feature
      "Send me a notification"          → triggers notification feature
    
    💡 The agent will always select the 2nd available feature (camera by default).
       Different features have different consent requirements!
    
    Type any message and press Enter to send it to the agent.
    """)
  }
}

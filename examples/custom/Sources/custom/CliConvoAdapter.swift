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

  init(chatViewModel: ChatViewModel) {
    self.chatViewModel = chatViewModel
    super.init()
  }

  // Override to handle message display - update your CLI component
  override func handleMessages(_ messages: [NeuronMessage]) {
    print("[CLI] Messages: \(messages.count)")

    // In a real SwiftUI app, you'd update @Published properties
    DispatchQueue.main.async {
      self.chatViewModel.messages = messages
    }

    // Show the latest message
    if let latest = messages.last {
      let ts = ISO8601DateFormatter().string(from: latest.timestamp)
      print("\n—— Inbound ——")
      print("time: \(ts)")
      print("from: \(latest.sender.rawValue)")
      print("text: \(latest.content)")
      print("———————\n")
    }
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
    print("[CLI] 📢 System: \(text)")

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
      while !(Task.isCancelled) {
        print("> ", terminator: "")
        guard let line = readLine() else { break }
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { continue }
        if trimmed == "/quit" || trimmed == "/exit" || trimmed == ":q" {
          print("[CLI] exiting... bye!")
          fflush(stdout)
          exit(0)
        }
        if trimmed == "/help" { self?.printHelp(); continue }
        do {
          try await self?.sendMessage(trimmed)
        } catch {
          print("[CLI] send error: \(error)")
        }
      }
      print("[CLI] exiting input loop (press Ctrl+C to quit the app)")
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

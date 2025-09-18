import Foundation
import Combine
import NeuronKit

// MARK: - Example: Custom CLI-style ConvoUI Adapter

/// This example shows how to create a custom ConvoUI adapter that wraps a CLI component
/// The adapter bridges between the CLI component and NeuronKit
class CliConvoAdapter: BaseConvoUIAdapter {

  // Reference to your UI component (in a real app, this would be a SwiftUI view model or UIKit controller)
  private let chatViewModel: ChatViewModel

  init(chatViewModel: ChatViewModel) {
    self.chatViewModel = chatViewModel
    super.init()
  }

  // Override to handle message display - update your CLI component
  override func handleMessages(_ messages: [NeuronMessage]) {
    print("[CLIAdapter] Updating UI with \(messages.count) messages")

    // In a real SwiftUI app, you'd update @Published properties
    DispatchQueue.main.async {
      self.chatViewModel.messages = messages
    }

    // Show the latest message
    if let latest = messages.last {
      print("[CLIAdapter] Latest: \(latest.sender.rawValue) - \(latest.content)")
    }
  }

  // Override to show consent UI - integrate with your UI framework
  override func handleConsentRequest(proposalId: UUID, sessionId: UUID, feature: String, args: [String: Any]) {
    print("[CLIAdapter] 🔐 Consent request for: \(feature)")
    print("[CLIAdapter] Args: \(args)")

    // In a real app, you'd show a SwiftUI alert or sheet
    chatViewModel.showConsentDialog(
      title: "Permission Request",
      message: "The agent wants to use: \(feature)",
      onApprove: { [weak self] in
        self?.context?.userProvidedConsent(messageId: proposalId, approved: true)
      },
      onDeny: { [weak self] in
        self?.context?.userProvidedConsent(messageId: proposalId, approved: false)
      }
    )
  }

  // Override to handle system notifications
  override func handleSystemMessage(_ text: String) {
    print("[CLIAdapter] 📢 System: \(text)")

    // In a real app, you might show a toast or banner
    DispatchQueue.main.async {
      self.chatViewModel.showSystemNotification(text)
    }
  }

  // Called after binding - set up any additional subscriptions
  override func didBind(sessionId: UUID) {
    print("[CLIAdapter] ✅ Bound to session: \(sessionId)")

    // In a real app, you might set up additional UI state
    chatViewModel.isConnected = true
  }

  // Called before unbinding - clean up resources
  override func didUnbind() {
    print("[CLIAdapter] 🔌 Unbound from session")
    chatViewModel.isConnected = false
  }
}

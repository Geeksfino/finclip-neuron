import Foundation
import Combine
import NeuronKit
import SandboxSDK

// MARK: - Mock UI Component (represents your actual UI)

/// This represents your actual UI component (SwiftUI ViewModel, UIKit Controller, etc.)
/// The ConvoUI adapter wraps this and bridges it with NeuronKit
class ChatViewModel: ObservableObject {
  @Published var messages: [NeuronMessage] = []
  @Published var isConnected: Bool = false
  @Published var systemNotification: String?
  
  // In a real SwiftUI app, this would trigger a sheet or alert
  func showConsentDialog(title: String, message: String, onApprove: @escaping () -> Void, onDeny: @escaping () -> Void) {
    print("🔔 [UI] Showing consent dialog: \(title)")
    print("   \(message)")
    
    // For demo, auto-approve after a delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      print("✅ [UI] User approved")
      onApprove()
    }
  }
  
  func showSystemNotification(_ text: String) {
    systemNotification = text
    
    // Clear after 3 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
      self.systemNotification = nil
    }
  }
  
  // This would be called from your UI (button tap, etc.)
  func sendMessage(_ text: String, adapter: CliConvoAdapter) async {
    do {
      try await adapter.sendMessage(text)
      print("📤 [UI] Message sent: \(text)")
    } catch {
      print("❌ [UI] Failed to send message: \(error)")
    }
  }
}

@main
enum CustomDemoApp {
  static func main() async {
    await runAdapterIntegrationExample()
  }
  
  // MARK: - Adapter Integration Example
  
  static func runAdapterIntegrationExample() async {
    print("🎨 Adapter Integration Example")
    print("This shows how to wrap your UI component with a ConvoUI adapter")
    
    // 1. Create your UI component (SwiftUI ViewModel, UIKit Controller, etc.)
    let chatViewModel = ChatViewModel()
    
    // 2. Create the adapter that wraps your UI component
    let uiAdapter = CliConvoAdapter(chatViewModel: chatViewModel)
    
    // 3. Set up NeuronKit with custom network adapter
    let config = NeuronKitConfig(
      serverURL: URL(string: "wss://api.example.com")!,
      deviceId: "demo-device",
      userId: "demo-user"
    )
    let neuronKit = NeuronRuntime(config: config)
    
    // Use mock network adapter to show proper flow
    let mockNetworkAdapter = MockAgentNetworkAdapter()
    neuronKit.setNetworkAdapter(mockNetworkAdapter)
    
    // 4. Register features
    let paymentFeature = SandboxSDK.Feature(
      id: "open_payment",
      name: "Open Payment",
      description: "Opens payment screen",
      category: .Native,
      path: "/payment",
      requiredCapabilities: [.UIAccess],
      primitives: [.MobileUI(page: "/payment", component: nil)]
    )
    
    _ = neuronKit.sandbox.registerFeature(paymentFeature)
    _ = neuronKit.sandbox.setPolicy("open_payment", SandboxSDK.Policy(
      requiresUserPresent: true,
      requiresExplicitConsent: true,
      sensitivity: .medium,
      rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 5)
    ))
    
    // 5. Set the adapter (this automatically handles all message/event subscriptions)
    neuronKit.setConvoUIAdapter(uiAdapter)
    
    // 6. Start session (adapter automatically binds)
    let sessionId = UUID()
    neuronKit.openSession(sessionId: sessionId, agentId: UUID())
    
    // 7. Send messages (can be done from UI or programmatically)
    try? await neuronKit.sendMessage(sessionId: sessionId, text: "Hello from custom UI!")
    
    // Simulate user sending message from UI
    await chatViewModel.sendMessage("I want to make a payment", adapter: uiAdapter)
    
    // Wait for responses
    try? await Task.sleep(nanoseconds: 1_000_000_000)
    
    // 8. The MockAgentNetworkAdapter will automatically simulate agent responses
    // This shows the proper flow: NetworkAdapter → NeuronKit → ConvoUIAdapter
    print("⏳ [Demo] Waiting for agent response via NetworkAdapter...")
    
    // Wait for the mock network adapter to send agent directive
    try? await Task.sleep(nanoseconds: 3_000_000_000)
    
    print("✅ Adapter Integration example completed!")
    print("")
    print("📱 In a real app with WebSocketNetworkAdapter:")
    print("   1. Agent sends: {\"type\":\"directives\", \"directives\":[{\"feature\":\"open_payment\"}]}")
    print("   2. WebSocketAdapter.inbound publishes the raw JSON data")
    print("   3. NeuronKit.acceptInboundFrame() receives the data")
    print("   4. DirectiveWorker parses InboundEnvelope → creates ConvoEvent")
    print("   5. ConvoUIAdapter.handleConsentRequest() shows UI")
    print("   6. User approves → context.userProvidedConsent() → agent gets response")
    print("")
    print("🎨 UI Framework Integration:")
    print("   - ChatViewModel would be your SwiftUI @ObservableObject")
    print("   - CliConvoAdapter would bridge NeuronKit ↔ CLI/SwiftUI")
    print("   - UI events (button taps) would call adapter.sendMessage()")
    print("   - Adapter updates would trigger SwiftUI view updates")
  }
}
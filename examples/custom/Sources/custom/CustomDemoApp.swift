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
    print("🎨 Adapter Integration Example (CLI)")
    print("Type /help for commands. Messages you type are sent to the agent.")
    
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
    
    // Use local MyLoopbackNetworkAdapter (namespaced in CustomAdapters) to show proper end-to-end flow without a server
    let loopback = MyLoopbackNetworkAdapter()
    neuronKit.setNetworkAdapter(loopback)
    
    // 4. Register multiple features with different policies
    let features = [
      // Feature 1: Payment (high security)
      SandboxSDK.Feature(
        id: "open_payment",
        name: "Open Payment",
        description: "Opens payment screen for transactions",
        category: .Native,
        path: "/payment",
        requiredCapabilities: [.UIAccess],
        primitives: [.MobileUI(page: "/payment", component: nil)]
      ),
      
      // Feature 2: Camera (medium security)
      SandboxSDK.Feature(
        id: "open_camera",
        name: "Open Camera",
        description: "Access device camera for photos",
        category: .Native,
        path: "/camera",
        requiredCapabilities: [.UIAccess],
        primitives: [.MobileUI(page: "/camera", component: "camera")]
      ),
      
      // Feature 3: Contacts (high sensitivity)
      SandboxSDK.Feature(
        id: "access_contacts",
        name: "Access Contacts",
        description: "Read user's contact list",
        category: .Native,
        path: "/contacts",
        requiredCapabilities: [.UIAccess],
        primitives: [.MobileUI(page: "/contacts", component: "list")]
      ),
      
      // Feature 4: Location (medium sensitivity)
      SandboxSDK.Feature(
        id: "get_location",
        name: "Get Location",
        description: "Access current GPS location",
        category: .Native,
        path: "/location",
        requiredCapabilities: [.UIAccess],
        primitives: [.MobileUI(page: "/location", component: "map")]
      ),
      
      // Feature 5: Send notification (low security)
      SandboxSDK.Feature(
        id: "send_notification",
        name: "Send Notification",
        description: "Display system notification",
        category: .Native,
        path: "/notification",
        requiredCapabilities: [.UIAccess],
        primitives: [.MobileUI(page: "/notification", component: "alert")]
      ),

      // Feature 6: Export report with parameters (typed, using primitive fields)
      // Demonstrates passing parameters via primitive configuration
      SandboxSDK.Feature(
        id: "export_report",
        name: "Export Report",
        description: "Export a report with a given format",
        category: .Native,
        path: "/report/export",
        requiredCapabilities: [.UIAccess],
        // Encode parameters into the primitive (e.g., component holds query-like info for demo)
        primitives: [.MobileUI(page: "/report/export", component: "format=csv&range=last30d")],
        argsSchema: FeatureArgsSchema(
          required: ["format", "range"],
          properties: [
            "format": FeatureArgSpec(
              type: .string,
              description: "Export format",
              enumVals: ["csv", "xlsx"]
            ),
            "range": FeatureArgSpec(
              type: .string,
              description: "Time range identifier",
              pattern: "^(today|yesterday|last7d|last30d|mtd|ytd)$"
            )
          ]
        ) // demonstrate required args + typed constraints
      ),

      // Feature 7: MiniApp route (category MiniApp)
      // Spec defines categories: Native, MiniApp, IoTDevice.
      // Here we register a MiniApp feature; primitive uses MobileUI for demo wiring.
      SandboxSDK.Feature(
        id: "miniapp_order_detail",
        name: "MiniApp Order Detail",
        description: "Open order detail within embedded mini app",
        category: .MiniApp,
        path: "/miniapp/order",
        requiredCapabilities: [.UIAccess],
        primitives: [.MobileUI(page: "/miniapp/order", component: "detail")]
      )
    ]
    
    // Register all features
    for feature in features {
      _ = neuronKit.sandbox.registerFeature(feature)
    }
    
    // Set different policies for each feature
    _ = neuronKit.sandbox.setPolicy("open_payment", SandboxSDK.Policy(
      requiresUserPresent: true,
      requiresExplicitConsent: true,
      sensitivity: .high,
      rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 3)
    ))
    
    _ = neuronKit.sandbox.setPolicy("open_camera", SandboxSDK.Policy(
      requiresUserPresent: true,
      requiresExplicitConsent: true,
      sensitivity: .medium,
      rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 10)
    ))
    
    _ = neuronKit.sandbox.setPolicy("access_contacts", SandboxSDK.Policy(
      requiresUserPresent: true,
      requiresExplicitConsent: true,
      sensitivity: .high,
      rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 2)
    ))
    
    _ = neuronKit.sandbox.setPolicy("get_location", SandboxSDK.Policy(
      requiresUserPresent: true,
      requiresExplicitConsent: false, // No explicit consent needed
      sensitivity: .medium,
      rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 20)
    ))
    
    _ = neuronKit.sandbox.setPolicy("send_notification", SandboxSDK.Policy(
      requiresUserPresent: false, // Can work in background
      requiresExplicitConsent: false,
      sensitivity: .low,
      rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 30)
    ))

    _ = neuronKit.sandbox.setPolicy("export_report", SandboxSDK.Policy(
      requiresUserPresent: true,
      requiresExplicitConsent: true,
      sensitivity: .medium,
      rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 10)
    ))

    _ = neuronKit.sandbox.setPolicy("miniapp_order_detail", SandboxSDK.Policy(
      requiresUserPresent: true,
      requiresExplicitConsent: false,
      sensitivity: .low,
      rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 30)
    ))
    
    // 5. Open conversation and bind UI (fluent API)
    let sessionId = UUID()
    let convo = neuronKit.openConversation(sessionId: sessionId, agentId: UUID())
    convo.bindUI(uiAdapter)
    
    // Keep the process alive for interactive CLI input; exit with Ctrl+C
    // Use an async-friendly infinite sleep loop to avoid Swift 6 warnings
    while true {
      do { try await Task.sleep(nanoseconds: 3_600_000_000_000) } // 1 hour
      catch { /* ignore */ }
    }
  }
}
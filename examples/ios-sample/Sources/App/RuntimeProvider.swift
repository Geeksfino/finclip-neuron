import Foundation
import Combine
import NeuronKit
import SandboxSDK

/// RuntimeProvider is a tiny utility that owns the NeuronRuntime lifecycle
/// and exposes its Sandbox for feature registration.
final class RuntimeProvider: ObservableObject {
  let runtime: NeuronRuntime
  let sandbox: Sandbox

  @Published var isSessionOpen: Bool = false
  @Published var conversations: [UUID] = []
  private var conversation: Conversation?
  private(set) var sessionId: UUID? // kept for display/debug if needed

  init() {
    // 1) Configuration (adjust to your environment)
    let config = NeuronKitConfig(
      serverURL: URL(string: "wss://agent.example.com")!,
      deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "demo-device",
      userId: "demo-user"
    )

    // 2) Initialize runtime
    self.runtime = NeuronRuntime(config: config)

    // 3) Get sandbox reference
    self.sandbox = runtime.sandbox

    // 4) Register features & policies (sample)
    registerSampleFeatures()
    setSamplePolicies()

    // Optional (advanced):
    // runtime.setNetworkAdapter(MyWebSocketNetworkAdapter(url: URL(string: "wss://.../ws")!))
  }

  // MARK: - Conversations list helpers (attach vs resume)
  func createConversationEntry() {
    let sid = UUID()
    conversations.insert(sid, at: 0)
  }

  func messagesSnapshot(sessionId: UUID, limit: Int = 50, before: Date? = nil) -> [NeuronMessage] {
    (try? runtime.messagesSnapshot(sessionId: sessionId, limit: limit, before: before)) ?? []
  }

  func resumeAndBind(sessionId: UUID, adapter: ConvoUIAdapter, agentId: UUID = UUID()) {
    let convo = runtime.resumeConversation(sessionId: sessionId, agentId: agentId)
    self.conversation = convo
    self.sessionId = sessionId
    self.isSessionOpen = true
    convo.bindUI(adapter)
  }

  func openSession() {
    guard conversation == nil else { return }
    let sid = UUID()
    conversations.insert(sid, at: 0)
    let convo = runtime.openConversation(sessionId: sid, agentId: UUID())
    self.conversation = convo
    self.sessionId = sid
    self.isSessionOpen = true
  }

  func closeSession() {
    guard conversation != nil else { return }
    
    // Unbind UI and close session properly
    conversation?.unbindUI()
    conversation?.close()
    
    conversation = nil
    sessionId = nil
    isSessionOpen = false
  }
  
  func bindUI(_ adapter: ConvoUIAdapter) {
    conversation?.bindUI(adapter)
  }
  
  func unbindUI() {
    conversation?.unbindUI()
  }

  // Access to messages publisher for a given session (useful for read-only attach)
  func messagesPublisher(sessionId: UUID) -> AnyPublisher<[NeuronMessage], Never> {
    runtime.messagesPublisher(sessionId: sessionId)
  }

  // MARK: - Sample Feature Registration

  private func registerSampleFeatures() {
    let camera = SandboxSDK.Feature(
      id: "open_camera",
      name: "Open Camera",
      description: "Access device camera for photos",
      category: .Native,
      path: "/camera",
      requiredCapabilities: [.UIAccess],
      primitives: [.MobileUI(page: "/camera", component: "camera")]
    )
    _ = sandbox.registerFeature(camera)

    let export = SandboxSDK.Feature(
      id: "export_report",
      name: "Export Report",
      description: "Export a report with a given format",
      category: .Native,
      path: "/report/export",
      requiredCapabilities: [.UIAccess],
      primitives: [.MobileUI(page: "/report/export", component: "format=csv&range=last30d")],
      argsSchema: FeatureArgsSchema(
        required: ["format", "range"],
        properties: [
          "format": FeatureArgSpec(type: .string, description: "Export format", enumVals: ["csv", "xlsx"]),
          "range": FeatureArgSpec(type: .string, description: "Time range", pattern: "^(today|yesterday|last7d|last30d|mtd|ytd)$")
        ]
      )
    )
    _ = sandbox.registerFeature(export)
  }

  private func setSamplePolicies() {
    _ = sandbox.setPolicy("open_camera", SandboxSDK.Policy(
      requiresUserPresent: true,
      requiresExplicitConsent: true,
      sensitivity: .medium,
      rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 10)
    ))

    _ = sandbox.setPolicy("export_report", SandboxSDK.Policy(
      requiresUserPresent: true,
      requiresExplicitConsent: true,
      sensitivity: .medium,
      rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 5)
    ))
  }
}

import Foundation
import Combine
import NeuronKit

/// A trivial NetworkAdapter that loops outbound bytes back as inbound.
/// This adapter is primarily used for testing and development purposes.
public final class MyLoopbackNetworkAdapter: NetworkAdapter {
  private let queue = DispatchQueue(label: "loopback.adapter")
  private var started = false
  
  // NetworkAdapter required callback properties
  public var onOutboundData: ((Data) -> Void)?
  public var onStateChange: ((NetworkState) -> Void)?
  public var inboundDataHandler: ((Data) -> Void)?
  
  private let inboundSubject = PassthroughSubject<Data, Never>()
  private let stateSubject = CurrentValueSubject<NetworkState, Never>(.disconnected)
  
  public var inbound: AnyPublisher<Data, Never> { inboundSubject.eraseToAnyPublisher() }
  public var state: AnyPublisher<NetworkState, Never> { stateSubject.eraseToAnyPublisher() }
  
  public init() {}

  public func start() {
    started = true
    stateSubject.send(.connected)
    onStateChange?(.connected)
  }
  
  public func stop() {
    started = false
    stateSubject.send(.disconnected)
    onStateChange?(.disconnected)
  }

  public func send(_ data: Data) {
    guard started else { return }
    
    print("\n=== OUTBOUND JSON (Network Send) ===")
    if let jsonString = String(data: data, encoding: .utf8) {
      print(jsonString)
    }
    print("=====================================\n")
    
    // Inspect outbound JSON without relying on types from NeuronKit target
    var conversationId: UUID = UUID()
    var userContent: String = "(no content)"
    var availableFeatures: [[String: Any]] = []
    var deviceContext: [String: Any]? = nil
    
    if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
      // Extract message content
      if let c = obj["content"] as? String { userContent = c }
      print("[Loopback] 📤 User Message: \"\(userContent)\"")
      
      // Extract meta/application content
      if let meta = obj["meta"] as? [String: String], !meta.isEmpty {
        print("[Loopback] 📱 Application Context: \(meta)")
      } else {
        print("[Loopback] 📱 Application Context: none")
      }
      
      // Extract exported features
      if let feats = obj["availableFeatures"] as? [[String: Any]] {
        availableFeatures = feats
        print("[Loopback] 🔧 Available Features (\(feats.count)):")
        for (index, f) in feats.enumerated() {
          let fid = f["id"] as? String ?? "<no-id>"
          let fname = f["name"] as? String ?? "<no-name>"
          let fdesc = f["description"] as? String ?? "<no-desc>"
          print("  [\(index + 1)] \(fid): \(fname) - \(fdesc)")
        }
      } else {
        print("[Loopback] 🔧 Available Features: none")
      }
      
      // Extract device context
      deviceContext = obj["deviceContext"] as? [String: Any]
      if let dc = deviceContext {
        let dtype = dc["deviceType"] as? String ?? "<unknown>"
        let tz = dc["timezone"] as? String ?? "<unknown>"
        var extra = ""
        if let net = dc["networkType"] as? String { extra += ", network=\(net)" }
        if let bat = dc["batteryLevel"] as? Double { extra += ", battery=\(Int(bat * 100))%" }
        print("[Loopback] 📱 Device Context: \(dtype), \(tz)\(extra)")
      } else {
        print("[Loopback] 📱 Device Context: none")
      }
      
      // Extract conversation id
      if let conv = obj["conversationId"] as? String, let cid = UUID(uuidString: conv) {
        conversationId = cid
      }
    } else {
      print("[Loopback] ❌ Could not parse outbound JSON; falling back to raw echo")
      queue.asyncAfter(deadline: .now() + 0.01) { [weak self] in
        self?.inboundSubject.send(data)
        self?.inboundDataHandler?(data)
      }
      return
    }
    
    // First: echo a chat message back from the agent
    let responseTexts = [
      "I understand you want to \(userContent.lowercased()). Let me help you with that.",
      "Based on your request '\(userContent)', I'll suggest an appropriate action.",
      "I can help you with '\(userContent)'. Let me propose a suitable feature.",
      "Processing your request: '\(userContent)'. I'll recommend the best option."
    ]
    let agentResponse = responseTexts.randomElement() ?? "I received your message."
    
    let wire = WireMessage(
      id: UUID(),
      conversationId: conversationId,
      sender: "agent",
      content: agentResponse,
      timestamp: Date(),
      meta: nil as [String: String]?
    )
    if let reply = try? JSONEncoder().encode(wire) {
      queue.asyncAfter(deadline: .now() + 0.5) { [weak self] in 
        self?.inboundSubject.send(reply)
        self?.inboundDataHandler?(reply)
      }
    }
    
    // Second: intelligently select the second feature (index 1) if available, or first if only one
    if !availableFeatures.isEmpty {
      let selectedIndex = availableFeatures.count > 1 ? 1 : 0  // Always pick second feature if available
      let chosen = availableFeatures[selectedIndex]
      
      if let fid = chosen["id"] as? String,
         let fname = chosen["name"] as? String {
        print("[Loopback] 🤖 Agent selecting feature [\(selectedIndex + 1)]: \(fname) (\(fid))")
        
        // Create args based on feature type
        var args: [String: String] = [:]
        switch fid {
        case "open_payment":
          args = ["amount": "29.99", "currency": "USD", "merchant": "Demo Store"]
        case "open_camera":
          args = ["mode": "photo", "quality": "high"]
        case "access_contacts":
          args = ["purpose": "contact_suggestion", "limit": "10"]
        case "get_location":
          args = ["precision": "city", "purpose": "weather"]
        case "send_notification":
          args = ["title": "Demo Notification", "message": "This is a test notification"]
        default:
          args = ["action": "execute"]
        }
        
        let env = InboundEnvelope(
          type: .directives,
          sessionId: conversationId,
          directives: [ ActionProposal(id: UUID(), feature: fid, args: args) ]
        )
        if let payload = try? JSONEncoder().encode(env) {
          queue.asyncAfter(deadline: .now() + 1.0) { [weak self] in 
            self?.inboundSubject.send(payload)
            self?.inboundDataHandler?(payload)
          }
        }
      }
    }
  }
}

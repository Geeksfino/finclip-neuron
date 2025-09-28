import Foundation
import Combine
import NeuronKit

/// A loopback NetworkAdapter used by the CLI demo to inspect outbound envelopes and
/// simulate streamed responses + directives without a real transport.
public final class MyLoopbackNetworkAdapter: BaseNetworkAdapter {
  private let queue = DispatchQueue(label: "loopback.adapter")

  public override func start() {
    updateState(.connected)
  }

  public override func stop() {
    updateState(.disconnected)
  }

  public override func sendToNetworkComponent(_ data: Any) {
    guard let data = data as? Data else { return }

    print("\n=== OUTBOUND JSON (Network Send) ===")
    if let jsonString = String(data: data, encoding: .utf8) {
      print(jsonString)
    }
    print("=====================================\n")

    var conversationId = UUID()
    var availableFeatures: [[String: Any]] = []
    var userText = "(no content)"

    guard let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      print("[Loopback] ❌ Could not parse outbound JSON; falling back to raw echo")
      queue.asyncAfter(deadline: .now() + 0.05) { [weak self] in
        self?.handleInboundData(data)
      }
      return
    }

    // Extract message text
    if let userIntent = obj["userIntent"] as? [String: Any],
       let content = userIntent["content"] as? [String: Any],
       let text = content["text"] as? String {
      userText = text
    }
    print("[Loopback] 📤 User Message: \(userText)")

    // Extract features
    if let features = obj["features"] as? [[String: Any]], !features.isEmpty {
      availableFeatures = features
      print("[Loopback] 🔧 Available Features (\(features.count))")
      for (index, feature) in features.enumerated() {
        let fid = feature["id"] as? String ?? "<no-id>"
        let name = feature["name"] as? String ?? "<no-name>"
        let description = feature["description"] as? String ?? "<no-desc>"
        print("  [\(index + 1)] \(fid): \(name) - \(description)")
      }
    } else {
      print("[Loopback] 🔧 Available Features: none")
    }

    // Extract device context
    if let contexts = obj["deviceContext"] as? [[String: Any]],
       let deviceEntry = contexts.first(where: { ($0["contextType"] as? String) == "device" }),
       let payload = deviceEntry["payload"] as? [String: Any] {
      let dtype = payload["deviceType"] as? String ?? "<unknown>"
      let os = payload["osName"] as? String ?? "<unknown>"
      let osVersion = payload["osVersion"] as? String ?? "<unknown>"
      let tz = payload["timezone"] as? String ?? "<unknown>"
      print("[Loopback] 📱 Device Context: \(dtype) / \(os) \(osVersion), tz=\(tz)")
    } else {
      print("[Loopback] 📱 Device Context: none")
    }

    // Extract metadata (conversation IDs, locale, etc.)
    if let metadata = obj["metadata"] as? [String: Any] {
      if let conversation = metadata["conversationId"] as? String,
         let cid = UUID(uuidString: conversation) {
        conversationId = cid
      }
      print("[Loopback] 🧾 Metadata:")
      for (key, value) in metadata {
        print("  \(key): \(value)")
      }
    }

    sendStreamedChatResponse(for: userText,
                             conversationId: conversationId,
                             features: availableFeatures)
  }

  private func sendStreamedChatResponse(for userText: String,
                                        conversationId: UUID,
                                        features: [[String: Any]]) {
    let templates = [
      "I understand you want to \(userText.lowercased()). Let me help you with that.",
      "Based on your request '\(userText)', I'll suggest an appropriate action.",
      "I can help you with '\(userText)'. Let me propose a suitable feature.",
      "Processing your request: '\(userText)'. I'll recommend the best option."
    ]
    let response = templates.randomElement() ?? "I received your message."

    emitStreamingPreview(response,
                         conversationId: conversationId)

    let wire = WireMessage(
      id: UUID(),
      conversationId: conversationId,
      sender: "agent",
      content: response,
      timestamp: Date(),
      meta: nil as [String: String]?
    )

    guard let encoded = try? JSONEncoder().encode(wire) else { return }

    handleInboundData(encoded)

    let delay = streamingDelay(for: response.count)
    queue.asyncAfter(deadline: .now() + delay) { [weak self] in
      self?.sendActionProposal(conversationId: conversationId,
                               availableFeatures: features)
    }
  }

  private func sendActionProposal(conversationId: UUID,
                                  availableFeatures: [[String: Any]]) {
    guard !availableFeatures.isEmpty else { return }
    let index = availableFeatures.count > 1 ? 1 : 0
    let chosen = availableFeatures[index]
    guard let featureId = chosen["id"] as? String,
          let featureName = chosen["name"] as? String else { return }

    print("[Loopback] 🤖 Agent selecting feature [\(index + 1)]: \(featureName) (\(featureId))")

    let args: [String: String]
    switch featureId {
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

    let envelope = InboundEnvelope(
      type: .directives,
      sessionId: conversationId,
      directives: [ActionProposal(id: UUID(), feature: featureId, args: args)]
    )

    if let payload = try? JSONEncoder().encode(envelope) {
      handleInboundData(payload)
    }
  }

  private func emitStreamingPreview(_ text: String,
                                    conversationId: UUID) {
    let streamId = "loopback-" + UUID().uuidString
    let messageId = UUID()
    let tokens = makeChunks(text: text, size: 32)

    for (index, token) in tokens.enumerated() {
      let chunk = InboundStreamChunk(
        streamId: streamId,
        sequence: index,
        data: Data(token.utf8),
        isFinal: index == tokens.count - 1,
        messageId: messageId,
        conversationId: conversationId,
        sessionId: conversationId,
        metadata: ["transport": "loopback", "kind": "preview"]
      )

      queue.asyncAfter(deadline: .now() + 0.15 * Double(index)) { [weak self] in
        self?.inboundPartialDataHandler?(chunk)
      }
    }
  }

  private func makeChunks(text: String, size: Int) -> [String] {
    guard text.count > size else { return [text] }
    var result: [String] = []
    var current = text.startIndex
    while current < text.endIndex {
      let end = text.index(current, offsetBy: size, limitedBy: text.endIndex) ?? text.endIndex
      result.append(String(text[current..<end]))
      current = end
    }
    return result
  }

  private func streamingDelay(for byteCount: Int) -> TimeInterval {
    let chunkSize = max(64, byteCount / 3)
    let chunkCount = max(1, Int(ceil(Double(byteCount) / Double(chunkSize))))
    return 0.2 * Double(chunkCount) + 0.3
  }
}

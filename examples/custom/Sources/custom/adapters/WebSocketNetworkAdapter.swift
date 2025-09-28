import Foundation
import NeuronKit

/// Mock WebSocket adapter leveraging `BaseNetworkAdapter` to demonstrate streaming chunks.
/// Replace the simulated timers with a real WebSocket implementation (e.g. `URLSessionWebSocketTask`).
public final class MyWebSocketNetworkAdapter: BaseNetworkAdapter {
  private let url: URL?
  private let queue = DispatchQueue(label: "websocket.adapter")
  private var isStarted = false

  public init(url: URL? = nil) {
    self.url = url
    super.init()
  }

  public override func start() {
    guard !isStarted else { return }
    isStarted = true
    updateState(.connecting)

    queue.asyncAfter(deadline: .now() + 0.05) { [weak self] in
      guard let self else { return }
      if let url = self.url, url.absoluteString.contains("invalid") {
        let error = NetworkError(code: "connection_failed",
                                 message: "Failed to connect to WebSocket server",
                                 underlyingError: NSError(domain: "WebSocketError",
                                                          code: -1,
                                                          userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
        self.updateState(.error(error))
      } else {
        self.updateState(.connected)
      }
    }
  }

  public override func stop() {
    guard isStarted else { return }
    isStarted = false
    updateState(.disconnected)
  }

  public override func sendToNetworkComponent(_ data: Any) {
    guard isStarted, let payload = data as? Data else {
      print("[WebSocket] Attempted to send while not connected or payload not `Data`")
      return
    }

    onOutboundData?(payload)

    guard let envelope = try? JSONSerialization.jsonObject(with: payload) as? [String: Any],
          let userIntent = envelope["userIntent"] as? [String: Any],
          let content = userIntent["content"] as? [String: Any],
          let text = content["text"] as? String,
          let conversationId = envelope["conversationId"] as? String,
          let sessionId = UUID(uuidString: conversationId)
    else {
      queue.asyncAfter(deadline: .now() + 0.05) { [weak self] in
        self?.handleInboundData(payload)
      }
      return
    }

    emitStreamingPreview("Echo via WebSocket: \(text)", sessionId: sessionId)

    // Simulate final full message
    let wire = WireMessage(
      id: UUID(),
      conversationId: sessionId,
      sender: "agent",
      content: "Echo via WebSocket: \(text)",
      timestamp: Date(),
      meta: nil as [String: String]?
    )

    if let encoded = try? JSONEncoder().encode(wire) {
      queue.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        self?.handleInboundData(encoded)
      }
    }
  }

  private func emitStreamingPreview(_ text: String, sessionId: UUID) {
    let streamId = "ws-stream-" + UUID().uuidString
    let messageId = UUID()
    let tokens = makeChunks(text: text, size: 30)

    for (index, token) in tokens.enumerated() {
      let chunk = InboundStreamChunk(
        streamId: streamId,
        sequence: index,
        data: Data(token.utf8),
        isFinal: index == tokens.count - 1,
        messageId: messageId,
        conversationId: sessionId,
        sessionId: sessionId,
        metadata: ["transport": "websocket", "kind": "preview"]
      )

      queue.asyncAfter(deadline: .now() + Double(index) * 0.12) { [weak self] in
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
}

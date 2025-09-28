import Foundation
import Combine
import NeuronKit

// MARK: - Mock Network Adapter (shows proper flow)

/// This shows how agent responses would flow through a real NetworkAdapter
final class MockAgentNetworkAdapter: NetworkAdapter {
  private let inboundSubject = PassthroughSubject<Data, Never>()
  private let stateSubject = CurrentValueSubject<NetworkState, Never>(.disconnected)
  private let queue = DispatchQueue(label: "mock.network.adapter")
  private var currentSessionId: UUID?

  var onOutboundData: ((Data) -> Void)?
  var onStateChange: ((NetworkState) -> Void)?
  var inboundDataHandler: ((Data) -> Void)?
  var inboundPartialDataHandler: ((InboundStreamChunk) -> Void)?

  var inbound: AnyPublisher<Data, Never> { inboundSubject.eraseToAnyPublisher() }
  var state: AnyPublisher<NetworkState, Never> { stateSubject.eraseToAnyPublisher() }

  func start() {
    stateSubject.send(.connected)
    onStateChange?(.connected)
  }

  func stop() {
    stateSubject.send(.disconnected)
    onStateChange?(.disconnected)
  }

  func send(_ data: Data) {
    print("📡 [MockNetwork] Sending to agent: \(data.count) bytes")
    onOutboundData?(data)

    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let conversationId = json["conversationId"] as? String,
          let sessionId = UUID(uuidString: conversationId)
    else { return }

    currentSessionId = sessionId

    DispatchQueue.global().asyncAfter(deadline: .now() + 0.35) { [weak self] in
      self?.simulateStreamingMessage(sessionId: sessionId)
    }
    DispatchQueue.global().asyncAfter(deadline: .now() + 1.25) { [weak self] in
      self?.simulateAgentDirective(sessionId: sessionId)
    }
  }

  private func simulateStreamingMessage(sessionId: UUID) {
    guard let outboundId = currentSessionId,
          let handler = inboundPartialDataHandler else { return }

    let messageId = UUID()
    let streamId = "mock-stream-" + UUID().uuidString
    let preview = "Preparing approval flow for your payment request…"
    let tokens = makeChunks(text: preview, size: 28)

    for (index, token) in tokens.enumerated() {
      let chunk = InboundStreamChunk(
        streamId: streamId,
        sequence: index,
        data: Data(token.utf8),
        isFinal: index == tokens.count - 1,
        messageId: messageId,
        conversationId: outboundId,
        sessionId: outboundId,
        metadata: ["transport": "mock", "kind": "preview"]
      )

      queue.asyncAfter(deadline: .now() + Double(index) * 0.18) {
        print("📨 [MockNetwork] Streaming chunk #\(index) final=\(chunk.isFinal)")
        handler(chunk)
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

  private func simulateAgentDirective(sessionId: UUID) {
    print("🤖 [MockNetwork] Agent sending directive for session: \(sessionId)")

    let agentResponse = InboundEnvelope(
      type: .directives,
      sessionId: sessionId,
      directives: [ActionProposal(id: UUID(), feature: "open_payment", args: ["amount": "25.00"])]
    )

    if let data = try? JSONEncoder().encode(agentResponse) {
      print("📨 [MockNetwork] Publishing agent directive to NeuronKit")
      inboundSubject.send(data)
      inboundDataHandler?(data)
    }
  }
}

import Foundation
import Combine
import NeuronKit

// MARK: - Mock Network Adapter (shows proper flow)

/// This shows how agent responses would flow through a real NetworkAdapter
class MockAgentNetworkAdapter: NetworkAdapter {
  private let inboundSubject = PassthroughSubject<Data, Never>()
  private let stateSubject = CurrentValueSubject<NetworkState, Never>(.disconnected)
  private var currentSessionId: UUID?
  
  public var inbound: AnyPublisher<Data, Never> { inboundSubject.eraseToAnyPublisher() }
  public var state: AnyPublisher<NetworkState, Never> { stateSubject.eraseToAnyPublisher() }
  
  func start() {
    stateSubject.send(.connected)
  }
  
  func stop() {
    stateSubject.send(.disconnected)
  }
  
  func send(_ data: Data) {
    // In a real adapter, this would send over WebSocket/HTTP
    print("📡 [MockNetwork] Sending to agent: \(data.count) bytes")
    
    // Extract session ID from outbound message for response
    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let conversationId = json["conversationId"] as? String,
       let sessionId = UUID(uuidString: conversationId) {
      self.currentSessionId = sessionId
      
      // Simulate agent response after a delay
      DispatchQueue.global().asyncAfter(deadline: .now() + 1.5) {
        self.simulateAgentDirective(sessionId: sessionId)
      }
    }
  }
  
  private func simulateAgentDirective(sessionId: UUID) {
    print("🤖 [MockNetwork] Agent sending directive for session: \(sessionId)")
    
    // This is what an agent would send over the network
    let agentResponse = InboundEnvelope(
      type: .directives,
      sessionId: sessionId,
      directives: [
        ActionProposal(id: UUID(), feature: "open_payment", args: ["amount": "25.00"])
      ]
    )
    
    if let data = try? JSONEncoder().encode(agentResponse) {
      // This is the key: NetworkAdapter publishes data → NeuronKit receives it
      print("📨 [MockNetwork] Publishing agent directive to NeuronKit")
      inboundSubject.send(data)
    }
  }
}

import Foundation
import Combine
import NeuronKit

/// WebSocket adapter implementing the NetworkAdapter protocol.
/// This is a mock implementation that simulates WebSocket behavior for testing purposes.
/// In a real implementation, this would integrate with an actual WebSocket library.
public final class MyWebSocketNetworkAdapter: NetworkAdapter {
  private let url: URL?
  private var isStarted = false

  // NetworkAdapter required callback properties
  public var onOutboundData: ((Data) -> Void)?
  public var onStateChange: ((NetworkState) -> Void)?
  public var inboundDataHandler: ((Data) -> Void)?

  private let inboundSubject = PassthroughSubject<Data, Never>()
  private let stateSubject = CurrentValueSubject<NetworkState, Never>(.disconnected)

  public var inbound: AnyPublisher<Data, Never> { inboundSubject.eraseToAnyPublisher() }
  public var state: AnyPublisher<NetworkState, Never> { stateSubject.eraseToAnyPublisher() }

  public init(url: URL? = nil) {
    self.url = url
  }

  public func start() {
    guard !isStarted else { return }
    isStarted = true
    
    // Simulate connection process with enhanced error handling
    stateSubject.send(.connecting)
    onStateChange?(.connecting)
    
    // Simulate potential connection scenarios
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.02) { [weak self] in
      guard let self = self, self.isStarted else { return }
      
      // In a real implementation, this would handle actual connection errors
      if let url = self.url, url.absoluteString.contains("invalid") {
        let error = NetworkError(
          code: "connection_failed",
          message: "Failed to connect to WebSocket server",
          underlyingError: NSError(domain: "WebSocketError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        )
        self.stateSubject.send(.error(error))
        self.onStateChange?(.error(error))
      } else {
        self.stateSubject.send(.connected)
        self.onStateChange?(.connected)
      }
    }
  }

  public func stop() {
    isStarted = false
    stateSubject.send(.disconnected)
    onStateChange?(.disconnected)
  }

  public func send(_ data: Data) {
    guard isStarted else { 
      // Log error but don't propagate (NeuronKit handles retries)
      print("[WebSocket] Attempted to send data while adapter is not started")
      return 
    }
    onOutboundData?(data)
    
    // Simulate network send
    // In a real implementation, this would send data via WebSocket
    // For now, simulate successful send followed by response
    
    // First, emit an ack frame for the outbound message id (parse id from JSON generically)
    if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
       let idStr = obj["id"] as? String,
       let _ = UUID(uuidString: idStr) {
      let ack: [String: String] = ["ack_for": idStr]
      if let ackData = try? JSONSerialization.data(withJSONObject: ack) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.02) { [weak self] in
          self?.inboundSubject.send(ackData)
          self?.inboundDataHandler?(ackData)
        }
      }
    }
    
    // Then echo back as if agent replied
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) { [weak self] in
      self?.inboundSubject.send(data)
      self?.inboundDataHandler?(data)
    }
  }
}

import Foundation
import Combine
import NeuronKit

/// WebSocket adapter implementing the NetworkAdapter protocol.
/// This is a mock implementation that simulates WebSocket behavior for testing purposes.
/// In a real implementation, this would integrate with an actual WebSocket library.
public final class WebSocketNetworkAdapter: BaseNetworkAdapter {
  private let url: URL?
  private var isStarted = false
  
  public init(url: URL? = nil) { 
    self.url = url
    super.init()
  }

  public override func start() {
    guard !isStarted else { return }
    isStarted = true
    
    // Simulate connection process with enhanced error handling
    updateState(.connecting)
    
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
        self.updateState(.error(error))
      } else {
        self.updateState(.connected)
      }
    }
  }

  public override func stop() {
    isStarted = false
    updateState(.disconnected)
  }

  public override func sendToNetworkComponent(_ data: Any) {
    guard let data = data as? Data, isStarted else { 
      // Log error but don't propagate (NeuronKit handles retries)
      print("[WebSocket] Attempted to send data while adapter is not started")
      return 
    }
    
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
          self?.handleInboundData(ackData)
        }
      }
    }
    
    // Then echo back as if agent replied
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) { [weak self] in
      self?.handleInboundData(data)
    }
  }
  
  // MARK: - Data Conversion (Override if needed for specific WebSocket format)
  
  public override func convertOutboundData(_ data: Data) -> Any {
    // Default implementation passes Data through
    // Override this if your WebSocket library expects String or specific format
    return data
  }
  
  public override func convertInboundData(_ data: Any) -> Data? {
    // Handle different data types that might come from WebSocket
    if let data = data as? Data {
      return data
    } else if let string = data as? String {
      return string.data(using: .utf8)
    } else {
      print("[WebSocket] Received unsupported data type: \(type(of: data))")
      return nil
    }
  }
}

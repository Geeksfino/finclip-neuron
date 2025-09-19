import Foundation
import Combine
import NeuronKit

// MARK: - URLSession HTTP Adapter Example

/// Example NetworkAdapter implementation using URLSession for HTTP-based networking.
/// This demonstrates how to integrate HTTP polling and posting with NeuronKit.
public final class MyURLSessionHTTPAdapter: NetworkAdapter {
  private let session: URLSession
  private let baseURL: URL
  private let pollingInterval: TimeInterval
  private let sendEndpoint: String
  private let pollEndpoint: String
  
  private var pollingTask: Task<Void, Never>?
  private var isStarted = false
  
  // NetworkAdapter required callback properties
  public var onOutboundData: ((Data) -> Void)?
  public var onStateChange: ((NetworkState) -> Void)?
  public var inboundDataHandler: ((Data) -> Void)?
  
  private let inboundSubject = PassthroughSubject<Data, Never>()
  private let stateSubject = CurrentValueSubject<NetworkState, Never>(.disconnected)
  
  public var inbound: AnyPublisher<Data, Never> { inboundSubject.eraseToAnyPublisher() }
  public var state: AnyPublisher<NetworkState, Never> { stateSubject.eraseToAnyPublisher() }
  
  /// Initialize the adapter with HTTP configuration
  public init(
    baseURL: URL,
    session: URLSession = .shared,
    pollingInterval: TimeInterval = 1.0,
    sendEndpoint: String = "send",
    pollEndpoint: String = "poll"
  ) {
    self.baseURL = baseURL
    self.session = session
    self.pollingInterval = pollingInterval
    self.sendEndpoint = sendEndpoint
    self.pollEndpoint = pollEndpoint
  }
  
  // MARK: - NetworkAdapter Implementation
  
  public func start() {
    guard !isStarted else { return }
    
    isStarted = true
    stateSubject.send(.connecting)
    onStateChange?(.connecting)
    
    // Test connectivity with a simple request
    Task {
      await testConnectivity()
    }
  }
  
  public func stop() {
    isStarted = false
    pollingTask?.cancel()
    pollingTask = nil
    stateSubject.send(.disconnected)
    onStateChange?(.disconnected)
    print("URLSessionHTTPAdapter: Stopped")
  }
  
  public func send(_ data: Data) {
    guard isStarted else { 
      print("URLSessionHTTPAdapter: Cannot send data - not started or invalid data type")
      return 
    }
    onOutboundData?(data)
    
    Task {
      await sendMessage(data)
    }
  }
  
  // MARK: - HTTP Operations
  
  /// Test connectivity to the server
  private func testConnectivity() async {
    let testURL = baseURL.appendingPathComponent("health")
    var request = URLRequest(url: testURL)
    request.httpMethod = "GET"
    request.timeoutInterval = 10.0
    
    do {
      let (_, response) = try await session.data(for: request)
      
      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          stateSubject.send(.connected)
          onStateChange?(.connected)
          startPolling()
          print("URLSessionHTTPAdapter: Connected successfully")
        } else {
          let error = NetworkError(
            code: "http_error",
            message: "Server returned status code \(httpResponse.statusCode)"
          )
          stateSubject.send(.error(error))
          onStateChange?(.error(error))
        }
      }
    } catch {
      // If health endpoint doesn't exist, assume we're connected and start polling
      print("URLSessionHTTPAdapter: Health check failed, assuming connected: \(error)")
      stateSubject.send(.connected)
      onStateChange?(.connected)
      startPolling()
    }
  }
  
  /// Send a message via HTTP POST
  private func sendMessage(_ data: Data) async {
    let sendURL = baseURL.appendingPathComponent(sendEndpoint)
    var request = URLRequest(url: sendURL)
    request.httpMethod = "POST"
    request.httpBody = data
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 30.0
    
    do {
      let (_, response) = try await session.data(for: request)
      
      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode >= 400 {
          print("URLSessionHTTPAdapter: Send failed with status \(httpResponse.statusCode)")
          // Don't update state for send failures - NeuronKit handles retries
        } else {
          print("URLSessionHTTPAdapter: Message sent successfully")
        }
      }
    } catch {
      print("URLSessionHTTPAdapter: Send error: \(error)")
      // Don't propagate send errors - NeuronKit handles retries
    }
  }
  
  /// Start polling for messages
  private func startPolling() {
    guard pollingTask == nil else { return }
    
    pollingTask = Task { [weak self] in
      while !Task.isCancelled && self?.isStarted == true {
        await self?.pollForMessages()
        
        // Wait for the polling interval
        do {
          try await Task.sleep(nanoseconds: UInt64(self?.pollingInterval ?? 1.0 * 1_000_000_000))
        } catch {
          break
        }
      }
    }
  }
  
  /// Poll for new messages
  private func pollForMessages() async {
    let pollURL = baseURL.appendingPathComponent(pollEndpoint)
    var request = URLRequest(url: pollURL)
    request.httpMethod = "GET"
    request.timeoutInterval = 30.0
    
    do {
      let (data, response) = try await session.data(for: request)
      
      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          if !data.isEmpty {
            inboundSubject.send(data)
            inboundDataHandler?(data)
          }
        } else if httpResponse.statusCode >= 500 {
          let error = NetworkError(
            code: "server_error",
            message: "Server error: \(httpResponse.statusCode)"
          )
          stateSubject.send(.error(error))
          onStateChange?(.error(error))
        }
      }
    } catch {
      if isStarted {
        print("URLSessionHTTPAdapter: Polling error: \(error)")
        stateSubject.send(.reconnecting)
        onStateChange?(.reconnecting)
        try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        if isStarted {
          stateSubject.send(.connected)
          onStateChange?(.connected)
        }
      }
    }
  }
  
}

// MARK: - Convenience

extension MyURLSessionHTTPAdapter {
  public convenience init(
    baseURL: URL,
    apiKey: String? = nil,
    pollingInterval: TimeInterval = 1.0
  ) {
    let config = URLSessionConfiguration.default
    if let apiKey = apiKey {
      config.httpAdditionalHeaders = [
        "Authorization": "Bearer \(apiKey)",
        "User-Agent": "NeuronKit-HTTPAdapter/1.0"
      ]
    }
    let session = URLSession(configuration: config)
    self.init(
      baseURL: baseURL,
      session: session,
      pollingInterval: pollingInterval
    )
  }
}

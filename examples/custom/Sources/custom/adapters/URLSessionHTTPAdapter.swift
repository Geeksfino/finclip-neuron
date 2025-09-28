import Foundation
import Combine
import NeuronKit

/// URLSession-based NetworkAdapter demonstrating polling + streaming partial updates.
public final class MyURLSessionHTTPAdapter: BaseNetworkAdapter {
  private let session: URLSession
  private let baseURL: URL
  private let pollingInterval: TimeInterval
  private let sendEndpoint: String
  private let pollEndpoint: String

  private var pollingTask: Task<Void, Never>?
  private var isStarted = false

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
    super.init()
  }

  public override func start() {
    guard !isStarted else { return }
    isStarted = true
    updateState(.connecting)

    Task { await testConnectivity() }
  }

  public override func stop() {
    isStarted = false
    pollingTask?.cancel()
    pollingTask = nil
    updateState(.disconnected)
    print("URLSessionHTTPAdapter: Stopped")
  }

  public override func sendToNetworkComponent(_ data: Any) {
    guard isStarted, let payload = data as? Data else {
      print("URLSessionHTTPAdapter: Cannot send data - adapter stopped or payload invalid")
      return
    }
    onOutboundData?(payload)
    Task { await sendMessage(payload) }
  }

  private func testConnectivity() async {
    let testURL = baseURL.appendingPathComponent("health")
    var request = URLRequest(url: testURL)
    request.httpMethod = "GET"
    request.timeoutInterval = 10.0

    do {
      let (_, response) = try await session.data(for: request)
      if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
        let error = NetworkError(code: "http_error",
                                 message: "Server returned status code \(httpResponse.statusCode)")
        updateState(.error(error))
        return
      }
      updateState(.connected)
      startPolling()
    } catch {
      print("URLSessionHTTPAdapter: Health check failed, assuming connected: \(error)")
      updateState(.connected)
      startPolling()
    }
  }

  private func sendMessage(_ data: Data) async {
    let sendURL = baseURL.appendingPathComponent(sendEndpoint)
    var request = URLRequest(url: sendURL)
    request.httpMethod = "POST"
    request.httpBody = data
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.timeoutInterval = 30.0

    do {
      let (_, response) = try await session.data(for: request)
      if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
        print("URLSessionHTTPAdapter: Send failed with status \(httpResponse.statusCode)")
      } else {
        print("URLSessionHTTPAdapter: Message sent successfully")
      }
    } catch {
      print("URLSessionHTTPAdapter: Send error: \(error)")
    }
  }

  private func startPolling() {
    guard pollingTask == nil else { return }

    pollingTask = Task { [weak self] in
      guard let self else { return }
      while !Task.isCancelled && self.isStarted {
        await self.pollForMessages()

        do {
          try await Task.sleep(nanoseconds: UInt64(self.pollingInterval * 1_000_000_000))
        } catch {
          break
        }
      }
    }
  }

  private func emitPreview(envelope: MockPreviewEnvelope) {
    let streamId = envelope.streamId ?? "http-preview-" + UUID().uuidString
    let sessionId = envelope.sessionId ?? envelope.conversationId

    for (index, token) in envelope.tokens.enumerated() {
      let chunk = InboundStreamChunk(
        streamId: streamId,
        sequence: index,
        data: Data(token.text.utf8),
        isFinal: token.isFinal,
        messageId: envelope.messageId,
        conversationId: envelope.conversationId,
        sessionId: sessionId,
        metadata: ["transport": "http", "kind": "preview"]
      )

      let delay = envelope.chunkInterval ?? 0.1
      DispatchQueue.global().asyncAfter(deadline: .now() + Double(index) * delay) { [weak self] in
        self?.inboundPartialDataHandler?(chunk)
      }
    }
  }

  private func pollForMessages() async {
    let pollURL = baseURL.appendingPathComponent(pollEndpoint)
    var request = URLRequest(url: pollURL)
    request.httpMethod = "GET"
    request.timeoutInterval = 30.0

    do {
      let (data, response) = try await session.data(for: request)
      if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          guard !data.isEmpty else { return }
          if let stream = try? JSONDecoder().decode(MockStreamEnvelope.self, from: data) {
            emitStream(envelope: stream)
          } else if let preview = try? JSONDecoder().decode(MockPreviewEnvelope.self, from: data) {
            emitPreview(envelope: preview)
          } else {
            handleInboundData(data)
          }
        } else if httpResponse.statusCode >= 500 {
          let error = NetworkError(code: "server_error",
                                   message: "Server error: \(httpResponse.statusCode)")
          updateState(.error(error))
        }
      }
    } catch {
      guard isStarted else { return }
      print("URLSessionHTTPAdapter: Polling error: \(error)")
      updateState(.reconnecting)
      try? await Task.sleep(nanoseconds: 5_000_000_000)
      if isStarted { updateState(.connected) }
    }
  }

  private func emitStream(envelope: MockStreamEnvelope) {
    let streamId = envelope.streamId ?? "http-stream-" + UUID().uuidString
    let sessionId = envelope.sessionId ?? envelope.conversationId

    for (index, part) in envelope.chunks.enumerated() {
      let chunk = InboundStreamChunk(
        streamId: streamId,
        sequence: index,
        data: Data(part.text.utf8),
        isFinal: part.isFinal,
        messageId: envelope.messageId,
        conversationId: envelope.conversationId,
        sessionId: sessionId,
        metadata: ["transport": "http"]
      )

      let delay = envelope.chunkInterval ?? 0.15
      DispatchQueue.global().asyncAfter(deadline: .now() + Double(index) * delay) { [weak self] in
        self?.handleInboundPartialData(chunk)
      }
    }
  }
}

private struct MockStreamEnvelope: Decodable {
  struct Chunk: Decodable {
    let text: String
    let isFinal: Bool
  }

  let streamId: String?
  let conversationId: UUID
  let sessionId: UUID?
  let messageId: UUID
  let chunkInterval: Double?
  let chunks: [Chunk]
}

private struct MockPreviewEnvelope: Decodable {
  struct Token: Decodable {
    let text: String
    let isFinal: Bool
  }

  let streamId: String?
  let conversationId: UUID
  let sessionId: UUID?
  let messageId: UUID
  let chunkInterval: Double?
  let tokens: [Token]
}

extension MyURLSessionHTTPAdapter {
  public convenience init(
    baseURL: URL,
    apiKey: String? = nil,
    pollingInterval: TimeInterval = 1.0
  ) {
    let config = URLSessionConfiguration.default
    if let apiKey {
      config.httpAdditionalHeaders = [
        "Authorization": "Bearer \(apiKey)",
        "User-Agent": "NeuronKit-HTTPAdapter/1.0"
      ]
    }
    let session = URLSession(configuration: config)
    self.init(baseURL: baseURL, session: session, pollingInterval: pollingInterval)
  }
}

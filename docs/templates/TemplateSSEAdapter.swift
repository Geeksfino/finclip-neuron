import Foundation
import NeuronKit

/// Template Server-Sent Events (SSE) network adapter.
///
/// Copy this file and tailor it to your transport. The implementation shows how to:
///  - manage URLSession lifecycle in `start()` / `stop()`
///  - accumulate partial SSE frames and emit `InboundStreamChunk` previews
///  - forward the final assembled payload to NeuronKit via `handleInboundData(_:)`
final class SSEAdapterTemplate: BaseNetworkAdapter {
  private let url: URL
  private lazy var session: URLSession = {
    URLSession(configuration: .default, delegate: self, delegateQueue: nil)
  }()
  private var task: URLSessionDataTask?
  private var buffer = Data()
  private var sequence = 0

  init(url: URL) {
    self.url = url
    super.init()
  }

  override func start() {
    updateState(.connecting)
    task = session.dataTask(with: url)
    task?.resume()
  }

  override func stop() {
    task?.cancel()
    task = nil
    updateState(.disconnected)
  }
}

extension SSEAdapterTemplate: URLSessionDataDelegate {
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    buffer.append(data)

    while let range = buffer.range(of: "\n\n".data(using: .utf8)!) {
      let frame = buffer.subdata(in: 0..<range.lowerBound)
      buffer.removeSubrange(0..<range.upperBound)

      guard let text = String(data: frame, encoding: .utf8), !text.isEmpty else { continue }

      // Parse SSE fields
      var streamId = dataTask.taskIdentifier.description
      var messageId = UUID()
      var isFinal = false
      var payload = ""

      for line in text.split(separator: "\n") {
        if line.hasPrefix("id:") {
          streamId = line.dropFirst(3).trimmingCharacters(in: .whitespaces)
        } else if line.hasPrefix("event:") {
          let eventType = line.dropFirst(6).trimmingCharacters(in: .whitespaces)
          isFinal = eventType == "complete"
        } else if line.hasPrefix("data:") {
          payload += line.dropFirst(5)
        } else if line.hasPrefix("meta-message-id:") {
          messageId = UUID(uuidString: line.dropFirst(16).trimmingCharacters(in: .whitespaces)) ?? messageId
        }
      }

      let chunk = InboundStreamChunk(
        streamId: streamId,
        sequence: sequence,
        data: Data(payload.utf8),
        isFinal: isFinal,
        messageId: messageId
      )

      sequence += 1
      inboundPartialDataHandler?(chunk)

      if isFinal {
        handleInboundData(Data(payload.utf8))
      }
    }
  }

  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    if let error {
      updateState(.failed(error.localizedDescription))
    } else {
      updateState(.connected)
    }
  }
}

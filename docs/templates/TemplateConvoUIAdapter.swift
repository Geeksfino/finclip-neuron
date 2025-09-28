import Foundation
import Combine
import NeuronKit

/// Template ConvoUI adapter demonstrating how to bridge streaming previews
/// and persisted `NeuronMessage` updates into a view model.
///
/// Copy this file and customize it for your UI framework (SwiftUI / UIKit).
/// Highlights:
///  - Subscribes to `messagesPublisher` for snapshots & deltas
///  - Subscribes to `streamingUpdatesPublisher` for preview tokens
///  - Accumulates preview text keyed by `messageId`
///  - Deduplicates the preview once the final `NeuronMessage` arrives
final class TemplateConvoUIAdapter: BaseConvoUIAdapter {
  private let viewModel: ChatViewModel
  private var previews: [UUID: String] = [:]
  private var awaitingFinalMessage: Set<UUID> = []

  init(viewModel: ChatViewModel) {
    self.viewModel = viewModel
    super.init()
  }

  // MARK: - Message snapshots / deltas
  override func handleMessages(_ messages: [NeuronMessage]) {
    viewModel.messages = messages

    // Remove preview bubbles when the persisted message arrives.
    for message in messages {
      if awaitingFinalMessage.remove(message.id) || previews[message.id] != nil {
        previews.removeValue(forKey: message.id)
        viewModel.clearStreamingMessage(id: message.id)
      }
    }
  }

  // MARK: - Streaming previews
  override func handleStreamingChunk(_ chunk: InboundStreamChunk) {
    let text = String(decoding: chunk.data, as: UTF8.self)
    guard !text.isEmpty else { return }

    let messageId = chunk.messageId ?? UUID(uuidString: chunk.streamId) ?? UUID()
    previews[messageId, default: ""] += text
    viewModel.updateStreamingMessage(id: messageId, text: previews[messageId] ?? "")

    if chunk.isFinal {
      awaitingFinalMessage.insert(messageId)
    }
  }

  // MARK: - Consent & system events (override as needed)
  override func handleConvoEvent(_ event: ConvoEvent) {
    switch event {
    case let .directiveAsk(proposalId, sessionId, feature, args):
      viewModel.presentConsent(proposalId: proposalId,
                               sessionId: sessionId,
                               feature: feature,
                               args: args) { approved in
        self.context?.userProvidedConsent(messageId: proposalId, approved: approved)
      }
    case let .systemMessage(text):
      viewModel.showSystemBanner(text)
    }
  }
}

// MARK: - Example view model interface (supply your own implementation)
protocol ChatViewModel: AnyObject {
  var messages: [NeuronMessage] { get set }
  func updateStreamingMessage(id: UUID, text: String)
  func clearStreamingMessage(id: UUID)
  func presentConsent(proposalId: UUID,
                      sessionId: UUID,
                      feature: String,
                      args: [String: Any],
                      completion: @escaping (Bool) -> Void)
  func showSystemBanner(_ text: String)
}

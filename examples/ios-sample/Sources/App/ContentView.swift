import SwiftUI
import NeuronKit

struct ContentView: View {
  @EnvironmentObject var provider: RuntimeProvider

  var body: some View {
    NavigationStack {
      List {
        Section {
          HStack {
            Text("NeuronKit iOS Sample")
              .font(.title3)
            Spacer()
            Circle()
              .fill(provider.isSessionOpen ? .green : .red)
              .frame(width: 10, height: 10)
            Text(provider.isSessionOpen ? "LIVE" : "IDLE")
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }

        Section("Conversations") {
          Button {
            provider.createConversationEntry()
          } label: {
            Label("New Conversation", systemImage: "plus")
          }

          ForEach(provider.conversations, id: \.self) { sid in
            NavigationLink(value: sid) {
              VStack(alignment: .leading, spacing: 4) {
                Text(sid.uuidString.prefix(8) + "…")
                  .font(.subheadline).bold()
                let last = provider.messagesSnapshot(sessionId: sid, limit: 1).last
                Text(last?.content ?? "(no messages)")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
            }
          }
        }

        Section("Registered Features (examples)") {
          Text("• open_camera — Open Camera (requires UIAccess)")
          Text("• export_report — Export Report (typed args: format, range)")
        }
      }
      .navigationDestination(for: UUID.self) { sid in
        ConversationDetailView(sessionId: sid)
          .environmentObject(provider)
      }
      .navigationTitle("Demo")
    }
  }
}

#Preview {
  ContentView()
    .environmentObject(RuntimeProvider())
}

struct ConversationDetailView: View {
  @EnvironmentObject var provider: RuntimeProvider
  let sessionId: UUID
  @State private var isLive = false
  @State private var preview: [NeuronMessage] = []

  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Text("Conversation")
          .font(.headline)
        Text(sessionId.uuidString.prefix(8) + "…")
          .font(.callout)
          .foregroundStyle(.secondary)
        Spacer()
        Circle()
          .fill(isLive ? .green : .orange)
          .frame(width: 10, height: 10)
        Text(isLive ? "LIVE" : "PREVIEW")
          .font(.caption)
          .foregroundStyle(.secondary)
      }

      List {
        Section("History (latest)") {
          ForEach(preview, id: \.id) { msg in
            VStack(alignment: .leading, spacing: 2) {
              Text(msg.sender.rawValue.capitalized)
                .font(.caption2)
                .foregroundStyle(.secondary)
              Text(msg.content)
            }
          }
        }
      }

      HStack {
        Button("Continue (Live)") {
          // Bind a simple adapter; for demo we reuse SimpleConvoAdapter from MultiSessionExample
          let adapter = SimpleConvoAdapter(context: "Detail")
          provider.resumeAndBind(sessionId: sessionId, adapter: adapter)
          isLive = true
        }
        .buttonStyle(.borderedProminent)

        Button("Refresh Preview") {
          loadPreview()
        }
        .buttonStyle(.bordered)
      }
    }
    .padding()
    .onAppear { loadPreview() }
  }

  private func loadPreview() {
    preview = provider.messagesSnapshot(sessionId: sessionId, limit: 50).suffix(50)
  }
}

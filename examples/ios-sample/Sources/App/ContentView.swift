import SwiftUI

struct ContentView: View {
  @EnvironmentObject var provider: RuntimeProvider

  var body: some View {
    NavigationStack {
      VStack(spacing: 16) {
        Text("NeuronKit iOS Sample")
          .font(.title2)

        HStack {
          Circle()
            .fill(provider.isSessionOpen ? .green : .red)
            .frame(width: 10, height: 10)
          Text(provider.isSessionOpen ? "Session: OPEN" : "Session: CLOSED")
            .font(.caption)
            .foregroundStyle(.secondary)
        }

        HStack {
          Button("Open Session") { provider.openSession() }
            .buttonStyle(.borderedProminent)
          Button("Close Session") { provider.closeSession() }
            .buttonStyle(.bordered)
            .disabled(!provider.isSessionOpen)
        }

        Spacer()

        VStack(alignment: .leading, spacing: 8) {
          Text("Registered Features (examples)")
            .font(.headline)
          Text("• open_camera — Open Camera (requires UIAccess)")
          Text("• export_report — Export Report (typed args: format, range)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding()
      .navigationTitle("Demo")
    }
  }
}

#Preview {
  ContentView()
    .environmentObject(RuntimeProvider())
}

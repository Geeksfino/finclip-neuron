import SwiftUI

@main
struct NeuronKitIOSApp: App {
  @StateObject private var provider = RuntimeProvider()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(provider)
    }
  }
}

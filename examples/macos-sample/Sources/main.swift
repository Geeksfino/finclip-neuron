import SwiftUI
import NeuronKit
import SandboxSDK

@main
struct macos_sampleApp: App {
    @StateObject private var neuronManager = NeuronManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(neuronManager)
                .onAppear {
                    neuronManager.initialize()
                }
        }
    }
}

class NeuronManager: ObservableObject {
    private var runtime: NeuronRuntime?

    func initialize() {
        // 1. Create configuration
        // Note: Using a placeholder URL. Replace with your actual server URL.
        let config = NeuronKitConfig(
            serverURL: URL(string: "wss://your-agent-server.com")!,
            deviceId: "demo-macos-device",
            userId: "user-macos-123",
            storage: .persistent,
            contextProviders: [
                DeviceStateProvider(),
                NetworkStatusProvider(),
                TimeBucketProvider()
            ]
        )

        // 2. Initialize runtime
        runtime = NeuronRuntime(config: config)
        print("NeuronKit Runtime Initialized")

        // 3. Register app features
        setupFeatures()
    }

    private func setupFeatures() {
        guard let sandbox = runtime?.sandbox else { return }

        // Register a simple feature
        let showDialogFeature = SandboxSDK.Feature(
            id: "show_dialog",
            name: "Show Dialog",
            description: "Display a native dialog box",
            category: .Native,
            path: "/ui/showDialog",
            requiredCapabilities: [.UIAccess],
            primitives: [.ShowDialog(title: "Default Title", message: "Default Message")]
        )

        _ = sandbox.registerFeature(showDialogFeature)
        print("Feature 'show_dialog' registered.")

        // Set security policy
        _ = sandbox.setPolicy("show_dialog", SandboxSDK.Policy(
            requiresUserPresent: true,
            requiresExplicitConsent: false, // For simplicity in this example
            sensitivity: .low,
            rateLimit: nil
        ))
        print("Policy for 'show_dialog' set.")
    }
}

struct ContentView: View {
    @EnvironmentObject var neuronManager: NeuronManager

    var body: some View {
        VStack {
            Text("NeuronKit macOS Sample")
                .font(.largeTitle)
                .padding()

            Text("This example demonstrates a basic integration of NeuronKit in a macOS application.")
                .padding()

            Button("Test Feature") {
                // This is a placeholder to show the app is interactive.
                // In a real app, an AI agent would trigger features.
                print("Button 'Test Feature' was clicked.")
            }
            .padding()
        }
        .frame(width: 400, height: 300)
    }
}
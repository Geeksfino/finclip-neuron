# iOS Sample App (SwiftUI + NeuronKit)

This minimal template shows the primary integration steps for NeuronKit on iOS:

1) Create a configuration
2) Initialize the runtime
3) Open a conversation (fluent API)
4) Bind a ConvoUI adapter to that conversation
5) Get the sandbox reference and register features/policies

NetworkAdapter setup is optional/advanced and not required to bootstrap.

## How to use this template

There are two ways to try it:

- Option A: Create an Xcode iOS App project and copy the sources from `Sources/App/*.swift` into your project. Add the `finclip-neuron` Swift Package to your project and run on a simulator/device.
- Option B: Use the provided `Package.swift` as a starting point to integrate in your own workspace (you'll still open/build with Xcode for an iOS target).

### Conversation-centric integration (recommended)

```swift
let runtime = NeuronRuntime(config: config)
let convo = runtime.openConversation(agentId: UUID())
convo.bindUI(MyConvoAdapter())
try await convo.sendMessage("Hello")
// ... later
convo.close()
```

## Files

- `Sources/App/RuntimeProvider.swift` — Creates `NeuronRuntime`, exposes its `sandbox`, registers sample features/policies, and provides bind/unbind helpers
- `Sources/App/ContentView.swift` — Very simple SwiftUI view wiring to show state/messages hook points
- `Sources/App/App.swift` — SwiftUI App entry that initializes the provider
- `Sources/App/MultiSessionExample.swift` — Demonstrates multiple conversations and UI binding
- `Package.swift` — A sample manifest showing dependency on `finclip-neuron`

## Sample manifest

If you want to use SwiftPM to manage dependencies in Xcode:

```swift
// Package.swift (for reference)
// Use in your own app workspace; open with Xcode and add this package.
// Note: SPM does not create an iOS app bundle by itself; use Xcode for the iOS target.

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "NeuronKitIOSSample",
  platforms: [ .iOS(.v15) ],
  products: [
    .library(name: "NeuronKitIOSSample", targets: ["NeuronKitIOSSample"])
  ],
  dependencies: [
    .package(url: "https://github.com/Geeksfino/finclip-neuron.git", branch: "main-swift6_0")
  ],
  targets: [
    .target(
      name: "NeuronKitIOSSample",
      dependencies: [
        .product(name: "NeuronKit", package: "finclip-neuron"),
        .product(name: "SandboxSDK", package: "finclip-neuron"),
        .product(name: "convstorelib", package: "finclip-neuron")
      ],
      path: "Sources/App"
    )
  ]
)
```

## Next steps

- Replace the sample feature/policy with your app’s real features
- Implement your ConvoUI adapter to bridge your UI and the runtime
- Choose a NetworkAdapter (WebSocket/HTTP/custom) and set it on the runtime if needed
- Add consent UI flows in your app when policies require explicit approval

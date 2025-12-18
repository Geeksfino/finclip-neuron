// swift-tools-version: 6.0
import PackageDescription

// Bootstrap manifest for neuronkit builds - contains only dependencies (no NeuronKit)
// This prevents circular dependency when neuronkit tries to build using finclip-neuron
// Auto-synced from main-swift6_0 by sync-bootstrap workflow
let package = Package(
  name: "finclip-neuron",
  platforms: [.iOS(.v14), .macOS(.v12)],
  products: [
    .library(name: "SandboxSDK", targets: ["SandboxSDK"]),
    .library(name: "convstorelib", targets: ["convstorelib"]),
    .library(name: "ConvoUI", targets: ["ConvoUI"])
  ],
  targets: [
    .binaryTarget(
      name: "SandboxSDK",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v4aef8eb-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "1ec9c58742c018a1e4a356e3d51c8b34717978f5b7e8d2052815ecd172895416"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v7a096e9-swift6_0/convstorelib.xcframework.zip",
      checksum: "3f9e3c3c011089ad208539347a14a6cd1253f77b5d568e291b271c8e8fe01c50"
    ),
    .binaryTarget(
      name: "ConvoUI",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-vb845375-swift6_0/ConvoUI.xcframework.zip",
      checksum: "b3be48c50241b1551c7959e9e838260d388557c25d3dd5e6acecafef5812e34f"
    )
  ]
)

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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-vfb7b6f0-swift6_0/convstorelib.xcframework.zip",
      checksum: "d532a0a938d447875b8b8bee4795198d93a93a368c957b9461290fa1f1773213"
    ),
    .binaryTarget(
      name: "ConvoUI",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-vd2c0a71-swift6_0/ConvoUI.xcframework.zip",
      checksum: "770cf1bc3e5cdb7325376ee5b17e99a7b98fedde2ee5637e0a1cacbab81d10e5"
    )
  ]
)

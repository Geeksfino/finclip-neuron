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
    .library(name: "NeuronKit", targets: ["NeuronKit"])
  ],
  targets: [
    .binaryTarget(
      name: "SandboxSDK",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-vf64da07-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "95dcfa3bb8584e93c9d8b2297f67ba71f1b71458e9b8cdec9e6f06734e2dc973"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v1a27ae4-swift6_0/convstorelib.xcframework.zip",
      checksum: "e140e4dff2461e3d7cb8270c3c2204e75ab4d18a64cad6604eb34b8c04dd06bd"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-v1dce083-swift6_0/NeuronKit.xcframework.zip",
      checksum: "b87dcdf1aa8d4f516fb41a5c0b6c3bd8714d6f9fd8c1b22a9bbe82b1d3df3695"
    )
  ]
)

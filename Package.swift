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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-vf64da07-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "95dcfa3bb8584e93c9d8b2297f67ba71f1b71458e9b8cdec9e6f06734e2dc973"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-vc5cbf1b-swift6_0/convstorelib.xcframework.zip",
      checksum: "55535d11c1f11c93cc01e2ad27794187ebac95f8975ff5bff7082231d056a486"
    ),
    .binaryTarget(
      name: "ConvoUI",
      url: "",
      checksum: ""
    )
  ]
)

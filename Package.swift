// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "finclip-neuron",
  platforms: [
    .iOS(.v14),
    .macOS(.v12)
  ],
  products: [
    .library(name: "SandboxSDK", targets: ["SandboxSDK"]),
    .library(name: "convstorelib", targets: ["convstorelib"]),
    .library(name: "NeuronKit", targets: ["NeuronKit"])
  ],
  targets: [
    .binaryTarget(
      name: "SandboxSDK",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v6497964/SandboxSDK.xcframework.zip",
      checksum: "75aa4ba4635292b5d6de7a54a15dca437383c28f1e76b28fdd7ba65f86fe0990"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v6497964/convstorelib.xcframework.zip",
      checksum: "f14151ae5af48224968df86ea531491dd959aad362a3a13b41f93ef74619d056"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-vfc0440f/NeuronKit.xcframework.zip",
      checksum: "45e070d1ce5bfa9f20fcbb3151bc4057a5a9d30acaa0bacf826c8f18099eb074"
    )
  ]
)

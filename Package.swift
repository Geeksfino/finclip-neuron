// swift-tools-version: 6.0
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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-vcc74a28-swift6_2/convstorelib.xcframework.zip",
      checksum: "c5972835822e4ed9a6399ebe0ebea6f360a122bdc4f54dcd30f63c0df66938a7"
    )
   ,
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-vfc0440f/NeuronKit.xcframework.zip",
      checksum: "45e070d1ce5bfa9f20fcbb3151bc4057a5a9d30acaa0bacf826c8f18099eb074"
    )
  ]
)

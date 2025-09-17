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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v52d4562-swift6_0/convstorelib.xcframework.zip",
      checksum: "60891f2206e45defa3def4e257d349ec53d25e5c39c8a0b76a500a7c363bec77"
    )
   ,
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-vfc0440f/NeuronKit.xcframework.zip",
      checksum: "45e070d1ce5bfa9f20fcbb3151bc4057a5a9d30acaa0bacf826c8f18099eb074"
    )
  ]
)

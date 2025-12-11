// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "finclip-neuron",
  platforms: [.iOS(.v14), .macOS(.v12)],
  products: [
    .library(name: "SandboxSDK", targets: ["SandboxSDK"]),
    .library(name: "convstorelib", targets: ["convstorelib"]),
    .library(name: "ConvoUI", targets: ["ConvoUI"]),
    .library(name: "NeuronKit", targets: ["NeuronKit"])
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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-v76f02e0-swift6_0/ConvoUI.xcframework.zip",
      checksum: "72d3c133befa49eb372f97e471051e324342cbd992b358191ddbc4586b1ad832"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-vded10c4-swift6_0/NeuronKit.xcframework.zip",
      checksum: "60859725f90d39b265a7b94acce4fbd0e424f40428ba05e0d1c7a0cc6ba9c40a"
    )
  ]
)

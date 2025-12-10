// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "finclip-neuron",
  platforms: [
    .iOS(.v14)
  ],
  products: [
    .library(name: "SandboxSDK", targets: ["SandboxSDK"]),
    .library(name: "convstorelib", targets: ["convstorelib"]),
    .library(name: "NeuronKit", targets: ["NeuronKit"]),
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
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-v64af17f-swift6_0/NeuronKit.xcframework.zip",
      checksum: "6c9c36cf5965b57a3fb10db0186b188afbf506aaabd60497daf5e4d84cfe5987"
    ),
    .binaryTarget(
      name: "ConvoUI",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-v76f02e0-swift6_0/ConvoUI.xcframework.zip",
      checksum: "72d3c133befa49eb372f97e471051e324342cbd992b358191ddbc4586b1ad832"
    )
  ]
)

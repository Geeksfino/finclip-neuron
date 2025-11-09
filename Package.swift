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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-vf64da07-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "95dcfa3bb8584e93c9d8b2297f67ba71f1b71458e9b8cdec9e6f06734e2dc973"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-vf8164bb-swift6_0/convstorelib.xcframework.zip",
      checksum: "ca9291932eab5ee768522f58b9239b738c69a2a1630f2821d55ce9d7e4c3c502"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-v06e53e9-swift6_0/NeuronKit.xcframework.zip",
      checksum: "598c87ae8de3f3b09b6d54edd5b88f923620be6325fcc3d3773814a6f603c8d3"
    ),
    .binaryTarget(
      name: "ConvoUI",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-v19faf67-swift6_0/ConvoUI.xcframework.zip",
      checksum: "d7432af8bab974983fa8b50ec79f1d3be2dd5f9f50c8ef963928de143017b478"
    )
  ]
)

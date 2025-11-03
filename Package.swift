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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-vf64da07-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "95dcfa3bb8584e93c9d8b2297f67ba71f1b71458e9b8cdec9e6f06734e2dc973"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-vf8164bb-swift6_0/convstorelib.xcframework.zip",
      checksum: "ca9291932eab5ee768522f58b9239b738c69a2a1630f2821d55ce9d7e4c3c502"
    ),
    .binaryTarget(
      name: "ConvoUI",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-vd757974-swift6_0/ConvoUI.xcframework.zip",
      checksum: "f8c9734dec48ae5f775d239d79ccbf87098fec83c6866943841a0b752dcb1c7b"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-vcd971ad-swift6_0/NeuronKit.xcframework.zip",
      checksum: "a89c5313cdf986e4b438783b302835da603d7400648604bfcd87b044130ce307"
    )
  ]
)

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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v4c6cdce-swift6_0/convstorelib.xcframework.zip",
      checksum: "2ebb10dbde0d82f8c935f7078dfc6cfe3a1052441ad962754971db98db5a2e10"
    ),
    .binaryTarget(
      name: "ConvoUI",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-v4dfb265-swift6_0/ConvoUI.xcframework.zip",
      checksum: "e26a363a8a2b3da72bdfd43f657fa14b9a6ae58211c5ef9b9d313810ea476eea"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-vbd62152-swift6_0/NeuronKit.xcframework.zip",
      checksum: "c56a4b4d22615631576979a3adb6cfe3e37f410a1bac09cad91e6ab4cfc04f3d"
    )
  ]
)

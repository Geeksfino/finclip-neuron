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
    .library(name: "NeuronKit", targets: ["NeuronKit"]),
    .library(name: "ConvoUI", targets: ["ConvoUI"])
  ],
  targets: [
    .binaryTarget(
      name: "SandboxSDK",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v3087fd0-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "3604f459a5dd09f02f6c2d261216ea2751b3e59a462bf23d26ba1144cbbce477"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v590c996-swift6_0/convstorelib.xcframework.zip",
      checksum: "414b0f4ad1344aa5599097be3a5cb353e2e9690d7df9fc282fe5171471733a02"
    )
   ,
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-v98e0cf6-swift6_0/NeuronKit.xcframework.zip",
      checksum: "c565580c2642030b8d37a334611b647f928dccd46da2b6b6d25c29f4a2b5f76b"
    )
   ,
    .binaryTarget(
      name: "ConvoUI",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-v55a2c60-swift6_0/ConvoUI.xcframework.zip",
      checksum: "d2284de4eca274182a0b2e6b9529d9e69b10e238b39a6b1cef49879d1bfca32b"
    )
  ]
)

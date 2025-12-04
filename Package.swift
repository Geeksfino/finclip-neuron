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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v3c42d73-swift6_0/convstorelib.xcframework.zip",
      checksum: "ea6a2f94110c30a8ab9e9f65eacb90babb714b80b3f49e87db58b1a734e50f2d"
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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-vaf07c40-swift6_0/ConvoUI.xcframework.zip",
      checksum: "cd642905220a3ab625355edbada29a2f0e20865b8004569d99ffb10814189a41"
    )
  ]
)

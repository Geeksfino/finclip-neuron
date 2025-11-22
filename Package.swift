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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v3087fd0-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "3604f459a5dd09f02f6c2d261216ea2751b3e59a462bf23d26ba1144cbbce477"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v59f911a-swift6_0/convstorelib.xcframework.zip",
      checksum: "52d4f090b59678334602c754b570db76ca4b992779c02d2c3dd707873aebd225"
    ),
    .binaryTarget(
      name: "ConvoUI",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-vaf07c40-swift6_0/ConvoUI.xcframework.zip",
      checksum: "cd642905220a3ab625355edbada29a2f0e20865b8004569d99ffb10814189a41"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-v2778ea7-swift6_0/NeuronKit.xcframework.zip",
      checksum: "54d07388d4fe4e12f8a65c7b0f47424b306653299fc63a1feae78b810d88219c"
    )
  ]
)

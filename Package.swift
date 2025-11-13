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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-v4dfb265-swift6_0/ConvoUI.xcframework.zip",
      checksum: "e26a363a8a2b3da72bdfd43f657fa14b9a6ae58211c5ef9b9d313810ea476eea"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-v8f3d10a-swift6_0/NeuronKit.xcframework.zip",
      checksum: "cd71a086acf0abe8b8589a5b0087894ec5a2d31d2278803a6e1be0dd4e7e198f"
    )
  ]
)

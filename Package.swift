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
    .library(name: "NeuronKit", targets: ["NeuronKit"])
  ],
  targets: [
    .binaryTarget(
      name: "SandboxSDK",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-vc90ac18-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "7376c401868ce2b97d7edd2b5cffef5e1ae3aa35a1f46fb7e5d7f23d8ea54e6b"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v1a27ae4-swift6_0/convstorelib.xcframework.zip",
      checksum: "bdf13010debfd9463d1fd14f32861554f99fb86e503eaac5ea6fe0c962a07d66"
    )
   ,
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-v230155a-swift6_0/NeuronKit.xcframework.zip",
      checksum: "40a535b92f2e2a65c6c91653a78ff093824fcbd99e71a219758f4d85d95215fd"
    )
  ]
)

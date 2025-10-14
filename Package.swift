// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "finclip-neuron",
  platforms: [.iOS(.v14), .macOS(.v12)],
  products: [
    .library(name: "SandboxSDK", targets: ["SandboxSDK"]),
    .library(name: "convstorelib", targets: ["convstorelib"]),
    .library(name: "NeuronKit", targets: ["NeuronKit"])
  ],
  targets: [
    .binaryTarget(
      name: "SandboxSDK",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-vf64da07-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "ca5db62a860bb421bdefe6ceed26bdb8efa00789f65e838ddd2e3508e277cbbc"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v1a27ae4-swift6_0/convstorelib.xcframework.zip",
      checksum: "bdf13010debfd9463d1fd14f32861554f99fb86e503eaac5ea6fe0c962a07d66"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-v1dce083-swift6_0/NeuronKit.xcframework.zip",
      checksum: "b87dcdf1aa8d4f516fb41a5c0b6c3bd8714d6f9fd8c1b22a9bbe82b1d3df3695"
    )
  ]
)

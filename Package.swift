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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v4916ef0-swift6_2/SandboxSDK.xcframework.zip",
      checksum: "5d7cac4f2d3fd1df96775a06b727957a9f971eeb9ffeda9184c5c76414d50a11"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v32fa11d-swift6_2/convstorelib.xcframework.zip",
      checksum: "823b9f2ebe3101d10a89c0620fccf5eede411976f54ba6cbf05f94d96f8830c8"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-v7602426-swift6_2/NeuronKit.xcframework.zip",
      checksum: "f333b221c57de51247c9777af649002db0d7f2de1f44ba953a5578034bfba2b7"
    )
  ]
)

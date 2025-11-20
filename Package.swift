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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v3087fd0-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "3604f459a5dd09f02f6c2d261216ea2751b3e59a462bf23d26ba1144cbbce477"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v59f911a-swift6_0/convstorelib.xcframework.zip",
      checksum: "52d4f090b59678334602c754b570db76ca4b992779c02d2c3dd707873aebd225"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-v8f3d10a-swift6_0/NeuronKit.xcframework.zip",
      checksum: "cd71a086acf0abe8b8589a5b0087894ec5a2d31d2278803a6e1be0dd4e7e198f"
    ),
    .binaryTarget(
      name: "ConvoUI",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-vab4ce4a-swift6_0/ConvoUI.xcframework.zip",
      checksum: "09b8d7ee7f3e417678466cdbb8ea7910bf5a06b1132102a82de28fa3dd582d0c"
    )
  ]
)

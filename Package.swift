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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v4aef8eb-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "1ec9c58742c018a1e4a356e3d51c8b34717978f5b7e8d2052815ecd172895416"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-vc610b1b-swift6_0/convstorelib.xcframework.zip",
      checksum: "634e4e83cbdb663c8d6e95ce804b8c97f1f306d6fba308c2faa1f1885ab908ec"
    )
   ,
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-vded10c4-swift6_0/NeuronKit.xcframework.zip",
      checksum: "60859725f90d39b265a7b94acce4fbd0e424f40428ba05e0d1c7a0cc6ba9c40a"
    )
   ,
    .binaryTarget(
      name: "ConvoUI",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-vb845375-swift6_0/ConvoUI.xcframework.zip",
      checksum: "b3be48c50241b1551c7959e9e838260d388557c25d3dd5e6acecafef5812e34f"
    )
  ]
)

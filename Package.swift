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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v4aef8eb-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "1ec9c58742c018a1e4a356e3d51c8b34717978f5b7e8d2052815ecd172895416"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v0d422c1-swift6_0/convstorelib.xcframework.zip",
      checksum: "80ef958c713df6a361246ccd53fa4f679ab5892d8999dcd7f6016b08426fefbe"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-v61e3514-swift6_0/NeuronKit.xcframework.zip",
      checksum: "f205f8cf022dae555827413c097aa3a5347746a57fda43d6abff69ba0ddc323e"
    ),
    .binaryTarget(
      name: "ConvoUI",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-vf19b9a6-swift6_0/ConvoUI.xcframework.zip",
      checksum: "f10927fbe4563270adf02a176e3b9f9d2b8350c0c1ba70804b82b83ecd6294c8"
    )
  ]
)

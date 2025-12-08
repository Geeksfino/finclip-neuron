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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-vb922bba-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "a988a8e757ed9b5a639bffecf45fc146a0c6ac160552ddc4deaf0bf6766e5964"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-va8eb9b5-swift6_0/convstorelib.xcframework.zip",
      checksum: "3e9a00fdf7c049af2e29fa7c2df9d773e37449c5943f709cd3b1a05acfe9a988"
    )
   ,
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-v64af17f-swift6_0/NeuronKit.xcframework.zip",
      checksum: "6c9c36cf5965b57a3fb10db0186b188afbf506aaabd60497daf5e4d84cfe5987"
    )
   ,
    .binaryTarget(
      name: "ConvoUI",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-v55a2c60-swift6_0/ConvoUI.xcframework.zip",
      checksum: "d2284de4eca274182a0b2e6b9529d9e69b10e238b39a6b1cef49879d1bfca32b"
    )
  ]
)

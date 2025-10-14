// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "finclip-neuron",
  platforms: [
    .iOS(.v14),
    .macOS(.v12)
  ],
  products: [
    .library(name: "ConvoUI", targets: ["ConvoUI"])
  ],
  targets: [
    .binaryTarget(
      name: "ConvoUI",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-v30e9500-swift6_0/ConvoUI.xcframework.zip",
      checksum: "8f7e222302e43287484b1a7b8bb6bb02bd1c8a01cb13731968a660bc2d706595"
    )
  ]
)

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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-vbac5ae1-swift6_0/ConvoUI.xcframework.zip",
      checksum: "0a6dd1c3d7a9c8456728ff6db75dbbcd4c7f979954714f163debc6a3a268d58c"
    )
  ]
)

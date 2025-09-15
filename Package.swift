// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "finclip-neuron",
  platforms: [
    .iOS(.v14),
    .macOS(.v12)
  ],
  products: [
    .library(name: "SandboxSDK", targets: ["SandboxSDK"])
  ],
  targets: [
    .binaryTarget(
      name: "SandboxSDK",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v14287a9/SandboxSDK.xcframework.zip",
      checksum: "ae5c1a1c882586a4c3cc0c4568ccdf43953d041bc7f2677781ffa2c04eb362e6"
    )
  ]
)

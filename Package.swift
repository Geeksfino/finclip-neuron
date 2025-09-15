// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "finclip-neuron",
  platforms: [
    .iOS(.v14),
    .macOS(.v12)
  ],
  products: [
    .library(name: "SandboxSDK", targets: ["SandboxSDK"]),
    .library(name: "convstorelib", targets: ["convstorelib"])
  ],
  targets: [
    .binaryTarget(
      name: "SandboxSDK",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v14287a9/SandboxSDK.xcframework.zip",
      checksum: "ae5c1a1c882586a4c3cc0c4568ccdf43953d041bc7f2677781ffa2c04eb362e6"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v5d6a529/convstorelib.xcframework.zip",
      checksum: "79b8f8c82686f7948295c957f332c025f0611e23b1c33552c37f1e17fff55fae"
    )
  ]
)

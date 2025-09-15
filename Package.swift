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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v2b2ab17/convstorelib.xcframework.zip",
      checksum: "f350a6337ed1264ef2c3668404ce6b6d794abc39c29f676cfd8fad9bb4bac17d"
    )
  ]
)

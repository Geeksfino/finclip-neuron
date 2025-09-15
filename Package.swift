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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-ve5de24f/SandboxSDK.xcframework.zip",
      checksum: "3f40fd85902bbe8268d30572fca43afd129c3a0f50b4a46b8d0d20540f58ec94"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v986d06b/convstorelib.xcframework.zip",
      checksum: "79703458a0d48351fb1d95ea8c8b97ddbd312f5c2ad55b712a540ccbcde51c51"
    )
  ]
)

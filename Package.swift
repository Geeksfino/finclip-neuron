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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v57b21ac/convstorelib.xcframework.zip",
      checksum: "c9aa7cbdeeff8f62b6b4c9f0f4515072fe58c8e3a102a05d611eea4ec4412c05"
    )
  ]
)

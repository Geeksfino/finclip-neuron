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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-vf2d55f6/SandboxSDK.xcframework.zip",
      checksum: "499a35ede6b7b934a79fef71d49e7ccd5258ebb6da7328a7daf8e4e0a1fa7d63"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-vf2d55f6/convstorelib.xcframework.zip",
      checksum: "cc2d52872ba37b94d644603933192202be50e86cad3540d613cf5c2689493196"
    )
  ]
)

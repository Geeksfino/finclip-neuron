// swift-tools-version: 5.9
import PackageDescription

// Distribution package for SandboxSDK binary XCFramework (iOS + macOS)
let package = Package(
  name: "SandboxSDK",
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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-vfae88b8/SandboxSDK.xcframework.zip",
      checksum: "9f7117ec53f15b335df88d6c7c712ffe956764f9779c9d617ee96575baf81c86"
    )
  ]
)

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
      url: "https://github.com/Geeksfino/finclip-sandbox/releases/download/sdk-v9a855e6/SandboxSDK.xcframework.zip",
      checksum: "a6502f205b112a07bc0bcec6a530f278736ac62960f333392eb8ff80f89ab907"
    )
  ]
)

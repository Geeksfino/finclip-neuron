// swift-tools-version: 5.9
import PackageDescription

// Distribution package for SandboxSDK binary XCFramework (iOS + macOS)
// Update the URL and checksum after CI publishes a new release.
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
      url: "https://github.com/Geeksfino/finclip-sandbox/releases/download/sdk-vREPLACE_ME/SandboxSDK.xcframework.zip",
      checksum: "REPLACE_ME_CHECKSUM"
    )
  ]
)

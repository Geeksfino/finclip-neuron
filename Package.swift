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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v8186758/SandboxSDK.xcframework.zip",
      checksum: "efa10b88fc9d46d67eedff2c8bf609de63b3c74bf8c27209db7d3129ba9c4734"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-vfd89baa/convstorelib.xcframework.zip",
      checksum: "3b90c5cc245240f13c522a0026c59965889ed600d33c6153f3fc568716e6f88b"
    )
  ]
)

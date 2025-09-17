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
    .library(name: "convstorelib", targets: ["convstorelib"]),
    .library(name: "NeuronKit", targets: ["NeuronKit"])
  ],
  targets: [
    .binaryTarget(
      name: "SandboxSDK",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-vd13f744/SandboxSDK.xcframework.zip",
      checksum: "7b624db0d0e339ef5a62eea9023122bf77fceef6dd0f24537a2f72bc45e7c917"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-vd13f744/convstorelib.xcframework.zip",
      checksum: "e01c0d05d8f90cacc846a4b69a4a5b4017bbb84b3223dafacb78d30d9b0316ce"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-v19ef3f4/NeuronKit.xcframework.zip",
      checksum: "3a2ad7bd7eeaeac0a23d988aa287f0d90e1c5b0aed262918599b249c40051f35"
    )
  ]
)

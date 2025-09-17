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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-vafad7a3/NeuronKit.xcframework.zip",
      checksum: "7d53d99d58d9e3e6cc619745160b452fe25bb68e55d442ecc971c00c4d3dd385"
    )
  ]
)

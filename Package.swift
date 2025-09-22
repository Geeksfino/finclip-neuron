// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "finclip-neuron",
  platforms: [.iOS(.v14), .macOS(.v12)],
  products: [
    .library(name: "SandboxSDK", targets: ["SandboxSDK"]),
    .library(name: "convstorelib", targets: ["convstorelib"]),
    .library(name: "NeuronKit", targets: ["NeuronKit"])
  ],
  targets: [
    .binaryTarget(
      name: "SandboxSDK",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-vc90ac18-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "7376c401868ce2b97d7edd2b5cffef5e1ae3aa35a1f46fb7e5d7f23d8ea54e6b"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v6ca80f6-swift6_0/convstorelib.xcframework.zip",
      checksum: "03861a0bbfecdd66f2063976bcf5c2a2648c24f644c6b4790c26ac1955105543"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-vb3a72d4-swift6_0/NeuronKit.xcframework.zip",
      checksum: "56b657fb9c39ee09ae9809cf6db76529cb895ff05d5f68df044ab851eebbbc68"
    )
  ]
)

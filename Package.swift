// swift-tools-version: 6.0
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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v0661965-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "056d3c2118dc9683117fe49843443c7ff7ea9dfa6f37c53cfa450c106b3bd95f"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v32fa11d-swift6_0/convstorelib.xcframework.zip",
      checksum: "8a46f9a446518518fd46c665667f22f3adf644aee7917035d0de7a211cb77fc8"
    )
   ,
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-vc62bc4e-swift6_0/NeuronKit.xcframework.zip",
      checksum: "d841f30e630df479da5cf2d39a880088d5464fc6812c775f68eed2b8cf800d5b"
    )
  ]
)

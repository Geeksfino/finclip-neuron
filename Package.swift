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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v0661965-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "056d3c2118dc9683117fe49843443c7ff7ea9dfa6f37c53cfa450c106b3bd95f"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v6ca80f6-swift6_0/convstorelib.xcframework.zip",
      checksum: "03861a0bbfecdd66f2063976bcf5c2a2648c24f644c6b4790c26ac1955105543"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-vc4c459e-swift6_0/NeuronKit.xcframework.zip",
      checksum: "4e1ebc1261fbeed508e12c0ad08a4c12e80eeddcaaed89452efe655c454b716a"
    )
  ]
)

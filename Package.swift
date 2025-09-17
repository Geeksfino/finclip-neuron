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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v4916ef0-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "53fccab65e85fe5852e37cbb05a76512c230b5f6d334a84ab580a5b194aca80c"
    )
   ,
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v32fa11d-swift6_0/convstorelib.xcframework.zip",
      checksum: "e1cdf3ad5bb8b39442c92ecf12d4aadbd1f3e800977cbcdb447c3d8025e4c0bd"
    )
   ,
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-vfc0440f/NeuronKit.xcframework.zip",
      checksum: "45e070d1ce5bfa9f20fcbb3151bc4057a5a9d30acaa0bacf826c8f18099eb074"
    )
  ]
)

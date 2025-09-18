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
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-v0661965-swift6_2/SandboxSDK.xcframework.zip",
      checksum: "f0028d026997eb42530295e2b5012d9cb3a94f95bba8ef13f894082bf8e832f3"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v32fa11d-swift6_2/convstorelib.xcframework.zip",
      checksum: "0d8a886f04611805c65884c7348f9eb640c267710a42f33068895a014d5d30fc"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-vc62bc4e-swift6_2/NeuronKit.xcframework.zip",
      checksum: "b22c7e23a88d8db619d7d3191ddfb5838ee67d3787cf949083e3e9c1d296e2ae"
    )
  ]
)

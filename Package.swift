// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "finclip-neuron",
  platforms: [
    .iOS(.v14)
  ],
  products: [
    .library(name: "SandboxSDK", targets: ["SandboxSDK"]),
    .library(name: "convstorelib", targets: ["convstorelib"]),
    .library(name: "NeuronKit", targets: ["NeuronKit"]),
    .library(name: "ConvoUI", targets: ["ConvoUI"])
  ],
  targets: [
    .binaryTarget(
      name: "SandboxSDK",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/sdk-vf64da07-swift6_0/SandboxSDK.xcframework.zip",
      checksum: "95dcfa3bb8584e93c9d8b2297f67ba71f1b71458e9b8cdec9e6f06734e2dc973"
    ),
    .binaryTarget(
      name: "convstorelib",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-vc5cbf1b-swift6_0/convstorelib.xcframework.zip",
      checksum: "55535d11c1f11c93cc01e2ad27794187ebac95f8975ff5bff7082231d056a486"
    ),
    .binaryTarget(
      name: "NeuronKit",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/neuronkit-v9f1ec47-swift6_0/NeuronKit.xcframework.zip",
      checksum: "1f887d368f8347b3e23f9c240d54102929151967cefc1d181fb22f1a76c580e2"
    ),
    .binaryTarget(
      name: "ConvoUI",
      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/convoui-v4dfb265-swift6_0/ConvoUI.xcframework.zip",
      checksum: "e26a363a8a2b3da72bdfd43f657fa14b9a6ae58211c5ef9b9d313810ea476eea"
    )
  ]
)

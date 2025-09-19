// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "CustomDemoApp",
  platforms: [ .iOS(.v14), .macOS(.v12) ],
  products: [
    .executable(name: "CustomDemoApp", targets: ["CustomDemoApp"])
  ],
  dependencies: [
    .package(url: "https://github.com/Geeksfino/finclip-neuron.git", branch: "main-swift6_0")
  ],
  targets: [
    .executableTarget(
      name: "CustomDemoApp",
      dependencies: [
        .product(name: "NeuronKit", package: "finclip-neuron"),
        .product(name: "SandboxSDK", package: "finclip-neuron"),
        .product(name: "convstorelib", package: "finclip-neuron")
      ],
      path: "Sources/custom",
      exclude: []
    )
  ]
)
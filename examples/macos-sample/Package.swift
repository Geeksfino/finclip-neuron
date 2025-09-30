// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "macos-sample",
    platforms: [
        .macOS(.v12)
    ],
    dependencies: [
        .package(url: "https://github.com/Geeksfino/finclip-neuron.git", branch: "main-swift6_0")
    ],
    targets: [
        .executableTarget(
            name: "macos-sample",
            dependencies: [
                .product(name: "NeuronKit", package: "finclip-neuron"),
                .product(name: "SandboxSDK", package: "finclip-neuron"),
                .product(name: "convstorelib", package: "finclip-neuron")
            ],
            path: "Sources"
        )
    ]
)
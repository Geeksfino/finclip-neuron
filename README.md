# SandboxSDK Distribution (SPM Binary Package)

This repository distributes the multi-platform (iOS + macOS) SandboxSDK as a Swift Package Manager binary target.

- Platforms: iOS 14+, macOS 12+
- Product: `SandboxSDK` (library)
- Target: `.binaryTarget(name: "SandboxSDK", url: ..., checksum: ...)`

## Usage

Add the package to your project using SPM with the repository URL of this repo (e.g., `https://github.com/Geeksfino/finclip-neuron.git`).

Then depend on the product `SandboxSDK`.

```swift
// In your Package.swift
.package(url: "https://github.com/Geeksfino/finclip-neuron.git", branch: "main"),

// Or in Xcode: File -> Add Package Dependencies...
```

## Updating to a New SDK Build

This repository should be updated when the CI in `finclip-sandbox` publishes a new Release with:
- `SandboxSDK.xcframework.zip`
- `SandboxSDK.xcframework.zip.checksum`

Steps:
1. Copy the Release tag (e.g., `sdk-v<short_sha>`).
2. In `Package.swift`, update the binary target:
   - `url`: `https://github.com/Geeksfino/finclip-sandbox/releases/download/sdk-v<short_sha>/SandboxSDK.xcframework.zip`
   - `checksum`: content of `SandboxSDK.xcframework.zip.checksum`
3. Commit and push.

Example diff:
```diff
-      url: "https://github.com/Geeksfino/finclip-sandbox/releases/download/sdk-vREPLACE_ME/SandboxSDK.xcframework.zip",
-      checksum: "REPLACE_ME_CHECKSUM"
+      url: "https://github.com/Geeksfino/finclip-sandbox/releases/download/sdk-v2d96a2f/SandboxSDK.xcframework.zip",
+      checksum: "<checksum-from-file>"
```

## Notes
- Only the relevant platform slice (iOS or macOS) is linked into consuming apps; the multi-platform XCFramework doesn't bloat final app sizes.
- Keep `BUILD_LIBRARY_FOR_DISTRIBUTION=YES` when building the frameworks so the ABI remains stable for SPM consumption.

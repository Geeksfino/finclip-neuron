# finclip-neuron SPM Binary Packages

This repository distributes multi-platform (iOS + macOS) binary SDKs via Swift Package Manager.

- Platforms: iOS 14+, macOS 12+
- Products:
  - `SandboxSDK` (library)
  - `convstorelib` (library)
- Targets:
  - `.binaryTarget(name: "SandboxSDK", url: ..., checksum: ...)`
  - `.binaryTarget(name: "convstorelib", url: ..., checksum: ...)`

## Usage

Add the package to your project using SPM with the repository URL of this repo (e.g., `https://github.com/Geeksfino/finclip-neuron.git`).

Then depend on one or both products (`SandboxSDK`, `convstorelib`) as needed.

```swift
// In your Package.swift
.package(url: "https://github.com/Geeksfino/finclip-neuron.git", branch: "main"),

// Or in Xcode: File -> Add Package Dependencies...
// Example target dependencies:
// .product(name: "SandboxSDK", package: "finclip-neuron"),
// .product(name: "convstorelib", package: "finclip-neuron")
```

## Updating to a New SDK Build

This repository should be updated when CI publishes new Releases for either binary target.

### SandboxSDK

Expected artifacts in `finclip-sandbox` Release:

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

### convstorelib

Expected artifacts in `finclip-neuron` Release:

- `convstorelib.xcframework.zip`
- `convstorelib.xcframework.zip.checksum`

Steps:

1. Copy the Release tag (e.g., `conv-v<short_sha>`).
2. In `Package.swift`, update the binary target:
   - `url`: `https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v<short_sha>/convstorelib.xcframework.zip`
   - `checksum`: content of `convstorelib.xcframework.zip.checksum`
3. Commit and push.

Example diff:

```diff
-      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-vREPLACE_ME/convstorelib.xcframework.zip",
-      checksum: "REPLACE_ME_CHECKSUM"
+      url: "https://github.com/Geeksfino/finclip-neuron/releases/download/conv-v2b2ab17/convstorelib.xcframework.zip",
+      checksum: "<checksum-from-file>"
```

## Notes

- Only the relevant platform slice (iOS or macOS) is linked into consuming apps; the multi-platform XCFramework doesn't bloat final app sizes.
- Keep `BUILD_LIBRARY_FOR_DISTRIBUTION=YES` when building the frameworks so the ABI remains stable for SPM consumption.

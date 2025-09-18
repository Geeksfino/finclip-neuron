# NeuronKit Developer Guide

> 📖 **Language**: [English](README.md) | [中文](README.zh.md)

NeuronKit is a Swift SDK that enables conversational AI agents in your iOS app. This guide shows how to integrate it into your project.

## Installation

### Swift Toolchain Compatibility

We publish pre-compiled binaries for multiple Swift toolchains. Please use the branch that matches your Xcode version to ensure binary compatibility.

**For Swift 6.2 (Xcode 16.2 and later):**

Use the `main` branch in your `Package.swift`:

```swift
// Package.swift
.dependencies: [
  .package(url: "https://github.com/Geeksfino/finclip-neuron.git", branch: "main")
],
```

**For Swift 6.0.x (Xcode 16.1):**

Use the `main-swift6_0` branch in your `Package.swift`:

```swift
// Package.swift
.dependencies: [
  .package(url: "https://github.com/Geeksfino/finclip-neuron.git", branch: "main-swift6_0")
],
```

### Adding the Package in Xcode

1. In Xcode, go to **File → Add Package Dependencies…**
2. Enter the repository URL: `https://github.com/Geeksfino/finclip-neuron.git`
3. For the **Dependency Rule**, select **Branch** and enter `main` or `main-swift6_0` based on your toolchain.
4. Add the `NeuronKit`, `SandboxSDK`, and `convstorelib` products to your app's target.

---

## Quick Start

Here's how to add conversational AI to your app in 5 simple steps:

### 1. Import and Configure

```swift
import NeuronKit

let config = NeuronKitConfig(
  serverURL: URL(string: "wss://your-agent-server.com")!,
  deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device",
  userId: "your-user-id"
)
let neuronKit = NeuronKit(config: config)
```

### 2. Start a Conversation Session

```swift
let sessionId = UUID()
neuronKit.openSession(sessionId: sessionId, agentId: UUID())
```

### 3. Send Messages

```swift
// Send text messages
try? await neuronKit.sendMessage(
  sessionId: sessionId,
  text: "Hello, assistant!"
)

// Send with context (optional)
try? await neuronKit.sendMessage(
  sessionId: sessionId,
  text: "Help me with my order",
  context: ["screen": "orders", "user_action": "support"]
)
```

That's it! Your app now has conversational AI capabilities.

---

## Configuration

### Basic Configuration

```swift
let config = NeuronKitConfig(
  serverURL: URL(string: "wss://your-agent-server.com")!,
  deviceId: "unique-device-id", // Usually UUID
  userId: "user-identifier"     // Your user ID
)
```

---

## Error Handling

NeuronKit throws errors for network issues and invalid operations:

```swift
func sendMessage(_ text: String) async {
  do {
    try await neuronKit.sendMessage(sessionId: sessionId, text: text)
  } catch {
    print("Failed to send message: \(error)")
    // Handle error (show alert, retry, etc.)
  }
}
```

---

## Requirements

- iOS 14+
- Swift 6.0+
- Xcode 16.1+

---

## License

Copyright 2023 Finclip / Geeksfino.

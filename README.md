# NeuronKit Developer Guide

> 📖 **Language**: [English](README.md) | [中文](README.zh.md)

NeuronKit is a Swift SDK that enables conversational AI agents in your iOS app. This guide shows how to integrate it into your project.

## Installation

Add the package to your project:

### Xcode

- File → Add Package Dependencies…
- URL: `https://github.com/Geeksfino/finclip-neuron.git`
- Select `NeuronKit`

### SwiftPM `Package.swift`

```swift
// Package.swift
.dependencies: [
  .package(url: "https://github.com/Geeksfino/finclip-neuron.git", branch: "main")
],
.targets: [
  .target(
    name: "MyApp",
    dependencies: [
      .product(name: "NeuronKit", package: "finclip-neuron")
    ]
  )
]
```

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
- Swift 5.9+
- Xcode 15+

---

## License

Copyright 2023 Finclip / Geeksfino.

# NeuronKit 开发者指南

NeuronKit 是一个 Swift SDK，可以在您的 iOS 应用中启用对话式 AI 代理。本指南展示了如何将其集成到您的项目中。

## 安装

将包添加到您的项目中：

### Xcode

- 文件 → 添加包依赖项…
- URL：`https://github.com/Geeksfino/finclip-neuron.git`
- 选择 `NeuronKit`

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

## 快速开始

以下是在您的应用中添加对话式 AI 的 3 个简单步骤：

### 1. 导入和配置

```swift
import NeuronKit

let config = NeuronKitConfig(
  serverURL: URL(string: "wss://your-agent-server.com")!,
  deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "unknown-device",
  userId: "your-user-id"
)
let neuronKit = NeuronKit(config: config)
```

### 2. 开始对话会话

```swift
let sessionId = UUID()
neuronKit.openSession(sessionId: sessionId, agentId: UUID())
```

### 3. 发送消息

```swift
// 发送文本消息
try? await neuronKit.sendMessage(
  sessionId: sessionId,
  text: "Hello, assistant!"
)

// 发送带有上下文的消息（可选）
try? await neuronKit.sendMessage(
  sessionId: sessionId,
  text: "Help me with my order",
  context: ["screen": "orders", "user_action": "support"]
)
```

就是这样！您的应用现在具有对话式 AI 功能。

---

## 配置

### 基本配置

```swift
let config = NeuronKitConfig(
  serverURL: URL(string: "wss://your-agent-server.com")!,
  deviceId: "unique-device-id", // 通常是 UUID
  userId: "user-identifier"     // 您的用户 ID
)
```

---

## 错误处理

NeuronKit 会为网络问题和无效操作抛出错误：

```swift
func sendMessage(_ text: String) async {
  do {
    try await neuronKit.sendMessage(sessionId: sessionId, text: text)
  } catch {
    print("发送消息失败：\(error)")
    // 处理错误（显示警报、重试等）
  }
}
```

---

## 要求

- iOS 14+
- Swift 5.9+
- Xcode 15+

---

## 许可证

Copyright 2023 Finclip / Geeksfino.

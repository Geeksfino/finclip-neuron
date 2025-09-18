# NeuronKit 开发者指南

> 📖 **语言**: [English](README.md) | [中文](README.zh.md)

NeuronKit 是一个 Swift SDK，可以在您的 iOS 应用中启用对话式 AI 代理。本指南展示了如何将其集成到您的项目中。

## 安装

### Swift 工具链兼容性

我们为多个 Swift 工具链发布预编译二进制文件。请使用与您的 Xcode 版本匹配的分支以确保二进制兼容性。

**对于 Swift 6.2（Xcode 16.2 及更高版本）：**

在您的 `Package.swift` 中使用 `main` 分支：

```swift
// Package.swift
.dependencies: [
  .package(url: "https://github.com/Geeksfino/finclip-neuron.git", branch: "main")
],
```

**对于 Swift 6.0.x（Xcode 16.1）：**

在您的 `Package.swift` 中使用 `main-swift6_0` 分支：

```swift
// Package.swift
.dependencies: [
  .package(url: "https://github.com/Geeksfino/finclip-neuron.git", branch: "main-swift6_0")
],
```

### 在 Xcode 中添加包

1. 在 Xcode 中，转到**文件 → 添加包依赖项…**
2. 输入仓库 URL：`https://github.com/Geeksfino/finclip-neuron.git`
3. 对于**依赖规则**，选择**分支**并输入 `main` 或 `main-swift6_0`（根据您的工具链）。
4. 将 `NeuronKit`、`SandboxSDK` 和 `convstorelib` 产品添加到您的应用目标中。

---

## 使用类型化 API 声明参数

类型化的 `Feature` 模型现在支持通过 `FeatureArgsSchema` 声明必需参数。这映射到 PDP 的 `args_schema`，并通过 `exportFeatureOverviews()` 暴露给智能体。

示例：

```swift
import SandboxSDK

let exportFeature = SandboxSDK.Feature(
  id: "exportPortfolioCSV",
  name: "导出投资组合 CSV",
  description: "将持仓导出为 CSV",
  category: .Native,
  path: "/export",
  requiredCapabilities: [.Network],
  primitives: [
    .NetworkOp(url: "https://api.example.com/export", method: .GET, headers: ["Accept": "text/csv"], body: nil)
  ],
  argsSchema: FeatureArgsSchema(required: ["format", "date_from", "date_to"]) // ← 新增
)

_ = SandboxSDK.registerFeature(exportFeature)

let dec = try SandboxSDK.evaluateFeature(
  "exportPortfolioCSV",
  args: ["format": "csv", "date_from": "2025-09-01", "date_to": "2025-09-18"],
  context: nil
)
if dec.status == .allowed {
  _ = try SandboxSDK.recordUsage("exportPortfolioCSV")
}
```

注意：

- 确保您的应用依赖包含 `FeatureArgsSchema`（和更新的 `Feature` 初始化器）的 SandboxSDK 版本。
- 对于更高级的模式（类型、枚举），您仍可以使用清单/字典注册。

---

## 类型化 vs 清单注册（对比）

以下是同一功能用两种方式注册的示例：类型化 API 和清单/字典。

### 1) 类型化 API（简洁，编译时模型）

```swift
import SandboxSDK

let feature = SandboxSDK.Feature(
  id: "open_payment",
  name: "打开支付",
  description: "打开支付界面",
  category: .Native,
  path: "/payment",
  requiredCapabilities: [.UIAccess],
  primitives: [.MobileUI(page: "/payment", component: nil)],
  argsSchema: FeatureArgsSchema(required: ["amount", "currency"]) // 最小必需键
)
_ = SandboxSDK.registerFeature(feature)
_ = SandboxSDK.setPolicy("open_payment", SandboxSDK.Policy(
  requiresUserPresent: true,
  requiresExplicitConsent: true,
  sensitivity: .medium,
  rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 5)
))
```

### 2) 清单/字典（完整模式灵活性）

```swift
let ok = SandboxSDK.applyManifest([
  "features": [[
    "id": "open_payment",
    "name": "打开支付",
    "category": "Native",
    "path": "/payment",
    "required_capabilities": ["UIAccess"],
    "primitives": [["type": "MobileUI", "page": "/payment"]],
    // 可能的更丰富模式（类型/枚举/模式）
    "args_schema": [
      "amount": ["type": "number", "min": 0],
      "currency": ["type": "string", "enum": ["USD", "EUR", "CNY"]]
    ]
  ]],
  "policies": [
    "open_payment": [
      "requires_user_present": true,
      "requires_explicit_consent": true,
      "sensitivity": "medium",
      "rate_limit": ["unit": "minute", "max": 5]
    ]
  ]
])
```

使用类型化 API 获得易用性和编译时结构。当您需要更丰富的验证时，切换到清单。

---

## FeatureArgsSchema 是否应包含类型/枚举/模式？

简短回答：即使智能体提供的值是字符串，这也很有用。

- 验证：PDP 可以根据预期形状（数字、枚举成员、模式）验证字符串，并提前拒绝/询问。
- 智能体指导：导出的模式帮助智能体产生更好的值（工具提示、UI 表单）。
- 互操作：当模式保证形状时，您的应用可以安全地解析/转换字符串（例如，转换为 Decimal）。

然而，添加完全类型化的模式会增加 API 表面和维护成本。务实的方法是：

- 现在保持类型化 API 最小化（必需键）以获得人体工程学。
- 当您需要类型/枚举/模式或自定义验证器时，使用清单/字典。
- 如果您的应用经常依赖严格验证，考虑逐步扩展 `FeatureArgsSchema`，使用可选注释如 `types`、`enums` 或 `pattern`。

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
let runtime = NeuronRuntime(config: config)
```

### 2. 开始对话会话

```swift
let sessionId = UUID()
runtime.openSession(sessionId: sessionId, agentId: UUID())
```

### 3. 发送消息

```swift
// 发送文本消息
try? await runtime.sendMessage(
  sessionId: sessionId,
  text: "Hello, assistant!"
)

// 发送带有上下文的消息（可选）
try? await runtime.sendMessage(
  sessionId: sessionId,
  text: "Help me with my order",
  context: ["screen": "orders", "user_action": "support"]
)
```

就是这样！您的应用现在具有对话式 AI 功能。

---

## 核心概念

- **NeuronRuntime**：以 `NeuronKitConfig` 初始化的核心运行时，负责会话、消息、沙箱策略和网络适配器。
- **ConvoUIAdapter**：应用 UI 与运行时的桥梁，接收对话更新、展示消息，并处理用户授权。
- **Sandbox（沙箱）**：策略引擎，用于控制代理可以使用哪些功能、在何种条件下（用户在场、显式同意、速率限制、敏感度等），并具备审计能力。
- **NetworkAdapter**：可插拔的网络传输层（WebSocket/HTTP/自定义），可在不改变业务逻辑的情况下替换。
- **会话与消息**：为每段对话创建 `sessionId`，发送用户文本与可选上下文；通过适配器接收代理消息和指令。

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
    try await runtime.sendMessage(sessionId: sessionId, text: text)
  } catch {
    print("发送消息失败：\(error)")
    // 处理错误（显示警报、重试等）
  }
}
```

---

## Sandbox：注册功能与设置策略

NeuronKit 内置「沙箱（Sandbox）」用于精细控制代理可执行的动作。你可以：

- 注册应用功能（Feature）
- 为功能配置策略（如：是否需要用户在场、是否需要显式同意、频率限制等）
- 在会话期间将已注册的功能导出给代理使用

- 注册 `open_payment` 功能
- 设置策略（需要用户在场 + 需要显式同意 + 速率限制）
- 说明如何挂载对话 UI 适配器以处理授权弹窗与消息更新

```swift
import NeuronKit
import SandboxSDK

// 1) 创建运行时（以及可选的 UI 适配器）
let config = NeuronKitConfig(
  serverURL: URL(string: "wss://api.example.com")!,
  deviceId: "demo-device",
  userId: "demo-user"
)
let runtime = NeuronRuntime(config: config)

// 2) 注册功能
let paymentFeature = SandboxSDK.Feature(
  id: "open_payment",
  name: "Open Payment",
  description: "Opens payment screen",
  category: .Native,
  path: "/payment",
  requiredCapabilities: [.UIAccess],
  primitives: [.MobileUI(page: "/payment", component: nil)]
)
_ = runtime.sandbox.registerFeature(paymentFeature)

// 3) 为功能设置策略
_ = runtime.sandbox.setPolicy("open_payment", SandboxSDK.Policy(
  requiresUserPresent: true,
  requiresExplicitConsent: true,
  sensitivity: .medium,
  rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 5)
))

// 4) （可选）挂载对话 UI 适配器以处理授权 UI 与消息更新
// runtime.setConvoUIAdapter(yourAdapter)

// 5) 开启会话——运行时会自动向代理暴露已注册的功能
let sessionId = UUID()
runtime.openSession(sessionId: sessionId, agentId: UUID())
```

说明：

- 当代理提出动作（如 `open_payment`）时，Sandbox 的策略判定（PDP）会先评估策略。如果需要显式同意，你的 `ConvoUIAdapter` 会收到 `handleConsentRequest(...)` 回调，用于弹窗征求用户授权。

### 在 ConvoUIAdapter 中处理授权

实现一个最小可用的适配器，用于向用户展示授权请求并将选择回传给运行时：

```swift
final class MyConvoAdapter: BaseConvoUIAdapter {
  override func handleMessages(_ messages: [NeuronMessage]) {
    // 将最新消息更新到你的 UI（聊天界面等）
  }

  override func handleConsentRequest(
    proposalId: UUID,
    sessionId: UUID,
    feature: String,
    args: [String: Any]
  ) {
    // 弹出授权 UI（警告框/底部弹窗等）征求用户同意
    let userApproved = true // 从你的 UI 结果中获取
    context?.userProvidedConsent(messageId: proposalId, approved: userApproved)
  }

  override func didBind(sessionId: UUID) {
    // 当适配器绑定到会话时触发，可在此初始化 UI 状态
  }
}

// 使用
let adapter = MyConvoAdapter()
runtime.setConvoUIAdapter(adapter)
```

---

## 网络适配器：构建与使用

NeuronKit 通过 `NetworkAdapter` 与代理服务通信。SDK 开箱即用地提供了以下参考适配器：

- `WebSocketNetworkAdapter`（模拟 WebSocket，便于本地测试）
- `URLSessionHTTPAdapter`（HTTP POST + 轮询）
- `StarscreamWebSocketAdapter`（基于第三方 Starscream 的 WebSocket 方案）
- `LoopbackNetworkAdapter`（回环 + 指令模拟，便于演示）

### 使用内置适配器

- WebSocket（模拟）

```swift
let ws = WebSocketNetworkAdapter(url: URL(string: "wss://your-server/ws"))
let runtime = NeuronRuntime(config: config)
runtime.setNetworkAdapter(ws)
```

- HTTP（URLSession）

```swift
let http = URLSessionHTTPAdapter(
  baseURL: URL(string: "https://api.example.com")!,
  pollingInterval: 2.0
)
let runtime = NeuronRuntime(config: config)
runtime.setNetworkAdapter(http)
```

- Starscream（三方 WebSocket）

```swift
// 需在项目中添加 Starscream 依赖并启用真实实现
let ws = StarscreamWebSocketAdapter(url: URL(string: "wss://api.example.com/ws")!)
let runtime = NeuronRuntime(config: config)
runtime.setNetworkAdapter(ws)
```

- Loopback（演示/测试）

```swift
let loop = LoopbackNetworkAdapter()
let runtime = NeuronRuntime(config: config)
runtime.setNetworkAdapter(loop)
```

### 自定义你的适配器

要实现自定义网络适配器，继承 `BaseNetworkAdapter` 并实现三类核心能力：

1) 连接生命周期：重写 `start()`/`stop()` 并在合适时机调用 `updateState(...)`
2) 出站发送：重写 `sendToNetworkComponent(_:)`，将字节传给你的网络层
3) 入站接收：当有消息到达时调用 `handleInboundData(...)`（支持 `Data` 或 `String`）

骨架代码：

```swift
import Foundation

final class MyNetworkAdapter: BaseNetworkAdapter {
  private var isStarted = false

  override func start() {
    guard !isStarted else { return }
    isStarted = true
    updateState(.connecting)
    // 建立连接...
    updateState(.connected)
  }

  override func stop() {
    isStarted = false
    // 断开连接...
    updateState(.disconnected)
  }

  override func sendToNetworkComponent(_ data: Any) {
    guard let data = data as? Data, isStarted else { return }
    // 将字节写入你的网络传输
  }

  // 若你的库需要进行字符串/二进制互转，可重写：
  override func convertOutboundData(_ data: Data) -> Any { data }
  override func convertInboundData(_ data: Any) -> Data? {
    if let d = data as? Data { return d }
    if let s = data as? String { return s.data(using: .utf8) }
    return nil
  }

  // 当网络收到数据时调用：
  func onBytesFromNetwork(_ data: Data) {
    handleInboundData(data)
  }
}
```

提示：可以先使用 `LoopbackNetworkAdapter` 验证应用接线是否正确，然后再切换到 HTTP 或 WebSocket。

### 适配器状态与错误处理

适配器需通过 `updateState(...)` 报告连接状态：

- `.connecting` → `.connected` → `.disconnected`
- 网络瞬断可使用 `.reconnecting`
- 严重错误可使用 `.error(NetworkError)` 便于诊断

参考 `URLSessionHTTPAdapter`，其中包含连通性检测、轮询、失败退避等较完整的实现细节。

---

## 支持的能力（Capabilities）与原语（Primitives）

本 SDK 遵循通用 Sandbox 规格来声明应用 Feature、所需能力以及可执行原语。

### 当前支持的能力

- `UIAccess`
- `Network`
- `DeviceControl`（物联网）
- `Camera`
- `Microphone`
- `AudioOutput`
- `Bluetooth`
- `NFC`
- `Sensors`

参考：`sandbox/docs/spec.md` 第 3.2 节（CapabilityType）。

### 当前支持的原语（subset）

移动 UI 与导航：

- `MobileUI { page, component? }`
- `ShowDialog { title, message }`

小程序/微应用控制：

- `MiniApp { url_path, js_api[] }`
- `InvokeJSAPI { api_name, params }`

媒体与硬件：

- `CapturePhoto { params }`
- `CaptureVideo { params }`
- `RecordAudio { params }`
- `PickImage {}`
- `PickVideo {}`

文件系统：

- `FileOp { path, op }`

网络：

- `NetworkOp { url, method, headers?, body? }`
- `WebSocketConnect { url }`

系统能力：

- `ClipboardOp { action, text? }`
- `ShowNotification { title, body }`
- `CreateCalendarEvent { event }`
- `GetCurrentLocation {}`

音频输出：

- `PlayAudio { source, volume? }`，`StopAudio {}`

蓝牙/NFC：

- `BluetoothScan { filters? }`、`BluetoothConnect { device_id }`、`BluetoothWrite { ... }`、`BluetoothRead { ... }`
- `NfcReadTag {}`、`NfcWriteTag { payload }`

IoT 控制与传感：

- `DeviceControl { device_type, action, device_id? }`
- `DevicePower { device_id, state }`
- `SetDeviceMode { device_id, mode }`
- `SetTemperature { device_id, value }`
- `SetBrightness { device_id, value }`
- `LockDevice/UnlockDevice { device_id }`
- `ReadSensor { sensor_type, device_id }`
- `ExecuteScene { scene_id }`、`SyncDeviceGroup { group_id }`

跨域通用：

- `ValidateUser { token }`、`CheckCapability { permission }`、`GetContext { key }`、`LogAudit { action, result }`

说明：不同平台可按需启用子集。完整清单与路线图见 `sandbox/docs/spec.md`。

---

## 支持的功能分类（Feature Categories）

Feature 根据执行位置/形态划分为以下分类（见 `sandbox/docs/spec.md` 的 FeatureCategory）：

- `Native` —— 应用原生功能（导航、对话框、媒体、通知等）
- `MiniApp` —— 内嵌微应用/小程序路由及其 JS API
- `IoTDevice` —— 物联网设备控制与自动化
- `External` —— 委托给外部第三方应用
- `SystemApp` —— 操作系统提供的应用（日历、邮件等）
- `Web` —— 浏览器/网页运行时调用

在声明 `Feature` 时设置分类（Typed API 支持：`.Native | .MiniApp | .IoTDevice | .External | .SystemApp | .Web`）。

提示：分类不等同于权限。请始终为 Feature 指定所需能力（如 `UIAccess`、`Network`），并映射到合适的 Primitives。

---

## 策略流程（PDP 模式）

iOS 层充当 PDP（策略决策点），您的应用是 PEP（策略执行点）：

1) 初始化并应用清单（或动态注册），包含 Feature、所需能力与策略。
2) 调用 `evaluateFeature(name,args,context)`。

   - 返回 `.allowed | .ask | .denied | .rateLimited`，可包含 `reason` 与 `reset_at`。

3) 若返回 `.allowed`，由宿主代码执行动作，随后调用 `recordUsage(name)` 更新频率限制与审计。

Swift 示例：

```swift
// 1) 初始化并注册
SandboxSDK.initialize()
let ok = SandboxSDK.applyManifest([
  "features": [[
    "name": "exportPortfolioCSV",
    "category": "Native",
    "path": "/export",
    "required_capabilities": ["Network"],
    "primitives": [["type": "NetworkOp", "url": "https://api.example.com/export", "method": "GET"]]
  ]],
  "policies": [
    "exportPortfolioCSV": [
      "requires_user_present": true,
      "requires_explicit_consent": true,
      "sensitivity": "high"
    ]
  ]
])

// 2) 评估 → 宿主执行 → 记录使用
let decision = try SandboxSDK.evaluateFeature("exportPortfolioCSV", args: [:], context: nil)
if decision.status == .allowed {
  // 执行动作
  _ = try SandboxSDK.recordUsage("exportPortfolioCSV")
}
```

如需无清单的临时注册，使用 `registerFeature` 与 `setPolicies`。更多细节见 `sandbox/docs/ios_sandboxsdk_developer_guide.md`。

---

## 要求

- iOS 14+
- Swift 6.0+
- Xcode 16.1+

---

## 许可证

Copyright 2023 Finclip / Geeksfino.

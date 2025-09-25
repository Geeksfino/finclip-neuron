# FinClip Neuron — 开发者指南（中文）

 📖 **语言**: [English](README.md) | [中文](README.zh.md)

## 1. 介绍

FinClip Neuron 帮助你在移动端、桌面端、物联网设备上安全地构建“智能体驱动”的体验。它包含：

- 基于能力模型（Capability Model）的安全沙箱（Sandbox），提供最小权限、用户同意、频率限制等精细控制，让云端智能体能在用户许可下，对本地功能进行调度，实现人机协同（Human in the loop）的自动化
- 会话运行时（NeuronKit），将智能体的提案（指令）安全地转化为可审计的动作
- 结合设备端场景数据例如地理位置、时间日程、网络、环境等不下十多类（[设备端上下文](docs/context.zh.md)）数据内容，协助智能体识别用户意向，实现更智能的自动化
- 多场景的会话管理，支持在App内任何页面下开启和继续会话，在传统的触控型、鼠标点击型的人机交互方式上，叠加AI时代的会话型人机交互方式，让当前会话与当前UI页面达成场景融合，实现更流畅的交互体验，达成“点击流”与“会话流”的“合流”
- 接入云端上下文管理引擎（Context Engine），对用户、设备、应用、场景等多维度数据进行管理，实现以用户为中心的跨设备、跨场景、跨会话的多形态记忆 -如语义记忆（Semantic Memory）、短期记忆（Short-term Memory）、长期记忆（Long-term Memory）、场景记忆（Episodic Memory）、程序记忆（Procedural Memory）等，让所对接的智能体能更好地理解用户，实现更智能的自动化

本仓库发布 NeuronKit 以及示例应用，并提供 SandboxSDK 与 convstorelib 的二进制依赖。

- 推荐路径：
  - `finclip-neuron/examples/custom/` — CLI 快速上手示例，可直接 `swift run` 运行。

---

## 2. 核心概念

- **基于能力模型的沙盒：Feature → Capability → Primitive**
  - Feature 表达高层功能（如“打开相机”）。
  - 每个 Feature 需要一个或多个 Capability（如 UI 访问、设备传感器访问）。
  - Capability 最终由具体 Primitive 执行（如 `MobileUI(page:"/camera", component:"camera")`）。

- **PDP（策略决策点）**
  - 评估提案是否允许：考虑用户在场、显式同意、敏感级别、频控、历史使用等。

- **PEP（策略执行点）**
  - 在应用运行时执行 PDP 结果：拒绝则阻断；需要同意则弹出 UI；允许则执行。

- **上下文（Context）**
  - 设备上下文：设备类型、时区、网络/电量等。
  - 应用/场景上下文：业务路由、页面、业务标识等。

- **特性调用（工具调用）**
  - 智能体通过 Feature ID + 类型化参数（FeatureArgsSchema）提出指令。运行时在执行前会进行参数校验与策略评估。

---

## 架构总览（Architecture Overview）

```mermaid
flowchart LR
  subgraph App
    UI[应用 UI]
    ConvoUI[ConvoUI 适配器]
    Runtime[NeuronRuntime]
    Sandbox["Sandbox (PDP/PEP)"]
  end

  Agent[(Agent 服务)]

  UI -->|用户输入/事件| ConvoUI
  ConvoUI -->|绑定会话，转发用户意图| Runtime
  Runtime --> Sandbox
  Sandbox -->|决策：允许/询问/拒绝| Runtime
  Runtime -->|特性提案/消息| ConvoUI
  ConvoUI -->|需要时展示同意 UI| UI

  Runtime <--> |字节流| Net[NetworkAdapter]
  Net <--> Agent
```

要点：

- **ConvoUI 适配器** 负责桥接 UI 与运行时（典型集成中不要直接调用 `sendMessage`）。
- **Sandbox** 做策略判定（PDP），应用侧按结果执行（PEP），包括弹窗征求同意等。
- **NetworkAdapter** 可插拔（WebSocket/HTTP/自定义），用于与后端智能体传输消息。

---

## 3. 安装与依赖

在 SwiftPM 中添加依赖：

```swift
// Package.swift
dependencies: [
  .package(url: "https://github.com/Geeksfino/finclip-neuron.git", branch: "main-swift6_0")
],

targets: [
  .executableTarget(
    name: "YourApp",
    dependencies: [
      .product(name: "NeuronKit", package: "finclip-neuron"),
      .product(name: "SandboxSDK", package: "finclip-neuron"),
      .product(name: "convstorelib", package: "finclip-neuron")
    ]
  )
]
```

本仓库提供以下二进制依赖：

- `NeuronKit.xcframework`
- `SandboxSDK.xcframework`
- `convstorelib.xcframework`

---

## 4. 快速开始

运行内置示例：

```bash
cd finclip-neuron/examples/custom
swift run
```

你将看到：

- 启动 NeuronRuntime。
- 注册多个 Feature（相机、支付、通讯录、定位、通知、导出报表、MiniApp 路由）。
- 使用回环（Loopback）网络适配器模拟智能体指令。
- 使用 CLI ConvoUI 适配器展示消息与同意弹窗。

关键文件：

- `examples/custom/Sources/custom/CustomDemoApp.swift`
- `examples/custom/Sources/custom/CliConvoAdapter.swift`
- `examples/custom/Sources/custom/adapters/`（Loopback / WebSocket / HTTP 示例）

最小集成代码：

```swift
import NeuronKit
import SandboxSDK

// 配置（默认持久化，可通过 storage 指定内存模式）
let config = NeuronKitConfig(
  serverURL: URL(string: "wss://api.example.com")!,
  deviceId: "demo-device",
  userId: "demo-user",
  storage: .persistent, // 默认；测试/演示可用 .inMemory
  contextProviders: [  // 所有项均可选。此数组可以为空。
    ScreenStateProvider(),   // 屏幕开关/方向
    ThermalStateProvider(),  // 热压力
    DeviceEnvironmentProvider(), // 语言与 24 小时制
    TimeBucketProvider(), // 时间分段/星期
    NetworkQualityProvider(), // 网络质量
    NetworkStatusProvider(), // 网络类型（wifi/cellular 等）
    CalendarPeekProvider(), // 近期日历事件
    BarometerProvider(), // 环境气压（iOS）
    DeviceStateProvider(), // 电池电量/状态（iOS）
    LocationContextProvider(), // 需要已有定位权限，Provider 不主动弹窗
    RoutineInferenceProvider(), // 日常模式推断
    UrgencyEstimatorProvider() // 紧急程度估计
  ]
)
let runtime = NeuronRuntime(config: config)

// 打开会话（会话句柄，流式/实时）
let convo = runtime.openConversation(agentId: UUID())

// 绑定 UI 适配器到该会话
let uiAdapter = CliConvoAdapter(chatViewModel: ChatViewModel())
convo.bindUI(uiAdapter)

// 设置网络适配器（示例使用 WebSocket）
let networkAdapter = MyWebSocketNetworkAdapter(url: URL(string: "wss://your-server")!)
runtime.setNetworkAdapter(networkAdapter)

// 发送消息
try await convo.sendMessage("Hello")

// （可选）只读历史：attach + 快照分页
let attached = runtime.attachConversation(sessionId: convo.sessionId)
let firstPage = try? runtime.messagesSnapshot(sessionId: attached.sessionId, limit: 50)
let olderPage = try? runtime.messagesSnapshot(sessionId: attached.sessionId, limit: 50, before: firstPage?.first?.timestamp)
```

---

## 5. 沙箱用法：类型化 API、Manifest、PDP 流程

- **类型化 API（FeatureArgsSchema）**
  - 为每个 Feature 定义参数 schema（必填/可选/约束）。
  - 运行时在执行前会校验参数，确保与 schema 匹配。

```swift
let exportFeature = SandboxSDK.Feature(
  id: "export_report",
  name: "Export Report",
  description: "Export a report with a given format",
  category: .Native,
  path: "/report/export",
  requiredCapabilities: [.UIAccess],
  primitives: [.MobileUI(page: "/report/export", component: "format=csv&range=last30d")],
  argsSchema: FeatureArgsSchema(
    required: ["format", "range"],
    properties: [
      "format": FeatureArgSpec(type: .string, description: "Export format", enumVals: ["csv", "xlsx"]),
      "range": FeatureArgSpec(type: .string, description: "Time range", pattern: "^(today|yesterday|last7d|last30d|mtd|ytd)$")
    ]
  )
)
```

- **Manifest**
  - 可在启动时一次性应用特性清单（包含 Feature、schema 与 capabilities）。

- **策略与 PDP**
  - 为每个 Feature 设置策略（敏感度、频率限制、是否需要用户同意/在场等）：

```swift
_ = runtime.sandbox.setPolicy("open_camera", SandboxSDK.Policy(
  requiresUserPresent: true,
  requiresExplicitConsent: true,
  sensitivity: .medium,
  rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 10)
))
```

- **上下文参与评估**
  - 消息携带设备上下文（时区、设备类型等）与业务上下文（当前页面/场景），PDP 会纳入评估。

---

## 6. 支持的 Features / Capabilities / Primitives

示例中包含以下常见 Feature：

- `open_camera`, `open_payment`, `access_contacts`, `get_location`, `send_notification`, `export_report`, `miniapp_order_detail`。
- 能力示例：UI 访问、设备传感器、网络、媒体等。
- 常见 Primitive：`MobileUI(page:..., component:...)`，可路由到原生或 MiniApp 流程。

完整的概念模型与可扩展性，请参考 `neuronkit/docs/spec.md`。

---

## 7. 网络适配器（自定义实现）

实现 `NetworkAdapter` 协议即可接入自有网络传输。

必需表面：

- 属性：`onOutboundData: ((Data) -> Void)?`, `onStateChange: ((NetworkState) -> Void)?`, `inboundDataHandler: ((Data) -> Void)?`
- 发布者：`inbound: AnyPublisher<Data, Never>`, `state: AnyPublisher<NetworkState, Never>`
- 方法：`start()`, `stop()`, `send(_ data: Data)`

实践建议：

- 状态变更时调用 `onStateChange?`（`.connecting/.connected/.reconnecting/.disconnected/.error`）。
- 收到网络数据时调用 `inboundSubject.send(data)` 和 `inboundDataHandler?(data)`。
- `onOutboundData?(data)` 仅用于可观察性（可选）；在 loopback/mock 路径中避免调用以防止重入。

示例：

- `examples/custom/Sources/custom/adapters/WebSocketNetworkAdapter.swift`
- `examples/custom/Sources/custom/adapters/URLSessionHTTPAdapter.swift`
- `examples/custom/Sources/custom/adapters/LoopbackNetworkAdapter.swift`（回环示例）

---

## 8. 存储配置（持久化）

NeuronKit 使用本地消息存储保存会话历史，默认“持久化”开启。可在创建 `NeuronKitConfig` 时配置：

```swift
let config = NeuronKitConfig(
  serverURL: URL(string: "wss://api.example.com")!,
  deviceId: "demo-device",
  userId: "demo-user",
  storage: .persistent // 默认
)

// 测试/演示无需持久化：
let inMemory = NeuronKitConfig(
  serverURL: URL(string: "wss://api.example.com")!,
  deviceId: "demo-device",
  userId: "demo-user",
  storage: .inMemory
)
```

- 使用发布者 `runtime.messagesPublisher(sessionId:)`（或 `convo.messagesPublisher`）获取历史+增量更新。
- 使用 `runtime.messagesSnapshot(sessionId:limit:before:)` 做分页或列表预览。

## 9. ConvoUI 适配器（自定义实现）

ConvoUI 适配器负责将你的 UI 与 NeuronKit 对接：

- 将用户输入转交给运行时（典型集成中不要直接调用 `sendMessage`）。
- 渲染智能体消息与系统提醒。
- PDP 返回需要显式同意时，展示同意 UI。

### 消息模型：`NeuronMessage`

适配器通过 `ConvoSession.messagesPublisher`（或运行时级别的 `messagesPublisher`）接收 `NeuronMessage` 数组。每条消息都已过标准化，直接可用于渲染。

- **content** —— 主文本内容。来源为 `wire.text ?? wire.content ?? ""`，因此后端可发送 `text` 或 `content` 字段。若为空字符串，请结合 `attachments` 或 `components` 渲染。
- **sender** —— 枚举（`.user`/`.agent`/`.system`/`.tool`），用于区分气泡样式与归属。
- **attachments** —— 附件数组，包含 `displayName`、`mimeType`、可选 `url`、可选内联 `dataBase64` 与自定义 `meta`。存在 `url` 时建议惰性下载；存在 `dataBase64` 时可直接渲染预览。
- **components** —— 结构化 UI 组件，由 `type`/`variant` 与可选 `payload` 描述。你可以将其映射为自定义 SwiftUI / UIKit 视图。
- **metadata** —— 可选的键值对，用于分析标签或轻量提示（如 "intent"、"topic"）。
- **timestamp & id** —— 稳定字段，便于排序、去重与持久化，适配 diffable 数据源。

#### 流式 API

- `messagesPublisher(sessionId:isDelta:initialSnapshot:)` —— 通过 `ConvoSession.bindUI` 绑定时，默认采用“增量模式 + 初始快照”（`isDelta: true, initialSnapshot: .full`）。即首次推送为完整历史，其后仅推送新变更。若希望每次都是完整历史，可传 `isDelta: false`。
- `messagesSnapshot(sessionId:limit:before:)` —— 一次性分页快照，适合列表首屏或下拉加载更早历史。

#### 典型绑定示例

```swift
import Combine

final class MyConvoAdapter {
  private var cancellables = Set<AnyCancellable>()

  func bind(session: ConvoSession) {
    session.messagesPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] messages in
        self?.render(messages: messages)
      }
      .store(in: &cancellables)
  }

  func send(text: String, session: ConvoSession) {
    Task { try await session.sendMessage(text) }
  }

  private func render(messages: [NeuronMessage]) {
    // 在此更新你的视图模型或界面
  }
}
```

> 提示：在 SwiftUI 中可将消息存入 `@Published` 数组，并通过 `ForEach(messages)` 绑定；稳定的 `id` 能确保快速流式更新下依然高效 diff。

### 会话中心绑定（推荐）

新方法允许你动态地将 UI 适配器绑定/解绑到特定会话：

```swift
// 打开会话
let convo = runtime.openConversation(agentId: UUID())

// 将 UI 适配器绑定到此特定会话
let adapter = MyConvoAdapter()
convo.bindUI(adapter)

// 稍后：当 UI 不再活跃时解绑（如视图消失）
convo.unbindUI()

// 对话结束时关闭会话
convo.close()
```

### 多会话支持

现在可以有多个活跃会话，每个都有不同的 UI 适配器：

```swift
// 为不同上下文创建会话
let supportConvo = runtime.openConversation(agentId: UUID())
let salesConvo = runtime.openConversation(agentId: UUID())

// 将不同适配器绑定到各自会话
supportConvo.bindUI(supportAdapter)
salesConvo.bindUI(salesAdapter)

// 稍后：关闭会话
supportConvo.close()
salesConvo.close()
```

示例：

- `examples/custom/Sources/custom/CliConvoAdapter.swift`
- `examples/custom/Sources/custom/CustomDemoApp.swift`
- `examples/ios-sample/Sources/App/MultiSessionExample.swift`

---

## 10. 上下文（概览）

上下文是 NeuronKit SDK 最重要的设计之一。它持续收集与用户意图相关的移动设备与应用内信号，并随消息一并发送给智能体，帮助其理解当下情境、安全态势与偏好。这属于智能体系统中的“上下文工程”。

NeuronKit 会为每条出站消息自动富集设备与应用上下文，帮助 PDP 做出更优决策。

- 在创建 `NeuronKitConfig` 时注册 Context provider，可在发送时/按 TTL/前台刷新生成值。
- 上下文通过强类型的 `DeviceContext` 与 `additionalContext: [String: String]`（粗粒度信号）传递。
- provider 不会触发系统权限弹窗；请在 App 中先请求权限，再注册相关 provider。

快速链接：

- [设备端的上下文](docs/context.zh.md)
  
上述文档包含刷新策略、快速上手示例、完整的 provider 参考（标准/高级/衍生），以及后端解析指引。

---

## 许可

参见仓库中的 LICENSE。

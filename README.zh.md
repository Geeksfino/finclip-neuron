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

当你希望 NeuronKit 通过自定义传输层通信（WebSocket、HTTP 轮询、SSE、gRPC、蓝牙等）时，需要实现 `NetworkAdapter` 协议。适配器位于 NeuronKit 运行时与服务器之间：

1. 运行时在有出站 JSON 数据时调用 `send(_:)`。适配器负责把字节写入具体传输层（socket、HTTP、gRPC 等）。
2. 服务器返回实时预览片段或最终响应时，适配器把字节交回 NeuronKit。
3. 适配器汇报连接状态，便于运行时和 UI 做重试、提示。

### 7.1 生命周期与必备接口

- **属性**
  - `onStateChange: ((NetworkState) -> Void)?` —— 连接状态变化时调用（连接中/已连接/重连/断开/错误）。
  - `inboundDataHandler: ((Data) -> Void)?` —— 收到完整响应（常为最终帧）时调用，让 NeuronKit 持久化并分发。
  - `onOutboundData: ((Data) -> Void)?` —— 可选，用于日志或链路追踪。避免在回调里再次调用 `send(_:)` 以免重入。

- **Publishers**
  - `inbound: AnyPublisher<Data, Never>` —— `BaseNetworkAdapter` 已帮忙实现，多数适配器直接用 `inboundDataHandler` 即可。
  - `state: AnyPublisher<NetworkState, Never>` —— 状态流，可供 UI 订阅。

- **方法**
  - `start()` —— 建立连接或开启轮询，设置状态为 `.connecting`/`.connected`。
  - `stop()` —— 关闭连接，释放资源，发出 `.disconnected`。
  - `send(_ data: Data)` —— 写出字节；若需要确认或排队，在此处理。

建议继承 `BaseNetworkAdapter`，它提供 `inboundSubject`、publishers 等基础能力。

### 7.2 入站数据回流

- **完整响应**：调用 `handleInboundData(_:)` 或 `inboundDataHandler?(payload)`，NeuronKit 会解析、存储并通知 UI。
- **流式响应**：为每个实时预览片段构造 `InboundStreamChunk`，通过 `inboundPartialDataHandler?(chunk)` 发送，`sequence` 保证顺序，`messageId` 用于最终去重。最后再调用 `handleInboundData(_:)` 将完整结果入库。
- **状态更新**：在握手成功、重连、断线、异常时调用 `onStateChange?`。

### 7.3 出站请求发送

- **WebSocket** —— 发送文本或二进制帧。
- **HTTP** —— 将数据放入请求体；若需流式可用长轮询或 SSE。
- **SSE/长轮询** —— `send(_:)` 触发 HTTP 请求，等待服务端推送。
- **自定义协议** —— 如蓝牙、gRPC，序列化 JSON 并调用相应 SDK。

如需确认/节流，可在 `send(_:)` 中排队或等待 ACK。

### 7.4 流式注意事项

- 与后端约定“预览”和“最终”的标记方式（参见下文“服务端约定”）。
- 使用 `InboundStreamChunk` 传递实时预览片段，`sequence`/`messageId` 有助于 UI 合并、去重。
- 每条消息仅调用一次 `handleInboundData(_:)`，通常在最终帧。
- 流结束时清理适配器缓存，避免内存泄露。

### 7.5 数据流示意

```plaintext
NeuronKit send(_:) → 适配器写入传输层 → 服务端返回预览 → inboundPartialDataHandler 推送预览片段 → UI 展示预览
→ 服务端返回最终帧 → 适配器调用 handleInboundData(_) → NeuronKit 持久化并通知 UI
```

### 7.6 参考实现

- `examples/custom/Sources/custom/adapters/WebSocketNetworkAdapter.swift`
- `examples/custom/Sources/custom/adapters/URLSessionHTTPAdapter.swift`
- `examples/custom/Sources/custom/adapters/LoopbackNetworkAdapter.swift`
- 模板：`docs/templates/TemplateSSEAdapter.swift`

### 流式适配器与 SSE 蓝图

- **实时预览片段** —— `examples/custom/` 目录下的 loopback、mock、WebSocket、HTTP 适配器已经演示如何构造 `InboundStreamChunk` 并通过 `inboundPartialDataHandler` 推送流式文本。可以对照这些文件了解拆分长度、metadata 标记（如 `transport` / `kind`）以及时间节奏。仓库还提供了可直接拷贝的模板：`docs/templates/TemplateSSEAdapter.swift`。
- **HTTP 轮询** —— `MyURLSessionHTTPAdapter` 能解析两种响应：实时预览片段（`MockPreviewEnvelope`）以及完整缓冲结果（`MockStreamEnvelope`），在最终帧到达时调用 `handleInboundData(_:)`。
- **Server-Sent Events (SSE)** —— 可以借助 `URLSessionDataDelegate` 收集增量帧，先行发出预览 chunk，再在最终帧到达时转交给 `handleInboundData(_:)`：
- **服务端约定** —— 请与你的后端明确“预览帧”和“最终帧”的标记方式。例如 SSE 可以通过 `event: preview` 多次推送实时预览片段，最后发送 `event: complete` 或在数据里带上 `is_final`，适配器需据此填充 `InboundStreamChunk.isFinal` 并仅在最终帧调用一次 `handleInboundData(_:)`。

```swift
final class SSEAdapter: BaseNetworkAdapter, URLSessionDataDelegate {
  private let url: URL
  private lazy var session = URLSession(configuration: .default,
                                        delegate: self,
                                        delegateQueue: nil)
  private var task: URLSessionDataTask?
  private var buffer = Data()

  override func start() {
    updateState(.connecting)
    task = session.dataTask(with: url)
    task?.resume()
  }

  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    buffer.append(data)

    while let range = buffer.range(of: "\n\n".data(using: .utf8)!) {
      let frame = buffer.subdata(in: 0..<range.lowerBound)
      buffer.removeSubrange(0..<range.upperBound)

      guard let parsed = SSEFrame(frame) else { continue }

      switch parsed.kind {
      case .preview(let chunk):
        inboundPartialDataHandler?(chunk)
      case .final(let payload):
        handleInboundData(payload)
      }
    }
  }
}
```

其中 `SSEFrame` 是一个轻量辅助结构，用来解析 `id:`、`event:`、`data:` 字段，并在 preview 阶段把文本拆成 `InboundStreamChunk`，最终帧则还原为完整 `Data`。可结合 loopback 适配器中的拆分工具与 metadata 约定来实现生产级 SSE 适配器。

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
- 接收流式预览 chunk（逐片段 streaming）以及最终持久化消息。
- `docs/templates/TemplateConvoUIAdapter.swift` 提供了一个可直接复制的子类，已经实现了流式预览积累、去重以及同意处理样板代码。

- **流式预览如何处理**  
  重写 `handleStreamingChunk(_:)`，按照 `chunk.messageId`（或 `streamId`）累计文本，并在 UI 中展示“正在输入”效果。若 `chunk.isFinal == true`，需记录该消息以便最终消息落库时清除预览。
- **为何需要去重**  
  例如服务端先逐段推送“好的，我来查一下……”的实时预览片段，随后将同一句完整文本作为最终 `NeuronMessage` 返回。如果不清除预览，用户会看到两条内容相同的气泡（预览 + 持久化）。追踪 `messageId`/`streamId` 并在最终消息到达后清除即可避免重复。
- **完成时如何合并**  
  在 `handleMessages(_:)` 中对比最新的 `NeuronMessage` 与预览文本，若内容一致则移除预览或合并内容，确保界面只保留最终气泡。
- **同意与系统事件**  
  重写 `handleConvoEvent(_:)` / `handleConsentRequest`，在 UI 中呈现审批提示或系统消息。
- **发送出站消息**  
  调用 `sendMessage(_:)` 或 `sendMessage(_:context:)` 将用户输入传回 NeuronKit。

### 9.1 流式预览示例适配器

```swift
import Combine

final class MyConvoAdapter: BaseConvoUIAdapter {
  private let viewModel: ChatViewModel
  private var cancellables = Set<AnyCancellable>()
  private var previews: [UUID: String] = [:]
  private var awaitingFinalMessage: Set<UUID> = []

  init(viewModel: ChatViewModel) {
    self.viewModel = viewModel
    super.init()
  }

  override func bind(to session: ConvoSession) {
    super.bind(to: session)

    session.messagesPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] messages in
        self?.viewModel.messages = messages
        self?.dedupeStreamingPreviews(with: messages)
      }
      .store(in: &cancellables)

    session.streamingUpdatesPublisher()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] chunk in
        self?.handleStreamingChunk(chunk)
      }
      .store(in: &cancellables)
  }

  override func handleStreamingChunk(_ chunk: InboundStreamChunk) {
    let id = chunk.messageId ?? UUID(uuidString: chunk.streamId) ?? UUID()
    let delta = String(decoding: chunk.data, as: UTF8.self)
    previews[id, default: ""] += delta

    viewModel.showPreview(id: id, text: previews[id] ?? "")

    if chunk.isFinal {
      awaitingFinalMessage.insert(id)
    }
  }

  override func handleMessages(_ messages: [NeuronMessage]) {
    super.handleMessages(messages)

    for message in messages {
      if awaitingFinalMessage.remove(message.id) || previews[message.id] != nil {
        previews.removeValue(forKey: message.id)
        viewModel.clearPreview(id: message.id)
      }
    }
  }

  func send(text: String, via session: ConvoSession) {
    Task { try await session.sendMessage(text) }
  }
}
```

### 9.2 会话绑定

```swift
let convo = runtime.openConversation(agentId: UUID())
let adapter = MyConvoAdapter(viewModel: chatViewModel)

convo.bindUI(adapter)

// 稍后：当 UI 不再活跃时解绑
convo.unbindUI()

convo.close()
```

### 9.3 多会话示例

```swift
let supportConvo = runtime.openConversation(agentId: UUID())
let salesConvo = runtime.openConversation(agentId: UUID())

supportConvo.bindUI(supportAdapter)
salesConvo.bindUI(salesAdapter)

supportConvo.close()
salesConvo.close()
```

### 9.4 消息模型：`NeuronMessage`

- `content` —— 主文本内容（`wire.text ?? wire.content ?? ""`）；若为空，请结合 `attachments` 或 `components` 渲染。
- `sender` —— `.user` / `.agent` / `.system` / `.tool`，用于区分气泡样式与归属。
- `attachments` —— 含 `displayName`、`mimeType`、可选 `url`、可选内联 `dataBase64` 与自定义 `meta`。
- `components` —— 结构化 UI 组件，由 `type` / `variant` 与可选 `payload` 描述，可映射到自定义视图。
- `metadata` —— 可选键值提示（如 intent、topic）。
- `timestamp` / `id` —— 稳定字段，便于排序、去重与持久化，适配 diffable 数据源。

### 9.5 流式 API

- `messagesPublisher(sessionId:isDelta:initialSnapshot:)` —— `ConvoSession.bindUI` 默认采用“增量 + 初始快照”（`isDelta: true, initialSnapshot: .full`）。若需每次完整历史，可传 `isDelta: false`。
- `messagesSnapshot(sessionId:limit:before:)` —— 一次性分页快照，适合列表首屏或加载更早的历史消息。
- `streamingUpdatesPublisher(sessionId:)` —— 提供 `InboundStreamChunk` 流式消息，让 UI 在最终 `NeuronMessage` 入库前展示预览。

### 9.6 典型绑定示例

```swift
import Combine

final class MyConvoAdapter {
  private var cancellables = Set<AnyCancellable>()
  private var previews: [UUID: String] = [:]
  private var awaitingFinalMessage: Set<UUID> = []

  func bind(session: ConvoSession) {
    session.messagesPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] messages in
        self?.render(messages: messages)
        self?.dedupeStreamingPreviews(with: messages)
      }
      .store(in: &cancellables)

    session.streamingUpdatesPublisher()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] chunk in
        self?.handleStreaming(chunk)
      }
      .store(in: &cancellables)
  }

  func send(text: String, session: ConvoSession) {
    Task { try await session.sendMessage(text) }
  }

  private func render(messages: [NeuronMessage]) {
    // 在此更新你的视图模型或界面
  }

  private func handleStreaming(_ chunk: InboundStreamChunk) {
    let id = chunk.messageId ?? UUID(uuidString: chunk.streamId) ?? UUID()
    let delta = String(decoding: chunk.data, as: UTF8.self)
    previews[id, default: ""] += delta
    // 可在此把 previews[id] 绑定到“智能体正在输入”气泡
    if chunk.isFinal {
      awaitingFinalMessage.insert(id)
    }
  }

  private func dedupeStreamingPreviews(with messages: [NeuronMessage]) {
    for message in messages {
      if awaitingFinalMessage.remove(message.id) || previews[message.id] != nil {
        previews.removeValue(forKey: message.id)
        // 同步清理 UI 上的流式预览
        // viewModel.clearStreamingMessage(id: message.id)
      }
    }
  }
}
```

> 提示：在 SwiftUI 中可将消息存入 `@Published` 数组，并通过 `ForEach(messages)` 绑定；稳定的 `id` 能确保快速流式更新下依然高效 diff。将预览文本单独存储，待最终 `NeuronMessage` 抵达后清除或合并，以避免重复气泡，并在预览阶段记录需要等待的 `messageId`，以便达到去重效果。

### 以会话为中心的UI绑定

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

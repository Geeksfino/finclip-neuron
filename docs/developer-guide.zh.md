# NeuronKit 开发者指南（中文）

面向 iOS 开发者的完整指南，帮助你使用 NeuronKit 将 AI 会话式体验集成到移动应用中。

## 目录

1. [NeuronKit 是什么？](#neuronkit-是什么)
2. [核心概念](#核心概念)
3. [安装](#安装)
4. [快速开始](#快速开始)
5. [理解上下文](#理解上下文)
6. [沙箱与安全](#沙箱与安全)
7. [构建会话式 UI](#构建会话式-ui)
8. [高级特性](#高级特性)
9. [最佳实践](#最佳实践)
10. [故障排查](#故障排查)

---

## NeuronKit 是什么？

NeuronKit 是一套 iOS SDK，可将传统移动应用升级为智能的会话式体验。它让你的应用理解用户上下文、以自然语言交互，并在云端 AI Agent 的协同下安全地在本地执行动作。

### 关键优势

- **上下文感知智能**：自动采集设备信号（位置、时间、传感器等），理解用户场景。
- **会话式交互体验**：在传统触控界面旁增添自然语言交互能力。
- **安全执行**：本地沙箱确保所有 AI 发起的操作都在用户授权下完成。
- **低侵入集成**：以最少代码让既有应用具备 Agent 能力。
- **企业级准备**：内置合规、审计追踪与策略控制。

### 架构概览

```ascii
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Your iOS App  │    │   Cloud Agent   │    │ Context Memory  │
│                 │    │                 │    │    Server       │
│  ┌───────────┐  │    │                 │    │                 │
│  │ NeuronKit │◄─┼────┤ AI Reasoning    │◄───┤ User Context    │
│  │    SDK    │  │    │                 │    │ & History       │
│  └───────────┘  │    │                 │    │                 │
│        │        │    └─────────────────┘    └─────────────────┘
│  ┌───────────┐  │
│  │  Sandbox  │  │     Cloud: Thinks & Plans
│  │   (PEP)   │  │     Device: Executes & Protects
│  └───────────┘  │
└─────────────────┘
```

**核心理念**：*云端思考，设备执行* —— 云端负责智能推理，本地在用户掌控下执行动作。

---

## 核心概念

在编写代码前，先理解这些基础概念：

### 沙箱（Sandbox）

安全层，用于控制 AI Agent 在应用中的权限：

- **Feature（特性）**：高阶应用功能（例如“发送消息”“拍照”）。
- **Capability（能力）**：特性所需的权限（例如相机、网络）。
- **Primitive（原语）**：具体实现动作（例如 `CapturePhoto`、`MobileUI`）。
- **Policy（策略）**：限定特性在何种条件、频率下可被使用。

### 上下文提供者（Context Providers）

模块化组件，用于收集设备与应用状态：

- **Device Context**：位置、传感器、电量、网络状态等。
- **App Context**：当前页面、用户旅程、业务状态。
- **Temporal Context**：时间段、日程事件、惯例模式。

### ConvoUI

会话界面层：

- **会话（Session）**：与不同 Agent 的独立对话线程。
- **消息流（Message Streams）**：实时文本/语音交互，支持打字指示。
- **嵌入式 UI**：在会话流程中插入传统 UI 组件。

### 网络适配器（Network Adapters）

负责应用与 AI Agent 的通信：

- **WebSocket**：实时全双工通信。
- **HTTP**：请求/响应模式，可选流式传输。
- **自定义协议**：例如蓝牙、gRPC 等。

---

## 安装

### 第一步：添加包依赖

通过 Swift Package Manager 将 NeuronKit 集成到 Xcode 项目中：

```swift
// Xcode 中：File → Add Package Dependencies
// URL: https://github.com/Geeksfino/finclip-neuron.git
// Branch: main-swift6_0
```

或在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/Geeksfino/finclip-neuron.git", 
             branch: "main-swift6_0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "NeuronKit", package: "finclip-neuron"),
            .product(name: "SandboxSDK", package: "finclip-neuron"),
            .product(name: "convstorelib", package: "finclip-neuron")
        ]
    )
]
```

### 第二步：导入框架

```swift
import NeuronKit
import SandboxSDK
```

### 第三步：补充权限声明

根据所需上下文提供者修改 `Info.plist`：

```xml
<!-- 位置上下文 -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>用于提供基于位置的智能协助</string>

<!-- 日历上下文 -->
<key>NSCalendarsUsageDescription</key>
<string>用于了解你的日程安排以提供帮助</string>

<!-- 相机特性 -->
<key>NSCameraUsageDescription</key>
<string>在 AI 助手请求时用于拍摄照片</string>
```

---

## 快速开始

### 基础集成

下面是将 NeuronKit 集成到应用的最小代码示例：

```swift
import SwiftUI
import NeuronKit
import SandboxSDK

@main
struct MyApp: App {
    @StateObject private var neuronManager = NeuronManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(neuronManager)
        }
    }
}

class NeuronManager: ObservableObject {
    private var runtime: NeuronRuntime?
    
    func initialize() {
        // 1. 创建配置
        let config = NeuronKitConfig(
            serverURL: URL(string: "wss://your-agent-server.com")!,
            deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "demo-device",
            userId: "user-123",
            storage: .persistent,
            contextProviders: [
                DeviceStateProvider(),
                NetworkStatusProvider(),
                TimeBucketProvider()
            ]
        )
        
        // 2. 初始化运行时
        runtime = NeuronRuntime(config: config)
        
        // 3. 注册应用特性
        setupFeatures()
    }
    
    private func setupFeatures() {
        guard let sandbox = runtime?.sandbox else { return }
        
        // 注册一个简单的消息特性
        let sendMessage = SandboxSDK.Feature(
            id: "send_message",
            name: "Send Message",
            description: "Send a message to contacts",
            category: .Native,
            path: "/messaging/send",
            requiredCapabilities: [.UIAccess],
            primitives: [.MobileUI(page: "/messages", component: "compose")]
        )
        
        _ = sandbox.registerFeature(sendMessage)
        
        // 设置安全策略
        _ = sandbox.setPolicy("send_message", SandboxSDK.Policy(
            requiresUserPresent: true,
            requiresExplicitConsent: true,
            sensitivity: .medium,
            rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 5)
        ))
    }
}
```

### 创建首个会话

```swift
struct ConversationView: View {
    @EnvironmentObject var neuronManager: NeuronManager
    @StateObject private var chatViewModel = ChatViewModel()
    
    var body: some View {
        VStack {
            // 消息列表
            ScrollView {
                LazyVStack {
                    ForEach(chatViewModel.messages) { message in
                        MessageBubble(message: message)
                    }
                }
            }
            
            // 输入区域
            HStack {
                TextField("Type a message...", text: $chatViewModel.inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Send") {
                    chatViewModel.sendMessage()
                }
            }
            .padding()
        }
        .onAppear {
            chatViewModel.startConversation(with: neuronManager.runtime)
        }
    }
}

class ChatViewModel: ObservableObject {
    @Published var messages: [NeuronMessage] = []
    @Published var inputText: String = ""
    
    private var conversation: ConvoSession?
    private var adapter: SimpleConvoAdapter?
    
    func startConversation(with runtime: NeuronRuntime?) {
        guard let runtime = runtime else { return }
        
        // 与 AI Agent 打开会话
        conversation = runtime.openConversation(agentId: UUID())
        
        // 创建并绑定 UI 适配器
        adapter = SimpleConvoAdapter(viewModel: self)
        conversation?.bindUI(adapter!)
    }
    
    func sendMessage() {
        guard !inputText.isEmpty else { return }
        
        Task {
            try await conversation?.sendMessage(inputText)
            await MainActor.run {
                inputText = ""
            }
        }
    }
}
```

---

## 理解上下文

上下文让 AI 助手真正具备“理解力”。NeuronKit 提供模块化的上下文提供者，捕获与用户场景相关的信息。

### 可用的上下文提供者

#### 基础提供者（安全默认）

```swift
let basicProviders = [
    DeviceStateProvider(),        // 电量、设备类型
    NetworkStatusProvider(),      // Wi-Fi、蜂窝信号
    TimeBucketProvider(),         // 上午/下午/晚上
    ThermalStateProvider(),       // 设备温度
    DeviceEnvironmentProvider()   // 区域、时区
]
```

#### 需权限的提供者

```swift
let advancedProviders = [
    LocationContextProvider(),    // 需要定位权限
    CalendarPeekProvider(),       // 需要日历权限
    BarometerProvider(),          // 需要运动权限
]
```

#### 推断型提供者

```swift
let smartProviders = [
    RoutineInferenceProvider(),   // 学习日常规律
    UrgencyEstimatorProvider(),   // 推断紧急程度
    ScreenStateProvider()         // 屏幕开关/方向
]
```

### 上下文的实际应用

上下文会随每条消息自动传递，帮助 AI Agent 提供更贴切的回复。

**场景**：用户说“我要迟到了”。

**无上下文**：

```json
{
  "message": "I'm running late",
  "context": {}
}
```

**有上下文**：

```json
{
  "message": "I'm running late", 
  "context": {
    "location": "Home",
    "nextCalendarEvent": "Team Meeting at 9:00 AM",
    "currentTime": "8:45 AM",
    "routeToOffice": "25 min with traffic"
  }
}
```

**AI 回复**：“我看到你 15 分钟后有团队会议。目前去办公室的路上交通拥堵，要不要帮你通知同事你将晚到 10 分钟？”

### 自定义上下文提供者

可为特定业务场景创建自定义提供者：

```swift
class ShoppingContextProvider: ContextProvider {
    var id: String { "shopping_context" }
    var updatePolicy: ContextUpdatePolicy { .onSend }
    
    func collect() async -> [String: String] {
        // 收集购物相关上下文
        let cart = await ShoppingCart.current()
        let recommendations = await getPersonalizedRecommendations()
        
        return [
            "cart_items": String(cart.itemCount),
            "cart_value": String(cart.totalValue),
            "has_recommendations": String(!recommendations.isEmpty),
            "user_tier": getCurrentUserTier()
        ]
    }
}

// 在配置中注册
let config = NeuronKitConfig(
    // ... 其他配置 ...
    contextProviders: [
        ShoppingContextProvider(),
        LocationContextProvider(),
        TimeBucketProvider()
    ]
)
```

---

## 沙箱与安全

沙箱确保 AI Agent 在获得适当的用户授权和安全控制后才能执行动作。

### 特性注册

```swift
func registerAppFeatures() {
    let sandbox = runtime.sandbox
    
    // 相机特性
    let cameraFeature = SandboxSDK.Feature(
        id: "take_photo", 
        name: "Take Photo",
        description: "Capture photos using device camera",
        category: .Native,
        path: "/camera/capture",
        requiredCapabilities: [.Camera, .UIAccess],
        primitives: [.CapturePhoto(params: nil)],
        argsSchema: FeatureArgsSchema(
            required: ["quality"],
            properties: [
                "quality": FeatureArgSpec(
                    type: .string,
                    description: "Photo quality", 
                    enumVals: ["low", "medium", "high"]
                )
            ]
        )
    )
    
    _ = sandbox.registerFeature(cameraFeature)
    
    // 设置安全策略  
    _ = sandbox.setPolicy("take_photo", SandboxSDK.Policy(
        requiresUserPresent: true,
        requiresExplicitConsent: true,
        sensitivity: .high,
        rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 3)
    ))
}
```

### 特性分类

- **`.Native`** —— 应用自身功能（导航、弹窗、媒体、通知等）。
- **`.MiniApp`** —— 嵌入式小程序路由与 JavaScript API。
- **`.IoTDevice`** —— 智能家居/设备控制与自动化。
- **`.External`** —— 调用第三方外部应用。
- **`.SystemApp`** —— 系统原生应用（如日历、邮件）。
- **`.Web`** —— 浏览器/网页运行时调用。

### 能力类型

- **`UIAccess`** —— 控制应用内导航、展示同意弹窗。
- **`Network`** —— 发起出站网络请求（HTTP、WebSocket 等）。
- **`DeviceControl`** —— 操控 IoT 外设与智能设备。
- **`Camera`** —— 拍摄照片或视频。
- **`Microphone`** —— 录音。
- **`AudioOutput`** —— 播放音频。
- **`Bluetooth`** —— 搜索并交互蓝牙设备。
- **`NFC`** —— 读写 NFC 标签。
- **`Sensors`** —— 访问设备传感器数据（气压、运动等）。

### 原语参考

SandboxSDK 针对移动场景提供的常见原语包括：

- **移动 UI 与导航**
  - `MobileUI { page, component? }`
  - `ShowDialog { title, message }`
- **MiniApp 控制**
  - `MiniApp { url_path, js_api[] }`
  - `InvokeJSAPI { api_name, params }`
- **媒体与硬件**
  - `CapturePhoto { params }`
  - `CaptureVideo { params }`
  - `RecordAudio { params }`
  - `PickImage {}` / `PickVideo {}`
- **文件系统**
  - `FileOp { path, op: Read|Write|Delete }`
- **网络与外部调用**
  - `NetworkOp { url, method, headers?, body? }`
  - `WebSocketConnect { url }`
  - `OpenUrl { url, app_hint? }`
- **系统特性与应用**
  - `ClipboardOp { action, text? }`
  - `ShowNotification { title, body }`
  - `CreateCalendarEvent { event }`
  - `ComposeEmail { to?, subject? }`
  - `GetCurrentLocation {}`
- **音频输出**
  - `PlayAudio { source, volume? }`
  - `StopAudio {}`
- **蓝牙/NFC**
  - `BluetoothScan { filters? }`
  - `BluetoothConnect { device_id }`
  - `BluetoothWrite { ... }`
  - `BluetoothRead { ... }`
  - `NfcReadTag {}` / `NfcWriteTag { payload }`
- **IoT 控制与传感器**
  - `DeviceControl { device_type, action, device_id? }`
  - `DevicePower { device_id, state }`
  - `SetDeviceMode { device_id, mode }`
  - `SetTemperature { device_id, value }`
  - `SetBrightness { device_id, value }`
  - `LockDevice { device_id }` / `UnlockDevice { device_id }`
  - `ReadSensor { sensor_type, device_id }`
  - `ExecuteScene { scene_id }`
  - `SyncDeviceGroup { group_id }`
- **跨域工具**
  - `ValidateUser { token }`
  - `CheckCapability { permission }`
  - `GetContext { key }`
  - `LogAudit { action, result }`

> **提示**：不同平台构建版本可用的原语可能不同。上线前请检查运行时日志和权限声明，确认可用性。

### 策略配置

策略用于控制特性何时、如何被使用：

```swift
let policy = SandboxSDK.Policy(
    requiresUserPresent: true,      // 用户需活跃使用设备
    requiresExplicitConsent: true,  // 显式同意弹窗
    sensitivity: .high,             // 安全等级
    rateLimit: SandboxSDK.RateLimit(unit: .hour, max: 10)
)
```

### 同意 UI 整合

在 UI 中处理同意请求：

```swift
class ConsentManager: ConvoUIAdapter {
    override func handleConsentRequest(_ request: ConsentRequest) {
        DispatchQueue.main.async {
            self.showConsentAlert(for: request)
        }
    }
    
    private func showConsentAlert(for request: ConsentRequest) {
        let alert = UIAlertController(
            title: "Permission Required",
            message: "Allow AI assistant to \(request.feature.name)?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Allow", style: .default) { _ in
            request.respond(granted: true)
        })
        
        alert.addAction(UIAlertAction(title: "Deny", style: .cancel) { _ in
            request.respond(granted: false)  
        })
        
        // Present alert...
    }
}
```

---

## 构建会话式 UI

NeuronKit 提供灵活的工具，让会话式体验与既有 UI 融合。

### 基本消息处理

```swift
import Combine

class ConversationViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    
    private var conversation: ConvoSession?
    private var messages: [NeuronMessage] = []
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupConversation()
    }
    
    private func setupConversation() {
        // 创建会话
        conversation = neuronRuntime.openConversation(agentId: UUID())
        
        // 订阅消息更新
        conversation?.messagesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                self?.messages = messages
                self?.tableView.reloadData()
                self?.scrollToBottom()
            }
            .store(in: &cancellables)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        guard let text = inputTextField.text, !text.isEmpty else { return }
        
        Task {
            try await conversation?.sendMessage(text)
            await MainActor.run {
                inputTextField.text = ""
            }
        }
    }
}
```

### 流式消息支持

在 AI 生成回复时显示“正在输入”指示：

```swift
class StreamingConvoAdapter: BaseConvoUIAdapter {
    weak var viewController: ConversationViewController?
    private var streamingPreviews: [UUID: String] = [:]
    
    override func handleStreamingChunk(_ chunk: InboundStreamChunk) {
        let messageId = chunk.messageId ?? UUID()
        let text = String(decoding: chunk.data, as: UTF8.self)
        
        // 累积流式文本
        streamingPreviews[messageId, default: ""] += text
        
        DispatchQueue.main.async {
            self.viewController?.showTypingIndicator(
                id: messageId,
                text: self.streamingPreviews[messageId] ?? ""
            )
        }
        
        if chunk.isFinal {
            // 最终消息到达后清理预览
            DispatchQueue.main.async {
                self.viewController?.hideTypingIndicator(id: messageId)
                self.streamingPreviews.removeValue(forKey: messageId)
            }
        }
    }
}
```

### 富消息组件

NeuronKit 支持渲染文本以外的丰富内容：

```swift
func renderMessage(_ message: NeuronMessage) -> UIView {
    let containerView = UIStackView()
    containerView.axis = .vertical
    containerView.spacing = 8
    
    // 文本内容
    if !message.content.isEmpty {
        let textLabel = UILabel()
        textLabel.text = message.content
        textLabel.numberOfLines = 0
        containerView.addArrangedSubview(textLabel)
    }
    
    // 附件内容
    for attachment in message.attachments {
        if attachment.mimeType.hasPrefix("image/") {
            let imageView = UIImageView()
            loadImage(from: attachment.url, into: imageView)
            containerView.addArrangedSubview(imageView)
        }
    }
    
    // 交互组件
    for component in message.components {
        switch component.type {
        case "button_group":
            let buttonStack = createButtonGroup(from: component)
            containerView.addArrangedSubview(buttonStack)
        case "form":
            let formView = createForm(from: component)
            containerView.addArrangedSubview(formView)
        default:
            break
        }
    }
    
    return containerView
}
```

### 多会话管理

支持多个并发会话：

```swift
class MultiSessionManager: ObservableObject {
    @Published var activeSessions: [ConvoSession] = []
    private let runtime: NeuronRuntime
    
    init(runtime: NeuronRuntime) {
        self.runtime = runtime
    }
    
    func createSession(for agentType: AgentType) -> ConvoSession {
        let session = runtime.openConversation(agentId: agentType.uuid)
        activeSessions.append(session)
        return session
    }
    
    func closeSession(_ session: ConvoSession) {
        session.close()
        activeSessions.removeAll { $0.id == session.id }
    }
}

// SwiftUI 使用示例
struct MultiChatView: View {
    @StateObject private var sessionManager = MultiSessionManager(runtime: neuronRuntime)
    @State private var selectedSession: ConvoSession?
    
    var body: some View {
        NavigationSplitView {
            // 会话列表侧边栏
            List(sessionManager.activeSessions, id: \ .id) { session in
                SessionRow(session: session)
                    .onTapGesture {
                        selectedSession = session
                    }
            }
            .navigationTitle("Conversations")
        } detail: {
            // 默认选中会话的聊天界面
            if let session = selectedSession {
                ChatView(session: session)
            } else {
                Text("Select a conversation")
            }
        }
    }
}
```

---

## 高级特性

### 自定义特性实现

针对应用特定逻辑实现 Feature：

```swift
class CustomFeatureHandler {
    func handleCameraCapture(args: [String: Any]) -> FeatureResult {
        guard let quality = args["quality"] as? String else {
            return .failure("Missing quality parameter")
        }
        
        DispatchQueue.main.async {
            self.presentCameraInterface(quality: quality)
        }
        
        return .success("Camera opened")
    }
    
    func handleSendMessage(args: [String: Any]) -> FeatureResult {
        guard let recipient = args["recipient"] as? String,
              let message = args["message"] as? String else {
            return .failure("Missing required parameters")
        }
        
        // 实现发送消息逻辑
        MessageService.shared.send(message, to: recipient) { success in
            if success {
                NotificationCenter.default.post(
                    name: .messageWasSent,
                    object: ["recipient": recipient, "message": message]
                )
            }
        }
        
        return .success("Message sent to \(recipient)")
    }
}
```

### 上下文感知特性

构建根据上下文自适应的 Feature：

```swift
class LocationAwareFeature: ContextProvider {
    var id: String { "location_actions" }
    var updatePolicy: ContextUpdatePolicy { .onSend }
    
    func collect() async -> [String: String] {
        let location = await LocationManager.shared.getCurrentLocation()
        let nearbyPOIs = await findNearbyPointsOfInterest(location)
        
        return [
            "current_location": location.description,
            "poi_count": String(nearbyPOIs.count)
        ]
    }
}
```

```swift
// 根据上下文注册与位置相关的特性
func registerLocationFeatures() {
    // 仅在附近存在餐厅时注册点餐能力
    if contextHasNearbyRestaurants() {
        let foodFeature = SandboxSDK.Feature(
            id: "order_food",
            name: "Order Food",
            description: "Order food from nearby restaurants",
            category: .External,
            path: "/food/order",
            requiredCapabilities: [.Network, .UIAccess],
            primitives: [.OpenUrl(url: "foodapp://order", app_hint: "FoodDelivery")]
        )
        
        _ = runtime.sandbox.registerFeature(foodFeature)
    }
}
```

### 内存与持久化

通常应用无需直接读取会话历史，NeuronKit 运行时会自动管理。但若需要更灵活的控制，可以通过快照 API 访问本地历史记录：

```swift
class ConversationManager {
    private let runtime: NeuronRuntime
    
    init(runtime: NeuronRuntime) {
        self.runtime = runtime
    }
    
    func getConversationHistory(sessionId: UUID, limit: Int = 50) -> [NeuronMessage] {
        return runtime.messagesSnapshot(
            sessionId: sessionId,
            limit: limit,
            before: nil
        )
    }
    
    func searchConversations(query: String) -> [NeuronMessage] {
        // 在本地存储的会话中执行搜索
        let allSessions = getAllSessionIds()
        var results: [NeuronMessage] = []
        
        for sessionId in allSessions {
            let messages = runtime.messagesSnapshot(sessionId: sessionId, limit: 100, before: nil)
            let matches = messages.filter {
                $0.content.localizedCaseInsensitiveContains(query)
            }
            results.append(contentsOf: matches)
        }
        
        return results
    }
    
    func exportConversation(sessionId: UUID) -> Data? {
        let messages = runtime.messagesSnapshot(sessionId: sessionId, limit: 1000, before: nil)
        
        let export = ConversationExport(
            sessionId: sessionId,
            messages: messages,
            exportDate: Date()
        )
        
        return try? JSONEncoder().encode(export)
    }
}
```

---

## 最佳实践

### 安全指引

1. **最小权限原则**

   ```swift
   // 推荐：仅请求必要的能力
   let feature = SandboxSDK.Feature(
       id: "view_calendar",
       requiredCapabilities: [.UIAccess],
       // ...
   )
   
   // 避免：请求与功能无关的能力
   let badFeature = SandboxSDK.Feature(
       id: "view_calendar",
       requiredCapabilities: [.UIAccess, .Camera, .Microphone],
       // ...
   )
   ```

2. **上下文最小化**

   ```swift
   // 推荐：仅收集当前任务需要的上下文
   class FocusedContextProvider: ContextProvider {
       func collect() async -> [String: String] {
           return [
               "current_screen": getCurrentScreen(),
               "user_activity": getCurrentActivity()
           ]
       }
   }
   
   // 避免：输出与任务无关或敏感的数据
   class VerboseContextProvider: ContextProvider {
       func collect() async -> [String: String] {
           return [
               "current_screen": getCurrentScreen(),
               "all_contacts": getAllContacts(),
               "message_history": getMessageHistory(),
               "browsing_history": getBrowsingHistory()
           ]
       }
   }
   ```

3. **频率限制**

   ```swift
   let policy = SandboxSDK.Policy(
       requiresUserPresent: true,
       requiresExplicitConsent: true,
       sensitivity: .high,
       rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 3)
   )
   ```

### 性能优化

1. **懒加载上下文**

   ```swift
   class OptimizedContextProvider: ContextProvider {
       var updatePolicy: ContextUpdatePolicy { .onDemand }
       
       func collect() async -> [String: String] {
           // 仅在确有需要时采集
           guard shouldCollectContext() else { return [:] }
           
           return await expensiveContextCollection()
       }
   }
   ```

2. **消息分页**

   ```swift
   func loadMoreMessages() {
       let oldestMessage = messages.first
       let earlierMessages = runtime.messagesSnapshot(
           sessionId: currentSessionId,
           limit: 20,
           before: oldestMessage?.timestamp
       )
       
       messages.insert(contentsOf: earlierMessages, at: 0)
   }
   ```

3. **高效 UI 更新**

   ```swift
   // 使用增量更新而非完整重载
   conversation?.messagesPublisher(isDelta: true, initialSnapshot: .full)
       .sink { [weak self] deltaMessages in
           self?.applyMessageDelta(deltaMessages)
       }
   ```

### 错误处理

1. **优雅降级**

   ```swift
   func initializeNeuronKit() {
       do {
           runtime = try NeuronRuntime(config: config)
       } catch {
           // 回退到传统 UI
           useTraditionalInterface()
           logError("NeuronKit initialization failed: \(error)")
       }
   }
   ```

### 用户体验

1. **循序渐进地开放能力**

   ```swift
   func registerBasicFeatures() {
       let simpleFeatures = ["send_message", "take_photo", "set_reminder"]
       simpleFeatures.forEach { registerFeature($0) }
   }
   
   func registerAdvancedFeatures() {
       let advancedFeatures = ["schedule_meeting", "analyze_document", "control_smart_home"]
       advancedFeatures.forEach { registerFeature($0) }
   }
   ```

2. **提供上下文相关的帮助**

   ```swift
   func showContextualHelp() -> String {
       let availableFeatures = runtime.sandbox.getRegisteredFeatures()
       let contextualHelp = generateHelpText(for: availableFeatures, context: currentContext)
       return contextualHelp
   }
   ```

---

## 故障排查

### 常见问题

#### 1. 特性无法触发

- **问题**：Agent 尝试使用特性但没有任何响应。
- **解决方案**：检查特性注册与策略配置。

```swift
// 调试特性注册
let registeredFeatures = runtime.sandbox.getRegisteredFeatures()
print("Registered features: \(registeredFeatures.map { $0.id })")

// 校验特性配置
if let feature = registeredFeatures.first(where: { $0.id == "problematic_feature" }) {
    print("Feature found: \(feature)")
    
    if let policy = runtime.sandbox.getPolicy(feature.id) {
        print("Policy: \(policy)")
    } else {
        print("No policy set for feature \(feature.id)")
    }
}
```

#### 2. 上下文未更新

- **问题**：AI 助手似乎不了解当前场景。
- **解决方案**：确认上下文提供者已激活。

```swift
// 查看当前注册的上下文提供者
let config = runtime.config
print("Context providers: \(config.contextProviders.map { $0.id })")

// 手动采集以验证输出
Task {
    for provider in config.contextProviders {
        let context = await provider.collect()
        print("Provider \(provider.id): \(context)")
    }
}
```

#### 3. 权限被拒导致失败

- **问题**：特性执行时提示权限错误。
- **解决方案**：核查 iOS 系统权限与能力映射。

```swift
import AVFoundation
import CoreLocation

func checkPermissions() {
    let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
    print("Camera permission: \(cameraStatus)")
    
    let locationManager = CLLocationManager()
    let locationStatus = locationManager.authorizationStatus
    print("Location permission: \(locationStatus)")
    
    if cameraStatus == .notDetermined {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            print("Camera permission granted: \(granted)")
        }
    }
}
```

#### 4. 网络连接异常

- **问题**：消息无法发送/接收。
- **解决方案**：单独测试网络适配器的连通性。

```swift
class NetworkTestAdapter: BaseNetworkAdapter {
    override func start() {
        testConnection()
    }
    
    private func testConnection() {
        let url = URL(string: "https://httpbin.org/get")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network test failed: \(error)")
                self.updateState(.error(error.localizedDescription))
            } else {
                print("Network test passed")
                self.updateState(.connected)
            }
        }.resume()
    }
}
```

### 调试工具

#### 开启详细日志

```swift
// 在 DEBUG 构建开启详细日志
#if DEBUG
let config = NeuronKitConfig(
    // ... 其他配置 ...
    loggingLevel: .verbose
)
#endif
```

#### 消息检查

```swift
// 打印所有消息，便于排查
conversation?.messagesPublisher
    .sink { messages in
        for message in messages {
            print("Message: \(message.content)")
            print("Metadata: \(message.metadata ?? [:])")
            print("Components: \(message.components)")
        }
    }
```

#### 上下文调试

```swift
// 自定义调试用上下文提供者
class DebugContextProvider: ContextProvider {
    var id: String { "debug_context" }
    var updatePolicy: ContextUpdatePolicy { .onSend }
    
    func collect() async -> [String: String] {
        let context = [
            "debug_mode": "enabled",
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "device_model": UIDevice.current.model,
            "ios_version": UIDevice.current.systemVersion
        ]
        
        print("Debug context: \(context)")
        return context
    }
}
```

### 获取帮助

1. **参考示例代码**：查看 `finclip-neuron` 仓库中的 `examples/` 目录。
2. **查阅 API 文档**：利用 SDK 的内联注释和文档注解。
3. **加入社区**：与其他开发者交流经验、共享最佳实践。
4. **反馈问题**：在提交 Issue 时附上错误信息与复现步骤。

---

## 总结

NeuronKit 让传统 iOS 应用以最小改动升级为智能、可会话的体验。关键步骤包括：

1. **安装**：通过 Swift Package Manager 引入 SDK。
2. **配置**：设定上下文提供者与安全策略。
3. **注册**：暴露 AI 可调用的应用特性。
4. **构建**：使用提供的适配器搭建会话式 UI。
5. **连接**：通过网络适配器与云端 Agent 服务交互。

先从最基础的能力入手，再根据用户需求逐步扩展功能。模块化架构帮助你以渐进方式增加能力，同时维持安全与用户信任。

更多示例与高级用法请参阅 `finclip-neuron` 仓库，并加入开发者社区。

祝开发顺利！🚀

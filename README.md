# FinClip Neuron — Developer Guide

## 1. Introduction

FinClip Neuron provides a runtime and SDKs to build agent-driven experiences safely on mobile and desktop. It combines:

- A capabilities-based sandbox with fine‑grained policies (least privilege, consent, rate limits).
- A conversation runtime (NeuronKit) that turns agent proposals into safe, auditable actions.
- Pluggable adapters for networking (bring your own transport) and UI (bridge your UI to the runtime).
- Built-in message storage with persistence enabled by default (configurable).

This repository publishes NeuronKit and example apps, and hosts binary XCFrameworks for SandboxSDK and convstorelib.

- Repo path to explore:
  - `finclip-neuron/examples/custom/` — a CLI example you can run with `swift run`.

---

## 2. Core Concepts

- **Features → Capabilities → Primitives**
  - A Feature describes a high-level function (e.g., "Open Camera").
  - Each Feature requires one or more Capabilities (e.g., UI access, device sensor access).
  - Capabilities are exercised by concrete Primitives (e.g., `MobileUI(page:"/camera", component:"camera")`).

- **PDP (Policy Decision Point)**
  - Evaluates whether a proposed action is allowed. Inputs include: user presence, explicit consent, sensitivity, rate limits, historical usage.

- **PEP (Policy Enforcement Point)**
  - Enforces the PDP decision in the app runtime. If denied, the action is blocked. If allowed with consent, it prompts UI.

- **Context**
  - Device Context: device type, timezone, network/battery, etc.
  - Application/Scenario Context: app-specific state, current screen/route, business metadata.

- **Feature Invocation (Tools)**
  - Agents propose directives referencing Feature IDs and typed args. The runtime validates arguments (FeatureArgsSchema) and policies before invoking primitives.

---

## Architecture Overview

```mermaid
flowchart LR
  subgraph App
    UI[Your UI]
    ConvoUI[ConvoUI Adapter]
    Runtime[NeuronRuntime]
    Sandbox[Sandbox (PDP/PEP)]
  end

  Agent[(Agent Service)]

  UI -->|User input/events| ConvoUI
  ConvoUI -->|binds session, forwards user intent| Runtime
  Runtime --> Sandbox
  Sandbox -->|decision: allow/ask/deny| Runtime
  Runtime -->|feature proposals / messages| ConvoUI
  ConvoUI -->|consent UI when needed| UI

  Runtime <--> |bytes| Net[NetworkAdapter]
  Net <--> Agent
```

Key points:

- **ConvoUI Adapter** bridges your UI and the runtime (typical apps do not call `sendMessage` directly).
- **Sandbox** evaluates policy (PDP) and the app enforces it (PEP) by showing consent and shaping execution.
- **NetworkAdapter** is pluggable (WebSocket/HTTP/custom) and transports messages to your agent backend.

---

## 3. Installation and Dependencies

Add the package to your SwiftPM manifest:

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

Binary artifacts provided by this repo:

- `NeuronKit.xcframework`
- `SandboxSDK.xcframework`
- `convstorelib.xcframework`

---

## 4. Quick Start (Primary integration steps)

The primary SDK integration sequence is:

1) Create a configuration.
2) Initialize the runtime.
3) Get a reference to the sandbox.
4) Register features and set policies.

Setting network and ConvoUI adapters is optional/advanced. Applications typically do not call `runtime.sendMessage` directly; your chosen UI/adapter integration will drive messaging.

Minimal integration snippet:

```swift
import NeuronKit
import SandboxSDK

// 1) Configuration
// Storage is persistent by default; override with `storage: .inMemory` for tests/demos
let config = NeuronKitConfig(
  serverURL: URL(string: "wss://agent.example.com")!,
  deviceId: "demo-device",
  userId: "demo-user",
  storage: .persistent // default; use .inMemory for tests
)

// 2) Initialize runtime
let runtime = NeuronRuntime(config: config)

// 3) Get sandbox reference
let sandbox = runtime.sandbox

// 4) Register Features and set Policies
let camera = SandboxSDK.Feature(
  id: "open_camera",
  name: "Open Camera",
  description: "Access device camera for photos",
  category: .Native,
  path: "/camera",
  requiredCapabilities: [.UIAccess],
  primitives: [.MobileUI(page: "/camera", component: "camera")]
)
_ = sandbox.registerFeature(camera)

_ = sandbox.setPolicy("open_camera", SandboxSDK.Policy(
  requiresUserPresent: true,
  requiresExplicitConsent: true,
  sensitivity: .medium,
  rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 10)
))

// Optional (advanced): configure adapters
// runtime.setNetworkAdapter(MyWebSocketNetworkAdapter(url: URL(string: "wss://...")!))

// Open a conversation when your app is ready to converse (fluent API)
let convo = runtime.openConversation(agentId: UUID())
// Optionally bind a UI adapter for streaming messages
// convo.bindUI(MyConvoAdapter())
```

To see a working end‑to‑end demo (with a simple CLI adapter and loopback networking), run:

```bash
cd finclip-neuron/examples/custom
swift run
```

---

## 5. Sandbox Usage (Typed API, Manifest, PDP)

- **Typed API (FeatureArgsSchema)**
  - Define required/optional args and constraints for each Feature.
  - The runtime validates agent-provided args against the schema before invocation.

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
  - You can bundle features/schemas/capabilities in a manifest and apply it at startup.

- **Policies & PDP flow**
  - Set per-feature policies with sensitivity, rate limits, and consent:

```swift
_ = sandbox.setPolicy("open_camera", SandboxSDK.Policy(
  requiresUserPresent: true,
  requiresExplicitConsent: true,
  sensitivity: .medium,
  rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 10)
))
```

- **Context during evaluation**
  - Provide Device Context (timezone, device type, etc.) and App Context (current route, scenario) with each message. PDP considers these in decisions.

---

## 6. Supported Features, Capabilities, and Primitives (Reference)

Below is a reference list you can use directly without external documents.

### Feature Categories

- `Native` — App-native functionality (navigation, dialogs, media, notifications, etc.)
- `MiniApp` — Embedded micro-app/miniapp routes and JS APIs
- `IoTDevice` — Smart home/device control and automations
- `External` — Delegation to external third-party apps
- `SystemApp` — OS-provided apps (Calendar, Mail, etc.)
- `Web` — Browser/web runtime invocations

### Capabilities

- `UIAccess`
- `Network`
- `DeviceControl` (IoT)
- `Camera`
- `Microphone`
- `AudioOutput`
- `Bluetooth`
- `NFC`
- `Sensors`

### Primitives (common subset)

Mobile UI & Navigation:

- `MobileUI { page, component? }`
- `ShowDialog { title, message }`

MiniApp control:

- `MiniApp { url_path, js_api[] }`
- `InvokeJSAPI { api_name, params }`

Media & hardware:

- `CapturePhoto { params }`
- `CaptureVideo { params }`
- `RecordAudio { params }`
- `PickImage {}`
- `PickVideo {}`

File system:

- `FileOp { path, op: Read|Write|Delete }`

Network & external:

- `NetworkOp { url, method, headers?, body? }`
- `WebSocketConnect { url }`
- `OpenUrl { url, app_hint? }`

System features & apps:

- `ClipboardOp { action, text? }`
- `ShowNotification { title, body }`
- `CreateCalendarEvent { event }`
- `ComposeEmail { to?, subject? }`
- `GetCurrentLocation {}`

Audio output:

- `PlayAudio { source, volume? }`, `StopAudio {}`

Bluetooth/NFC:

- `BluetoothScan { filters? }`, `BluetoothConnect { device_id }`, `BluetoothWrite { ... }`, `BluetoothRead { ... }`
- `NfcReadTag {}`, `NfcWriteTag { payload }`

IoT control & sensors:

- `DeviceControl { device_type, action, device_id? }`
- `DevicePower { device_id, state }`
- `SetDeviceMode { device_id, mode }`
- `SetTemperature { device_id, value }`
- `SetBrightness { device_id, value }`
- `LockDevice/UnlockDevice { device_id }`
- `ReadSensor { sensor_type, device_id }`
- `ExecuteScene { scene_id }`, `SyncDeviceGroup { group_id }`

Common cross-domain:

- `ValidateUser { token }`, `CheckCapability { permission }`, `GetContext { key }`, `LogAudit { action, result }`

Note: Implementations may enable a subset per platform.

---

## 7. Network Adapters (for custom implementation)

Implement the `NetworkAdapter` protocol to bring your own transport.

Required surface:

- Properties: `onOutboundData: ((Data) -> Void)?`, `onStateChange: ((NetworkState) -> Void)?`, `inboundDataHandler: ((Data) -> Void)?`
- Publishers: `inbound: AnyPublisher<Data, Never>`, `state: AnyPublisher<NetworkState, Never>`
- Methods: `start()`, `stop()`, `send(_ data: Data)`

Guidance:

- Call `onStateChange?` as you transition through `.connecting`, `.connected`, `.reconnecting`, `.disconnected`, `.error`.
- Call `inboundSubject.send(data)` and `inboundDataHandler?(data)` when bytes arrive from the server.
- Calling `onOutboundData?(data)` is optional for observability. Avoid it in loopback/mock paths to prevent re-entrancy.

See examples:

- `examples/custom/Sources/custom/adapters/WebSocketNetworkAdapter.swift`
- `examples/custom/Sources/custom/adapters/URLSessionHTTPAdapter.swift`
- `examples/custom/Sources/custom/adapters/LoopbackNetworkAdapter.swift` (synthetic, no real network)

---

## 8. Storage configuration (persistence)

NeuronKit uses a local message store to persist conversation history. By default, persistence is enabled. Configure it when creating `NeuronKitConfig`:

```swift
let config = NeuronKitConfig(
  serverURL: URL(string: "wss://agent.example.com")!,
  deviceId: "demo-device",
  userId: "demo-user",
  storage: .persistent // default
)
// For tests/demos where persistence is not needed:
let inMemory = NeuronKitConfig(
  serverURL: URL(string: "wss://agent.example.com")!,
  deviceId: "demo-device",
  userId: "demo-user",
  storage: .inMemory
)
```

- Use the publisher `runtime.messagesPublisher(sessionId:)` (or `convo.messagesPublisher`) to stream history and updates.
- Use `runtime.messagesSnapshot(sessionId:limit:before:)` to fetch one-shot paginated history for list previews or initial render.

## 9. ConvoUI Adapters (for custom implementation)

A ConvoUI adapter bridges your UI with NeuronKit.

- It forwards user input into the runtime (so your app does not call `sendMessage` directly in typical integrations).
- It renders inbound messages and system notifications.
- It shows consent prompts when PDP requires explicit approval.

> Attach vs Resume (short guide)
>
> - Use `attachConversation(sessionId:)` to obtain a read-only handle for lists and previews. You can still bind a UI to stream history via `messagesPublisher`, but live events won’t flow until resumed.
> - Use `resumeConversation(sessionId:agentId:)` to ensure the session is live (workers active) and bind a UI for history + live updates.
> - For screen navigation, prefer `convo.unbindUI()` on disappear and `convo.bindUI(...)` on appear; call `convo.close()` only when ending the conversation.

### Session-Centric Binding (Recommended)

The new approach allows you to bind/unbind UI adapters to specific sessions dynamically:

```swift
// Open a conversation
let convo = runtime.openConversation(agentId: UUID())

// Bind UI adapter to this specific conversation
let adapter = MyConvoAdapter()
convo.bindUI(adapter)

// Later: unbind when UI is no longer active (e.g., view disappears)
convo.unbindUI()

// Close conversation when done
convo.close()
```

### Multiple Sessions Support

You can now have multiple active sessions with different UI adapters:

```swift
// Create conversations for different contexts
let supportConvo = runtime.openConversation(agentId: UUID())
let salesConvo = runtime.openConversation(agentId: UUID())

// Bind different adapters to each conversation
supportConvo.bindUI(supportAdapter)
salesConvo.bindUI(salesAdapter)

// Later: close conversations when done
supportConvo.close()
salesConvo.close()
```

Examples:

- `examples/custom/Sources/custom/CliConvoAdapter.swift`
- `examples/custom/Sources/custom/CustomDemoApp.swift`
- `examples/ios-sample/Sources/App/MultiSessionExample.swift`

---

## License

See LICENSE in the repository.

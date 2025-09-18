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

## Declaring Arguments with the Typed API

The typed `Feature` model now supports declaring required arguments via `FeatureArgsSchema`. This maps to the PDP's `args_schema` and is surfaced to agents via `exportFeatureOverviews()`.

Example:

```swift
import SandboxSDK

let exportFeature = SandboxSDK.Feature(
  id: "exportPortfolioCSV",
  name: "Export Portfolio CSV",
  description: "Export positions as CSV",
  category: .Native,
  path: "/export",
  requiredCapabilities: [.Network],
  primitives: [
    .NetworkOp(url: "https://api.example.com/export", method: .GET, headers: ["Accept": "text/csv"], body: nil)
  ],
  argsSchema: FeatureArgsSchema(required: ["format", "date_from", "date_to"]) // ← new
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

Note:

- Ensure your app depends on a SandboxSDK version that includes `FeatureArgsSchema` (and updated `Feature` initializers).
- For more advanced schemas (types, enums), you can still use manifest/dictionary registration.

---

## Typed vs. Manifest Registration (Side-by-side)

Below is the same feature registered in two ways: typed API and manifest/dictionary.

### 1) Typed API (concise, compile-time model)

```swift
import SandboxSDK

let feature = SandboxSDK.Feature(
  id: "open_payment",
  name: "Open Payment",
  description: "Opens payment screen",
  category: .Native,
  path: "/payment",
  requiredCapabilities: [.UIAccess],
  primitives: [.MobileUI(page: "/payment", component: nil)],
  argsSchema: FeatureArgsSchema(required: ["amount", "currency"]) // minimal required-keys
)
_ = SandboxSDK.registerFeature(feature)
_ = SandboxSDK.setPolicy("open_payment", SandboxSDK.Policy(
  requiresUserPresent: true,
  requiresExplicitConsent: true,
  sensitivity: .medium,
  rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 5)
))
```

### 2) Manifest/Dictionary (full schema flexibility)

```swift
let ok = SandboxSDK.applyManifest([
  "features": [[
    "id": "open_payment",
    "name": "Open Payment",
    "category": "Native",
    "path": "/payment",
    "required_capabilities": ["UIAccess"],
    "primitives": [["type": "MobileUI", "page": "/payment"]],
    // Richer schema possible (types/enums/patterns)
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

Use the typed API for ergonomics and compile-time structure. Switch to manifest when you need richer validation.

---

## Should FeatureArgsSchema include types/enums/patterns?

Short answer: it can be useful, even if agent-provided values are strings.

- Validation: PDP can validate strings against expected shapes (numeric, enum members, patterns) and reject/ask early.
- Agent guidance: exported schemas help agents produce better values (tooling prompts, UI forms).
- Interop: downstream host code can safely parse/convert strings (e.g., to Decimal) when the schema promises numeric.

However, adding a fully-typed schema increases API surface and maintenance cost. A pragmatic approach is:

- Keep typed API minimal (required keys) for now.
- Use manifest/dictionary when you need types/enums/patterns or custom validators.
- If your app frequently relies on strict validation, consider incrementally extending `FeatureArgsSchema` with optional annotations like `types`, `enums`, or `pattern`.

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
let runtime = NeuronRuntime(config: config)
```

### 2. Start a Conversation Session

```swift
let sessionId = UUID()
runtime.openSession(sessionId: sessionId, agentId: UUID())
```

### 3. Send Messages

```swift
// Send text messages
try? await runtime.sendMessage(
  sessionId: sessionId,
  text: "Hello, assistant!"
)

// Send with context (optional)
try? await runtime.sendMessage(
  sessionId: sessionId,
  text: "Help me with my order",
  context: ["screen": "orders", "user_action": "support"]
)
```

That's it! Your app now has conversational AI capabilities.

---

## Core Concepts

- **NeuronRuntime**: The central object you create with `NeuronKitConfig`. It manages sessions, messaging, sandbox policies, and network adapters.
- **ConvoUIAdapter**: Your app's bridge between UI and the runtime. It receives conversation updates, displays messages, and handles consent prompts.
- **Sandbox**: A policy engine that governs what features the agent can use, under what conditions (user present, consent, rate limits, sensitivity), and with full auditability.
- **NetworkAdapter**: Pluggable transport to connect to your agent service (WebSocket/HTTP/custom). You can swap adapters without changing your business logic.
- **Sessions & Messages**: Create a `sessionId` per conversation. Send user text and optional context; receive agent messages and directives through your adapter.

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
    try await runtime.sendMessage(sessionId: sessionId, text: text)
  } catch {
    print("Failed to send message: \(error)")
    // Handle error (show alert, retry, etc.)
  }
}
```

---

## Sandbox: Register Features and Set Policies

NeuronKit ships with a powerful in-app Sandbox to control what agent actions are allowed. You can register app features, define policies (e.g., user presence, explicit consent, rate limits), and then export those features to the agent at runtime.

The following snippet shows:

- Registering a feature (`open_payment`)
- Setting a policy (requires user present + explicit consent + rate limit)
- Wiring a UI adapter to handle consent requests and messages

```swift
import NeuronKit
import SandboxSDK

// 1) Create runtime and (optionally) your UI adapter
let config = NeuronKitConfig(
  serverURL: URL(string: "wss://api.example.com")!,
  deviceId: "demo-device",
  userId: "demo-user"
)
let runtime = NeuronRuntime(config: config)

// 2) Register a feature
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

// 3) Set a policy for that feature
_ = runtime.sandbox.setPolicy("open_payment", SandboxSDK.Policy(
  requiresUserPresent: true,
  requiresExplicitConsent: true,
  sensitivity: .medium,
  rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 5)
))

// 4) (Optional) Attach a ConvoUI adapter to handle consent UI and message updates
// runtime.setConvoUIAdapter(yourAdapter)

// 5) Start a session – the runtime will automatically expose registered features
let sessionId = UUID()
runtime.openSession(sessionId: sessionId, agentId: UUID())
```

Notes:

- When the agent proposes an action (e.g., `open_payment`), the Sandbox PDP will evaluate the policy. If explicit consent is required, your `ConvoUIAdapter` will receive `handleConsentRequest(...)` and can present UI to the user.

### Consent UI in your ConvoUIAdapter

Implement a minimal adapter to surface consent prompts to users and to forward their decision back to the runtime:

```swift
final class MyConvoAdapter: BaseConvoUIAdapter {
  override func handleMessages(_ messages: [NeuronMessage]) {
    // Update your UI (chat view) with latest messages
  }

  override func handleConsentRequest(
    proposalId: UUID,
    sessionId: UUID,
    feature: String,
    args: [String: Any]
  ) {
    // Present your UI (alert/sheet) asking user to approve/deny
    let userApproved = true // result from your UI
    context?.userProvidedConsent(messageId: proposalId, approved: userApproved)
  }

  override func didBind(sessionId: UUID) {
    // Called when adapter is bound to a session
  }
}

// Usage
let adapter = MyConvoAdapter()
runtime.setConvoUIAdapter(adapter)
```

---

## Network Adapters: Build and Use Your Own

NeuronKit talks to your agent server via a `NetworkAdapter`. The SDK includes these reference adapters out of the box:

- `WebSocketNetworkAdapter` (mock WebSocket for local testing)
- `URLSessionHTTPAdapter` (HTTP POST + polling)
- `StarscreamWebSocketAdapter` (interface for Starscream-based WebSocket)
- `LoopbackNetworkAdapter` (echo + directive simulation for demos)

### Using built-in adapters

- WebSocket (mock)

```swift
let ws = WebSocketNetworkAdapter(url: URL(string: "wss://your-server/ws"))
let runtime = NeuronRuntime(config: config)
runtime.setNetworkAdapter(ws)
```

- HTTP (URLSession)

```swift
let http = URLSessionHTTPAdapter(
  baseURL: URL(string: "https://api.example.com")!,
  pollingInterval: 2.0
)
let runtime = NeuronRuntime(config: config)
runtime.setNetworkAdapter(http)
```

- Starscream (3rd-party WebSocket)

```swift
// Requires adding Starscream dependency and enabling the real implementation
let ws = StarscreamWebSocketAdapter(url: URL(string: "wss://api.example.com/ws")!)
let runtime = NeuronRuntime(config: config)
runtime.setNetworkAdapter(ws)
```

- Loopback (demo/testing)

```swift
let loop = LoopbackNetworkAdapter()
let runtime = NeuronRuntime(config: config)
runtime.setNetworkAdapter(loop)
```

### Implement your own adapter

To build a custom adapter, subclass `BaseNetworkAdapter` and implement three key pieces:

1) Connection lifecycle – override `start()` and `stop()` and call `updateState(...)` appropriately
2) Outbound send – override `sendToNetworkComponent(_:)` and forward bytes to your network
3) Inbound receive – call `handleInboundData(...)` with raw bytes (Data or String) when messages arrive

Skeleton:

```swift
import Foundation

final class MyNetworkAdapter: BaseNetworkAdapter {
  private var isStarted = false

  override func start() {
    guard !isStarted else { return }
    isStarted = true
    updateState(.connecting)
    // Connect to your transport...
    updateState(.connected)
  }

  override func stop() {
    isStarted = false
    // Tear down connection
    updateState(.disconnected)
  }

  override func sendToNetworkComponent(_ data: Any) {
    guard let data = data as? Data, isStarted else { return }
    // Write bytes to your transport
  }

  // If your library needs string/binary conversion, override these:
  override func convertOutboundData(_ data: Data) -> Any { data }
  override func convertInboundData(_ data: Any) -> Data? {
    if let d = data as? Data { return d }
    if let s = data as? String { return s.data(using: .utf8) }
    return nil
  }

  // When data arrives from the network, call:
  func onBytesFromNetwork(_ data: Data) {
    handleInboundData(data)
  }
}
```

Tip: Start with `LoopbackNetworkAdapter` to validate your app wiring without a server; then switch to HTTP or WebSocket.

### Adapter state and error handling

All adapters should report connectivity via `updateState(...)` with:

- `.connecting` → `.connected` → `.disconnected`
- `.reconnecting` for transient issues
- `.error(NetworkError)` for fatal/diagnostic cases

See `URLSessionHTTPAdapter` for a robust implementation that handles connectivity tests, polling, and backoff on failures.

---

## Supported Capabilities and Primitives

This SDK follows the universal Sandbox spec for declaring app Features with required Capabilities and executable Primitives.

### Supported Capabilities (current)

- `UIAccess`
- `Network`
- `DeviceControl` (IoT)
- `Camera`
- `Microphone`
- `AudioOutput`
- `Bluetooth`
- `NFC`
- `Sensors`

Reference: `sandbox/docs/spec.md` section 3.2 (CapabilityType).

### Supported Primitives (current subset)

Mobile UI & Navigation:

- `MobileUI { page, component? }`
- `ShowDialog { title, message }`

Mini-App control:

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

Note: Implementations may enable a subset per platform. See `sandbox/docs/spec.md` for the complete roadmap list.

For the most complete, always up-to-date list used by this SDK, also see `neuronkit/README.md` ("Supported Capabilities and Primitives").

---

## Supported Feature Categories

Features are grouped into categories to reflect where/how they execute (see `sandbox/docs/spec.md` and `sandbox/universal/src/types.rs`, FeatureCategory):

- `Native` – App-native functionality (navigation, dialogs, media, notifications, etc.)
- `MiniApp` – Embedded micro-apps/mini-app routes and their JS APIs
- `IoTDevice` – Smart home / device control and automations
- `External` – Delegation to external third-party apps
- `SystemApp` – OS-provided apps (Calendar, Mail, etc.)
- `Web` – Browser/web runtime invocations

You declare the category on each `Feature` (typed API supports: `.Native | .MiniApp | .IoTDevice | .External | .SystemApp | .Web`).

Tip: Categories do not replace capabilities. Always specify required capabilities (e.g., `UIAccess`, `Network`) and map to appropriate primitives.

---

## Policy Flow (PDP pattern)

The iOS layer is a PDP (Policy Decision Point). Your app is the PEP (Policy Enforcement Point):

1) Initialize and apply a manifest (or register dynamically), including features, required capabilities, and policies.
2) Call `evaluateFeature(name,args,context)`.
   - Returns `.allowed | .ask | .denied | .rateLimited` with optional `reason` and `reset_at`.
3) If `.allowed`, your host code executes the action and then calls `recordUsage(name)` to update rate limits and audit.

Swift example:

```swift
// 1) Initialize and register
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

// 2) Evaluate → host executes → record usage
let decision = try SandboxSDK.evaluateFeature("exportPortfolioCSV", args: [:], context: nil)
if decision.status == .allowed {
  // Perform the action
  _ = try SandboxSDK.recordUsage("exportPortfolioCSV")
}
```

For ad-hoc registration without a full manifest, use `registerFeature` and `setPolicies`. See `sandbox/docs/ios_sandboxsdk_developer_guide.md` for more details.

---

## Requirements

- iOS 14+
- Swift 6.0+
- Xcode 16.1+

---

## License

Copyright 2023 Finclip / Geeksfino.

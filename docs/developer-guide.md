# NeuronKit Developer Guide

A comprehensive guide for iOS developers to integrate AI-powered conversational experiences into mobile apps using NeuronKit.

## Table of Contents

1. [What is NeuronKit?](#what-is-neuronkit)
2. [Core Concepts](#core-concepts)
3. [Installation](#installation)
4. [Quick Start](#quick-start)
5. [Understanding Context](#understanding-context)
6. [Sandbox & Security](#sandbox--security)
7. [Building Conversational UI](#building-conversational-ui)
8. [Advanced Features](#advanced-features)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

---

## What is NeuronKit?

NeuronKit is an iOS SDK that transforms traditional mobile apps into intelligent, conversational experiences. It enables your app to understand user context, engage through natural language, and execute actions safely on-device while coordinating with AI agents in the cloud.

### Key Benefits

- **Context-Aware Intelligence**: Automatically captures device signals (location, time, sensors) to understand user situations
- **Conversational UX**: Add natural language interaction alongside traditional touch interfaces  
- **Secure Execution**: On-device sandbox ensures user privacy and consent for all AI-initiated actions
- **Drop-in Integration**: Minimal code changes to add agentic capabilities to existing apps
- **Enterprise Ready**: Built-in compliance, audit trails, and policy controls

### Architecture Overview

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

**Key Principle**: *Cloud brain, device hands* — AI reasoning happens in the cloud, but all actions execute locally under user control.

---

## Core Concepts

Before diving into code, understand these foundational concepts:

### Sandbox

A security layer that controls what AI agents can do in your app:

- **Features**: High-level app functions (e.g., "Send Message", "Take Photo")
- **Capabilities**: Required permissions for features (e.g., Camera, Network)  
- **Primitives**: Concrete implementation actions (e.g., `CapturePhoto`, `MobileUI`)
- **Policies**: Rules governing when and how features can be used

### Context Providers

Modular components that capture device and app state:

- **Device Context**: Location, sensors, battery, network status
- **App Context**: Current screen, user journey, business logic state
- **Temporal Context**: Time of day, calendar events, routines

### ConvoUI

The conversational interface layer:

- **Sessions**: Independent conversation threads with different agents
- **Message Streams**: Real-time text/voice interaction with typing indicators
- **Embedded UI**: Traditional UI elements within conversational flows

### Network Adapters

Communication layer between your app and AI agents:

- **WebSocket**: Real-time bidirectional communication
- **HTTP**: Request/response pattern with optional streaming
- **Custom**: Your own transport protocol (Bluetooth, gRPC, etc.)

---

## Installation

### Step 1: Add Package Dependency

Add NeuronKit to your Xcode project via Swift Package Manager:

```swift
// In Xcode: File → Add Package Dependencies
// URL: https://github.com/Geeksfino/finclip-neuron.git
// Branch: main-swift6_0
```

Or add to your `Package.swift`:

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

### Step 2: Import Frameworks

```swift
import NeuronKit
import SandboxSDK
```

### Step 3: Add Required Permissions

Update your `Info.plist` for context providers you plan to use:

```xml
<!-- For location context -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Used to provide location-aware assistance</string>

<!-- For calendar context -->
<key>NSCalendarsUsageDescription</key>
<string>Used to understand your schedule for better assistance</string>

<!-- For camera features -->
<key>NSCameraUsageDescription</key>
<string>Used to capture photos when requested by AI assistant</string>
```

---

## Quick Start

### Basic Integration

Here's the minimal code to add NeuronKit to your app:

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
        // 1. Create configuration
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
        
        // 2. Initialize runtime
        runtime = NeuronRuntime(config: config)
        
        // 3. Register app features
        setupFeatures()
    }
    
    private func setupFeatures() {
        guard let sandbox = runtime?.sandbox else { return }
        
        // Register a simple messaging feature
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
        
        // Set security policy
        _ = sandbox.setPolicy("send_message", SandboxSDK.Policy(
            requiresUserPresent: true,
            requiresExplicitConsent: true,
            sensitivity: .medium,
            rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 5)
        ))
    }
}
```

### Creating Your First Conversation

```swift
struct ConversationView: View {
    @EnvironmentObject var neuronManager: NeuronManager
    @StateObject private var chatViewModel = ChatViewModel()
    
    var body: some View {
        VStack {
            // Message list
            ScrollView {
                LazyVStack {
                    ForEach(chatViewModel.messages) { message in
                        MessageBubble(message: message)
                    }
                }
            }
            
            // Input area
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
        
        // Open conversation with AI agent
        conversation = runtime.openConversation(agentId: UUID())
        
        // Create and bind UI adapter
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

## Understanding Context

Context is what makes AI assistants truly intelligent. NeuronKit provides modular context providers to capture relevant information about the user's situation.

### Available Context Providers

#### Basic Providers (Always Safe)

```swift
let basicProviders = [
    DeviceStateProvider(),        // Battery, device type
    NetworkStatusProvider(),      // Wi-Fi, cellular strength  
    TimeBucketProvider(),         // Morning/afternoon/evening
    ThermalStateProvider(),       // Device temperature
    DeviceEnvironmentProvider()   // Locale, timezone
]
```

#### Permission-Based Providers

```swift
let advancedProviders = [
    LocationContextProvider(),    // Requires location permission
    CalendarPeekProvider(),       // Requires calendar permission
    BarometerProvider(),          // Requires motion permission
]
```

#### Inferred Providers

```swift
let smartProviders = [
    RoutineInferenceProvider(),   // Learns daily patterns
    UrgencyEstimatorProvider(),   // Infers urgency from context
    ScreenStateProvider()         // Screen on/off, orientation
]
```

### Practical Context Usage

Context flows automatically with each message. Here's how it helps AI agents:

**Scenario**: User says "I'm running late"

**Without Context**: Agent doesn't know where user is going or when

```json
{
  "message": "I'm running late",
  "context": {}
}
```

**With Context**: Agent can provide specific help

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

**AI Response**: "I see you have a team meeting in 15 minutes. Traffic to the office is heavy - should I message the attendees that you'll be about 10 minutes late?"

### Custom Context Providers

Create your own context provider for app-specific information:

```swift
class ShoppingContextProvider: ContextProvider {
    var id: String { "shopping_context" }
    var updatePolicy: ContextUpdatePolicy { .onSend }
    
    func collect() async -> [String: String] {
        // Gather shopping-specific context
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

// Register it in your config
let config = NeuronKitConfig(
    // ... other config ...
    contextProviders: [
        ShoppingContextProvider(),
        LocationContextProvider(),
        TimeBucketProvider()
    ]
)
```

---

## Sandbox & Security

The sandbox ensures AI agents can only perform actions with proper user consent and security controls.

### Feature Registration

Features represent high-level capabilities your app exposes to AI agents:

```swift
func registerAppFeatures() {
    let sandbox = runtime.sandbox
    
    // Camera feature
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
    
    // Set security policy  
    _ = sandbox.setPolicy("take_photo", SandboxSDK.Policy(
        requiresUserPresent: true,
        requiresExplicitConsent: true,
        sensitivity: .high,
        rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 3)
    ))
}
```

### Feature Categories

- **`.Native`** — App-native functionality (navigation, dialogs, media, notifications, etc.)
- **`.MiniApp`** — Embedded micro-app/miniapp routes and JavaScript APIs
- **`.IoTDevice`** — Smart home/device control and automations
- **`.External`** — Delegation to external third-party apps
- **`.SystemApp`** — OS-provided apps such as Calendar or Mail
- **`.Web`** — Browser/web runtime invocations

### Capability Types

- **`UIAccess`** — Drive in-app navigation and surface consent prompts
- **`Network`** — Perform outbound network calls (HTTP, WebSocket, etc.)
- **`DeviceControl`** — Interact with IoT peripherals and smart devices
- **`Camera`** — Capture photos or video
- **`Microphone`** — Record audio
- **`AudioOutput`** — Play audio responses
- **`Bluetooth`** — Discover and interact with Bluetooth peripherals
- **`NFC`** — Read/write NFC tags
- **`Sensors`** — Access device sensor data (barometer, motion, etc.)

### Primitive Reference

Representative primitives that ship with SandboxSDK for mobile scenarios:

- **Mobile UI & Navigation**
  - `MobileUI { page, component? }`
  - `ShowDialog { title, message }`
- **MiniApp Control**
  - `MiniApp { url_path, js_api[] }`
  - `InvokeJSAPI { api_name, params }`
- **Media & Hardware**
  - `CapturePhoto { params }`
  - `CaptureVideo { params }`
  - `RecordAudio { params }`
  - `PickImage {}` / `PickVideo {}`
- **File System**
  - `FileOp { path, op: Read|Write|Delete }`
- **Network & External**
  - `NetworkOp { url, method, headers?, body? }`
  - `WebSocketConnect { url }`
  - `OpenUrl { url, app_hint? }`
- **System Features & Apps**
  - `ClipboardOp { action, text? }`
  - `ShowNotification { title, body }`
  - `CreateCalendarEvent { event }`
  - `ComposeEmail { to?, subject? }`
  - `GetCurrentLocation {}`
- **Audio Output**
  - `PlayAudio { source, volume? }`
  - `StopAudio {}`
- **Bluetooth/NFC**
  - `BluetoothScan { filters? }`
  - `BluetoothConnect { device_id }`
  - `BluetoothWrite { ... }`
  - `BluetoothRead { ... }`
  - `NfcReadTag {}` / `NfcWriteTag { payload }`
- **IoT Control & Sensors**
  - `DeviceControl { device_type, action, device_id? }`
  - `DevicePower { device_id, state }`
  - `SetDeviceMode { device_id, mode }`
  - `SetTemperature { device_id, value }`
  - `SetBrightness { device_id, value }`
  - `LockDevice { device_id }` / `UnlockDevice { device_id }`
  - `ReadSensor { sensor_type, device_id }`
  - `ExecuteScene { scene_id }`
  - `SyncDeviceGroup { group_id }`
- **Cross-Domain Utilities**
  - `ValidateUser { token }`
  - `CheckCapability { permission }`
  - `GetContext { key }`
  - `LogAudit { action, result }`

> **Note:** Platform builds may enable a subset of primitives. Review runtime logs and entitlements to confirm availability before exposing a feature to agents.

### Policy Configuration

Policies control when and how features can be used:

```swift
let policy = SandboxSDK.Policy(
    requiresUserPresent: true,      // User must be actively using device
    requiresExplicitConsent: true,  // Show confirmation dialog
    sensitivity: .high,             // Security classification
    rateLimit: SandboxSDK.RateLimit(unit: .hour, max: 10)
)
```

### Consent UI Integration

Handle consent requests in your UI:

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

## Building Conversational UI

NeuronKit provides flexible tools for creating conversational interfaces that blend naturally with your existing UI.

### Basic Message Handling

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
        // Create conversation
        conversation = neuronRuntime.openConversation(agentId: UUID())
        
        // Subscribe to message updates
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

### Streaming Message Support

Show typing indicators as AI generates responses:

```swift
class StreamingConvoAdapter: BaseConvoUIAdapter {
    weak var viewController: ConversationViewController?
    private var streamingPreviews: [UUID: String] = [:]
    
    override func handleStreamingChunk(_ chunk: InboundStreamChunk) {
        let messageId = chunk.messageId ?? UUID()
        let text = String(decoding: chunk.data, as: UTF8.self)
        
        // Accumulate streaming text
        streamingPreviews[messageId, default: ""] += text
        
        DispatchQueue.main.async {
            self.viewController?.showTypingIndicator(
                id: messageId,
                text: self.streamingPreviews[messageId] ?? ""
            )
        }
        
        if chunk.isFinal {
            // Clear preview when final message arrives
            DispatchQueue.main.async {
                self.viewController?.hideTypingIndicator(id: messageId)
                self.streamingPreviews.removeValue(forKey: messageId)
            }
        }
    }
}
```

### Rich Message Components

NeuronKit supports rich message components beyond plain text:

```swift
func renderMessage(_ message: NeuronMessage) -> UIView {
    let containerView = UIStackView()
    containerView.axis = .vertical
    containerView.spacing = 8
    
    // Text content
    if !message.content.isEmpty {
        let textLabel = UILabel()
        textLabel.text = message.content
        textLabel.numberOfLines = 0
        containerView.addArrangedSubview(textLabel)
    }
    
    // Attachments
    for attachment in message.attachments {
        if attachment.mimeType.hasPrefix("image/") {
            let imageView = UIImageView()
            loadImage(from: attachment.url, into: imageView)
            containerView.addArrangedSubview(imageView)
        }
    }
    
    // Interactive components
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

### Multi-Session Management

Support multiple concurrent conversations:

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

// Usage in SwiftUI
struct MultiChatView: View {
    @StateObject private var sessionManager = MultiSessionManager(runtime: neuronRuntime)
    @State private var selectedSession: ConvoSession?
    
    var body: some View {
        NavigationSplitView {
            // Session list sidebar
            List(sessionManager.activeSessions, id: \.id) { session in
                SessionRow(session: session)
                    .onTapGesture {
                        selectedSession = session
                    }
            }
            .navigationTitle("Conversations")
        } detail: {
            // Chat interface for selected session
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

## Advanced Features

### Custom Feature Implementation

Implement app-specific features that AI agents can use:

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
        
        // Implement message sending logic
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

### Context-Aware Features

Create features that adapt based on current context:

```swift
class LocationAwareFeature: ContextProvider {
    var id: String { "location_actions" }
    var updatePolicy: ContextUpdatePolicy { .onSend }
    
    func collect() async -> [String: String] {
        let location = await LocationManager.shared.getCurrentLocation()
        let nearbyPOIs = await findNearbyPointsOfInterest(location)
        
        return [
            "current_location": location.name,
            "nearby_restaurants": String(nearbyPOIs.restaurants.count),
            "nearby_shops": String(nearbyPOIs.shops.count),
            "can_order_food": String(nearbyPOIs.restaurants.count > 0)
        ]
    }
}

// Register location-aware features based on context
func registerLocationFeatures() {
    // Only register food ordering if restaurants are nearby
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

### Memory and Persistence

Normally applications don't need to acces conversation history as it is managed by Neuronkit runtime. But for greater flexibility Neuronkit exposes local conversation history to applications via its snapshot API.

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
        // Implement search across stored conversations
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

## Best Practices

### Security Guidelines

1. **Principle of Least Privilege**

   ```swift
   // Good: Only request necessary capabilities
   let feature = SandboxSDK.Feature(
       id: "view_calendar",
       requiredCapabilities: [.UIAccess], // Only UI access needed
       // ...
   )
   
   // Avoid: Requesting unnecessary capabilities  
   let badFeature = SandboxSDK.Feature(
       id: "view_calendar", 
       requiredCapabilities: [.UIAccess, .Camera, .Microphone], // Overkill
       // ...
   )
   ```

2. **Context Minimization**

   ```swift
   // Good: Collect only relevant context
   class FocusedContextProvider: ContextProvider {
       func collect() async -> [String: String] {
           return [
               "current_screen": getCurrentScreen(),
               "user_activity": getCurrentActivity()
           ]
       }
   }
   
   // Avoid: Oversharing context
   class VerboseContextProvider: ContextProvider {
       func collect() async -> [String: String] {
           return [
               "current_screen": getCurrentScreen(),
               "all_contacts": getAllContacts(), // Too much!
               "message_history": getMessageHistory(), // Sensitive!
               "browsing_history": getBrowsingHistory() // Privacy risk!
           ]
       }
   }
   ```

3. **Rate Limiting**

   ```swift
   let policy = SandboxSDK.Policy(
       requiresUserPresent: true,
       requiresExplicitConsent: true,
       sensitivity: .high,
       rateLimit: SandboxSDK.RateLimit(unit: .minute, max: 3) // Prevent abuse
   )
   ```

### Performance Optimization

1. **Lazy Context Loading**

   ```swift
   class OptimizedContextProvider: ContextProvider {
       var updatePolicy: ContextUpdatePolicy { .onDemand }
       
       func collect() async -> [String: String] {
           // Only collect when specifically needed
           guard shouldCollectContext() else { return [:] }
           
           return await expensiveContextCollection()
       }
   }
   ```

2. **Message Pagination**

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

3. **Efficient UI Updates**

   ```swift
   // Use delta updates instead of full reloads
   conversation?.messagesPublisher(isDelta: true, initialSnapshot: .full)
       .sink { [weak self] deltaMessages in
           self?.applyMessageDelta(deltaMessages)
       }
   ```

### Error Handling

1. **Graceful Degradation**

   ```swift
   func initializeNeuronKit() {
       do {
           runtime = try NeuronRuntime(config: config)
       } catch {
           // Fall back to traditional UI
           useTraditionalInterface()
           logError("NeuronKit initialization failed: \(error)")
       }
   }
   ```

### User Experience

1. **Progressive Disclosure**

   ```swift
   // Start with basic features, add advanced ones as user engages
   func registerBasicFeatures() {
       let simpleFeatures = ["send_message", "take_photo", "set_reminder"]
       simpleFeatures.forEach { registerFeature($0) }
   }
   
   func registerAdvancedFeatures() {
       let advancedFeatures = ["schedule_meeting", "analyze_document", "control_smart_home"]
       advancedFeatures.forEach { registerFeature($0) }
   }
   ```

2. **Contextual Help**

   ```swift
   func showContextualHelp() -> String {
       let availableFeatures = runtime.sandbox.getRegisteredFeatures()
       let contextualHelp = generateHelpText(for: availableFeatures, context: currentContext)
       return contextualHelp
   }
   ```

---

## Troubleshooting

### Common Issues

#### 1. Features Not Working

**Problem**: Agent tries to use a feature but nothing happens

**Solution**: Check feature registration and policies

```swift
// Debug feature registration
let registeredFeatures = runtime.sandbox.getRegisteredFeatures()
print("Registered features: \(registeredFeatures.map { $0.id })")

// Check if feature is properly configured
if let feature = registeredFeatures.first(where: { $0.id == "problematic_feature" }) {
    print("Feature found: \(feature)")
    
    // Verify policy exists
    if let policy = runtime.sandbox.getPolicy(feature.id) {
        print("Policy: \(policy)")
    } else {
        print("No policy set for feature \(feature.id)")
    }
}
```

#### 2. Context Not Updating

**Problem**: AI agent doesn't seem aware of current context

**Solution**: Verify context providers are active

```swift
// Check which providers are registered
let config = runtime.config
print("Context providers: \(config.contextProviders.map { $0.id })")

// Test context collection manually
Task {
    for provider in config.contextProviders {
        let context = await provider.collect()
        print("Provider \(provider.id): \(context)")
    }
}
```

#### 3. Permission Denied Errors

**Problem**: Features fail with permission errors

**Solution**: Check iOS permissions and capability mappings

```swift
import AVFoundation
import CoreLocation

func checkPermissions() {
    // Camera permission
    let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
    print("Camera permission: \(cameraStatus)")
    
    // Location permission
    let locationManager = CLLocationManager()
    let locationStatus = locationManager.authorizationStatus
    print("Location permission: \(locationStatus)")
    
    // Request missing permissions
    if cameraStatus == .notDetermined {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            print("Camera permission granted: \(granted)")
        }
    }
}
```

#### 4. Network Connection Issues

**Problem**: Messages not sending/receiving

**Solution**: Test network adapter independently

```swift
class NetworkTestAdapter: BaseNetworkAdapter {
    override func start() {
        // Test basic connectivity
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

### Debug Tools

#### Enable Verbose Logging

```swift
// Enable detailed logging in debug builds
#if DEBUG
let config = NeuronKitConfig(
    // ... your config ...
    loggingLevel: .verbose
)
#endif
```

#### Message Inspection

```swift
// Log all messages for debugging
conversation?.messagesPublisher
    .sink { messages in
        for message in messages {
            print("Message: \(message.content)")
            print("Metadata: \(message.metadata ?? [:])")
            print("Components: \(message.components)")
        }
    }
```

#### Context Debugging

```swift
// Create a debug context provider
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

### Getting Help

1. **Check Example Code**: Review the examples in the [finclip-neuron repository](https://github.com/Geeksfino/finclip-neuron/tree/main/examples)

2. **API Documentation**: Refer to inline documentation in the SDK

3. **Community Support**: Join developer discussions and share experiences

4. **Issue Reporting**: Report bugs with specific error messages and reproduction steps

---

## Summary

NeuronKit enables you to transform traditional iOS apps into intelligent, conversational experiences with minimal integration effort. The key steps are:

1. **Install** the SDK via Swift Package Manager
2. **Configure** context providers and security policies  
3. **Register** app features that AI agents can use
4. **Build** conversational UI using provided adapters
5. **Connect** to your AI agent service via network adapters

Start with basic features and gradually expand as you understand your users' needs. The modular design lets you add capabilities incrementally while maintaining security and user trust.

For more examples and advanced use cases, explore the [finclip-neuron repository](https://github.com/Geeksfino/finclip-neuron) and join the developer community.

Happy building! 🚀

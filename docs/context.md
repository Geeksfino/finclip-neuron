# Understanding Context in NeuronKit

Context is the cornerstone of building a truly intelligent and proactive agent. It's the data that allows the agent to understand the user's environment, situation, and intent, moving beyond simple command-and-response interactions. This guide explains the "what," "why," and "how" of the context system in NeuronKit.

## 1. What is Context? A Taxonomy of Signals

Context is more than just raw data; it's a collection of signals that, when combined, paint a rich picture of the user's world. We categorize these signals into several types:

| Context Signal | Sources | Example Agent Categories |
| --- | --- | --- |
| **Location / Movement** | GPS, geofencing, accelerometer, gyroscope, compass | Travel planner, commuter assistant, safety escort, workout coach |
| **Time / Schedule** | System clock, calendar, alarms, recurring reminders | Travel planner, medication adherence, productivity coach |
| **Device Usage** | App in foreground, screen on/off, typing speed, battery level | Productivity coach, digital wellbeing, travel safety |
| **Audio Signals** | Microphone (ambient noise), voice activity | Home repair helper, stress detection, event buddy |
| **Camera / Vision** | Object recognition (keys, suitcase, pill bottle), QR/barcode scans | Home chef, medication adherence, shopping companion |
| **Health & Biometrics** | Heart rate, step count, breathing rate (wearable integration) | Workout coach, stress management, posture coach |
| **Social / Comm.** | Recent calls, unread messages, email drafts | Contextual communication, commute briefing, silent commuter |
| **Environment** | Weather API, ambient light, noise levels, nearby devices | Hydration reminder, travel safety, home automation |
| **Network** | Wi-Fi/cellular state, signal strength, roaming | Travel safety, productivity coach |
| **Digital Artifacts** | Emails, search history, shopping lists, documents in use | Travel planner, home chef, presentation preparation |
| **Identity & Security** | Biometric status, device lock state, SIM info | Secure financial transactions, identity verification |
| **User Profile** | Name, language, interests, accessibility needs (user-provided) | Personalization, accessibility adjustments |
| **Peripherals** | Headphones, car infotainment, smartwatch, external display | Driving mode, UI optimization, music suggestions |
| **Inferred Context** | (Synthesized from raw data) | Routine detection, environmental understanding, urgency/intent analysis |

## 2. How NeuronKit Uses Context

NeuronKit collects context and sends it with every message to your agent backend. This data is structured into two main parts within the outbound message envelope:

1. **`DeviceContext` (Strongly-Typed)**: A core set of structured data for essential device state. This includes `timezone`, `deviceType`, `networkType`, etc.
2. **`additionalContext` (Key-Value Map)**: A flexible `[String: String]` dictionary for richer, more varied signals that don't fit into the core `DeviceContext`. This is where most providers contribute their data.

This combined context allows your backend PDP (Policy Decision Point) and agent logic to make smarter, safer, and more relevant decisions.

## 3. Implementing Context: The `ContextProvider`

To feed context into the system, you register one or more **Context Providers** when you initialize NeuronKit. Each provider is a lightweight component responsible for fetching a specific piece of context.

### Update Policies

You control how often a provider fetches data using an `updatePolicy`. Choose based on freshness needs, battery/CPU impact, and UX expectations:

- `.onMessageSend`
  - When to use: highly dynamic signals (e.g., `NetworkQualityProvider`).
  - Pros: maximum freshness at send time; simplest mental model.
  - Trade-offs: runs on every send; ensure work is very lightweight.

- `.every(ttl)`
  - When to use: polled/semi-dynamic signals where slight staleness is fine (e.g., calendar peek every few minutes, routine inference every 10–15 minutes).
  - Pros: predictable cost; balances freshness with battery/CPU.
  - Trade-offs: may serve cached values within TTL; pick TTL per use case.

- `.onAppForeground`
  - When to use: semi-static signals tied to app visibility or OS settings (e.g., locale, 24‑hour preference, device environment snapshot).
  - Pros: near-zero background cost; updates when user returns.
  - Trade-offs: values won’t refresh while app is backgrounded unless you manually call `await runtime.refreshContextOnForeground()` after state changes.

### Quick Start: Registering Providers

It's as simple as adding them to your `NeuronKitConfig`:

```swift
import NeuronKit

// 1. Initialize the providers you need with an update policy
let quality  = NetworkQualityProvider(updatePolicy: .onMessageSend)
let calendar = CalendarPeekProvider(updatePolicy: .every(300))
let routine  = RoutineInferenceProvider(updatePolicy: .every(900))
let urgency  = UrgencyEstimatorProvider(updatePolicy: .onMessageSend)

// 2. Add them to the config
let cfg = NeuronKitConfig(
  serverURL: URL(string: "wss://agent.example.com")!,
  deviceId: "demo-device", userId: "demo-user",
  contextProviders: [quality, calendar, routine, urgency]
)

// 3. Initialize the runtime
let runtime = NeuronRuntime(config: cfg)

// Now, when you send a message, the SDK automatically enriches it with context.
let convo = runtime.openConversation(agentId: UUID())
try await convo.sendMessage("Hello")
```

### Provider Template

Use this commented Swift template as a starting point for your own provider implementation:

- `docs/templates/TemplateProvider.swift`

## 4. Built-in Provider Reference

NeuronKit comes with a rich set of built-in providers. You just need to initialize and register them.

### Provider Quick Reference

| Provider | Keys / Outputs (examples) | Purpose |
| --- | --- | --- |
| `ScreenStateProvider` | `screenOn`, `orientation` | Snapshot of screen power state and device orientation. |
| `ThermalStateProvider` | `thermalState` | Reports current thermal pressure for performance-aware decisions. |
| `DeviceEnvironmentProvider` | `locale`, `is24Hour` | Locale and time format preferences to tailor responses/UI. |
| `TimeBucketProvider` | `daySegment`, `weekday` | Time-of-day buckets and weekday for routine-aware logic. |
| `NetworkQualityProvider` | `network.quality` | Lightweight network quality signal for reliability/routing. |
| `NetworkStatusProvider` | `network.type` | Current connectivity type (wifi/cellular/wired/none/etc.). |
| `CalendarPeekProvider` | `social.calendar_next_event`, `social.calendar_next_event.start_ts` | Whether a near-future event exists and its start time. |
| `BarometerProvider` (iOS) | `env.pressure_kPa` | Ambient pressure hinting at environment/elevation changes. |
| `DeviceStateProvider` (iOS) | `battery.level`, `battery.state` | Battery level/state for power-aware behaviors. |
| `LocationContextProvider` (iOS) | `location.latitude`, `location.longitude`, `location.accuracy` | Coarse/fine location snapshot when already authorized (no prompts). |
| `RoutineInferenceProvider` | `inferred.routine`, `inferred.routine.confidence` | High-level routine (work/commute/home) inferred from signals. |
| `UrgencyEstimatorProvider` | `inferred.urgency`, `inferred.urgency.rationale` | Heuristic estimation of urgency/emotional state. |

### Standard Providers (Mapped to `DeviceContext`)

These providers populate the core `DeviceContext` object.

- `ScreenStateProvider` → `screenOn`, `orientation`
- `ThermalStateProvider` → `thermalState`
- `DeviceEnvironmentProvider` → `locale`, `is24Hour`
- `TimeBucketProvider` → `daySegment`, `weekday`

### Advanced Providers (Mapped to `additionalContext`)

These providers add key-value pairs to the `additionalContext` map.

- `NetworkQualityProvider` → `network.quality` (good | fair | none | unknown)
- `CalendarPeekProvider` → `social.calendar_next_event` (true | false), `social.calendar_next_event.start_ts` (epoch seconds)
- `BarometerProvider` (iOS only) → `env.pressure_kPa` (numeric string)

### Inferred Context Providers (Optional)

These powerful providers synthesize raw data to derive higher-level insights about the user's situation.

- `RoutineInferenceProvider`: Infers the user's current routine (e.g., *work*, *commute*, *home*).
  - **Keys**: `inferred.routine`, `inferred.routine.confidence`
  - **Formula**: Location + Time + Calendar Events + App Usage History
- `UrgencyEstimatorProvider`: Infers the urgency or emotional state from user behavior.
  - **Keys**: `inferred.urgency` (low | med | high), `inferred.urgency.rationale`
  - **Formula**: Typing speed + App data + Time of day + Heart rate

### Creating a Custom Provider

You can build your own provider when you need domain-specific signals.

Key pieces you implement:

- A `struct` for the value you emit (Codable)
- A type that conforms to `ContextProvider`
  - `key`: a unique identifier for your provider
  - `updatePolicy`: when to refresh (on send / TTL / app foreground)
  - `getCurrentContext()`: async function that returns your value (or `nil`)

Example: a simple Battery Health provider that writes into `additionalContext`.

```swift
import Foundation
import NeuronKit
import UIKit

// 1) Define the value you want to emit (optional – you can also emit a flat map)
struct BatteryHealthContext: Codable {
  let level: Int?           // 0..100
  let state: String?        // charging|unplugged|full|unknown
}

// 2) Implement a ContextProvider
public final class BatteryHealthProvider: ContextProvider {
  public let key: String = "battery.health"
  public let updatePolicy: ContextUpdatePolicy

  public init(updatePolicy: ContextUpdatePolicy = .every(120)) {
    self.updatePolicy = updatePolicy
    #if canImport(UIKit)
    UIDevice.current.isBatteryMonitoringEnabled = true
    #endif
  }

  public func getCurrentContext() async -> Codable? {
    #if canImport(UIKit)
    let levelPct: Int?
    if UIDevice.current.batteryLevel >= 0 {
      levelPct = Int(UIDevice.current.batteryLevel * 100)
    } else {
      levelPct = nil
    }

    let stateStr: String
    switch UIDevice.current.batteryState {
    case .charging: stateStr = "charging"
    case .full: stateStr = "full"
    case .unplugged: stateStr = "unplugged"
    default: stateStr = "unknown"
    }

    return BatteryHealthContext(level: levelPct, state: stateStr)
    #else
    return nil
    #endif
  }
}
```

Register it the same way as built-ins:

```swift
let battery = BatteryHealthProvider(updatePolicy: .every(120))
let cfg = NeuronKitConfig(
  serverURL: URL(string: "wss://agent.example.com")!,
  deviceId: "demo-device", userId: "demo-user",
  contextProviders: [battery]
)
```

Best practices:

- Prefer coarse, privacy-safe values (strings/numbers) – avoid PII
- Do not prompt for permissions inside providers; return `nil` if unauthorized
- Keep work lightweight; cache when using `.every(ttl)`
- Consider app lifecycle (foreground/background) and platform availability
- Add unit tests for serialization and edge cases

## 5. Use Case Scenarios in Action

Here’s how different context signals come together to enable proactive agent experiences.

### General and Home Scenarios

- **The “Getting Ready to Go Out” Agent**
  - **Context**: `accelerometer` (walking) + `location` (home) + `time` (weekend afternoon) + `camera` (sees suitcase).
  - **Prompt**: “It looks like you’re getting ready to leave. Would you like me to set your smart home to away mode, order you a ride, or check the traffic?”

- **The “Productivity Coach” Agent**
  - **Context**: `time` (late night) + `app usage` (coding app) + `network` (home Wi-Fi) + `calendar` (no early meetings).
  - **Prompt**: “You’re working late. Would you like me to send a ‘Do Not Disturb’ message to your key contacts or play some focus-enhancing ambient music?”

### Office and Business Scenarios

- **The “Meeting Follow-Up” Agent**
  - **Context**: `calendar` (meeting ends) + `location` (changes) + `camera` (sees business card).
  - **Prompt**: “I saw you just finished the ‘Project X’ meeting. Would you like to create a summary of the meeting notes, set a follow-up task, or create a contact entry?”

- **The “Commute-to-Work Briefing” Agent**
  - **Context**: `GPS` (commute route) + `calendar` (first meeting at 9:30) + `app usage` (unread Slack messages).
  - **Prompt**: “Good morning! Traffic looks heavy. Would you like me to summarize unread Slack threads or prep you with key notes for your meeting?”

### Healthcare Scenarios

- **The “Medication Adherence” Agent**
  - **Context**: `calendar` (recurring event) + `motion sensors` (user is active) + `camera` (recognizes pill bottle).
  - **Prompt**: “It looks like you’re up and about. Have you taken your medication yet? I can set a quick timer for you for the next dose.”

- **The “Stress & Mental Well-being” Agent**
  - **Context**: `location` (home) + `heart rate` (elevated) + `microphone` (irregular breathing) + `call log` (late-night call).
  - **Prompt**: “I’ve noticed your heart rate and breathing are elevated. Would you like to listen to a guided meditation or a calming playlist?”

## 6. Privacy, Consent, and Best Practices

With great context comes great responsibility. Follow these principles:

1. **Transparency is Key**: Always inform the user what context is being collected and why. Even if your app has OS-level permission (e.g., for location), you should be clear about when and how that data is shared with the agent.
2. **Use the Least Privileged Context**: Only register the providers you absolutely need for a given feature. Don't collect everything just in case.
3. **Providers Don't Prompt**: NeuronKit providers **never** trigger OS permission dialogs themselves. Your application is responsible for requesting user permission *before* registering a provider that requires it. If permission is not granted, the provider will simply return `nil`.
4. **Avoid PII in `additionalContext`**: This map is designed for coarse, privacy-safe signals (strings and numbers). Avoid sending Personally Identifiable Information (PII) through this channel.

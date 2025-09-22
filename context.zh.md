# 理解 NeuronKit 中的上下文（Context）

上下文（Context）是构建真正智能和主动型智能体的基石。它所包含的数据能让智能体理解用户的环境、处境和意图，从而超越简单的“命令-响应”式交互。本指南将解释 NeuronKit 上下文系统的“是什么”、“为什么”以及“如何做”。

## 1. 上下文是什么？信号分类法

上下文不仅是原始数据，更是一系列信号的集合。当这些信号组合在一起时，就能描绘出用户所处世界的丰富画面。我们将这些信号分为几类：

| 上下文信号 | 来源 | 应用场景示例 |
| --- | --- | --- |
| **位置/移动** | GPS、地理围栏、加速计、陀螺仪、指南针 | 旅行规划、通勤助手、安全护航、健身教练 |
| **时间/日程** | 系统时钟、日历、闹钟、周期性提醒 | 旅行规划、用药提醒、效率教练 |
| **设备使用** | 前台应用、屏幕开关、打字速度、电池电量 | 效率教练、数字健康、出行安全 |
| **音频信号** | 麦克风（环境噪音）、语音活动 | 家庭维修助手、压力检测、活动伴侣 |
| **摄像头/视觉** | 物体识别（钥匙、行李箱、药瓶）、二维码/条形码扫描 |家庭厨师、用药提醒、购物伴侣 |
| **健康/生物特征** | 心率、步数、呼吸频率（来自穿戴设备） | 健身教练、压力管理、姿势教练 |
| **社交/通讯** | 最近通话、未读消息、邮件草稿 | 上下文感知沟通、通勤简报、静默通勤者 |
| **环境** | 天气 API、环境光、噪音水平、附近设备 | 补水提醒、出行安全、家庭自动化 |
| **网络** | Wi-Fi/蜂窝网络状态、信号强度、漫游 | 出行安全、效率教练 |
| **数字产物** | 电子邮件、搜索历史、购物清单、使用中的文档 | 旅行规划、家庭厨师、演示准备 |
| **身份/安全** | 生物识别状态、设备锁定状态、SIM 卡信息 | 安全金融交易、身份验证 |
| **用户个人资料** | 姓名、语言、兴趣、无障碍需求（用户提供） | 个性化、无障碍适配 |
| **连接的外设** | 耳机、车载信息娱乐系统、智能手表、外接显示器 | 驾驶模式、UI 优化、音乐推荐 |
| **衍生上下文** | （从原始数据中综合推断） | 日常活动检测、环境理解、紧急/意图分析 |

## 2. NeuronKit 如何使用上下文

NeuronKit 收集上下文，并随每条消息发送到您的智能体后端。这些数据在出站消息信封中主要分为两部分：

1. **`DeviceContext` (强类型)**：一组用于核心设备状态的结构化数据，包括 `timezone`、`deviceType`、`networkType` 等。
2. **`additionalContext` (键值对)**：一个灵活的 `[String: String]` 字典，用于更丰富、多样化的信号，这些信号不适合放入核心 `DeviceContext`。大多数 provider 在此贡献数据。

这种组合式的上下文能让您的后端 PDP（策略决策点）和智能体逻辑做出更智能、更安全、更相关的决策。

## 3. 实现上下文：`ContextProvider`

要将上下文送入系统，您需要在初始化 NeuronKit 时注册一个或多个 **Context Provider**。每个 provider 都是一个轻量级组件，负责获取特定的上下文信息。

### 更新策略

您可以使用 `updatePolicy` 控制 provider 获取数据的频率。请根据新鲜度、耗电/CPU 以及用户体验取舍选择：

- `.onMessageSend`
  - 何时使用：高度动态的信号（如 `NetworkQualityProvider`）。
  - 优点：发送时拥有最高新鲜度；心智模型最简单。
  - 取舍：每次发送都会执行；务必保持逻辑极其轻量。

- `.every(ttl)`
  - 何时使用：可轮询/半动态信号，允许轻微陈旧（如日历窥探每几分钟一次、日常模式推断每 10–15 分钟）。
  - 优点：成本可预测；在新鲜度与电量/CPU 之间取得平衡。
  - 取舍：在 TTL 内返回缓存值；请按场景合理选择 TTL。

- `.onAppForeground`
  - 何时使用：与可见性或系统设置相关的半静态信号（如语言/24小时制、设备环境快照）。
  - 优点：几乎零后台成本；用户返回前台时刷新。
  - 取舍：后台期间不会刷新；如状态改变可在唤醒后手动调用 `await runtime.refreshContextOnForeground()`。

### 快速上手：注册 Provider

只需将它们添加到您的 `NeuronKitConfig` 中即可：

```swift
import NeuronKit

// 1. 根据需要初始化 provider，并指定更新策略
let quality  = NetworkQualityProvider(updatePolicy: .onMessageSend)
let calendar = CalendarPeekProvider(updatePolicy: .every(300))
let routine  = RoutineInferenceProvider(updatePolicy: .every(900))
let urgency  = UrgencyEstimatorProvider(updatePolicy: .onMessageSend)

// 2. 将它们添加到配置中
let cfg = NeuronKitConfig(
  serverURL: URL(string: "wss://agent.example.com")!,
  deviceId: "demo-device", userId: "demo-user",
  contextProviders: [quality, calendar, routine, urgency]
)

// 3. 初始化运行时
let runtime = NeuronRuntime(config: cfg)

// 现在，当您发送消息时，SDK 会自动用上下文丰富消息
let convo = runtime.openConversation(agentId: UUID())
try await convo.sendMessage("Hello")
```

### Provider 模板

你可以从以下带注释的 Swift 模板开始实现自定义 Provider：

- `docs/templates/TemplateProvider.swift`

## 4. 内置 Provider 参考

NeuronKit 自带一组丰富的内置 provider。您只需初始化并注册它们。

### 标准 Provider (映射到 `DeviceContext`)

这些 provider 填充核心的 `DeviceContext` 对象。

- `ScreenStateProvider` → `screenOn`, `orientation`
- `ThermalStateProvider` → `thermalState`
- `DeviceEnvironmentProvider` → `locale`, `is24Hour`
- `TimeBucketProvider` → `daySegment`, `weekday`

### 高级 Provider (映射到 `additionalContext`)

这些 provider 向 `additionalContext` 字典添加键值对。

- `NetworkQualityProvider` → `network.quality` (good | fair | none | unknown)
- `CalendarPeekProvider` → `social.calendar_next_event` (true | false), `social.calendar_next_event.start_ts` (epoch 秒)
- `BarometerProvider` (仅 iOS) → `env.pressure_kPa` (数值字符串)

### 衍生上下文 Provider (可选)

这些强大的 provider 通过综合原始数据，推断出关于用户处境的更高级别的洞察。

- `RoutineInferenceProvider`: 推断用户当前的日常活动（例如 *work*, *commute*, *home*）。
  - **键**: `inferred.routine`, `inferred.routine.confidence`
  - **算法**: 位置 + 时间 + 日历事件 + 应用使用历史
- `UrgencyEstimatorProvider`: 从用户行为中推断紧急程度或情绪状态。
  - **键**: `inferred.urgency` (low | med | high), `inferred.urgency.rationale`
  - **算法**: 打字速度 + 应用数据 + 时间 + 心率

### 自定义 Provider 的创建

当你需要领域特定（Domain-specific）的上下文信号时，可以实现自己的 Provider。

关键要点：

- 定义一个用于输出的值类型（`Codable` 的 `struct`）
- 实现一个符合 `ContextProvider` 协议的类型：
  - `key`：Provider 的唯一标识（用于 `additionalContext` 命名空间）
  - `updatePolicy`：何时刷新（发送时 / TTL / 前台）
  - `getCurrentContext()`：异步返回你的值（或者 `nil`）

示例：电池健康 Provider（写入 `additionalContext`）。

```swift
import Foundation
import NeuronKit
import UIKit

// 1) 定义要输出的值类型（也可直接输出平铺的字典）
struct BatteryHealthContext: Codable {
  let level: Int?    // 0..100
  let state: String? // charging|unplugged|full|unknown
}

// 2) 实现 ContextProvider
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

注册方式与内置 Provider 相同：

```swift
let battery = BatteryHealthProvider(updatePolicy: .every(120))
let cfg = NeuronKitConfig(
  serverURL: URL(string: "wss://agent.example.com")!,
  deviceId: "demo-device", userId: "demo-user",
  contextProviders: [battery]
)
```

最佳实践：

- 只输出粗粒度、隐私友好的字符串/数值，避免 PII
- Provider 不要主动触发权限弹窗；若无授权，返回 `nil`
- 保持轻量；对 `.every(ttl)` 类型的 Provider 做好缓存
- 考虑应用生命周期（前台/后台）和跨平台可用性
- 为序列化与边界条件添加单元测试

## 5. 实际应用场景

以下示例展示了不同上下文信号如何协同工作，以实现主动型智能体体验。

### 通用和家庭场景

- **“准备出门”智能体**
  - **上下文**: `accelerometer` (步行) + `location` (在家) + `time` (周末下午) + `camera` (看到行李箱)。
  - **提示**: “看起来您准备出门。需要我将您的智能家居设为离家模式、叫车，还是检查目的地交通状况？”

- **“效率教练”智能体**
  - **上下文**: `time` (深夜) + `app usage` (编程应用) + `network` (家庭 Wi-Fi) + `calendar` (没有早期会议)。
  - **提示**: “您工作到很晚。需要我向您的重要联系人发送‘请勿打扰’消息，还是播放一些有助专注的环境音乐？”

### 办公和商务场景

- **“会议跟进”智能体**
  - **上下文**: `calendar` (会议结束) + `location` (位置变化) + `camera` (看到名片)。
  - **提示**: “我看到您刚结束‘项目 X’会议。需要我创建会议纪要、为待办事项设置跟进任务，还是创建联系人？”

- **“通勤简报”智能体**
  - **上下文**: `GPS` (通勤路线) + `calendar` (9:30 有会议) + `app usage` (有未读的 Slack 消息)。
  - **提示**: “早上好！交通看起来很拥堵。需要我为您总结未读的 Slack 消息，还是为您的会议准备要点？”

### 健康医疗场景

- **“用药提醒”智能体**
  - **上下文**: `calendar` (周期性事件) + `motion sensors` (用户活动中) + `camera` (识别药瓶)。
  - **提示**: “您已经起床活动了。请问您吃药了吗？我可以为您设置下一次剂量的定时器。”

- **“压力与心理健康”智能体**
  - **上下文**: `location` (在家) + `heart rate` (心率升高) + `microphone` (呼吸不规律) + `call log` (深夜通话)。
  - **提示**: “我注意到您的心率和呼吸加快了。需要听一段引导式冥想或平静的音乐吗？”

## 6. 隐私、同意与最佳实践

强大的上下文能力伴随着巨大的责任。请遵循以下原则：

1. **透明是关键**: 始终告知用户正在收集哪些上下文以及原因。即使您的应用已获得操作系统级别的权限（例如位置），您也应清楚说明何时以及如何与智能体共享这些数据。
2. **使用最少权限上下文**: 只注册您功能绝对需要的 provider。不要为了以防万一而收集所有信息。
3. **Provider 不会主动请求权限**: NeuronKit 的 provider **绝不会**自行触发操作系统权限对话框。您的应用程序负责在注册需要权限的 provider *之前*请求用户许可。如果未授予权限，provider 将仅返回 `nil`。
4. **避免在 `additionalContext` 中发送个人身份信息(PII)**: 此字典设计用于粗粒度的、对隐私安全的信号（字符串和数字）。避免通过此渠道发送个人身份信息（PII）。

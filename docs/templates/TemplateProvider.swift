import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Template: Implement your own ContextProvider
///
/// Guidelines:
/// - Keep collection lightweight; providers run inline during context enrichment.
/// - Fail-open: if data is unavailable or permission is missing, return nil.
/// - Never trigger OS permission prompts here; request in your app UX beforehand.
/// - Prefer coarse, privacy-safe outputs (strings/numbers) and avoid PII.
///
/// Choosing an update policy:
/// - .onMessageSend: For highly dynamic signals that should be fresh on every send (e.g., network quality).
/// - .onAppForeground: For semi-static signals that change on app visibility (e.g., locale, 24h setting, cached profile state).
/// - .every(ttl): For polled signals; balance freshness vs. battery/CPU (e.g., calendar peek every few minutes).
public final class TemplateProvider: ContextProvider {
  /// Unique, stable key that namespaces your values in additionalContext
  /// Example: "battery.health" or "custom.company.metric"
  public let contextKey: String = "template.example"

  /// Decide how often your provider should refresh
  public let updatePolicy: ContextUpdatePolicy

  public init(updatePolicy: ContextUpdatePolicy = .every(300)) {
    self.updatePolicy = updatePolicy
    #if canImport(UIKit)
    // Optional: set up lightweight monitoring here (avoid heavy observers)
    #endif
  }

  /// Return your current context value (Codable) or nil when unavailable.
  /// This runs on an async context; perform minimal work and avoid blocking.
  public func getCurrentContext() async -> Codable? {
    // Example payload; replace with your own data model
    struct TemplateContext: Codable {
      let status: String
      let updatedAt: Int64
    }

    // Collect data (pseudo-code). Keep it light and fail-open.
    #if canImport(UIKit)
    // Example of using UIKit safely in a provider. Avoid UI-only APIs.
    let ts = Int64(Date().timeIntervalSince1970)
    return TemplateContext(status: "ok", updatedAt: ts)
    #else
    return nil
    #endif
  }
}

import Foundation
import NeuronKit
import SandboxSDK

/// Example showing how to manage multiple conversation sessions
/// This demonstrates the power of the new session-centric binding approach
class MultiSessionExample {
  private let runtime: NeuronRuntime
  private var sessions: [String: UUID] = [:]
  
  init(runtime: NeuronRuntime) {
    self.runtime = runtime
  }
  
  /// Create a new conversation session for a specific context
  func createSession(name: String, agentId: UUID) -> UUID {
    let sessionId = UUID()
    runtime.openSession(sessionId: sessionId, agentId: agentId)
    sessions[name] = sessionId
    print("📱 Created session '\(name)': \(sessionId)")
    return sessionId
  }
  
  /// Bind a UI adapter to a specific session
  func bindUI(_ adapter: ConvoUIAdapter, toSession name: String) {
    guard let sessionId = sessions[name] else {
      print("❌ Session '\(name)' not found")
      return
    }
    
    runtime.bindUI(adapter, toSession: sessionId)
    print("🔗 Bound UI to session '\(name)'")
  }
  
  /// Switch UI focus from one session to another
  func switchUI(_ adapter: ConvoUIAdapter, from oldSession: String, to newSession: String) {
    // Unbind from old session
    if let oldSessionId = sessions[oldSession] {
      runtime.unbindUI(fromSession: oldSessionId)
      print("🔄 Unbound UI from session '\(oldSession)'")
    }
    
    // Bind to new session
    bindUI(adapter, toSession: newSession)
  }
  
  /// Close a specific session
  func closeSession(name: String) {
    guard let sessionId = sessions[name] else {
      print("❌ Session '\(name)' not found")
      return
    }
    
    runtime.unbindUI(fromSession: sessionId)
    runtime.closeSession(sessionId: sessionId)
    sessions.removeValue(forKey: name)
    print("🗑️ Closed session '\(name)'")
  }
  
  /// Example usage demonstrating multiple sessions
  func demonstrateMultipleSessions() {
    // Create different sessions for different contexts
    let customerSupportSession = createSession(name: "customer_support", agentId: UUID())
    let salesSession = createSession(name: "sales_inquiry", agentId: UUID())
    let technicalSession = createSession(name: "technical_help", agentId: UUID())
    
    // Create different UI adapters for different contexts
    let supportAdapter = SimpleConvoAdapter(context: "Customer Support")
    let salesAdapter = SimpleConvoAdapter(context: "Sales")
    let techAdapter = SimpleConvoAdapter(context: "Technical")
    
    // Bind each adapter to its respective session
    bindUI(supportAdapter, toSession: "customer_support")
    bindUI(salesAdapter, toSession: "sales_inquiry")
    bindUI(techAdapter, toSession: "technical_help")
    
    // Now each session can operate independently with its own UI
    print("✅ Multiple sessions running independently")
    
    // Example: User switches between different chat windows
    // The UI can be dynamically rebound to different sessions
    switchUI(supportAdapter, from: "customer_support", to: "sales_inquiry")
    
    // Clean up when done
    closeSession(name: "customer_support")
    closeSession(name: "sales_inquiry") 
    closeSession(name: "technical_help")
  }
}

/// Simple adapter for demonstration
class SimpleConvoAdapter: BaseConvoUIAdapter {
  private let context: String
  
  init(context: String) {
    self.context = context
    super.init()
  }
  
  override func handleMessages(_ messages: [NeuronMessage]) {
    print("[\(context)] Messages updated: \(messages.count) messages")
  }
  
  override func handleConsentRequest(proposalId: UUID, sessionId: UUID, feature: String, args: [String: Any]) {
    print("[\(context)] Consent requested for \(feature)")
    // Auto-approve for demo
    context?.userProvidedConsent(messageId: proposalId, approved: true)
  }
  
  override func didBind(sessionId: UUID) {
    print("[\(context)] Bound to session \(sessionId)")
  }
  
  override func didUnbind() {
    print("[\(context)] Unbound from session")
  }
}

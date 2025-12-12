# Migration Strategy: Claude Code to OpenCode

This guide provides a step-by-step strategy for migrating Claude Island (macOS menu bar app for Claude Code CLI) to OpenCode Island.

## Migration Overview

### Goals
1. Maintain existing functionality
2. Leverage OpenCode's extensibility
3. Support multiple LLM providers
4. Minimize duplicate MCP servers
5. Add memory monitoring and auto-updates

### Timeline
- **Phase 1** (2 weeks): POC and validation
- **Phase 2** (3 weeks): Core migration
- **Phase 3** (2 weeks): Advanced features
- **Phase 4** (1 week): Testing and polish

## Phase 1: Proof of Concepts (2 weeks)

### POC 1: Configuration Schema Validation

**Objective:** Validate OpenCode configuration format

**Tasks:**
```bash
# 1. Create test configuration
cat > test-opencode.jsonc << 'EOF'
{
  "model": {
    "provider": "anthropic",
    "name": "claude-sonnet-4"
  },
  "mcp": {
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/tmp"]
    }
  }
}
EOF

# 2. Validate with OpenCode CLI
opencode config validate --config test-opencode.jsonc

# 3. Test configuration loading
opencode --config test-opencode.jsonc "List files in current directory"
```

**Success Criteria:**
- [x] Configuration loads without errors
- [x] MCP server connects successfully
- [x] Commands execute correctly

**Deliverable:** `POC-CONFIG-VALIDATION.md` with results

### POC 2: Session Monitoring

**Objective:** Monitor OpenCode process memory usage

**Tasks:**
```swift
// Create monitoring test
class OpenCodeMonitorPOC {
    func testProcessDiscovery() {
        // Find OpenCode process by multiple methods
        let methods = [
            findByName("opencode"),
            findByName("node"),  // If running via Node
            findByName("bun"),   // If running via Bun
            findByCommandLine("opencode")
        ]
        
        // Verify we can find the process
        XCTAssertNotNil(findOpenCodeProcess())
    }
    
    func testMemoryTracking() {
        // Track memory over time
        let process = findOpenCodeProcess()
        var readings: [Int] = []
        
        for _ in 0..<10 {
            readings.append(getProcessMemory(process))
            sleep(1)
        }
        
        // Verify readings are reasonable
        XCTAssert(readings.allSatisfy { $0 > 0 && $0 < 10000 })
    }
}
```

**Success Criteria:**
- [x] Can locate OpenCode process
- [x] Can read memory usage accurately
- [x] Memory tracking updates in real-time

**Deliverable:** `POC-MEMORY-MONITORING.md`

### POC 3: Hook System Compatibility

**Objective:** Verify OpenCode hooks work with existing Unix socket

**Current Claude Hooks:**
```bash
~/.claude/hooks/
├── before_tool.sh
├── after_tool.sh
└── session_start.sh
```

**OpenCode Equivalent:**
```bash
~/.config/opencode/hooks/
├── before-tool.sh
├── after-tool.sh
└── session-start.sh
```

**Test:**
```bash
# 1. Create OpenCode hooks
mkdir -p ~/.config/opencode/hooks

# 2. Create test hook
cat > ~/.config/opencode/hooks/session-start.sh << 'EOF'
#!/bin/bash
echo "Session started" | nc -U /tmp/opencode-island.sock
EOF

chmod +x ~/.config/opencode/hooks/session-start.sh

# 3. Start OpenCode and verify hook fires
opencode "Test session"
```

**Success Criteria:**
- [x] Hooks execute on OpenCode events
- [x] Unix socket receives messages
- [x] Message format is compatible

**Deliverable:** `POC-HOOKS-COMPATIBILITY.md`

## Phase 2: Core Migration (3 weeks)

### Week 1: Configuration Layer

#### Task 1.1: Configuration Parser
```swift
// OpenCodeConfigParser.swift
struct OpenCodeConfig: Codable {
    let model: ModelConfig?
    let mcp: [String: MCPServerConfig]?
    let plugins: [String: PluginConfig]?
    let tools: ToolsConfig?
}

struct MCPServerConfig: Codable {
    let type: String  // "local" or "remote"
    let command: [String]?
    let url: String?
    let env: [String: String]?
    let disabled: Bool?
}

class OpenCodeConfigParser {
    func parse(at path: String) throws -> OpenCodeConfig {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        return try JSONDecoder().decode(OpenCodeConfig.self, from: data)
    }
    
    func findConfigFile() -> String? {
        // Search in order:
        // 1. PROJECT_ROOT/opencode.jsonc
        // 2. PROJECT_ROOT/.opencode/opencode.jsonc
        // 3. ~/.config/opencode/opencode.jsonc
    }
}
```

#### Task 1.2: Update Session Monitor
```swift
class OpenCodeSessionMonitor {
    private let configParser: OpenCodeConfigParser
    private var config: OpenCodeConfig?
    
    func startMonitoring() {
        // Load configuration
        config = try? configParser.parse(at: configPath)
        
        // Monitor OpenCode process instead of Claude
        watchForProcess(name: "opencode")
        
        // Watch for session files
        watchSessionDirectory(path: "~/.config/opencode/sessions")
    }
}
```

#### Task 1.3: Testing
```bash
# Test suite
swift test --filter OpenCodeConfigParserTests
swift test --filter OpenCodeSessionMonitorTests
```

**Deliverables:**
- Updated config parser
- Migration guide for config files
- Test suite passing

### Week 2: UI Updates

#### Task 2.1: Rebrand UI
```swift
// Update app name and branding
- ClaudeIsland → OpenCodeIsland
- Claude Code → OpenCode
- Update icons and colors
```

#### Task 2.2: Multi-Provider Support
```swift
// Add provider indicator
struct ProviderIndicator: View {
    let provider: String  // "anthropic", "openai", "google", etc.
    
    var body: some View {
        HStack {
            Image(systemName: providerIcon)
            Text(provider)
        }
    }
    
    var providerIcon: String {
        switch provider {
        case "anthropic": return "brain"
        case "openai": return "sparkles"
        case "google": return "cloud"
        default: return "cpu"
        }
    }
}
```

#### Task 2.3: Tool Display Updates
```swift
// Update MCPToolFormatter for OpenCode tools
struct OpenCodeToolFormatter {
    static func formatToolName(_ toolId: String) -> String {
        // Handle OpenCode tool naming
        // e.g., "read", "write", "bash", "task"
        return toolId.capitalized
    }
}
```

**Deliverables:**
- Updated UI with OpenCode branding
- Provider-aware displays
- Tool formatter for OpenCode tools

### Week 3: Hook System

#### Task 3.1: Hook Installer
```swift
class OpenCodeHookInstaller {
    func install() throws {
        let hooksDir = FileManager.default
            .homeDirectoryForCurrentUser
            .appendingPathComponent(".config/opencode/hooks")
        
        try FileManager.default.createDirectory(
            at: hooksDir,
            withIntermediateDirectories: true
        )
        
        // Install hooks
        try installHook("session-start", content: sessionStartHook)
        try installHook("before-tool", content: beforeToolHook)
        try installHook("after-tool", content: afterToolHook)
    }
    
    private var sessionStartHook: String {
        """
        #!/bin/bash
        SESSION_ID="$1"
        echo "SESSION_START|$SESSION_ID" | nc -U /tmp/opencode-island.sock
        """
    }
}
```

#### Task 3.2: Socket Server
```swift
// Update HookSocketServer for OpenCode format
class OpenCodeSocketServer {
    func parseMessage(_ message: String) -> SessionEvent? {
        let parts = message.split(separator: "|")
        guard parts.count >= 2 else { return nil }
        
        let eventType = String(parts[0])
        let data = String(parts[1])
        
        switch eventType {
        case "SESSION_START":
            return .sessionStarted(sessionId: data)
        case "TOOL_START":
            return .toolStarted(toolName: data)
        // ... handle OpenCode events
        }
    }
}
```

**Deliverables:**
- OpenCode hooks installed
- Socket server updated
- Event handling working

## Phase 3: Advanced Features (2 weeks)

### Week 1: Memory Monitoring

#### Implementation
```swift
class MemoryMonitor {
    private let warningThreshold = 2048  // 2GB
    private let criticalThreshold = 4096 // 4GB
    private var timer: Timer?
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: true
        ) { [weak self] _ in
            self?.checkMemory()
        }
    }
    
    private func checkMemory() {
        guard let process = findOpenCodeProcess() else { return }
        let memoryMB = getProcessMemory(process)
        
        if memoryMB > criticalThreshold {
            notifyUser(.critical, memoryMB: memoryMB)
            suggestRestart()
        } else if memoryMB > warningThreshold {
            notifyUser(.warning, memoryMB: memoryMB)
        }
    }
    
    private func suggestRestart() {
        let alert = NSAlert()
        alert.messageText = "High Memory Usage"
        alert.informativeText = """
            OpenCode is using \(memoryMB)MB of memory.
            Restarting may improve performance.
            """
        alert.addButton(withTitle: "Restart Now")
        alert.addButton(withTitle: "Later")
        
        if alert.runModal() == .alertFirstButtonReturn {
            restartOpenCode()
        }
    }
}
```

#### Configuration
```swift
struct MonitoringConfig {
    var enabled = true
    var checkInterval = 60
    var warningThreshold = 2048
    var criticalThreshold = 4096
    var autoRestart = false
}
```

### Week 2: Auto-Update

#### Implementation
```swift
import Sparkle

class UpdateManager {
    private let updater: SPUStandardUpdaterController
    
    init() {
        updater = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }
    
    func checkForUpdates() {
        updater.checkForUpdates()
    }
    
    func configureAutoUpdate() {
        // Set update feed URL
        updater.feedURL = URL(string: 
            "https://github.com/rothnic/opencode-island/releases.atom"
        )
        
        // Configure automatic checks
        updater.automaticallyChecksForUpdates = true
        updater.updateCheckInterval = 86400 // Daily
    }
}
```

#### Info.plist Updates
```xml
<key>SUFeedURL</key>
<string>https://github.com/rothnic/opencode-island/releases.atom</string>
<key>SUEnableAutomaticChecks</key>
<true/>
<key>SUScheduledCheckInterval</key>
<integer>86400</integer>
```

**Deliverables:**
- Memory monitoring active
- Auto-update functional
- User preferences for both

## Phase 4: Testing & Polish (1 week)

### Integration Testing

```bash
# Test script
#!/bin/bash

echo "Testing OpenCode Island..."

# 1. Start OpenCode
opencode --daemon &
OPENCODE_PID=$!

# 2. Start app
open OpenCodeIsland.app

# 3. Wait for connection
sleep 5

# 4. Test commands
opencode "List files in current directory"
opencode "Create a test file"
opencode "Read the test file"

# 5. Check app receives events
osascript -e 'tell application "System Events" to tell process "OpenCodeIsland"
    return value of attribute "AXDescription" of window 1
end tell'

# 6. Cleanup
kill $OPENCODE_PID
```

### User Acceptance Testing

**Test Scenarios:**
1. Fresh install
2. Upgrade from Claude Island
3. Multiple OpenCode sessions
4. Memory warning/restart
5. Auto-update
6. Different LLM providers

### Performance Testing

```swift
// Measure performance
func testPerformance() {
    measure {
        // Parse large config
        _ = configParser.parse(at: largeConfigPath)
    }
    
    measure {
        // Process 100 session events
        for i in 0..<100 {
            socketServer.handleMessage("TOOL_START|tool\(i)")
        }
    }
}
```

## Migration Checklist

### Pre-Migration
- [ ] Backup Claude Island configuration
- [ ] Export Claude sessions
- [ ] Document custom settings
- [ ] Install OpenCode CLI
- [ ] Test OpenCode with sample project

### Configuration Migration
- [ ] Convert `.claude.json` to `opencode.jsonc`
- [ ] Update MCP server configurations
- [ ] Migrate environment variables
- [ ] Test configuration validation
- [ ] Verify MCP servers connect

### Code Migration
- [ ] Update config parser
- [ ] Update session monitor
- [ ] Update hook installer
- [ ] Update UI components
- [ ] Update tool formatters

### Feature Addition
- [ ] Implement memory monitoring
- [ ] Integrate auto-updates
- [ ] Add provider selection UI
- [ ] Add settings panel

### Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing complete
- [ ] Performance acceptable
- [ ] Memory usage normal

### Deployment
- [ ] Build universal binary
- [ ] Sign and notarize
- [ ] Create DMG
- [ ] Upload to GitHub releases
- [ ] Update documentation
- [ ] Announce release

## Rollback Plan

If issues arise:

1. **Keep Claude Island available**
   ```bash
   # Don't delete until OpenCode Island is stable
   mv /Applications/ClaudeIsland.app ~/Backups/
   ```

2. **Configuration backup**
   ```bash
   cp -r ~/.config/opencode ~/.config/opencode.backup
   ```

3. **Easy revert**
   ```bash
   mv ~/Backups/ClaudeIsland.app /Applications/
   mv ~/.config/opencode.backup ~/.config/opencode
   ```

## Post-Migration

### Monitoring

**First Week:**
- Check app logs daily
- Monitor crash reports
- Track memory usage
- Gather user feedback

**First Month:**
- Performance metrics
- User satisfaction survey
- Feature requests
- Bug reports

### Optimization

Based on feedback:
- Optimize memory usage
- Improve UI responsiveness
- Add requested features
- Fix reported bugs

## Support Resources

- **Documentation**: `/docs` directory
- **Issues**: GitHub Issues
- **Discord**: OpenCode community
- **Examples**: `awesome-opencode` repository

## Next Steps

1. Review [Advanced Use Cases](./advanced-use-cases.md) for patterns
2. Check [Research Questions](./research-questions.md) for POC details
3. Explore [OpenCode-Specific Config](./opencode-specific-config.md) for implementation

## Success Metrics

- **Functionality**: 100% feature parity
- **Performance**: < 10% overhead vs Claude Island
- **Stability**: < 1% crash rate
- **User Satisfaction**: > 90% positive feedback
- **Memory**: < 500MB typical usage
- **Adoption**: > 80% users migrate within 3 months

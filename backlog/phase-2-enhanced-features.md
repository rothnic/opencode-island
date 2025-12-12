# Phase 2: Enhanced Features & MCP Integration

## Phase Overview

**Timeline:** 2-3 weeks  
**Dependencies:** Phase 1 (MVP OpenCode Integration) must be complete  
**Upstream Sync Impact:** Low - Primarily additive features, minimal changes to existing code

## Objectives

- [ ] Implement multi-provider LLM support with UI indicators
- [ ] Add MCP server configuration parsing and management
- [ ] Create provider-aware UI components
- [ ] Enhance tool formatting for all OpenCode tools
- [ ] Add configuration management UI
- [ ] Support multiple MCP servers running simultaneously

## Tasks

### Task Group 1: Multi-Provider Support

**Goal:** Support and display information about different LLM providers (Anthropic, OpenAI, Google, DeepSeek, etc.)

#### 1.1 Provider Detection
- [ ] Extend `OpenCodeConfigParser` to expose provider info
- [ ] Create `ProviderInfo` model with provider metadata
- [ ] Add provider detection from active session
- [ ] Map provider names to display information

**Implementation:**
```swift
// Models/ProviderInfo.swift
struct ProviderInfo {
    let id: String          // "anthropic", "openai", "google", etc.
    let displayName: String // "Anthropic Claude", "OpenAI", "Google Gemini"
    let iconName: String    // SF Symbol name
    let color: Color        // Brand color
    
    static let providers: [String: ProviderInfo] = [
        "anthropic": ProviderInfo(
            id: "anthropic",
            displayName: "Anthropic Claude",
            iconName: "brain",
            color: .orange
        ),
        "openai": ProviderInfo(
            id: "openai",
            displayName: "OpenAI",
            iconName: "sparkles",
            color: .green
        ),
        "google": ProviderInfo(
            id: "google",
            displayName: "Google Gemini",
            iconName: "cloud",
            color: .blue
        ),
        "deepseek": ProviderInfo(
            id: "deepseek",
            displayName: "DeepSeek",
            iconName: "waveform",
            color: .purple
        ),
        // ... more providers
    ]
    
    static func from(providerId: String) -> ProviderInfo {
        return providers[providerId] ?? ProviderInfo(
            id: providerId,
            displayName: providerId.capitalized,
            iconName: "cpu",
            color: .gray
        )
    }
}
```

#### 1.2 Model Information Display
- [ ] Parse model name from configuration
- [ ] Create `ModelInfo` component for UI
- [ ] Display provider + model in session list
- [ ] Show model info in conversation view
- [ ] Add tooltip with full model details

**UI Component:**
```swift
// UI/Components/ModelInfoView.swift
struct ModelInfoView: View {
    let provider: ProviderInfo
    let modelName: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: provider.iconName)
                .foregroundColor(provider.color)
            Text(modelName)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .help("\(provider.displayName) - \(modelName)")
    }
}
```

#### 1.3 Provider-Specific Handling
- [ ] Handle provider-specific quirks if any
- [ ] Support different context window sizes
- [ ] Map provider capabilities to UI features
- [ ] Add provider-specific tooltips/help

### Task Group 2: MCP Server Integration

**Goal:** Parse, manage, and display MCP server configurations from OpenCode config.

#### 2.1 MCP Configuration Parsing
- [ ] Extend `OpenCodeConfigParser` to parse MCP section
- [ ] Create `MCPServerConfig` models (already started in Phase 1)
- [ ] Support both `local` and `remote` server types
- [ ] Parse environment variables for servers
- [ ] Handle disabled servers

**Enhanced Model:**
```swift
// Models/MCPServerConfig.swift
struct MCPServerConfig: Codable, Identifiable {
    let id: String  // Server name from config
    let type: ServerType
    let command: [String]?
    let url: URL?
    let env: [String: String]?
    let disabled: Bool
    
    enum ServerType: String, Codable {
        case local
        case remote
    }
    
    var displayName: String {
        // Convert "filesystem" → "Filesystem"
        // Convert "github-mcp" → "GitHub MCP"
        return id.split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
    
    var isRunning: Bool {
        // Check if server process is running
        // For local: check process
        // For remote: check connectivity
    }
}
```

#### 2.2 MCP Server Status Monitoring
- [ ] Detect which MCP servers are configured
- [ ] Monitor MCP server process status (for local servers)
- [ ] Check connectivity for remote servers
- [ ] Track server health/errors
- [ ] Show server status in UI

**Service:**
```swift
// Services/MCP/MCPServerMonitor.swift
class MCPServerMonitor: ObservableObject {
    @Published var servers: [MCPServerConfig] = []
    @Published var serverStatus: [String: ServerStatus] = [:]
    
    enum ServerStatus {
        case running
        case stopped
        case error(String)
        case unknown
    }
    
    func loadServers(from config: OpenCodeConfig) {
        self.servers = Array(config.mcp?.map { (key, value) in
            MCPServerConfig(
                id: key,
                type: value.type == "local" ? .local : .remote,
                command: value.command,
                url: value.url.flatMap { URL(string: $0) },
                env: value.env,
                disabled: value.disabled ?? false
            )
        } ?? [])
        
        // Start monitoring
        monitorServerStatus()
    }
    
    private func monitorServerStatus() {
        // Poll or watch for server process status
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            self.updateServerStatus()
        }
    }
}
```

#### 2.3 MCP Server UI
- [ ] Create MCP servers list view
- [ ] Show server status indicators (running/stopped/error)
- [ ] Display server configuration details
- [ ] Add expand/collapse for server details
- [ ] Show which tools each server provides (if detectable)

**UI Component:**
```swift
// UI/Views/MCPServersView.swift
struct MCPServersView: View {
    @ObservedObject var monitor: MCPServerMonitor
    
    var body: some View {
        List(monitor.servers) { server in
            MCPServerRow(server: server, status: monitor.serverStatus[server.id] ?? .unknown)
        }
    }
}

struct MCPServerRow: View {
    let server: MCPServerConfig
    let status: MCPServerMonitor.ServerStatus
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                statusIndicator
                Text(server.displayName)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
            }
            .onTapGesture { isExpanded.toggle() }
            
            if isExpanded {
                serverDetails
            }
        }
    }
    
    var statusIndicator: some View {
        Circle()
            .fill(statusColor)
            .frame(width: 8, height: 8)
    }
    
    var statusColor: Color {
        switch status {
        case .running: return .green
        case .stopped: return .gray
        case .error: return .red
        case .unknown: return .yellow
        }
    }
}
```

### Task Group 3: Enhanced Tool Support

**Goal:** Complete support for all 18 OpenCode built-in tools with proper formatting and icons.

#### 3.1 Comprehensive Tool Formatter
- [ ] Expand `OpenCodeToolFormatter` to cover all 18 tools
- [ ] Add icons (SF Symbols) for each tool
- [ ] Add descriptions for each tool
- [ ] Support formatting tool arguments for display

**Complete Tool Reference:**
```swift
// Utilities/OpenCodeToolFormatter.swift
struct ToolDisplayInfo {
    let name: String
    let icon: String
    let category: ToolCategory
    let description: String
    
    enum ToolCategory {
        case file
        case search
        case shell
        case lsp
        case web
        case task
        case special
    }
}

class OpenCodeToolFormatter {
    static let tools: [String: ToolDisplayInfo] = [
        // File operations
        "read": ToolDisplayInfo(
            name: "Read File",
            icon: "doc.text",
            category: .file,
            description: "Read file contents"
        ),
        "write": ToolDisplayInfo(
            name: "Write File",
            icon: "square.and.pencil",
            category: .file,
            description: "Write or create file"
        ),
        "edit": ToolDisplayInfo(
            name: "Edit File",
            icon: "pencil",
            category: .file,
            description: "Edit file with search/replace"
        ),
        "multiedit": ToolDisplayInfo(
            name: "Multi Edit",
            icon: "doc.on.doc",
            category: .file,
            description: "Edit multiple locations in file"
        ),
        "patch": ToolDisplayInfo(
            name: "Apply Patch",
            icon: "bandage",
            category: .file,
            description: "Apply unified diff patch"
        ),
        "ls": ToolDisplayInfo(
            name: "List Directory",
            icon: "folder",
            category: .file,
            description: "List directory contents"
        ),
        
        // Search operations
        "grep": ToolDisplayInfo(
            name: "Grep Search",
            icon: "magnifyingglass",
            category: .search,
            description: "Search file contents with regex"
        ),
        "glob": ToolDisplayInfo(
            name: "Find Files",
            icon: "doc.text.magnifyingglass",
            category: .search,
            description: "Find files by pattern"
        ),
        "codesearch": ToolDisplayInfo(
            name: "Code Search",
            icon: "chevron.left.forwardslash.chevron.right",
            category: .search,
            description: "Semantic code search"
        ),
        
        // Shell operations
        "bash": ToolDisplayInfo(
            name: "Shell Command",
            icon: "terminal",
            category: .shell,
            description: "Execute bash command"
        ),
        "batch": ToolDisplayInfo(
            name: "Batch Commands",
            icon: "terminal.fill",
            category: .shell,
            description: "Execute multiple commands"
        ),
        
        // LSP operations
        "lsp_diagnostics": ToolDisplayInfo(
            name: "Code Diagnostics",
            icon: "exclamationmark.triangle",
            category: .lsp,
            description: "Get code diagnostics from LSP"
        ),
        "lsp_hover": ToolDisplayInfo(
            name: "Code Info",
            icon: "info.circle",
            category: .lsp,
            description: "Get symbol information"
        ),
        
        // Web operations
        "webfetch": ToolDisplayInfo(
            name: "Web Fetch",
            icon: "globe",
            category: .web,
            description: "Fetch web content"
        ),
        "websearch": ToolDisplayInfo(
            name: "Web Search",
            icon: "safari",
            category: .web,
            description: "Search the web"
        ),
        
        // Task operations
        "task": ToolDisplayInfo(
            name: "Task",
            icon: "checklist",
            category: .task,
            description: "Task management"
        ),
        "todoread": ToolDisplayInfo(
            name: "Read TODOs",
            icon: "list.bullet",
            category: .task,
            description: "Read TODO items"
        ),
        "todowrite": ToolDisplayInfo(
            name: "Write TODOs",
            icon: "square.and.pencil",
            category: .task,
            description: "Update TODO items"
        ),
        
        // Special
        "invalid": ToolDisplayInfo(
            name: "Invalid Tool",
            icon: "xmark.circle",
            category: .special,
            description: "Invalid tool call"
        )
    ]
    
    static func formatToolName(_ toolId: String) -> String {
        return tools[toolId]?.name ?? toolId.capitalized
    }
    
    static func getToolIcon(_ toolId: String) -> String {
        return tools[toolId]?.icon ?? "wrench"
    }
    
    static func getToolDescription(_ toolId: String) -> String {
        return tools[toolId]?.description ?? "Unknown tool"
    }
}
```

#### 3.2 Tool Usage Display
- [ ] Show tool icon in session events
- [ ] Display tool arguments in readable format
- [ ] Truncate long arguments intelligently
- [ ] Add expand/collapse for tool details
- [ ] Show tool execution time

**UI Component:**
```swift
// UI/Components/ToolExecutionView.swift
struct ToolExecutionView: View {
    let toolId: String
    let arguments: [String: Any]
    let duration: TimeInterval?
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: OpenCodeToolFormatter.getToolIcon(toolId))
                Text(OpenCodeToolFormatter.formatToolName(toolId))
                    .font(.headline)
                
                if let duration = duration {
                    Text(String(format: "%.2fs", duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: { isExpanded.toggle() }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 2) {
                    Text(OpenCodeToolFormatter.getToolDescription(toolId))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(Array(arguments.keys.sorted()), id: \.self) { key in
                        ArgumentRow(key: key, value: arguments[key])
                    }
                }
                .padding(.leading, 20)
            }
        }
    }
}
```

#### 3.3 Tool Categories
- [ ] Group tools by category in UI
- [ ] Add category filters
- [ ] Show tool usage statistics
- [ ] Display most-used tools

### Task Group 4: Configuration Management UI

**Goal:** Add UI for viewing and managing OpenCode configuration.

#### 4.1 Configuration Viewer
- [ ] Create settings panel for OpenCode Island
- [ ] Display current OpenCode configuration
- [ ] Show which config file is being used
- [ ] Highlight config file path
- [ ] Open config file in editor button

**UI Component:**
```swift
// UI/Views/SettingsView.swift
struct SettingsView: View {
    @ObservedObject var configManager: ConfigurationManager
    
    var body: some View {
        TabView {
            GeneralSettingsView(configManager: configManager)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            MCPServersView(monitor: configManager.mcpMonitor)
                .tabItem {
                    Label("MCP Servers", systemImage: "server.rack")
                }
            
            ProviderSettingsView(configManager: configManager)
                .tabItem {
                    Label("Provider", systemImage: "cloud")
                }
        }
        .frame(width: 600, height: 400)
    }
}

struct GeneralSettingsView: View {
    @ObservedObject var configManager: ConfigurationManager
    
    var body: some View {
        Form {
            Section("Configuration") {
                LabeledContent("Config File") {
                    HStack {
                        Text(configManager.configPath ?? "Not found")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                        
                        Button("Open") {
                            if let path = configManager.configPath {
                                NSWorkspace.shared.openFile(path)
                            }
                        }
                    }
                }
                
                LabeledContent("Valid") {
                    Image(systemName: configManager.isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(configManager.isValid ? .green : .red)
                }
            }
            
            Section("Model") {
                LabeledContent("Provider") {
                    if let provider = configManager.currentProvider {
                        HStack {
                            Image(systemName: provider.iconName)
                                .foregroundColor(provider.color)
                            Text(provider.displayName)
                        }
                    } else {
                        Text("Not configured")
                            .foregroundColor(.secondary)
                    }
                }
                
                LabeledContent("Model") {
                    Text(configManager.currentModel ?? "Not configured")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}
```

#### 4.2 Configuration Manager Service
- [ ] Create `ConfigurationManager` service
- [ ] Watch config file for changes
- [ ] Reload configuration automatically
- [ ] Validate configuration
- [ ] Notify UI of config changes

**Service:**
```swift
// Services/Config/ConfigurationManager.swift
class ConfigurationManager: ObservableObject {
    @Published var config: OpenCodeConfig?
    @Published var configPath: String?
    @Published var isValid: Bool = false
    @Published var validationErrors: [String] = []
    
    let mcpMonitor = MCPServerMonitor()
    private let parser = OpenCodeConfigParser()
    private var fileWatcher: FileWatcher?
    
    init() {
        loadConfiguration()
        watchConfiguration()
    }
    
    func loadConfiguration() {
        guard let url = parser.findConfigFile() else {
            configPath = nil
            isValid = false
            return
        }
        
        configPath = url.path
        
        do {
            config = try parser.parse(at: url)
            isValid = true
            validationErrors = []
            
            // Update MCP monitor
            if let config = config {
                mcpMonitor.loadServers(from: config)
            }
        } catch {
            isValid = false
            validationErrors = [error.localizedDescription]
        }
    }
    
    func watchConfiguration() {
        guard let path = configPath else { return }
        
        fileWatcher = FileWatcher(path: path) { [weak self] in
            self?.loadConfiguration()
        }
    }
    
    var currentProvider: ProviderInfo? {
        guard let providerId = config?.model?.provider else { return nil }
        return ProviderInfo.from(providerId: providerId)
    }
    
    var currentModel: String? {
        return config?.model?.name
    }
}
```

#### 4.3 Configuration Validation
- [ ] Validate config on load
- [ ] Show validation errors in UI
- [ ] Provide helpful error messages
- [ ] Suggest fixes for common errors

### Task Group 5: Enhanced Session Display

**Goal:** Improve session list and detail views with provider and MCP info.

#### 5.1 Session List Enhancements
- [ ] Add provider icon to session list items
- [ ] Show model name in session list
- [ ] Display active MCP servers per session
- [ ] Add session status indicators
- [ ] Show session duration

**Enhanced UI:**
```swift
// UI/Components/SessionListItem.swift
struct SessionListItem: View {
    let session: Session
    let provider: ProviderInfo?
    let model: String?
    
    var body: some View {
        HStack {
            // Provider icon
            if let provider = provider {
                Image(systemName: provider.iconName)
                    .foregroundColor(provider.color)
                    .frame(width: 20)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(session.name)
                    .font(.headline)
                
                HStack(spacing: 8) {
                    // Model name
                    if let model = model {
                        Text(model)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Duration
                    if let duration = session.duration {
                        Text(formatDuration(duration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Status indicator
            statusIndicator
        }
        .padding(.vertical, 4)
    }
    
    var statusIndicator: some View {
        Circle()
            .fill(session.isActive ? Color.green : Color.gray)
            .frame(width: 8, height: 8)
    }
}
```

#### 5.2 Session Detail View
- [ ] Show full provider and model information
- [ ] Display MCP servers used in session
- [ ] Show tool usage breakdown
- [ ] Add session statistics (tokens, time, etc. if available)

#### 5.3 Session Filtering
- [ ] Filter sessions by provider
- [ ] Filter by active/inactive
- [ ] Search sessions by content
- [ ] Sort sessions by date, duration, provider

### Task Group 6: Testing & Validation

**Goal:** Comprehensive testing of all Phase 2 features.

#### 6.1 Provider Testing
- [ ] Test with Anthropic (Claude)
- [ ] Test with OpenAI (GPT-4)
- [ ] Test with Google (Gemini)
- [ ] Test with local model (Ollama/LMStudio)
- [ ] Verify provider detection works
- [ ] Verify UI shows correct provider info

**Test Configs:**
```jsonc
// test-configs/anthropic.jsonc
{
  "model": { "provider": "anthropic", "name": "claude-sonnet-4" }
}

// test-configs/openai.jsonc
{
  "model": { "provider": "openai", "name": "gpt-4" }
}

// test-configs/google.jsonc
{
  "model": { "provider": "google", "name": "gemini-pro" }
}

// test-configs/local.jsonc
{
  "model": { "provider": "ollama", "name": "codellama:7b" }
}
```

#### 6.2 MCP Testing
- [ ] Test with no MCP servers
- [ ] Test with single MCP server
- [ ] Test with multiple MCP servers
- [ ] Test with disabled MCP server
- [ ] Test MCP server status monitoring
- [ ] Test MCP server error handling

**Test Config:**
```jsonc
// test-configs/multi-mcp.jsonc
{
  "model": { "provider": "anthropic", "name": "claude-sonnet-4" },
  "mcp": {
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/tmp"]
    },
    "github": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
    },
    "memory": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

#### 6.3 UI Testing
- [ ] Test settings panel opens
- [ ] Test configuration display updates
- [ ] Test MCP server list display
- [ ] Test tool formatting for all 18 tools
- [ ] Test session list with different providers
- [ ] Test expanded/collapsed states

#### 6.4 Integration Testing
- [ ] Config file changes trigger UI updates
- [ ] Switching providers works
- [ ] MCP servers start/stop correctly
- [ ] Tool executions show correct formatting
- [ ] Multiple sessions with different providers

## Technical Details

### Implementation Approach

Phase 2 is primarily **additive** - we're adding new features without changing core architecture:

1. **Provider Support:** Parse and display provider info from config
2. **MCP Integration:** Monitor MCP server status and display
3. **Enhanced UI:** Add new components for provider/MCP display
4. **Tool Enhancement:** Complete tool formatter with all 18 tools
5. **Config Management:** Add settings UI for viewing configuration

### Key Files to Create

**New Models:**
- `OpenCodeIsland/Models/ProviderInfo.swift`
- `OpenCodeIsland/Models/MCPServerConfig.swift` (enhance from Phase 1)
- `OpenCodeIsland/Models/ToolDisplayInfo.swift`

**New Services:**
- `OpenCodeIsland/Services/MCP/MCPServerMonitor.swift`
- `OpenCodeIsland/Services/Config/ConfigurationManager.swift`

**New UI Components:**
- `OpenCodeIsland/UI/Components/ModelInfoView.swift`
- `OpenCodeIsland/UI/Components/ToolExecutionView.swift`
- `OpenCodeIsland/UI/Views/SettingsView.swift`
- `OpenCodeIsland/UI/Views/MCPServersView.swift`
- `OpenCodeIsland/UI/Components/SessionListItem.swift` (enhance)

**Enhanced Files:**
- `OpenCodeIsland/Utilities/OpenCodeToolFormatter.swift` (expand)
- `OpenCodeIsland/Services/Config/OpenCodeConfigParser.swift` (enhance)

### Architecture Diagram

```
┌─────────────────────────────────────────┐
│         OpenCode Island App             │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   ConfigurationManager           │  │
│  │   - Loads opencode.jsonc         │  │
│  │   - Watches for changes          │  │
│  │   - Exposes provider info        │  │
│  └──────┬───────────────────────────┘  │
│         │                               │
│  ┌──────▼────────┐  ┌────────────────┐ │
│  │ MCPServer     │  │ ProviderInfo   │ │
│  │ Monitor       │  │ Display        │ │
│  └───────────────┘  └────────────────┘ │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │        UI Layer                   │  │
│  │  - Settings View                  │  │
│  │  - MCP Servers View               │  │
│  │  - Enhanced Session List          │  │
│  │  - Tool Execution Display         │  │
│  └──────────────────────────────────┘  │
│                                         │
└─────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│          OpenCode CLI                    │
│   - Multiple LLM providers               │
│   - Multiple MCP servers                 │
│   - 18 built-in tools                    │
└─────────────────────────────────────────┘
```

## Documentation

### References

**Required:**
- [OpenCode vs Claude Code](../docs/opencode-vs-claude.md) - Provider comparison
- [MCP Server Integration](../docs/mcp-server-integration.md) - MCP details
- [MCP Architecture](../docs/mcp-architecture.md) - MCP concepts
- [OpenCode Tools Reference](../docs/opencode-tools-reference.md) - All 18 tools
- [Configuration Guide](../docs/configuration-guide.md) - Config format

**Reference:**
- [Plugins and Tools Ecosystem](../docs/plugins-and-tools.md) - Plugin system
- [Advanced Use Cases](../docs/advanced-use-cases.md) - Multi-agent patterns

### To Update

- [ ] AGENTS.md - Add Phase 2 features
- [ ] README.md - Update feature list with provider support
- [ ] docs/README.md - Add Phase 2 completion notes

### To Create

- [ ] Phase 2 completion report
- [ ] Provider testing guide
- [ ] MCP server setup guide

## Success Criteria

- [ ] ✅ Multiple LLM providers supported (tested with 3+)
- [ ] ✅ Provider info displayed in UI (icon, name, color)
- [ ] ✅ MCP servers parsed from configuration
- [ ] ✅ MCP server status monitoring working
- [ ] ✅ MCP servers list displays in settings
- [ ] ✅ All 18 OpenCode tools have formatters
- [ ] ✅ Tool icons and descriptions display correctly
- [ ] ✅ Settings panel opens and shows config
- [ ] ✅ Configuration file path displayed
- [ ] ✅ Config file watcher triggers updates
- [ ] ✅ Session list shows provider info
- [ ] ✅ Tool executions show enhanced formatting
- [ ] ✅ Can switch between provider configs
- [ ] ✅ Multiple MCP servers can run simultaneously
- [ ] ✅ No regressions from Phase 1

## Rollback Plan

Phase 2 is additive, so rollback is straightforward:

1. **Revert to Phase 1:**
   ```bash
   git checkout phase-1-complete
   ```

2. **Disable new features:**
   - Comment out provider display code
   - Comment out MCP monitoring code
   - Keep basic functionality from Phase 1

3. **Minimal viable state:**
   - Basic OpenCode integration still works
   - Configuration parsing still works
   - Just without enhanced displays

## Dependencies

**Phase 1 must be complete:**
- Basic OpenCode integration working
- Configuration parser functional
- Hook system operational
- App renamed and working

**External:**
- Access to multiple LLM providers for testing (optional)
- MCP servers installed for testing
- OpenCode CLI with MCP support

## Notes

### Why This Approach

**Additive Strategy:**
- ✅ Doesn't break Phase 1 functionality
- ✅ Can be developed incrementally
- ✅ Each feature can be tested independently
- ✅ Easy to revert if issues arise

**User Benefits:**
- 🎯 See which provider/model is being used
- 🎯 Monitor MCP server health
- 🎯 Better understand tool executions
- 🎯 Manage configuration from UI

### Upstream Sync Considerations

Phase 2 changes are mostly new files:
- New models (ProviderInfo, etc.)
- New services (MCPServerMonitor, ConfigurationManager)
- New UI components

Minimal changes to existing files:
- Enhanced tool formatter (additive)
- Enhanced config parser (additive)
- Enhanced session display (optional decorations)

**Sync strategy:**
- Keep new files separate
- Use extension/decorator pattern when enhancing existing code
- Document all changes for easy merge conflict resolution

### Testing Strategy

**Progressive Testing:**
1. Test provider detection first
2. Then MCP parsing
3. Then UI components
4. Finally integration

**Real-World Testing:**
- Use actual LLM providers (if API keys available)
- Install real MCP servers
- Run real OpenCode sessions
- Test with actual projects

### Timeline

**Week 1: Foundation**
- Days 1-2: Provider support
- Days 3-4: MCP configuration parsing
- Day 5: MCP monitoring service

**Week 2: UI**
- Days 1-2: Settings panel
- Days 3-4: Enhanced displays
- Day 5: Tool formatter completion

**Week 3: Testing & Polish**
- Days 1-2: Provider testing
- Days 3-4: MCP testing
- Day 5: Documentation and wrap-up

## Related Issues

**Depends on:**
- Phase 1: MVP OpenCode Integration (must be complete)

**Blocks:**
- Phase 3: Advanced Capabilities (needs provider/MCP foundation)

**Related:**
- Upstream Claude Island features (track for parity)

## Labels

`phase-2`, `enhancement`, `ui`, `mcp`, `multi-provider`, `configuration`

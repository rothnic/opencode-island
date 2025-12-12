# Phase 1: MVP OpenCode Integration

## Phase Overview

**Timeline:** 2-3 weeks  
**Dependencies:** None (starting phase)  
**Upstream Sync Impact:** Medium - Primarily naming and configuration changes, minimal architectural changes

## Objectives

- [ ] Get OpenCode CLI working as a drop-in replacement for Claude Code
- [ ] Complete comprehensive renaming of all "claude" references (305+ occurrences)
- [ ] Rewrite README.md with OpenCode focus and upstream attribution
- [ ] Implement basic OpenCode configuration parsing
- [ ] Set up OpenCode hook system
- [ ] Validate "Hello World" integration with OpenCode

## Tasks

### Task Group 1: Project Renaming & Rebranding

**Goal:** Systematically rename all Claude references to OpenCode throughout the codebase.

#### 1.1 Directory & File Renaming
- [ ] Rename `ClaudeIsland/` directory to `OpenCodeIsland/`
- [ ] Rename `ClaudeIsland.xcodeproj` to `OpenCodeIsland.xcodeproj`
- [ ] Rename `ClaudeIslandApp.swift` to `OpenCodeIslandApp.swift`
- [ ] Rename `ClaudeSessionMonitor.swift` to `OpenCodeSessionMonitor.swift`
- [ ] Update all file headers and copyright notices
- [ ] Update Xcode project references

**Files to rename:**
```
ClaudeIsland/ → OpenCodeIsland/
ClaudeIsland.xcodeproj/ → OpenCodeIsland.xcodeproj/
App/ClaudeIslandApp.swift → App/OpenCodeIslandApp.swift
Services/Session/ClaudeSessionMonitor.swift → Services/Session/OpenCodeSessionMonitor.swift
```

#### 1.2 Code Reference Updates
- [ ] Update all Swift struct/class names: `ClaudeIsland` → `OpenCodeIsland`
- [ ] Update bundle identifiers in Info.plist
- [ ] Update scheme names in Xcode
- [ ] Update all string literals referencing "Claude" or "claude"
- [ ] Update all comments referencing Claude Code
- [ ] Update analytics event names (if keeping analytics)

**Search and replace patterns (305+ occurrences):**
```bash
# Case-sensitive replacements
"Claude Code" → "OpenCode"
"Claude Island" → "OpenCode Island"
"ClaudeIsland" → "OpenCodeIsland"
"claude-island" → "opencode-island"

# Path updates
"~/.claude/" → "~/.config/opencode/"
"/tmp/claude-island.sock" → "/tmp/opencode-island.sock"
```

#### 1.3 Asset Updates
- [ ] Update app icon if needed (or keep Dynamic Island theme)
- [ ] Update any Claude-specific branding in Assets.xcassets
- [ ] Verify menu bar icon still works
- [ ] Update any splash screens or about dialogs

### Task Group 2: README Rewrite

**Goal:** Create a comprehensive README for OpenCode Island with proper upstream attribution.

#### 2.1 New README Structure
- [ ] Create new README.md with OpenCode Island branding
- [ ] Add prominent upstream attribution to Claude Island
- [ ] Document OpenCode vs Claude Code differences
- [ ] Update feature list for OpenCode capabilities
- [ ] Add multi-provider support information
- [ ] Update installation instructions
- [ ] Update "How It Works" section for OpenCode

**New README sections:**
```markdown
# OpenCode Island

> A macOS menu bar app for OpenCode CLI sessions, based on [Claude Island](https://github.com/farouqaldori/claude-island)

## What's Different from Claude Island

- Supports 75+ LLM providers (not just Claude)
- OpenCode CLI integration instead of Claude Code
- MCP server coordination
- Enhanced configuration management

## Features

- **Multi-Provider Support** — Use Anthropic, OpenAI, Google, DeepSeek, local models, etc.
- **Notch UI** — Animated overlay from MacBook notch
- **Live Session Monitoring** — Track OpenCode sessions in real-time
- **MCP Integration** — Coordinate multiple MCP servers
- **Permission Approvals** — Approve tool executions from notch
- **Chat History** — Full conversation history with markdown

## Requirements

- macOS 12.0+
- OpenCode CLI (`npm install -g @open-codeai/cli`)

## Credits

OpenCode Island is a fork of [Claude Island](https://github.com/farouqaldori/claude-island) 
by [@farouqaldori](https://github.com/farouqaldori), adapted to support OpenCode's 
multi-provider capabilities.
```

#### 2.2 Documentation Updates
- [ ] Update AGENTS.md with new project name
- [ ] Update links in docs/ to reference OpenCode Island
- [ ] Create UPSTREAM_SYNC.md guide for maintaining fork
- [ ] Update LICENSE.md attribution if needed

### Task Group 3: OpenCode Configuration Support

**Goal:** Implement OpenCode configuration file parsing and validation.

#### 3.1 Configuration Parser
- [ ] Create `OpenCodeConfigParser.swift`
- [ ] Implement JSONC parsing (comments support)
- [ ] Support configuration hierarchy:
  - Project root: `opencode.jsonc`
  - Project config dir: `.opencode/opencode.jsonc`
  - Global: `~/.config/opencode/opencode.jsonc`
- [ ] Parse model configuration
- [ ] Parse MCP server configuration
- [ ] Handle environment variable substitution

**Implementation:**
```swift
// OpenCodeConfigParser.swift
import Foundation

struct OpenCodeConfig: Codable {
    let model: ModelConfig?
    let mcp: [String: MCPServerConfig]?
    let plugins: [String: PluginConfig]?
    let tools: ToolsConfig?
    
    struct ModelConfig: Codable {
        let provider: String
        let name: String
        let apiKey: String?
    }
    
    struct MCPServerConfig: Codable {
        let type: String  // "local" or "remote"
        let command: [String]?
        let url: String?
        let env: [String: String]?
        let disabled: Bool?
    }
}

class OpenCodeConfigParser {
    enum ConfigError: Error {
        case fileNotFound
        case invalidJSON
        case validationFailed(String)
    }
    
    func findConfigFile() -> URL? {
        // Search order:
        // 1. Current directory/opencode.jsonc
        // 2. Current directory/.opencode/opencode.jsonc
        // 3. ~/.config/opencode/opencode.jsonc
    }
    
    func parse(at url: URL) throws -> OpenCodeConfig {
        // Load file
        // Strip JSONC comments
        // Parse JSON
        // Validate structure
    }
}
```

#### 3.2 Configuration Testing
- [ ] Create test configurations for different providers
- [ ] Test configuration loading from different paths
- [ ] Test invalid configuration handling
- [ ] Test environment variable substitution

**Test cases:**
```jsonc
// test-anthropic.jsonc
{
  "model": {
    "provider": "anthropic",
    "name": "claude-sonnet-4"
  }
}

// test-openai.jsonc
{
  "model": {
    "provider": "openai",
    "name": "gpt-4"
  }
}

// test-with-mcp.jsonc
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
```

### Task Group 4: OpenCode CLI Integration

**Goal:** Replace Claude Code CLI calls with OpenCode CLI, detect OpenCode process.

#### 4.1 Process Detection
- [ ] Update process finder to look for `opencode` instead of `claude`
- [ ] Support detecting OpenCode running via Node, Bun, or binary
- [ ] Update process tree builder for OpenCode
- [ ] Test process detection on both Intel and Apple Silicon

**Implementation:**
```swift
// ProcessDetection.swift
class OpenCodeProcessFinder {
    func findOpenCodeProcess() -> Process? {
        // Try multiple detection methods:
        // 1. Process named "opencode"
        // 2. Node process with "opencode" in args
        // 3. Bun process with "opencode" in args
        // 4. Check command line: "opencode" or "@open-codeai/cli"
    }
}
```

#### 4.2 Session Monitoring
- [ ] Update `OpenCodeSessionMonitor` (renamed from Claude version)
- [ ] Monitor `~/.config/opencode/sessions/` instead of `~/.claude/sessions/`
- [ ] Parse OpenCode session file format (if different from Claude)
- [ ] Handle OpenCode conversation format (JSONL)
- [ ] Update file watchers for new paths

**Path updates:**
```swift
// Old: ~/.claude/sessions/
// New: ~/.config/opencode/sessions/

// Old: ~/.claude/hooks/
// New: ~/.config/opencode/hooks/

// Old: ~/.claude.json
// New: ~/.config/opencode/opencode.jsonc
```

#### 4.3 Conversation Parsing
- [ ] Verify OpenCode uses same JSONL format as Claude
- [ ] Update `ConversationParser.swift` if format differs
- [ ] Handle OpenCode-specific message types
- [ ] Parse OpenCode tool names (read, write, bash, etc.)

### Task Group 5: Hook System Setup

**Goal:** Install and configure OpenCode hooks for event communication.

#### 5.1 Hook Installer
- [ ] Update `HookInstaller.swift` for OpenCode paths
- [ ] Create OpenCode-compatible hook scripts
- [ ] Install hooks to `~/.config/opencode/hooks/`
- [ ] Set proper permissions (chmod +x)
- [ ] Test hook installation on clean system

**Hook files:**
```bash
~/.config/opencode/hooks/
├── session-start.sh
├── before-tool.sh
└── after-tool.sh
```

**Hook content (session-start.sh):**
```bash
#!/bin/bash
# OpenCode Island Hook: Session Start
SESSION_ID="$1"
echo "SESSION_START|$SESSION_ID|$(date -u +%Y-%m-%dT%H:%M:%SZ)" | nc -U /tmp/opencode-island.sock
```

#### 5.2 Socket Server Updates
- [ ] Update `HookSocketServer.swift` for new socket path
- [ ] Change socket from `/tmp/claude-island.sock` to `/tmp/opencode-island.sock`
- [ ] Parse OpenCode hook message format
- [ ] Handle OpenCode-specific events
- [ ] Test Unix socket communication

**Message format:**
```
EVENT_TYPE|DATA|TIMESTAMP

Examples:
SESSION_START|session-abc123|2025-01-01T00:00:00Z
TOOL_START|read|2025-01-01T00:00:01Z
TOOL_END|read|2025-01-01T00:00:02Z
```

#### 5.3 Hook Testing
- [ ] Test manual hook execution
- [ ] Test hooks fire during OpenCode session
- [ ] Test socket receives messages
- [ ] Test app responds to hook events
- [ ] Test multiple simultaneous sessions

### Task Group 6: Basic UI Updates

**Goal:** Update UI to reflect OpenCode branding and basic functionality.

#### 6.1 App Branding
- [ ] Update app name display: "Claude Island" → "OpenCode Island"
- [ ] Update menu bar tooltip
- [ ] Update about dialog
- [ ] Update notification messages
- [ ] Keep Dynamic Island UI style (it's generic enough)

#### 6.2 Tool Display
- [ ] Update `MCPToolFormatter.swift` for OpenCode tool names
- [ ] Map OpenCode tools to display names:
  - `read` → "Read File"
  - `write` → "Write File"
  - `bash` → "Execute Command"
  - `task` → "Task Management"
  - etc.
- [ ] Handle unknown tool names gracefully

**Tool mapping:**
```swift
// MCPToolFormatter.swift
struct OpenCodeToolFormatter {
    static let toolDisplayNames: [String: String] = [
        "read": "Read File",
        "write": "Write File",
        "edit": "Edit File",
        "bash": "Execute Command",
        "grep": "Search Files",
        "glob": "Find Files",
        "lsp_diagnostics": "Code Diagnostics",
        "webfetch": "Web Fetch",
        "task": "Task Management"
    ]
    
    static func formatToolName(_ toolId: String) -> String {
        return toolDisplayNames[toolId] ?? toolId.capitalized
    }
}
```

#### 6.3 Session Display
- [ ] Update session list to show "OpenCode" sessions
- [ ] Display basic session info (no provider yet - that's Phase 2)
- [ ] Update conversation view
- [ ] Test with actual OpenCode session

### Task Group 7: Build & Validation

**Goal:** Ensure the renamed project builds and runs successfully.

#### 7.1 Build System
- [ ] Update Xcode project settings
- [ ] Verify scheme builds successfully
- [ ] Update build scripts if any
- [ ] Test on both Intel and Apple Silicon (if possible)
- [ ] Fix any build errors from renaming

#### 7.2 "Hello World" Integration Test
- [ ] Install OpenCode CLI: `npm install -g @open-codeai/cli`
- [ ] Create test OpenCode configuration
- [ ] Start OpenCode Island app
- [ ] Run OpenCode command: `opencode "Say hello world"`
- [ ] Verify app detects session
- [ ] Verify hooks fire and app receives events
- [ ] Verify UI updates
- [ ] Verify conversation history appears

**Test script:**
```bash
#!/bin/bash
# test-phase1-integration.sh

echo "=== Phase 1 Integration Test ==="

# 1. Check OpenCode installed
if ! command -v opencode &> /dev/null; then
    echo "❌ OpenCode CLI not installed"
    exit 1
fi
echo "✅ OpenCode CLI found"

# 2. Create test config
cat > /tmp/test-opencode.jsonc << 'EOF'
{
  "model": {
    "provider": "anthropic",
    "name": "claude-sonnet-4"
  }
}
EOF
echo "✅ Test config created"

# 3. Check app running
if ! pgrep -x "OpenCodeIsland" > /dev/null; then
    echo "❌ OpenCodeIsland app not running"
    exit 1
fi
echo "✅ OpenCodeIsland app running"

# 4. Check hooks installed
if [ ! -f ~/.config/opencode/hooks/session-start.sh ]; then
    echo "❌ Hooks not installed"
    exit 1
fi
echo "✅ Hooks installed"

# 5. Run test OpenCode session
echo "Running test OpenCode session..."
echo "Say hello world and describe what OpenCode is" | opencode --config /tmp/test-opencode.jsonc

echo ""
echo "=== Manual Verification Required ==="
echo "1. Check OpenCodeIsland menu bar - did it show activity?"
echo "2. Click the menu bar - do you see a session?"
echo "3. Can you view the conversation history?"
echo "4. Did the notch UI appear (if applicable)?"
```

#### 7.3 Smoke Testing
- [ ] App launches without crashes
- [ ] Menu bar icon appears
- [ ] Configuration loads correctly
- [ ] Process detection works
- [ ] Hooks fire on OpenCode events
- [ ] Unix socket communication works
- [ ] Basic UI interactions work
- [ ] Session monitoring works
- [ ] No obvious regressions from Claude version

## Technical Details

### Implementation Approach

This phase focuses on **renaming and basic integration** without changing the core architecture:

1. **Systematic Renaming:** Use find/replace for 305+ "claude" references
2. **Path Updates:** Change all filesystem paths to OpenCode conventions
3. **Drop-in Replacement:** OpenCode should work where Claude Code did
4. **Minimal UI Changes:** Keep Dynamic Island UI, just update text/names
5. **Configuration Foundation:** Basic config parsing for OpenCode format

### Key Files to Modify

**Renaming (structure preserved):**
- `ClaudeIsland/` → `OpenCodeIsland/` (entire directory)
- `ClaudeIsland.xcodeproj/` → `OpenCodeIsland.xcodeproj/`
- `ClaudeIslandApp.swift` → `OpenCodeIslandApp.swift`
- `ClaudeSessionMonitor.swift` → `OpenCodeSessionMonitor.swift`

**New files to create:**
- `OpenCodeIsland/Services/Config/OpenCodeConfigParser.swift`
- `OpenCodeIsland/Utilities/OpenCodeToolFormatter.swift`
- `backlog/README.md` (this file)
- `UPSTREAM_SYNC.md`

**Files to update significantly:**
- `README.md` - Complete rewrite
- `HookInstaller.swift` - Update paths and hook content
- `HookSocketServer.swift` - Update socket path
- `Info.plist` - Bundle identifier and app name
- `AGENTS.md` - Update project references

**Search pattern across all files:**
```bash
# Find all occurrences (305+ found)
grep -r "claude" -i . --include="*.swift" --include="*.md" --include="*.json" --include="*.plist"

# Key replacements:
# - "Claude" → "OpenCode"
# - "claude" → "opencode"
# - "ClaudeIsland" → "OpenCodeIsland"
# - "~/.claude/" → "~/.config/opencode/"
# - "/tmp/claude-island.sock" → "/tmp/opencode-island.sock"
```

### Configuration Changes

**OpenCode configuration format:**
```jsonc
{
  "model": {
    "provider": "anthropic",  // or "openai", "google", etc.
    "name": "claude-sonnet-4",
    "apiKey": "${ANTHROPIC_API_KEY}"  // env var substitution
  },
  "mcp": {
    "server-name": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/tmp"]
    }
  }
}
```

**Key differences from Claude Code:**
- Uses `mcp` key (not `mcpServers`)
- Command is array (not separate `command` + `args`)
- Type field required: `"local"` or `"remote"`
- Supports plugins and tools sections (future phases)

## Testing Strategy

### Unit Tests
- [ ] `OpenCodeConfigParserTests` - Test configuration loading
- [ ] `PathUpdatesTests` - Verify all paths updated correctly
- [ ] `ProcessDetectionTests` - Test OpenCode process finding
- [ ] `ToolFormatterTests` - Test OpenCode tool name formatting

### Integration Tests
- [ ] Hook installation end-to-end
- [ ] Socket communication test
- [ ] Session monitoring with real OpenCode
- [ ] Configuration loading from different locations

### Manual Testing Scenarios

**Scenario 1: Fresh Install**
1. Clean build of OpenCodeIsland
2. Launch app
3. Install hooks (automatic)
4. Run OpenCode session
5. Verify detection and monitoring

**Scenario 2: Hello World**
1. Configure OpenCode with Anthropic
2. Run: `opencode "Say hello"`
3. App shows session
4. UI updates in real-time
5. Can view conversation

**Scenario 3: Different Provider**
1. Switch config to OpenAI
2. Run: `opencode "What is 2+2?"`
3. App handles session correctly
4. No provider-specific features yet (Phase 2)

**Scenario 4: Multiple Sessions**
1. Start session in terminal 1
2. Start session in terminal 2
3. App shows both sessions
4. Can switch between them

**Scenario 5: Hook Communication**
1. Manually trigger hook: `~/.config/opencode/hooks/session-start.sh test-id`
2. App receives message
3. UI updates accordingly

## Documentation

### References

**Required reading before implementation:**
- [OpenCode vs Claude Code Comparison](../docs/opencode-vs-claude.md) - Understand key differences
- [OpenCode SDK Fundamentals](../docs/opencode-sdk-fundamentals.md) - OpenCode basics
- [Configuration Guide](../docs/configuration-guide.md) - Config format details
- [OpenCode-Specific Configuration](../docs/opencode-specific-config.md) - Schema and validation
- [Migration Strategy](../docs/migration-strategy.md) - Overall migration plan

**Reference during implementation:**
- [OpenCode Tools Reference](../docs/opencode-tools-reference.md) - For tool formatter
- [MCP Server Integration](../docs/mcp-server-integration.md) - For config parsing
- [AGENTS.md](../AGENTS.md) - Project context

### To Update

- [ ] README.md - Complete rewrite with OpenCode focus
- [ ] AGENTS.md - Update all "Claude Island" references to "OpenCode Island"
- [ ] docs/README.md - Verify links still work after renaming
- [ ] Create UPSTREAM_SYNC.md - Document sync process with upstream
- [ ] Update any inline documentation in Swift files

### To Create

- [ ] `UPSTREAM_SYNC.md` - Guide for syncing with farouqaldori/claude-island
- [ ] `TESTING.md` - Manual testing procedures for this phase
- [ ] Phase 1 completion report (after phase done)

## Success Criteria

- [ ] ✅ All 305+ "claude" references renamed to "opencode"
- [ ] ✅ Project builds without errors
- [ ] ✅ App launches and menu bar icon appears
- [ ] ✅ OpenCode CLI process detected
- [ ] ✅ Hooks installed to `~/.config/opencode/hooks/`
- [ ] ✅ Socket communication working at `/tmp/opencode-island.sock`
- [ ] ✅ "Hello World" test passes: app monitors OpenCode session
- [ ] ✅ Configuration parser loads valid OpenCode configs
- [ ] ✅ README.md rewritten with upstream attribution
- [ ] ✅ Session appears in app UI
- [ ] ✅ Conversation history visible
- [ ] ✅ Tool executions shown in UI
- [ ] ✅ No crashes during basic operations
- [ ] ✅ Universal binary builds (Intel + Apple Silicon)

**Definition of Done:**
- Developer can run `opencode "Hello world"` and see the session monitored in OpenCode Island
- All renaming complete and consistent
- README clearly explains this is an OpenCode fork of Claude Island
- Basic configuration parsing works
- Hook system functional

## Rollback Plan

If critical issues arise:

1. **Keep upstream branch:**
   ```bash
   git branch upstream-claude-island d3c7dc9  # Before migration started
   ```

2. **Tag pre-migration state:**
   ```bash
   git tag pre-opencode-migration d3c7dc9
   ```

3. **Revert if needed:**
   ```bash
   git checkout upstream-claude-island
   # Or cherry-pick specific fixes back to Claude version
   ```

4. **Parallel installation:**
   - Keep Claude Island and OpenCode Island as separate apps initially
   - Bundle IDs different: `com.farouqaldori.claude-island` vs `com.rothnic.opencode-island`
   - Different socket paths: `/tmp/claude-island.sock` vs `/tmp/opencode-island.sock`
   - Users can run both during transition

## Dependencies

**External:**
- OpenCode CLI installed (`npm install -g @open-codeai/cli` or similar)
- Node.js or Bun runtime (for OpenCode)
- macOS 12.0+ (same as Claude Island)
- Xcode 14+ (for building)

**Internal:**
- Comprehensive OpenCode documentation (already in `/docs`)
- Understanding of Claude Island architecture
- Access to test with various LLM providers (optional for Phase 1)

## Notes

### Upstream Sync Strategy

To maintain ability to sync with farouqaldori/claude-island:

1. **Document all changes:** Keep detailed notes on what was changed and why
2. **Modular approach:** Keep OpenCode-specific code in new files when possible
3. **Preserve structure:** Don't refactor architecture unnecessarily
4. **Tag points:** Tag before major changes for easy comparison
5. **Regular checks:** Periodically check upstream for bug fixes to backport

**Sync workflow:**
```bash
# Add upstream if not added
git remote add upstream https://github.com/farouqaldori/claude-island

# Fetch upstream changes
git fetch upstream

# Check what's new
git log HEAD..upstream/main --oneline

# Selectively merge or cherry-pick
git cherry-pick <commit>
# Or merge with manual conflict resolution
git merge upstream/main
```

### Why This Approach

**Advantages:**
- ✅ Get working integration quickly (2-3 weeks)
- ✅ Validate OpenCode compatibility early
- ✅ Clear MVP target ("Hello World" working)
- ✅ Renaming done once, comprehensively
- ✅ Foundation for future phases
- ✅ Can sync upstream fixes

**Trade-offs:**
- ⚠️ Phase 1 doesn't include advanced features (that's Phase 2+)
- ⚠️ No provider selection UI yet (uses config file)
- ⚠️ No MCP server management UI yet
- ⚠️ No memory monitoring yet

**Future Phases Build On This:**
- Phase 2: Multi-provider UI, MCP management
- Phase 3: Memory monitoring, auto-update
- Phase 4: Polish, testing, release

### Research Questions Addressed

From [research-questions.md](../docs/research-questions.md):

**POC 1: Configuration Schema Validation**
- ✅ Addressed in Task Group 3
- Will validate OpenCode config format works
- Test with multiple providers

**POC 3: Hook System Compatibility**
- ✅ Addressed in Task Group 5
- Verify OpenCode hooks work with Unix socket
- Test message format compatibility

**Remaining POCs (Phase 2+):**
- POC 2: Memory monitoring → Phase 3
- POC 4: MCP coordination → Phase 2

### Open Questions

1. **Does OpenCode's JSONL format match Claude's exactly?**
   - Assumption: Yes, but will verify during implementation
   - Mitigation: Update ConversationParser if needed

2. **Can we detect OpenCode process reliably?**
   - OpenCode runs via Node/Bun, need multiple detection methods
   - Test on various installation methods

3. **Do all OpenCode hooks fire at same times as Claude's?**
   - Assumption: Similar lifecycle events
   - May need to adjust hook timing

4. **Will environment variable substitution work in Swift parser?**
   - Need to implement `${VAR}` expansion
   - Or rely on OpenCode CLI to do it

### Timeline Breakdown

**Week 1:**
- Days 1-2: Systematic renaming (Task Group 1)
- Days 3-4: README rewrite (Task Group 2)
- Day 5: Configuration parser (Task Group 3.1)

**Week 2:**
- Days 1-2: Configuration testing (Task Group 3.2)
- Days 2-3: OpenCode integration (Task Group 4)
- Days 4-5: Hook system (Task Group 5)

**Week 3:**
- Days 1-2: UI updates (Task Group 6)
- Days 3-4: Build & testing (Task Group 7)
- Day 5: Documentation and wrap-up

**Buffer:** Extra time for unexpected issues, testing, or documentation

## Related Issues

**Blocks:**
- Phase 2: Enhanced Features & MCP Integration (needs this phase complete)

**Blocked By:**
- None (this is the starting phase)

**Related:**
- Upstream Claude Island issues (for feature parity tracking)
- OpenCode SDK issues (for bugs or feature requests)

## Labels

`phase-1`, `mvp`, `enhancement`, `renaming`, `documentation`, `integration`

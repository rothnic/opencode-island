# GitHub Copilot Agents Configuration

This file provides context and references for GitHub Copilot and other AI coding agents working on the OpenCode Island project.

## Project Overview

**OpenCode Island** is a macOS menu bar application that provides a visual interface for OpenCode CLI sessions, similar to Claude Island but supporting multiple LLM providers through OpenCode's open-source platform.

### Key Information
- **Language**: Swift (macOS app), TypeScript/JavaScript (OpenCode CLI)
- **Architecture**: Menu bar app + Unix socket communication + OpenCode CLI integration
- **Migration**: From Claude Code to OpenCode (in progress)
- **Platform**: macOS 12.0+ (Intel & Apple Silicon)

## Project Structure

```
opencode-island/
├── ClaudeIsland/              # Main Swift application
│   ├── ClaudeIslandApp.swift  # App entry point
│   ├── Models/                # Data models
│   ├── Services/              # Business logic
│   ├── Utilities/             # Helper functions
│   └── Views/                 # SwiftUI views
├── docs/                      # Comprehensive documentation
│   ├── README.md              # Documentation index
│   ├── opencode-vs-claude.md # Comparison guide
│   ├── migration-strategy.md # Migration roadmap
│   └── [see Documentation section below]
└── scripts/                   # Build and utility scripts
```

## Documentation Index

### Core Concepts (Read First)
1. **[OpenCode vs Claude Code](./docs/opencode-vs-claude.md)**
   - Feature comparison (75+ LLM providers vs Claude-only)
   - Performance characteristics
   - Cost models and use cases
   - **Use when**: Understanding project requirements and OpenCode capabilities

2. **[OpenCode SDK Fundamentals](./docs/opencode-sdk-fundamentals.md)**
   - Installation and setup
   - Basic configuration
   - Session management
   - Built-in tools
   - **Use when**: Learning OpenCode basics or implementing core features

3. **[MCP Architecture](./docs/mcp-architecture.md)**
   - Model Context Protocol overview
   - Client-server model
   - Single vs multi-server deployment
   - Security and best practices
   - **Use when**: Designing MCP server integration or understanding architecture

### Integration & Configuration
4. **[MCP Server Integration](./docs/mcp-server-integration.md)**
   - Practical MCP server setup
   - Popular servers (filesystem, git, GitHub, Slack, etc.)
   - Configuration examples
   - Troubleshooting
   - **Use when**: Implementing or debugging MCP server connections

5. **[Plugins and Tools Ecosystem](./docs/plugins-and-tools.md)**
   - Plugin system overview
   - Popular community plugins
   - Plugin development guide
   - Tool composition patterns
   - **Use when**: Adding plugin support or understanding tool capabilities

6. **[Configuration Guide](./docs/configuration-guide.md)**
   - Complete configuration reference
   - Model providers
   - Environment variables
   - Project-specific configs
   - **Use when**: Implementing configuration parsing or troubleshooting config issues

7. **[OpenCode Tools Reference](./docs/opencode-tools-reference.md)**
   - All 18 built-in tools documented
   - Tool parameters and examples
   - Best practices
   - **Use when**: Implementing tool formatters or understanding tool behavior
   - **Source**: `packages/opencode/src/tool/` in sst/opencode repository

8. **[OpenCode-Specific Configuration](./docs/opencode-specific-config.md)**
   - OpenCode vs standard MCP config differences
   - Schema validation (Zod-based)
   - OpenCode-skills integration
   - Memory monitoring strategy
   - Auto-update implementation
   - Universal binary builds
   - **Use when**: Dealing with OpenCode-specific features or macOS implementation

### Advanced Topics
9. **[Advanced Use Cases](./docs/advanced-use-cases.md)**
   - Multi-agent development teams
   - Memory-first development
   - Context pruning
   - Session management
   - Real-world examples from awesome-opencode
   - **Use when**: Learning from established patterns or implementing advanced features

10. **[Migration Strategy](./docs/migration-strategy.md)**
    - Phase-by-phase migration plan
    - POC validation
    - Testing strategies
    - Rollback plan
    - **Use when**: Planning or executing migration from Claude to OpenCode

11. **[Research Questions & POCs](./docs/research-questions.md)**
    - Configuration schema validation
    - Memory monitoring tests
    - Hook compatibility testing
    - MCP coordination testing
    - **Use when**: Validating technical approaches before full implementation

## Key External Resources

### OpenCode Official
- **Repository**: [sst/opencode](https://github.com/sst/opencode)
  - Source code for OpenCode CLI
  - Tool implementations: `packages/opencode/src/tool/`
  - Configuration: `packages/opencode/parsers-config.ts`
  - **Use when**: Understanding OpenCode internals or finding implementation details

- **Documentation**: [opencode.ai/docs](https://opencode.ai/docs/)
  - Official guides and API reference
  - **Use when**: Looking for official documentation

### Community Resources
- **awesome-opencode**: [awesome-opencode/awesome-opencode](https://github.com/awesome-opencode/awesome-opencode)
  - Curated list of plugins
  - Example projects
  - Community tools
  - **Use when**: Finding examples or discovering plugins

- **xTamasu/awesome-opencode**: [xTamasu/awesome-opencode](https://github.com/xTamasu/awesome-opencode)
  - 14-agent virtual dev team
  - Advanced patterns
  - **Use when**: Learning multi-agent architectures

- **OpenSkills**: [numman-ali/openskills](https://github.com/numman-ali/openskills)
  - Universal skills loader
  - Compatible with Claude Skills
  - **Use when**: Implementing skills support

### MCP Resources
- **MCP Specification**: [modelcontextprotocol.io](https://modelcontextprotocol.io/)
  - Protocol specification
  - Best practices
  - **Use when**: Understanding MCP protocol details

- **MCP Server Registry**: [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers)
  - Official MCP servers
  - **Use when**: Finding server implementations

## Current Implementation Details

### Claude Island Architecture (Current)
```
┌─────────────────────┐
│   Menu Bar App      │
│   (Swift)           │
└──────┬──────────────┘
       │ Unix Socket
       │ (/tmp/claude-island.sock)
       │
┌──────▼──────────────┐
│   Hook Scripts      │
│   (~/.claude/hooks) │
└──────┬──────────────┘
       │
┌──────▼──────────────┐
│   Claude Code CLI   │
└─────────────────────┘
```

### Target OpenCode Architecture
```
┌─────────────────────┐
│   Menu Bar App      │
│   (Swift)           │
│   + Memory Monitor  │
│   + Auto-Update     │
└──────┬──────────────┘
       │ Unix Socket
       │ (/tmp/opencode-island.sock)
       │
┌──────▼──────────────┐
│   Hook Scripts      │
│   (~/.config/opencode/hooks)
└──────┬──────────────┘
       │
┌──────▼──────────────┐
│   OpenCode CLI      │
│   (Multi-provider)  │
└──────┬──────────────┘
       │
  ┌────┴────┬──────────┐
  │         │          │
┌─▼──┐  ┌──▼─┐    ┌───▼──┐
│MCP │  │MCP │    │ MCP  │
│Srv1│  │Srv2│    │ Srv3 │
└────┘  └────┘    └──────┘
```

## Key Code Locations

### Swift Application
- **Session Monitoring**: `ClaudeIsland/Services/Session/SessionMonitor.swift`
  - Watches for session files
  - Updates UI on changes
  
- **Conversation Parsing**: `ClaudeIsland/Services/Session/ConversationParser.swift`
  - Parses JSONL conversation format
  - Extracts messages and tool uses

- **Tool Formatting**: `ClaudeIsland/Utilities/MCPToolFormatter.swift`
  - Formats tool names for display
  - Handles MCP tool naming conventions
  - **UPDATE NEEDED**: Support OpenCode tool names

- **Hook Server**: `ClaudeIsland/Services/Hook/HookSocketServer.swift`
  - Unix socket server
  - Receives hook events
  - **COMPATIBLE**: Already supports OpenCode event format

### POC Implementation (Phase 1)
- **Configuration Models**: `ClaudeIsland/Models/OpenCodeConfig.swift`
  - OpenCode configuration data structures
  - Model, MCP, tools, UI config types
  
- **Configuration Loader**: `ClaudeIsland/Utilities/OpenCodeConfigLoader.swift`
  - Discovers config from standard locations
  - Merges configs with proper priority
  - JSONC comment support
  - Validation of required fields

- **Process Monitoring**: `ClaudeIsland/Services/Shared/OpenCodeMonitorPOC.swift`
  - Process discovery by name and command line
  - Memory tracking via task_info API
  - Real-time monitoring with thresholds
  - Memory statistics and alerting

### Configuration Files
- **OpenCode Config**: `opencode.jsonc` (project root or `~/.config/opencode/`)
  - Uses `mcp` key (not `mcpServers`)
  - Command is array (not command + args)
  - Zod schema validation

- **Hook Scripts**: `~/.config/opencode/hooks/`
  - `session-start.sh`
  - `before-tool.sh`
  - `after-tool.sh`

## Common Tasks & Solutions

### Task: Parse OpenCode Configuration
**Reference**: [Configuration Guide](./docs/configuration-guide.md), [OpenCode-Specific Config](./docs/opencode-specific-config.md)

**Key Points**:
- OpenCode uses `mcp` not `mcpServers`
- Command is array: `["npx", "-y", "server"]`
- Type field required: `"local"` or `"remote"`
- Zod validation in `parsers-config.ts`

### Task: Monitor OpenCode Process Memory
**Reference**: [OpenCode-Specific Config](./docs/opencode-specific-config.md), [Migration Strategy](./docs/migration-strategy.md)

**Implementation**:
```swift
func getProcessMemory(_ process: Process) -> Int {
    var info = task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<task_basic_info>.size)/4
    
    let result = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
            task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), $0, &count)
        }
    }
    
    return Int(info.resident_size) / 1024 / 1024  // Convert to MB
}
```

### Task: Format OpenCode Tool Names
**Reference**: [OpenCode Tools Reference](./docs/opencode-tools-reference.md)

**OpenCode Tools** (18 built-in):
- File: `read`, `write`, `edit`, `multiedit`, `patch`, `ls`
- Search: `grep`, `glob`, `codesearch`
- Shell: `bash`, `batch`
- LSP: `lsp_diagnostics`, `lsp_hover`
- Web: `webfetch`, `websearch`
- Task: `task`, `todo` (todoread/todowrite)
- Special: `invalid`

### Task: Handle MCP Server Configuration
**Reference**: [MCP Server Integration](./docs/mcp-server-integration.md), [MCP Architecture](./docs/mcp-architecture.md)

**Best Practice**: Multiple servers with single OpenCode coordinator
- Each server has specific responsibility
- OpenCode routes tool calls
- Failure isolation per server

### Task: Implement Auto-Update
**Reference**: [OpenCode-Specific Config](./docs/opencode-specific-config.md)

**Use Sparkle Framework**:
```swift
import Sparkle

let updater = SPUStandardUpdaterController(
    startingUpdater: true,
    updaterDelegate: nil,
    userDriverDelegate: nil
)
```

### Task: Build Universal Binary
**Reference**: [OpenCode-Specific Config](./docs/opencode-specific-config.md)

```bash
xcodebuild -arch arm64 -arch x86_64 ONLY_ACTIVE_ARCH=NO build
lipo -info build/Release/OpenCodeIsland.app/Contents/MacOS/OpenCodeIsland
# Expected: Architectures in the fat file: OpenCodeIsland are: x86_64 arm64
```

## Development Workflow

### Before Starting Work
1. Read relevant documentation from [Documentation Index](#documentation-index)
2. Check [awesome-opencode](https://github.com/awesome-opencode/awesome-opencode) for examples
3. Review [sst/opencode](https://github.com/sst/opencode) source if needed

### When Implementing Features
1. Consult [Migration Strategy](./docs/migration-strategy.md) for phase planning
2. Validate approach with [Research Questions](./docs/research-questions.md)
3. Reference [Advanced Use Cases](./docs/advanced-use-cases.md) for patterns

### When Debugging
1. Check [Configuration Guide](./docs/configuration-guide.md) for config issues
2. Review [MCP Server Integration](./docs/mcp-server-integration.md) for server problems
3. Consult [OpenCode Tools Reference](./docs/opencode-tools-reference.md) for tool behavior

## Migration Status

**Current Phase**: Phase 1 POC Complete ✅

**Completed:**
- ✅ Configuration schema validation and discovery
- ✅ Memory monitoring implementation
- ✅ Hook compatibility validation

**POC Deliverables:**
- [POC-CONFIG-VALIDATION.md](./POC-CONFIG-VALIDATION.md) - Config discovery and merging
- [POC-MEMORY-MONITORING.md](./POC-MEMORY-MONITORING.md) - Process and memory tracking
- [POC-HOOKS-COMPATIBILITY.md](./POC-HOOKS-COMPATIBILITY.md) - Hook system compatibility

**Next Phase**: Phase 2 - Core Integration
- [ ] Replace ClaudeSessionMonitor with OpenCodeSessionMonitor
- [ ] Update hook installer for OpenCode paths
- [ ] Integrate configuration UI
- [ ] Test with OpenCode CLI

**See**: [Migration Strategy](./docs/migration-strategy.md) for complete roadmap

## Quick Reference

### OpenCode Configuration Format
```jsonc
{
  "model": { "provider": "anthropic", "name": "claude-sonnet-4" },
  "mcp": {
    "server-name": {
      "type": "local",
      "command": ["executable", "arg1", "arg2"]
    }
  }
}
```

### Hook Message Format
```
EVENT_TYPE|DATA|TIMESTAMP
```

Examples:
- `SESSION_START|session-123|2025-01-01T00:00:00Z`
- `TOOL_START|read|2025-01-01T00:00:01Z`
- `TOOL_END|read|2025-01-01T00:00:02Z`

### Memory Thresholds
- Warning: 2048 MB (2 GB)
- Critical: 4096 MB (4 GB)
- Check interval: 60 seconds

## Contact & Resources

- **Issues**: [GitHub Issues](https://github.com/rothnic/opencode-island/issues)
- **OpenCode Discord**: For community support
- **awesome-opencode**: For examples and plugins

## Agent-Specific Notes

### For Code Modification
- **Always** check existing Swift code style
- **Always** maintain Unix socket compatibility
- **Never** break backward compatibility without migration path
- **Test** on both Intel and Apple Silicon when possible

### For Documentation
- Keep documents focused (< 500 lines preferred)
- Use clear hierarchies and interlinking
- Include code examples
- Reference external sources

### For Research
- Check awesome-opencode for existing solutions
- Review sst/opencode source for implementation details
- Validate assumptions with POCs before full implementation

---

**Last Updated**: 2025-12-12
**Document Version**: 1.0
**Project Status**: Documentation Complete, POC Phase Pending

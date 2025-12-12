<div align="center">
  <img src="ClaudeIsland/Assets.xcassets/AppIcon.appiconset/icon_128x128.png" alt="Logo" width="100" height="100">
  <h3 align="center">OpenCode Island</h3>
  <p align="center">
    A macOS menu bar app for OpenCode CLI sessions with Dynamic Island-style notifications.
    <br />
    <strong>Multi-provider LLM support • MCP integration • Memory monitoring</strong>
    <br />
    <br />
    <a href="https://github.com/rothnic/opencode-island/releases/latest" target="_blank" rel="noopener noreferrer">
      <img src="https://img.shields.io/github/v/release/rothnic/opencode-island?style=rounded&color=white&labelColor=000000&label=release" alt="Release Version" />
    </a>
    <a href="#" target="_blank" rel="noopener noreferrer">
      <img alt="GitHub Downloads" src="https://img.shields.io/github/downloads/rothnic/opencode-island/total?style=rounded&color=white&labelColor=000000">
    </a>
  </p>
</div>

> **Based on [Claude Island](https://github.com/farouqaldori/claude-island)** by [@farouqaldori](https://github.com/farouqaldori)  
> Adapted to support OpenCode's multi-provider capabilities with 75+ LLM providers.

## 🚀 Status: In Development

**Current Phase:** Phase 1 - POC Complete ✅  
**Next Phase:** Phase 2 - Core Integration (2-3 weeks)

See [Implementation Backlog](./backlog/README.md) for detailed roadmap.

### Phase 1 POC Results
- ✅ [Configuration Discovery & Validation](./POC-CONFIG-VALIDATION.md) - OpenCode config loading and merging
- ✅ [Memory Monitoring](./POC-MEMORY-MONITORING.md) - Process discovery and memory tracking
- ✅ [Hook Compatibility](./POC-HOOKS-COMPATIBILITY.md) - Unix socket communication validated

## ✨ Planned Features

### Phase 1: MVP (Coming Soon)
- **OpenCode Integration** — Full support for OpenCode CLI sessions
- **Multi-Provider Support** — Use Anthropic, OpenAI, Google, DeepSeek, local models, and 75+ providers
- **Notch UI** — Beautiful animated overlay from the MacBook notch
- **Live Session Monitoring** — Track multiple OpenCode sessions in real-time
- **Permission Approvals** — Approve tool executions directly from the notch
- **Chat History** — View conversation history with markdown rendering

### Phase 2: Enhanced Features
- **Provider-Aware UI** — See which LLM provider and model you're using
- **MCP Server Management** — Configure and monitor Model Context Protocol servers
- **Enhanced Tool Display** — Support for all 18 OpenCode built-in tools
- **Configuration UI** — Manage OpenCode configuration from settings

### Phase 3: Advanced Capabilities
- **Memory Monitoring** — Track OpenCode process memory with alerts
- **Auto-Updates** — Automatic update checking and installation
- **OpenSkills Integration** — Support for OpenCode skills (optional)
- **Performance Optimizations** — Enhanced performance for long-running sessions

### Phase 4: Production Ready
- **Universal Binary** — Single app for Intel and Apple Silicon
- **Signed & Notarized** — Fully notarized for easy installation
- **Comprehensive Testing** — Tested across macOS versions and providers
- **Complete Documentation** — User guide, FAQ, and troubleshooting

## 📋 Requirements

- macOS 12.0+ (Intel or Apple Silicon)
- [OpenCode CLI](https://github.com/sst/opencode) (install via npm, Bun, or other package managers)

## 🔧 Installation

**Note:** OpenCode Island is currently in development. Installation instructions will be provided when Phase 1 is complete.

The app will:
1. Install automatically via DMG
2. Set up OpenCode hooks in `~/.config/opencode/hooks/`
3. Monitor OpenCode sessions via Unix socket communication

## 🎯 What Makes OpenCode Island Different?

### vs. Claude Island (Upstream)
- ✅ **75+ LLM Providers** instead of Claude-only
- ✅ **MCP Server Coordination** with multiple servers
- ✅ **Memory Monitoring** for process health
- ✅ **Provider-Aware UI** showing which model you're using
- ✅ **Auto-Updates** via Sparkle
- ✅ Same great Dynamic Island UI

### vs. OpenCode CLI Alone
- ✅ **Visual Feedback** in menu bar without switching windows
- ✅ **Quick Approvals** for tool permissions from notch
- ✅ **Session Management** view all active sessions at a glance
- ✅ **Conversation History** with markdown rendering
- ✅ **Memory Monitoring** catch performance issues early

## 📚 Documentation

### For Users (Coming Soon)
- [User Guide](./docs/USER_GUIDE.md) - How to use OpenCode Island
- [FAQ](./docs/FAQ.md) - Common questions and answers
- [Troubleshooting](./docs/TROUBLESHOOTING.md) - Solve common issues

### For Developers
- [Implementation Backlog](./backlog/README.md) - Phased implementation plan
- [AGENTS.md](./AGENTS.md) - Context for AI coding agents
- [OpenCode Documentation](./docs/README.md) - Comprehensive OpenCode guides
- [Migration Strategy](./docs/migration-strategy.md) - Migration from Claude to OpenCode
- [Upstream Sync Guide](./docs/UPSTREAM_SYNC.md) - How to sync with Claude Island

### Quick Links
- [OpenCode vs Claude Code](./docs/opencode-vs-claude.md) - Feature comparison
- [OpenCode SDK Fundamentals](./docs/opencode-sdk-fundamentals.md) - Learn OpenCode basics
- [MCP Architecture](./docs/mcp-architecture.md) - Understanding MCP
- [Configuration Guide](./docs/configuration-guide.md) - OpenCode configuration

## 🗺️ Roadmap

| Phase | Timeline | Status |
|-------|----------|--------|
| **Phase 1:** POC Validation | 2 weeks | ✅ Complete |
| **Phase 2:** Core OpenCode Integration | 2-3 weeks | 📋 Planned |
| **Phase 3:** Enhanced Features & MCP | 2-3 weeks | 📋 Planned |
| **Phase 4:** Advanced Capabilities | 2 weeks | 📋 Planned |
| **Phase 5:** Polish & Production | 1-2 weeks | 📋 Planned |

**Total estimated time:** 9-12 weeks

See [backlog/SUMMARY.md](./backlog/SUMMARY.md) for detailed roadmap overview.

## 🤝 Contributing

OpenCode Island is under active development. Contributions are welcome!

**Current Focus:** Phase 1 MVP implementation

See [CONTRIBUTING.md](./CONTRIBUTING.md) (coming soon) for guidelines.

## 🙏 Credits

### Upstream Project
OpenCode Island is a fork of [Claude Island](https://github.com/farouqaldori/claude-island) by [@farouqaldori](https://github.com/farouqaldori).

The original Claude Island provides the excellent Dynamic Island UI and session monitoring architecture that OpenCode Island builds upon.

### OpenCode
[OpenCode](https://github.com/sst/opencode) by [SST](https://github.com/sst) is the open-source AI coding agent that powers OpenCode Island.

### Community
- [awesome-opencode](https://github.com/awesome-opencode/awesome-opencode) - Curated OpenCode resources
- [Model Context Protocol](https://modelcontextprotocol.io/) - MCP specification and servers

## 📄 License

Apache 2.0 - See [LICENSE.md](./LICENSE.md)

## 🔗 Links

- **OpenCode Island:** [GitHub Repository](https://github.com/rothnic/opencode-island)
- **Upstream (Claude Island):** [GitHub Repository](https://github.com/farouqaldori/claude-island)
- **OpenCode SDK:** [GitHub Repository](https://github.com/sst/opencode) | [Documentation](https://opencode.ai/docs/)
- **MCP:** [Website](https://modelcontextprotocol.io/) | [Servers](https://github.com/modelcontextprotocol/servers)

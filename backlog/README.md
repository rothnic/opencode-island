# OpenCode Island Implementation Backlog

This directory contains the phased implementation plan for migrating Claude Island to OpenCode Island.

## Overview

**Project Goal:** Migrate Claude Island (macOS menu bar app for Claude Code CLI) to OpenCode Island, supporting OpenCode's multi-provider LLM capabilities while maintaining the ability to sync upstream changes.

**Strategy:** Implement in focused phases that avoid major architectural changes to the upstream codebase, making it easier to merge updates from the original Claude Island project.

## Upstream Relationship

- **Upstream Repository:** [farouqaldori/claude-island](https://github.com/farouqaldori/claude-island)
- **This Fork:** [rothnic/opencode-island](https://github.com/rothnic/opencode-island)
- **Sync Strategy:** Keep changes modular and well-documented to facilitate periodic upstream merges

## Implementation Phases

### Phase 1: MVP OpenCode Integration
**File:** [phase-1-mvp-opencode-integration.md](./phase-1-mvp-opencode-integration.md)

**Duration:** 2-3 weeks  
**Focus:** Get a working "Hello World" with OpenCode, complete renaming, and rewritten README

**Key Deliverables:**
- OpenCode CLI integration working
- Complete "claude" → "opencode" renaming (305+ references)
- New README with upstream attribution
- Basic OpenCode configuration parsing
- OpenCode hook system functional

### Phase 2: Enhanced Features & MCP Integration
**File:** [phase-2-enhanced-features.md](./phase-2-enhanced-features.md)

**Duration:** 2-3 weeks  
**Focus:** Multi-provider support, MCP server integration, enhanced UI

**Key Deliverables:**
- Multi-provider LLM support (Anthropic, OpenAI, Google, etc.)
- MCP server configuration and management
- Provider-aware UI indicators
- Enhanced tool formatting for OpenCode tools

### Phase 3: Advanced Capabilities
**File:** [phase-3-advanced-capabilities.md](./phase-3-advanced-capabilities.md)

**Duration:** 2 weeks  
**Focus:** Memory monitoring, auto-updates, skills integration

**Key Deliverables:**
- Process memory monitoring
- Auto-update system (Sparkle)
- OpenSkills integration (optional)
- Performance optimizations

### Phase 4: Polish & Production Ready
**File:** [phase-4-polish-production.md](./phase-4-polish-production.md)

**Duration:** 1-2 weeks  
**Focus:** Testing, documentation, deployment

**Key Deliverables:**
- Comprehensive test suite
- Universal binary (Intel + Apple Silicon)
- Code signing and notarization
- Release automation
- Complete documentation

## Documentation References

All phases reference the comprehensive OpenCode documentation in `/docs`:

- [OpenCode vs Claude Code Comparison](../docs/opencode-vs-claude.md)
- [OpenCode SDK Fundamentals](../docs/opencode-sdk-fundamentals.md)
- [MCP Architecture](../docs/mcp-architecture.md)
- [MCP Server Integration](../docs/mcp-server-integration.md)
- [Configuration Guide](../docs/configuration-guide.md)
- [OpenCode Tools Reference](../docs/opencode-tools-reference.md)
- [OpenCode-Specific Configuration](../docs/opencode-specific-config.md)
- [Migration Strategy](../docs/migration-strategy.md)
- [Advanced Use Cases](../docs/advanced-use-cases.md)
- [Research Questions & POCs](../docs/research-questions.md)

## Issue Creation

When creating GitHub issues from these phase documents:

1. Use the issue template in `.github/ISSUE_TEMPLATE/phase-template.md`
2. Copy the relevant phase content
3. Label appropriately: `phase-1`, `phase-2`, etc.
4. Add `enhancement` label
5. Link dependencies between phases

## Progress Tracking

Track overall progress in the main project README and individual phase files. Each phase should maintain:

- ✅ Completed tasks
- 🔄 In-progress tasks
- ⏸️ Blocked tasks
- ⏭️ Upcoming tasks

## Notes

- **Upstream Sync:** Before starting each phase, check for upstream updates
- **Testing:** Each phase includes its own testing requirements
- **Documentation:** Keep AGENTS.md and docs updated as implementation progresses
- **Rollback:** Each phase includes rollback procedures

# OpenCode SDK Fundamentals

This document covers the core concepts, architecture, and fundamental features of the OpenCode SDK.

## What is OpenCode?

OpenCode is an open-source, terminal-based AI coding agent that supports multiple LLM providers. It provides a powerful CLI and TUI (Terminal User Interface) for interacting with AI assistants to write, refactor, and debug code.

### Key Characteristics
- **Open Source**: MIT licensed, community-driven development
- **Model Agnostic**: Works with 75+ LLM providers
- **Terminal Native**: Built for developer workflows in the terminal
- **Extensible**: Plugin system and MCP server integration
- **Multi-Session**: Run multiple concurrent coding sessions

## Installation

### Prerequisites
- Node.js (v18+) or Bun
- Access to an LLM API (OpenAI, Anthropic, etc.) or local model

### Installation Methods

#### Using NPM
```bash
npm install -g opencode
```

#### Using Bun
```bash
bun install -g opencode
```

#### Using PNPM
```bash
pnpm add -g opencode
```

#### Using Yarn
```bash
yarn global add opencode
```

## Basic Configuration

OpenCode uses configuration files to manage settings, model providers, and tool integrations.

### Configuration File Locations
- **Global**: `~/.config/opencode/opencode.jsonc`
- **Project**: `<project-root>/opencode.jsonc`
- **Settings merge**: Project settings override global settings

### Basic Configuration Structure

```json
{
  "models": {
    "provider": "anthropic",
    "apiKey": "${ANTHROPIC_API_KEY}",
    "model": "claude-sonnet-4"
  },
  "theme": "dark",
  "autoUpdate": true,
  "mcpServers": {}
}
```

## Core Features

### 1. Terminal User Interface (TUI)

OpenCode provides a rich terminal interface with:
- **Responsive Design**: Adapts to terminal size
- **Themeable**: Customize colors and appearance
- **Multi-pane Layout**: Chat, code preview, file tree
- **Keyboard Navigation**: Efficient keyboard-driven workflow

### 2. Model Management

#### Supported Providers
- OpenAI (GPT-3.5, GPT-4, GPT-4 Turbo)
- Anthropic (Claude Opus, Sonnet, Haiku)
- Google (Gemini Pro, Gemini Ultra)
- DeepSeek
- Qwen
- Local models (Ollama, LM Studio)
- Many more via OpenRouter or direct APIs

#### Switching Models
```bash
opencode --model gpt-4
opencode --model claude-sonnet-4
opencode --model local/llama3
```

### 3. Session Management

OpenCode supports multiple concurrent sessions:

```bash
# Start a new session
opencode

# List active sessions
opencode sessions list

# Resume a session
opencode sessions resume <session-id>

# Share a session
opencode sessions share <session-id>
```

### 4. Language Server Protocol (LSP) Integration

OpenCode uses LSP for deep code understanding:
- **Auto-context**: Automatically includes relevant code
- **Symbol Navigation**: Jump to definitions and references
- **Type Information**: Access type hints and documentation
- **Refactoring Support**: Safe rename, extract method, etc.

### 5. Built-in Tools

OpenCode includes native tools for common operations:

#### File Operations
- **Read**: Read file contents with line numbers
- **Write**: Create or overwrite files
- **Edit**: Make targeted edits to existing files

#### Code Search
- **Grep**: Search file contents with regex
- **Glob**: Find files by pattern

#### Shell Integration
- **Bash**: Execute shell commands
- **BashOutput**: Check status of background commands
- **KillShell**: Terminate running processes

#### Web Tools
- **WebFetch**: Retrieve web content
- **WebSearch**: Search the web for information

#### Task Management
- **Task**: Spawn sub-agents for complex tasks
- **TodoWrite**: Manage project todos
- **AskUserQuestion**: Interactive user input

## Working with OpenCode

### Basic Workflow

1. **Start a session**
   ```bash
   cd /path/to/project
   opencode
   ```

2. **Describe your task**
   ```
   Create a Python function to calculate Fibonacci numbers
   ```

3. **Review and approve changes**
   - OpenCode shows proposed file changes
   - Approve or reject each change
   - Provide feedback for iterations

4. **Continue the conversation**
   - Ask follow-up questions
   - Request modifications
   - Add new features

### Advanced Workflows

#### Multi-File Refactoring
```
Refactor the authentication system to use JWT tokens instead of sessions.
Update all affected files and tests.
```

#### Bug Investigation
```
There's a memory leak in the data processing pipeline.
Find and fix the issue.
```

#### Test Generation
```
Generate comprehensive unit tests for the UserService class.
Include edge cases and error handling.
```

## Plugin System

Plugins extend OpenCode's functionality with custom tools and behaviors.

### Plugin Structure
```
~/.config/opencode/plugins/
  my-plugin/
    plugin.json
    index.js
```

### Plugin Capabilities
- Add custom tools
- Integrate with external services
- Modify agent behavior
- Extend UI components

### Installing Plugins
```bash
opencode plugin install <plugin-name>
opencode plugin list
opencode plugin remove <plugin-name>
```

## MCP Integration

OpenCode supports the Model Context Protocol (MCP) for tool integration.

### What is MCP?
MCP is an open standard for connecting AI agents to external tools and services through a unified protocol.

### MCP Server Configuration
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "mcp-server-filesystem",
      "args": ["/workspace"]
    },
    "database": {
      "command": "python",
      "args": ["-m", "mcp_server_sqlite"],
      "env": {
        "DB_PATH": "/data/app.db"
      }
    }
  }
}
```

See [MCP Server Integration](./mcp-server-integration.md) for details.

## Context Management

### Auto-Context
OpenCode automatically includes relevant code context:
- Currently open files
- Recently modified files
- Related symbols and imports
- Project structure

### Manual Context Control
```
@file:src/utils/helpers.js
@symbol:processData
```

### Context Window Optimization
- OpenCode dynamically manages context
- Prunes less relevant information
- Prioritizes recent changes
- Uses LSP for smart context selection

## Performance Considerations

### Model Selection
- **Complex tasks**: Use GPT-4 or Claude Sonnet-4
- **Simple tasks**: Use GPT-3.5 or Claude Haiku for cost savings
- **Offline work**: Use local models via Ollama

### Context Size
- Monitor token usage to control costs
- Use targeted context for faster responses
- Clear context when switching tasks

### Caching
- OpenCode caches LSP results
- File contents are cached locally
- Model responses can be cached (provider-dependent)

## Best Practices

### 1. Clear Communication
- Be specific about requirements
- Provide examples when helpful
- Break complex tasks into steps

### 2. Iterative Development
- Start with small changes
- Test and verify before proceeding
- Provide feedback for improvements

### 3. Context Management
- Keep sessions focused on related tasks
- Clear context when switching topics
- Manually add important files when needed

### 4. Tool Usage
- Leverage built-in tools effectively
- Install plugins for specialized needs
- Configure MCP servers for external integrations

### 5. Cost Control
- Use appropriate models for task complexity
- Monitor API usage
- Consider local models for development

## Troubleshooting

### Common Issues

#### Model Connection Errors
```bash
# Check API key configuration
echo $ANTHROPIC_API_KEY

# Verify configuration
opencode config show
```

#### LSP Not Working
```bash
# Install language server
npm install -g typescript-language-server

# Verify LSP configuration
opencode lsp status
```

#### Performance Issues
- Reduce context window size
- Use faster model for simple tasks
- Check network connectivity
- Clear session cache

## Next Steps

- Learn about [MCP Architecture](./mcp-architecture.md)
- Explore [Plugins and Tools](./plugins-and-tools.md)
- Read the [Configuration Guide](./configuration-guide.md)
- Check out [Advanced Use Cases](./advanced-use-cases.md)

## Additional Resources

- [Official OpenCode Documentation](https://opencode.ai/docs/)
- [OpenCode GitHub Repository](https://github.com/opencode-ai/opencode)
- [OpenCode Discord Community](https://discord.gg/opencode)
- [Awesome OpenCode](https://github.com/awesome-opencode/awesome-opencode)

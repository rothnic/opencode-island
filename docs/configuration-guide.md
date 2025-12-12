# Configuration Guide

This comprehensive guide covers all configuration options for OpenCode, including global settings, project-specific configurations, MCP servers, plugins, and environment variables.

## Configuration Files

### Configuration File Locations

OpenCode uses a hierarchical configuration system:

1. **Global Configuration** (User-level)
   - `~/.config/opencode/opencode.jsonc`
   - Applies to all OpenCode sessions
   
2. **Project Configuration** (Project-level)
   - `<project-root>/.opencode/opencode.jsonc`
   - Project-specific overrides

3. **Environment Variables**
   - Runtime configuration
   - Highest priority

### Configuration Merging

Settings are merged in this order (later overrides earlier):
1. Default values
2. Global configuration
3. Project configuration
4. Environment variables

## Complete Configuration Schema

```jsonc
{
  // ===== Model Configuration =====
  "models": {
    "provider": "anthropic",        // Provider name
    "apiKey": "${ANTHROPIC_API_KEY}", // API key (use env var)
    "model": "claude-sonnet-4",     // Default model
    "temperature": 0.7,             // Creativity (0.0-1.0)
    "maxTokens": 4096,             // Max response tokens
    "topP": 0.9,                    // Nucleus sampling
    "streaming": true,              // Enable streaming responses
    "timeout": 60000,               // Request timeout (ms)
    
    // Multiple model configurations
    "configurations": {
      "fast": {
        "provider": "openai",
        "model": "gpt-3.5-turbo"
      },
      "powerful": {
        "provider": "anthropic",
        "model": "claude-opus-4"
      },
      "local": {
        "provider": "ollama",
        "model": "llama3",
        "baseUrl": "http://localhost:11434"
      }
    }
  },
  
  // ===== UI Configuration =====
  "ui": {
    "theme": "dark",                // "dark", "light", "auto"
    "colorScheme": "default",       // Color scheme name
    "fontSize": 14,                 // Terminal font size
    "showLineNumbers": true,        // Show line numbers in code
    "showTokenCount": true,         // Display token usage
    "compactMode": false,           // Compact UI layout
    "animations": true,             // Enable animations
    "notificationSound": true,      // Play sound on events
    "cursorStyle": "block"          // "block", "underline", "bar"
  },
  
  // ===== Session Configuration =====
  "session": {
    "autoSave": true,              // Auto-save sessions
    "saveInterval": 30000,         // Save interval (ms)
    "maxHistory": 100,             // Max chat history entries
    "persistContext": true,        // Persist context between sessions
    "compression": true,           // Compress session data
    "encryption": false            // Encrypt session data
  },
  
  // ===== Context Configuration =====
  "context": {
    "autoInclude": true,           // Auto-include relevant files
    "maxFileSize": 100000,         // Max file size to include (bytes)
    "maxFiles": 50,                // Max files in context
    "includeHidden": false,        // Include hidden files
    "excludePatterns": [           // Exclude patterns
      "node_modules/**",
      "dist/**",
      "*.log"
    ],
    "lspEnabled": true,            // Enable LSP integration
    "lspTimeout": 5000            // LSP request timeout (ms)
  },
  
  // ===== Tool Configuration =====
  "tools": {
    "enabled": true,               // Enable tools
    "autoApprove": false,          // Auto-approve tool calls
    "timeout": 30000,              // Tool execution timeout
    "maxConcurrent": 5,            // Max concurrent tool calls
    "retries": 3,                  // Retry failed tools
    "bashTimeout": 60000,          // Bash command timeout
    "webFetchTimeout": 30000,      // Web fetch timeout
    "allowedCommands": [],         // Whitelist commands (empty = all)
    "deniedCommands": [            // Blacklist commands
      "rm -rf /",
      "dd if="
    ]
  },
  
  // ===== MCP Servers =====
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/workspace"],
      "description": "File system operations",
      "enabled": true,
      "timeout": 30000,
      "env": {
        "READONLY": "false"
      }
    },
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git"],
      "cwd": "${PROJECT_ROOT}",
      "enabled": true
    },
    "database": {
      "command": "python",
      "args": ["-m", "mcp_server_postgres"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      },
      "enabled": false
    }
  },
  
  // ===== Plugins =====
  "plugins": {
    "opencode-sessions": {
      "enabled": true,
      "config": {
        "storageLocation": "~/.opencode/sessions"
      }
    },
    "opencode-context-analysis": {
      "enabled": true,
      "config": {
        "showInline": true,
        "warnThreshold": 0.8
      }
    }
  },
  
  // ===== Git Integration =====
  "git": {
    "autoCommit": false,           // Auto-commit changes
    "commitMessage": "AI-assisted changes", // Default commit message
    "autoStage": true,             // Auto-stage modified files
    "showDiff": true,              // Show diffs before commit
    "checkIgnored": true           // Check .gitignore
  },
  
  // ===== Security =====
  "security": {
    "requireApproval": true,       // Require approval for sensitive ops
    "sensitivePatterns": [         // Patterns requiring approval
      "rm ",
      "DELETE ",
      "DROP "
    ],
    "allowNetworkAccess": true,    // Allow network requests
    "trustedDomains": [            // Trusted domains for network
      "github.com",
      "api.anthropic.com"
    ],
    "maxFileSize": 10485760,      // Max file size to process (10MB)
    "sandboxMode": false          // Enable sandbox mode
  },
  
  // ===== Performance =====
  "performance": {
    "cacheEnabled": true,          // Enable caching
    "cacheTTL": 3600,             // Cache TTL (seconds)
    "maxCacheSize": 100,          // Max cache entries
    "parallelTools": 3,           // Parallel tool execution
    "debounceDelay": 300,         // Input debounce (ms)
    "lazyLoading": true           // Lazy load features
  },
  
  // ===== Logging =====
  "logging": {
    "level": "info",              // "debug", "info", "warn", "error"
    "file": "~/.opencode/logs/opencode.log",
    "maxFileSize": "10MB",
    "maxFiles": 5,
    "includeTimestamp": true,
    "includeLevel": true,
    "colorize": true,
    "logToolCalls": true,
    "logMCPCalls": true
  },
  
  // ===== Analytics =====
  "analytics": {
    "enabled": false,             // Enable analytics
    "endpoint": "",               // Analytics endpoint
    "anonymize": true,            // Anonymize data
    "events": [                   // Events to track
      "session_start",
      "tool_call",
      "error"
    ]
  },
  
  // ===== Notifications =====
  "notifications": {
    "enabled": true,              // Enable notifications
    "sound": true,                // Play sound
    "desktop": true,              // Show desktop notifications
    "events": {
      "sessionStart": false,
      "toolComplete": true,
      "error": true,
      "approval": true
    }
  },
  
  // ===== Keyboard Shortcuts =====
  "keybindings": {
    "approve": "ctrl+enter",
    "deny": "ctrl+d",
    "interrupt": "ctrl+c",
    "clear": "ctrl+l",
    "history": "ctrl+h",
    "search": "ctrl+f"
  },
  
  // ===== Advanced =====
  "advanced": {
    "experimentalFeatures": false, // Enable experimental features
    "verboseOutput": false,        // Verbose logging
    "debugMode": false,           // Enable debug mode
    "telemetry": true,            // Send telemetry
    "autoUpdate": true,           // Auto-update OpenCode
    "updateChannel": "stable"     // "stable", "beta", "nightly"
  }
}
```

## Model Provider Configuration

### Anthropic (Claude)

```jsonc
{
  "models": {
    "provider": "anthropic",
    "apiKey": "${ANTHROPIC_API_KEY}",
    "model": "claude-sonnet-4",
    "baseUrl": "https://api.anthropic.com" // Optional
  }
}
```

**Environment Variables:**
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
```

### OpenAI (GPT)

```jsonc
{
  "models": {
    "provider": "openai",
    "apiKey": "${OPENAI_API_KEY}",
    "model": "gpt-4-turbo",
    "organization": "${OPENAI_ORG_ID}" // Optional
  }
}
```

**Environment Variables:**
```bash
export OPENAI_API_KEY="sk-..."
export OPENAI_ORG_ID="org-..."
```

### Google (Gemini)

```jsonc
{
  "models": {
    "provider": "google",
    "apiKey": "${GOOGLE_API_KEY}",
    "model": "gemini-pro"
  }
}
```

**Environment Variables:**
```bash
export GOOGLE_API_KEY="..."
```

### Ollama (Local Models)

```jsonc
{
  "models": {
    "provider": "ollama",
    "model": "llama3",
    "baseUrl": "http://localhost:11434",
    "timeout": 120000  // Longer timeout for local models
  }
}
```

### Azure OpenAI

```jsonc
{
  "models": {
    "provider": "azure",
    "apiKey": "${AZURE_OPENAI_KEY}",
    "model": "gpt-4",
    "baseUrl": "https://${AZURE_RESOURCE}.openai.azure.com",
    "deployment": "${AZURE_DEPLOYMENT}",
    "apiVersion": "2024-02-01"
  }
}
```

### OpenRouter (Multiple Providers)

```jsonc
{
  "models": {
    "provider": "openrouter",
    "apiKey": "${OPENROUTER_API_KEY}",
    "model": "anthropic/claude-3-opus",
    "baseUrl": "https://openrouter.ai/api/v1"
  }
}
```

## Environment Variables Reference

### Core Variables

```bash
# API Keys
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
GOOGLE_API_KEY=...
AZURE_OPENAI_KEY=...
OPENROUTER_API_KEY=...

# Configuration
OPENCODE_CONFIG=~/.config/opencode/opencode.jsonc
OPENCODE_LOG_LEVEL=info
OPENCODE_CACHE_DIR=~/.cache/opencode

# Model Settings
OPENCODE_MODEL=claude-sonnet-4
OPENCODE_TEMPERATURE=0.7
OPENCODE_MAX_TOKENS=4096

# Session
OPENCODE_SESSION_DIR=~/.opencode/sessions
OPENCODE_AUTO_SAVE=true

# Security
OPENCODE_REQUIRE_APPROVAL=true
OPENCODE_SANDBOX_MODE=false

# Performance
OPENCODE_CACHE_ENABLED=true
OPENCODE_PARALLEL_TOOLS=3
```

### MCP Server Variables

```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost/db
REDIS_URL=redis://localhost:6379

# GitHub
GITHUB_TOKEN=ghp_...
GITHUB_ORG=myorg

# Slack
SLACK_BOT_TOKEN=xoxb-...
SLACK_TEAM_ID=T...

# AWS
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
```

## Project-Specific Configuration

### Node.js Project

```jsonc
{
  "context": {
    "excludePatterns": [
      "node_modules/**",
      "dist/**",
      "build/**",
      "coverage/**",
      "*.log"
    ]
  },
  "mcpServers": {
    "npm": {
      "command": "npx",
      "args": ["-y", "mcp-server-npm"]
    }
  }
}
```

### Python Project

```jsonc
{
  "context": {
    "excludePatterns": [
      "venv/**",
      "__pycache__/**",
      "*.pyc",
      ".pytest_cache/**"
    ],
    "lspCommand": "pylsp"
  },
  "mcpServers": {
    "pip": {
      "command": "python",
      "args": ["-m", "mcp_server_pip"]
    }
  }
}
```

### Rust Project

```jsonc
{
  "context": {
    "excludePatterns": [
      "target/**",
      "Cargo.lock"
    ],
    "lspCommand": "rust-analyzer"
  }
}
```

### Monorepo Configuration

```jsonc
{
  "workspaces": {
    "enabled": true,
    "packages": [
      "packages/*",
      "apps/*"
    ]
  },
  "context": {
    "autoIncludeWorkspace": true
  }
}
```

## Team Configuration

### Shared Configuration

```jsonc
// .opencode/team.jsonc (shared via git)
{
  "extends": "./base.jsonc",
  "mcpServers": {
    "company-api": {
      "url": "https://mcp.company.com",
      "headers": {
        "Authorization": "Bearer ${COMPANY_API_TOKEN}"
      }
    }
  },
  "plugins": {
    "company-standards": {
      "enabled": true
    }
  }
}
```

### Personal Overrides

```jsonc
// ~/.config/opencode/personal.jsonc (not shared)
{
  "models": {
    "apiKey": "${MY_PERSONAL_API_KEY}"
  },
  "ui": {
    "theme": "dark",
    "fontSize": 16
  }
}
```

## Configuration Best Practices

### 1. Use Environment Variables for Secrets

**❌ Don't:**
```json
{
  "models": {
    "apiKey": "sk-1234567890"
  }
}
```

**✅ Do:**
```json
{
  "models": {
    "apiKey": "${ANTHROPIC_API_KEY}"
  }
}
```

### 2. Use Configuration Inheritance

```jsonc
// base.jsonc
{
  "context": {
    "autoInclude": true
  },
  "tools": {
    "enabled": true
  }
}

// opencode.jsonc
{
  "extends": "./base.jsonc",
  "models": {
    "provider": "anthropic"
  }
}
```

### 3. Document Team Configurations

```jsonc
{
  "// NOTE": "This is our team's standard configuration",
  "// USAGE": "Copy to .opencode/opencode.jsonc and set env vars",
  "// REQUIRED_ENV": ["ANTHROPIC_API_KEY", "GITHUB_TOKEN"],
  
  "models": {
    "provider": "anthropic"
  }
}
```

### 4. Use Profiles for Different Scenarios

```bash
# Development
opencode --profile dev

# Production
opencode --profile prod

# Testing
opencode --profile test
```

```jsonc
// profiles/dev.jsonc
{
  "models": {
    "model": "gpt-3.5-turbo"  // Cheaper model for dev
  },
  "logging": {
    "level": "debug"
  }
}

// profiles/prod.jsonc
{
  "models": {
    "model": "claude-opus-4"  // Best model for prod
  },
  "security": {
    "requireApproval": true
  }
}
```

## Configuration Validation

### Validate Configuration

```bash
# Check configuration validity
opencode config validate

# Show resolved configuration
opencode config show

# Test MCP servers
opencode config test-mcp
```

### Configuration Schema

OpenCode validates against a JSON schema. Access it:

```bash
# View schema
opencode config schema

# Export schema
opencode config schema > opencode-schema.json
```

## Troubleshooting Configuration

### Common Issues

**Configuration not loading:**
```bash
# Check file path
ls -la ~/.config/opencode/opencode.jsonc

# Validate JSON syntax
opencode config validate

# Check permissions
chmod 600 ~/.config/opencode/opencode.jsonc
```

**Environment variables not substituting:**
```bash
# Check variable is set
echo $ANTHROPIC_API_KEY

# Use proper syntax
"${VAR_NAME}" not "$VAR_NAME"
```

**MCP servers not connecting:**
```bash
# Test individual server
opencode mcp test server-name

# Check logs
opencode mcp logs server-name

# Verify command exists
which npx
which python
```

## Configuration Examples

### Minimal Configuration

```jsonc
{
  "models": {
    "provider": "anthropic",
    "apiKey": "${ANTHROPIC_API_KEY}"
  }
}
```

### Full-Featured Configuration

See complete schema section above for comprehensive example.

### CI/CD Configuration

```jsonc
{
  "models": {
    "provider": "anthropic",
    "apiKey": "${CI_API_KEY}",
    "model": "claude-haiku-4"  // Fast, cheap model for CI
  },
  "ui": {
    "animations": false,
    "notificationSound": false
  },
  "session": {
    "autoSave": false
  },
  "security": {
    "requireApproval": false  // Auto-approve in CI
  },
  "logging": {
    "level": "info",
    "file": "./ci-logs/opencode.log"
  }
}
```

## Next Steps

- Review [MCP Server Integration](./mcp-server-integration.md) for server-specific configuration
- Explore [Plugins and Tools](./plugins-and-tools.md) for plugin configuration
- Check [Advanced Use Cases](./advanced-use-cases.md) for configuration examples
- Read [Migration Strategy](./migration-strategy.md) for migration guidance

## References

- [OpenCode Configuration Documentation](https://opencode.ai/docs/config/)
- [Configuration Schema Reference](https://opencode.ai/docs/config/schema)
- [Environment Variables Guide](https://opencode.ai/docs/config/env-vars)

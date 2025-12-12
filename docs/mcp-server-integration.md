# MCP Server Integration

This document provides practical guidance for integrating MCP servers with OpenCode, including configuration, development, and deployment.

## Getting Started with MCP Servers

### What You'll Need
- OpenCode CLI installed
- Basic understanding of JSON configuration
- (Optional) Development tools for creating custom servers

## Finding MCP Servers

### Official MCP Server Directory
- [MCP Server Registry](https://github.com/modelcontextprotocol/servers)
- Community-maintained servers
- Verified and tested implementations

### Awesome OpenCode Resources
- [awesome-opencode](https://github.com/awesome-opencode/awesome-opencode)
- Community plugins and servers
- Example implementations

### Popular MCP Servers

#### File System Server
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/workspace"],
      "description": "Access to file system operations"
    }
  }
}
```

#### Git Server
```json
{
  "mcpServers": {
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git"],
      "cwd": "${PROJECT_ROOT}",
      "description": "Git operations and repository management"
    }
  }
}
```

#### SQLite Server
```json
{
  "mcpServers": {
    "sqlite": {
      "command": "python",
      "args": ["-m", "mcp_server_sqlite", "/path/to/database.db"],
      "description": "SQLite database queries"
    }
  }
}
```

#### GitHub Server
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      },
      "description": "GitHub API integration"
    }
  }
}
```

#### Slack Server
```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "mcp-server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}",
        "SLACK_TEAM_ID": "${SLACK_TEAM_ID}"
      },
      "description": "Send and receive Slack messages"
    }
  }
}
```

#### PostgreSQL Server
```json
{
  "mcpServers": {
    "postgres": {
      "command": "docker",
      "args": [
        "run", "-i", "--rm",
        "-e", "DATABASE_URL=${POSTGRES_URL}",
        "mcp-postgres-server"
      ],
      "description": "PostgreSQL database operations"
    }
  }
}
```

## Configuration Guide

### Configuration File Structure

OpenCode looks for MCP server configurations in:
1. `<project>/.opencode/opencode.jsonc` (project-specific)
2. `~/.config/opencode/opencode.jsonc` (user global)
3. Environment variables for sensitive data

### Basic Server Configuration

```json
{
  "mcpServers": {
    "server-name": {
      "command": "executable-path",
      "args": ["arg1", "arg2"],
      "cwd": "/working/directory",
      "env": {
        "ENV_VAR": "value"
      },
      "disabled": false,
      "timeout": 30000
    }
  }
}
```

### Configuration Options

| Option | Type | Description | Default |
|--------|------|-------------|---------|
| `command` | string | Executable command | Required |
| `args` | array | Command arguments | `[]` |
| `cwd` | string | Working directory | Current directory |
| `env` | object | Environment variables | `{}` |
| `disabled` | boolean | Disable server | `false` |
| `timeout` | number | Connection timeout (ms) | `30000` |
| `description` | string | Human-readable description | `""` |

### Environment Variable Substitution

Use environment variables for sensitive data:

```json
{
  "mcpServers": {
    "api-server": {
      "command": "mcp-api-server",
      "env": {
        "API_KEY": "${API_KEY}",
        "API_URL": "${API_URL:-https://api.default.com}"
      }
    }
  }
}
```

Format: `${VAR_NAME}` or `${VAR_NAME:-default_value}`

### Remote Server Configuration

For HTTP-based servers:

```json
{
  "mcpServers": {
    "remote-api": {
      "url": "https://mcp.example.com/api",
      "headers": {
        "Authorization": "Bearer ${API_TOKEN}",
        "X-Custom-Header": "value"
      },
      "timeout": 60000
    }
  }
}
```

## Managing MCP Servers

### OpenCode CLI Commands

```bash
# List configured servers
opencode mcp list

# Show server details
opencode mcp describe <server-name>

# List available tools from a server
opencode mcp tools <server-name>

# Test a server connection
opencode mcp test <server-name>

# Refresh server capabilities
opencode mcp refresh

# Enable a disabled server
opencode mcp enable <server-name>

# Disable a server
opencode mcp disable <server-name>

# View server logs
opencode mcp logs <server-name>
```

## Creating Custom MCP Servers

### Server Development Options

#### Python Server
```python
# mcp_server.py
from mcp.server import MCPServer
from mcp.tools import tool

server = MCPServer("my-server")

@tool(name="greet", description="Greet a user")
def greet(name: str) -> str:
    return f"Hello, {name}!"

if __name__ == "__main__":
    server.run()
```

#### Node.js Server
```javascript
// server.js
const { MCPServer } = require('@modelcontextprotocol/sdk');

const server = new MCPServer('my-server');

server.registerTool({
  name: 'greet',
  description: 'Greet a user',
  inputSchema: {
    type: 'object',
    properties: {
      name: { type: 'string' }
    },
    required: ['name']
  },
  handler: async ({ name }) => {
    return { text: `Hello, ${name}!` };
  }
});

server.start();
```

#### Go Server
```go
// server.go
package main

import (
    "github.com/modelcontextprotocol/go-sdk/mcp"
)

func main() {
    server := mcp.NewServer("my-server")
    
    server.RegisterTool(&mcp.Tool{
        Name:        "greet",
        Description: "Greet a user",
        Handler:     greetHandler,
    })
    
    server.Run()
}

func greetHandler(params map[string]interface{}) (interface{}, error) {
    name := params["name"].(string)
    return map[string]string{
        "text": "Hello, " + name + "!",
    }, nil
}
```

### Tool Definition Best Practices

```json
{
  "name": "descriptive_tool_name",
  "description": "Clear, concise description of what the tool does",
  "inputSchema": {
    "type": "object",
    "properties": {
      "param1": {
        "type": "string",
        "description": "Detailed parameter description",
        "enum": ["option1", "option2"]  // For limited options
      },
      "param2": {
        "type": "number",
        "minimum": 0,
        "maximum": 100
      }
    },
    "required": ["param1"]
  }
}
```

## Advanced Integration Patterns

### 1. Conditional Server Loading

Load servers based on project type:

```json
{
  "mcpServers": {
    "python-tools": {
      "command": "python-mcp-server",
      "condition": "${PROJECT_TYPE} == 'python'"
    },
    "node-tools": {
      "command": "node-mcp-server",
      "condition": "${PROJECT_TYPE} == 'node'"
    }
  }
}
```

### 2. Server Composition

Combine multiple servers for complex workflows:

```json
{
  "workflows": {
    "deploy": {
      "steps": [
        { "server": "git", "tool": "commit" },
        { "server": "docker", "tool": "build" },
        { "server": "kubernetes", "tool": "deploy" },
        { "server": "slack", "tool": "notify" }
      ]
    }
  }
}
```

### 3. Server Chaining

Pass output from one server to another:

```
Agent workflow:
1. Use 'database' server to query user data
2. Use 'email' server to send personalized emails
3. Use 'analytics' server to log activity
```

### 4. Fallback Servers

Configure backup servers:

```json
{
  "mcpServers": {
    "primary-api": {
      "url": "https://api.primary.com",
      "priority": 1
    },
    "backup-api": {
      "url": "https://api.backup.com",
      "priority": 2,
      "fallback": true
    }
  }
}
```

## Security Best Practices

### 1. Credential Management

**Don't:**
```json
{
  "mcpServers": {
    "api": {
      "env": {
        "API_KEY": "sk-1234567890abcdef"  // ❌ Hardcoded secret
      }
    }
  }
}
```

**Do:**
```json
{
  "mcpServers": {
    "api": {
      "env": {
        "API_KEY": "${API_KEY}"  // ✅ Use environment variable
      }
    }
  }
}
```

### 2. Least Privilege Access

Grant only necessary permissions:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "mcp-filesystem",
      "args": ["--readonly", "/workspace/src"],
      "permissions": {
        "read": true,
        "write": false,
        "delete": false
      }
    }
  }
}
```

### 3. Network Isolation

Restrict server network access:

```json
{
  "mcpServers": {
    "database": {
      "command": "docker",
      "args": [
        "run", "--network=host",
        "--env", "DB_HOST=localhost",
        "mcp-db-server"
      ]
    }
  }
}
```

### 4. Input Validation

Servers should validate all inputs:

```python
@tool(name="execute_query")
def execute_query(query: str) -> dict:
    # Validate input
    if not is_safe_query(query):
        raise ValueError("Unsafe query detected")
    
    # Sanitize input
    query = sanitize_sql(query)
    
    # Execute with limits
    return execute_with_limits(query, max_rows=1000)
```

### 5. Audit Logging

Log all server interactions:

```json
{
  "logging": {
    "mcpServers": {
      "logLevel": "info",
      "logFile": "/var/log/opencode/mcp-servers.log",
      "includeTimestamp": true,
      "includeToolCalls": true,
      "redactSecrets": true
    }
  }
}
```

## Troubleshooting

### Server Connection Issues

**Problem**: Server won't start
```bash
# Check if command exists
which mcp-server-filesystem

# Test server manually
python -m mcp_server_sqlite test.db --test

# Check OpenCode logs
opencode mcp logs <server-name> --tail 50
```

**Problem**: Timeout errors
```json
{
  "mcpServers": {
    "slow-server": {
      "timeout": 60000,  // Increase from 30s to 60s
      "retries": 3
    }
  }
}
```

### Tool Discovery Issues

**Problem**: Tools not appearing
```bash
# Refresh MCP cache
opencode mcp refresh

# Verify server status
opencode mcp test <server-name>

# Check tool list
opencode mcp tools <server-name>
```

### Permission Issues

**Problem**: Access denied errors
```bash
# Check file permissions
ls -la $(which mcp-server-filesystem)

# Verify environment variables
env | grep API_KEY

# Check server logs for auth errors
opencode mcp logs <server-name> | grep -i "auth\|permission"
```

## Performance Optimization

### 1. Connection Pooling

```json
{
  "mcpServers": {
    "database": {
      "pooling": {
        "enabled": true,
        "minConnections": 2,
        "maxConnections": 10,
        "idleTimeout": 30000
      }
    }
  }
}
```

### 2. Caching

```json
{
  "mcpServers": {
    "api": {
      "cache": {
        "enabled": true,
        "ttl": 300,  // 5 minutes
        "maxSize": 100
      }
    }
  }
}
```

### 3. Lazy Loading

Only load servers when needed:

```json
{
  "mcpServers": {
    "heavy-server": {
      "lazyLoad": true,
      "loadOnDemand": true
    }
  }
}
```

## Testing MCP Servers

### Unit Testing Tools

```python
# test_mcp_server.py
from mcp.testing import MCPServerTest

def test_greet_tool():
    server = MCPServerTest("my-server")
    result = server.call_tool("greet", {"name": "Alice"})
    assert result["text"] == "Hello, Alice!"
```

### Integration Testing

```bash
# Test with OpenCode
opencode --test-mcp-server my-server

# Test specific tool
opencode mcp call my-server greet '{"name": "Alice"}'
```

## Deployment Scenarios

### Development

```json
{
  "mcpServers": {
    "dev-tools": {
      "command": "mcp-dev-server",
      "env": {
        "DEBUG": "true",
        "LOG_LEVEL": "debug"
      }
    }
  }
}
```

### Production

```json
{
  "mcpServers": {
    "prod-api": {
      "url": "https://mcp-prod.company.com",
      "headers": {
        "Authorization": "Bearer ${PROD_API_TOKEN}"
      },
      "timeout": 30000,
      "retries": 3,
      "circuit_breaker": {
        "enabled": true,
        "threshold": 5,
        "timeout": 60000
      }
    }
  }
}
```

## Real-World Examples

### Example 1: Development Workflow

```json
{
  "mcpServers": {
    "git": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-git"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "docker": {
      "command": "mcp-docker-server"
    }
  }
}
```

**Workflow**: Commit code → Create PR → Build Docker image

### Example 2: Data Pipeline

```json
{
  "mcpServers": {
    "postgres": {
      "command": "mcp-postgres-server",
      "env": {
        "DATABASE_URL": "${POSTGRES_URL}"
      }
    },
    "redis": {
      "command": "mcp-redis-server",
      "env": {
        "REDIS_URL": "${REDIS_URL}"
      }
    },
    "s3": {
      "command": "mcp-s3-server",
      "env": {
        "AWS_ACCESS_KEY": "${AWS_ACCESS_KEY}",
        "AWS_SECRET_KEY": "${AWS_SECRET_KEY}"
      }
    }
  }
}
```

**Workflow**: Query database → Process data → Cache in Redis → Upload to S3

### Example 3: Monitoring & Alerts

```json
{
  "mcpServers": {
    "prometheus": {
      "url": "https://prometheus.company.com/mcp"
    },
    "pagerduty": {
      "command": "mcp-pagerduty",
      "env": {
        "PD_API_KEY": "${PAGERDUTY_API_KEY}"
      }
    },
    "slack": {
      "command": "npx",
      "args": ["-y", "mcp-server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}"
      }
    }
  }
}
```

**Workflow**: Check metrics → Detect issue → Create incident → Notify team

## Next Steps

- Review [Configuration Guide](./configuration-guide.md) for full configuration options
- Explore [Plugins and Tools](./plugins-and-tools.md) for additional capabilities
- Check [Advanced Use Cases](./advanced-use-cases.md) for real-world examples
- Read [MCP Architecture](./mcp-architecture.md) for deeper understanding

## Resources

- [MCP Specification](https://modelcontextprotocol.io/)
- [MCP Server Registry](https://github.com/modelcontextprotocol/servers)
- [OpenCode MCP Documentation](https://opencode.ai/docs/mcp/)
- [MCP SDK Documentation](https://github.com/modelcontextprotocol/sdk)

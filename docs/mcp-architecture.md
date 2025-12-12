# MCP Architecture: Model Context Protocol

This document explains the Model Context Protocol (MCP) architecture, its client-server model, and best practices for implementation.

## Overview

Model Context Protocol (MCP) is an open standard that enables AI agents to seamlessly communicate with external tools, services, databases, and APIs through a unified, permission-based protocol.

### Analogy
Think of MCP as "USB-C for AI agents"—a universal connector that eliminates the need for bespoke integrations between every AI tool and service.

## Architecture Components

MCP consists of three core components:

### 1. Host
The application that embeds the AI functionality.

**Examples:**
- Claude Desktop
- Cursor IDE
- VS Code with AI extensions
- OpenCode CLI
- Custom applications

### 2. Client
The component within the host that manages communication with MCP servers.

**Responsibilities:**
- Maintain connections to servers
- Discover available tools and resources
- Format and send requests
- Handle responses and errors
- Manage authentication and permissions
- Choose appropriate transport (stdio, HTTP, SSE)

### 3. Server
A program that exposes specific capabilities to clients.

**Capabilities:**
- **Tools**: Functions the AI can invoke
- **Prompts**: Pre-defined prompt templates
- **Resources**: Access to files, databases, APIs

## Transport Mechanisms

MCP supports multiple transport protocols:

### stdio (Standard Input/Output)
- **Use case**: Local processes
- **Pros**: Simple, low latency, secure
- **Cons**: Local only, process management needed

```json
{
  "command": "python",
  "args": ["-m", "mcp_server"],
  "cwd": "/path/to/server"
}
```

### SSE (Server-Sent Events)
- **Use case**: Remote servers, streaming updates
- **Pros**: Real-time updates, HTTP-based
- **Cons**: One-way communication

### HTTP
- **Use case**: RESTful services, remote deployments
- **Pros**: Standard protocol, firewall-friendly, scalable
- **Cons**: Higher latency than stdio

```json
{
  "url": "https://api.example.com/mcp",
  "headers": {
    "Authorization": "Bearer ${API_TOKEN}"
  }
}
```

## Client-Server Model

### Single Server vs Multiple Servers

#### Single Server Approach

**Advantages:**
- Simpler setup and configuration
- Lower operational overhead
- Direct control over all capabilities
- Easier debugging

**Disadvantages:**
- **Monolithic anti-pattern**: Hard to scale and maintain
- Single point of failure
- Limited specialization
- Difficult to update independently
- Poor separation of concerns

**When to Use:**
- Prototypes and proof-of-concepts
- Simple, tightly-scoped applications
- Single-team ownership
- Limited scale requirements

#### Multiple Server Approach ⭐ **Recommended for Production**

**Advantages:**
- **Single Responsibility Principle**: Each server has one clear purpose
- Independent scaling per capability
- Fault isolation (one failure doesn't affect others)
- Clear team ownership boundaries
- Easier updates and deployments
- Better security segmentation
- Optimal for agentic workflows

**Disadvantages:**
- More complex setup
- Higher initial overhead
- Requires orchestration
- Potential for cross-server latency

**When to Use:**
- Production deployments
- Enterprise environments
- Multi-team organizations
- Scalable architectures
- Advanced agentic workflows

### Multi-Server Architecture Example

```
┌─────────────────┐
│   OpenCode      │
│   (Host)        │
└────────┬────────┘
         │
    ┌────▼────┐
    │  Client │
    └────┬────┘
         │
    ┌────┴────────────────────────┐
    │                             │
┌───▼────┐  ┌────────┐  ┌────────▼─────┐
│  File  │  │Database│  │   Email      │
│ Server │  │ Server │  │   Server     │
└────────┘  └────────┘  └──────────────┘
```

## Server Capabilities

### Tools
Functions that AI agents can invoke to perform actions.

**Example Tool Definition:**
```json
{
  "name": "read_file",
  "description": "Read contents of a file",
  "inputSchema": {
    "type": "object",
    "properties": {
      "path": {
        "type": "string",
        "description": "File path to read"
      }
    },
    "required": ["path"]
  }
}
```

### Resources
Data sources that can be accessed by the AI.

**Example Resource:**
```json
{
  "uri": "file:///workspace/README.md",
  "name": "Project README",
  "mimeType": "text/markdown"
}
```

### Prompts
Pre-defined prompt templates for common workflows.

**Example Prompt:**
```json
{
  "name": "code_review",
  "description": "Review code for quality and security",
  "arguments": [
    {
      "name": "file_path",
      "description": "Path to file to review",
      "required": true
    }
  ]
}
```

## Configuration Best Practices

### 1. Single Responsibility Principle

**Do:**
```json
{
  "mcpServers": {
    "files": {
      "command": "mcp-server-filesystem"
    },
    "database": {
      "command": "mcp-server-postgres"
    },
    "email": {
      "command": "mcp-server-smtp"
    }
  }
}
```

**Don't:**
```json
{
  "mcpServers": {
    "everything": {
      "command": "mcp-server-monolith"
      // One server trying to do everything
    }
  }
}
```

### 2. Defense in Depth Security

**Layered Security Measures:**
- Network isolation per server
- Authentication at the transport level
- Authorization for each tool/resource
- Input validation and sanitization
- Output sanitization
- Audit logging
- Rate limiting

**Example Secure Configuration:**
```json
{
  "mcpServers": {
    "database": {
      "command": "mcp-server-db",
      "env": {
        "DB_HOST": "localhost",
        "DB_USER": "mcp_readonly",
        "DB_MAX_CONNECTIONS": "5"
      },
      "permissions": {
        "allowedTools": ["query", "count"],
        "deniedTools": ["delete", "drop"]
      }
    }
  }
}
```

### 3. Fail-Safe Design Patterns

**Circuit Breaker:**
```javascript
// Pseudo-code for circuit breaker pattern
if (consecutiveFailures > threshold) {
  enterCircuitBreakerMode();
  return cachedResponse();
}
```

**Graceful Degradation:**
- Return cached data if server unavailable
- Provide partial results on timeout
- Clear error messages to users
- Automatic retry with exponential backoff

### 4. Configuration Management

**Environment-Based Configuration:**
```json
{
  "mcpServers": {
    "api": {
      "command": "mcp-server-api",
      "env": {
        "API_URL": "${API_URL}",
        "API_KEY": "${API_KEY}",
        "TIMEOUT_MS": "${TIMEOUT_MS:-30000}"
      }
    }
  }
}
```

**Configuration Hierarchy:**
1. Environment variables (highest priority)
2. Project-specific config
3. User/global config
4. Default values (lowest priority)

### 5. Monitoring and Observability

**Key Metrics to Track:**
- Request/response latency per server
- Error rates and types
- Tool invocation frequency
- Resource consumption
- Authentication failures
- Rate limit hits

**Logging Best Practices:**
```json
{
  "logging": {
    "level": "info",
    "format": "json",
    "outputs": ["stdout", "file"],
    "includeMetadata": true,
    "redactSecrets": true
  }
}
```

## Agentic Workflows with MCP

### Multi-Server Orchestration

AI agents can coordinate multiple MCP servers for complex tasks:

**Example Workflow:**
1. **Database Server**: Query user preferences
2. **File Server**: Read configuration files
3. **API Server**: Fetch external data
4. **Email Server**: Send notification
5. **File Server**: Write report

### Capability Discovery

Agents dynamically discover available tools:

```javascript
// Agent discovers capabilities at runtime
const servers = await client.listServers();
for (const server of servers) {
  const tools = await client.getTools(server);
  console.log(`${server}: ${tools.length} tools available`);
}
```

### Tool Selection

Agents reason about which tools to use:

```
Agent thinking:
- Need to analyze code → Use 'grep' tool from filesystem server
- Need to store results → Use 'insert' tool from database server
- Need to notify team → Use 'send' tool from email server
```

## Implementation Examples

### Basic MCP Server Setup

**Configuration:**
```json
{
  "mcpServers": {
    "opencode": {
      "command": "python",
      "args": ["-m", "src.services.fast_mcp.opencode_server"],
      "cwd": "/path/to/opencode-mcp"
    }
  }
}
```

### Multi-Server Production Setup

**Configuration:**
```json
{
  "mcpServers": {
    "filesystem": {
      "command": "mcp-server-filesystem",
      "args": ["--root", "/workspace"],
      "env": {
        "READONLY": "false"
      }
    },
    "database": {
      "command": "docker",
      "args": ["run", "mcp-postgres-server"],
      "env": {
        "POSTGRES_URL": "${DATABASE_URL}"
      }
    },
    "slack": {
      "url": "https://slack-mcp.company.com",
      "headers": {
        "Authorization": "Bearer ${SLACK_TOKEN}"
      }
    }
  }
}
```

## Advanced Patterns

### Server Composition

Compose multiple specialized servers:
- Authentication server
- Rate limiting server
- Caching server
- Business logic servers

### Dynamic Server Registration

Allow runtime addition/removal of servers:
```javascript
await mcpClient.registerServer('new-service', config);
await mcpClient.unregisterServer('old-service');
```

### Server Health Checks

Monitor server availability:
```javascript
setInterval(async () => {
  for (const server of servers) {
    const healthy = await checkHealth(server);
    if (!healthy) {
      await restartServer(server);
    }
  }
}, 60000); // Check every minute
```

## Security Considerations

### 1. Authentication
- Use API keys or tokens
- Rotate credentials regularly
- Store secrets securely (environment variables, secret managers)

### 2. Authorization
- Implement least-privilege access
- Define tool-level permissions
- Audit permission grants

### 3. Input Validation
- Validate all inputs at the server
- Sanitize file paths
- Restrict command injection
- Validate data types and ranges

### 4. Network Security
- Use TLS for remote servers
- Implement network segmentation
- Restrict server access by IP/network
- Use VPNs for sensitive servers

### 5. Audit Logging
- Log all tool invocations
- Record authentication events
- Track permission checks
- Monitor for suspicious patterns

## Troubleshooting

### Common Issues

**Server Won't Start**
```bash
# Check server logs
opencode mcp logs <server-name>

# Verify command path
which python
which mcp-server-filesystem

# Test server manually
python -m mcp_server --test
```

**Connection Timeout**
```json
{
  "timeout": 30000,  // Increase timeout
  "retries": 3,      // Add retries
  "retryDelay": 1000 // Delay between retries
}
```

**Tool Not Found**
```bash
# Refresh tool list
opencode mcp refresh

# Verify server registration
opencode mcp list-servers

# Check server capabilities
opencode mcp describe <server-name>
```

## Performance Optimization

### 1. Connection Pooling
Reuse connections to servers instead of creating new ones.

### 2. Caching
Cache tool responses when appropriate:
```json
{
  "cache": {
    "enabled": true,
    "ttl": 300,  // 5 minutes
    "maxSize": 100
  }
}
```

### 3. Parallel Execution
Execute independent tool calls in parallel:
```javascript
const results = await Promise.all([
  client.callTool('server1', 'tool1', args1),
  client.callTool('server2', 'tool2', args2),
  client.callTool('server3', 'tool3', args3)
]);
```

### 4. Request Batching
Batch multiple requests to the same server:
```javascript
const results = await client.batchCall('server1', [
  { tool: 'read', args: { path: 'file1.txt' } },
  { tool: 'read', args: { path: 'file2.txt' } },
  { tool: 'read', args: { path: 'file3.txt' } }
]);
```

## Deployment Strategies

### Development
- Use stdio for local servers
- Enable debug logging
- Use test/mock servers

### Staging
- Mix of stdio and HTTP
- Enable monitoring
- Test with production-like data

### Production
- Use HTTP/HTTPS for scalability
- Implement all security measures
- Enable comprehensive monitoring
- Use load balancers
- Implement circuit breakers

## Next Steps

- Explore [MCP Server Integration](./mcp-server-integration.md) for implementation details
- Read about [Plugins and Tools](./plugins-and-tools.md)
- Review [Advanced Use Cases](./advanced-use-cases.md)
- Check the [Configuration Guide](./configuration-guide.md)

## References

- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [MCP Best Practices Guide](https://modelcontextprotocol.info/docs/best-practices/)
- [OpenCode MCP Documentation](https://opencode.ai/docs/mcp/)

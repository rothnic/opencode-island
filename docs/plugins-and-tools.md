# Plugins and Tools Ecosystem

This document explores the OpenCode plugins and tools ecosystem, including available plugins, how to use them, and how to create custom ones.

## Overview

OpenCode's extensibility comes from two main sources:
1. **Plugins**: Extend OpenCode's core functionality
2. **MCP Tools**: External capabilities exposed through MCP servers

## Plugin System

### What are Plugins?

Plugins are modular pieces of code that extend OpenCode's functionality. They can:
- Add custom tools for the AI agent
- Modify agent behavior and decision-making
- Integrate with external services
- Enhance the user interface
- Add new workflows and commands

### Plugin Directory Structure

```
~/.config/opencode/plugins/
├── my-plugin/
│   ├── plugin.json        # Plugin metadata
│   ├── index.js           # Main entry point
│   ├── tools.js           # Tool definitions
│   ├── package.json       # Dependencies
│   └── README.md          # Documentation
└── another-plugin/
    └── ...
```

### Plugin Metadata (plugin.json)

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "My custom OpenCode plugin",
  "author": "Your Name",
  "license": "MIT",
  "main": "index.js",
  "opencode": {
    "minVersion": "1.0.0",
    "maxVersion": "2.0.0"
  },
  "capabilities": [
    "tools",
    "hooks",
    "commands"
  ],
  "dependencies": {
    "axios": "^1.6.0"
  }
}
```

## Popular Plugins

### From awesome-opencode Repository

#### 1. Context Analysis Plugin
**Purpose**: Token usage analysis for advanced context management

```bash
opencode plugin install opencode-context-analysis
```

**Features**:
- Real-time token counting
- Context window optimization
- Token usage reports
- Cost estimation

#### 2. Session Management Plugin
**Purpose**: Advanced session management for multi-agent workflows

```bash
opencode plugin install opencode-sessions
```

**Features**:
- Save and restore sessions
- Share sessions with team
- Session templates
- Collaborative coding

#### 3. Dynamic Context Pruning
**Purpose**: Optimize token usage by pruning obsolete data

```bash
opencode plugin install opencode-dynamic-context-pruning
```

**Features**:
- Automatic context cleanup
- Smart relevance detection
- Custom pruning rules
- Context history tracking

#### 4. OpenSkills
**Purpose**: Modular skills and capabilities management

```bash
opencode plugin install @opencode-skills/openskills
```

**Features**:
- Reusable skill modules
- Skill composition
- Skill marketplace
- Version management

#### 5. Google AI Search Plugin
**Purpose**: Native tool for querying Google AI

```bash
opencode plugin install opencode-google-ai-search
```

**Features**:
- Google Search integration
- Web scraping capabilities
- Result summarization
- Search history

#### 6. Gemini Auth Plugin
**Purpose**: Use your own Gemini plan for API quotas

```bash
opencode plugin install opencode-gemini-auth
```

**Features**:
- Direct Gemini API integration
- Quota management
- Multiple account support
- Usage tracking

#### 7. Warcraft Notifications
**Purpose**: Gamified notifications for OpenCode events

```bash
opencode plugin install opencode-warcraft-notifications
```

**Features**:
- Sound effects for events
- Achievement system
- Custom notification themes
- Progress tracking

#### 8. Roadmap Plugin
**Purpose**: Project-wide planning and strategic histories

```bash
opencode plugin install opencode-roadmap
```

**Features**:
- Project roadmap visualization
- Milestone tracking
- Decision history
- Collaboration features

## Plugin Management

### Installing Plugins

```bash
# Install from npm/registry
opencode plugin install <plugin-name>

# Install from local path
opencode plugin install /path/to/plugin

# Install from git repository
opencode plugin install github:user/repo

# Install specific version
opencode plugin install <plugin-name>@1.2.3
```

### Managing Plugins

```bash
# List installed plugins
opencode plugin list

# Show plugin details
opencode plugin info <plugin-name>

# Update plugin
opencode plugin update <plugin-name>

# Update all plugins
opencode plugin update --all

# Remove plugin
opencode plugin remove <plugin-name>

# Enable/disable plugin
opencode plugin enable <plugin-name>
opencode plugin disable <plugin-name>
```

### Plugin Configuration

Plugins can be configured in `opencode.jsonc`:

```json
{
  "plugins": {
    "my-plugin": {
      "enabled": true,
      "config": {
        "apiKey": "${MY_PLUGIN_API_KEY}",
        "timeout": 30000,
        "customOption": "value"
      }
    }
  }
}
```

## Creating Custom Plugins

### Basic Plugin Structure

```javascript
// index.js
module.exports = {
  name: 'my-plugin',
  version: '1.0.0',
  
  // Initialize plugin
  async initialize(context) {
    console.log('Plugin initialized');
    this.context = context;
  },
  
  // Register tools
  tools: [
    {
      name: 'my_tool',
      description: 'Does something useful',
      inputSchema: {
        type: 'object',
        properties: {
          input: { type: 'string' }
        },
        required: ['input']
      },
      handler: async (params) => {
        return { result: `Processed: ${params.input}` };
      }
    }
  ],
  
  // Register hooks
  hooks: {
    beforeToolCall: async (tool, params) => {
      console.log(`Calling tool: ${tool}`);
    },
    afterToolCall: async (tool, result) => {
      console.log(`Tool completed: ${tool}`);
    }
  },
  
  // Register commands
  commands: [
    {
      name: 'mycommand',
      description: 'My custom command',
      handler: async (args) => {
        console.log('Command executed');
      }
    }
  ]
};
```

### Plugin API

#### Context Object

```javascript
{
  // Configuration
  config: { ... },
  
  // OpenCode SDK
  sdk: {
    callTool: async (name, params) => { ... },
    sendMessage: async (message) => { ... },
    getSession: () => { ... }
  },
  
  // File system
  fs: {
    readFile: async (path) => { ... },
    writeFile: async (path, content) => { ... },
    exists: async (path) => { ... }
  },
  
  // HTTP client
  http: {
    get: async (url, options) => { ... },
    post: async (url, data, options) => { ... }
  },
  
  // Logging
  log: {
    info: (message) => { ... },
    error: (message) => { ... },
    debug: (message) => { ... }
  }
}
```

### Advanced Plugin Example

```javascript
// advanced-plugin/index.js
const axios = require('axios');

module.exports = {
  name: 'advanced-plugin',
  version: '1.0.0',
  
  async initialize(context) {
    this.context = context;
    this.cache = new Map();
    
    // Set up periodic cleanup
    setInterval(() => this.cleanup(), 60000);
  },
  
  tools: [
    {
      name: 'fetch_and_cache',
      description: 'Fetch data from URL with caching',
      inputSchema: {
        type: 'object',
        properties: {
          url: { type: 'string', format: 'uri' },
          ttl: { type: 'number', default: 300 }
        },
        required: ['url']
      },
      handler: async function(params) {
        const { url, ttl } = params;
        
        // Check cache
        if (this.cache.has(url)) {
          const cached = this.cache.get(url);
          if (Date.now() - cached.timestamp < ttl * 1000) {
            this.context.log.info(`Cache hit: ${url}`);
            return cached.data;
          }
        }
        
        // Fetch data
        try {
          const response = await axios.get(url, {
            timeout: this.context.config.timeout || 30000
          });
          
          const data = response.data;
          
          // Cache result
          this.cache.set(url, {
            data,
            timestamp: Date.now()
          });
          
          return data;
        } catch (error) {
          this.context.log.error(`Fetch failed: ${error.message}`);
          throw error;
        }
      }.bind(this)
    }
  ],
  
  hooks: {
    beforeToolCall: async function(tool, params) {
      this.context.log.debug(`Tool call: ${tool}`, params);
    }.bind(this),
    
    afterToolCall: async function(tool, result) {
      // Log metrics
      if (this.context.config.analytics) {
        await this.sendAnalytics(tool, result);
      }
    }.bind(this)
  },
  
  cleanup() {
    // Remove expired cache entries
    const now = Date.now();
    for (const [key, value] of this.cache.entries()) {
      if (now - value.timestamp > 3600000) { // 1 hour
        this.cache.delete(key);
      }
    }
  },
  
  async sendAnalytics(tool, result) {
    // Send usage analytics
    await this.context.http.post(
      this.context.config.analyticsUrl,
      { tool, timestamp: Date.now() }
    );
  }
};
```

## Built-in Tools Reference

### File Operations

#### read
Read file contents
```javascript
{
  path: '/path/to/file',
  viewRange: [1, 100]  // Optional line range
}
```

#### write
Create or overwrite file
```javascript
{
  path: '/path/to/file',
  content: 'File contents'
}
```

#### edit
Make targeted edits
```javascript
{
  path: '/path/to/file',
  oldStr: 'text to replace',
  newStr: 'replacement text'
}
```

### Code Search

#### grep
Search file contents
```javascript
{
  pattern: 'search pattern',
  glob: '*.js',          // File pattern
  outputMode: 'content', // or 'files_with_matches', 'count'
  contextLines: 3        // Lines around match
}
```

#### glob
Find files by pattern
```javascript
{
  pattern: '**/*.js'  // Glob pattern
}
```

### Shell Integration

#### bash
Execute shell command
```javascript
{
  command: 'npm install',
  description: 'Install dependencies',
  mode: 'sync'  // or 'async', 'detached'
}
```

#### bash_output
Check background command status
```javascript
{
  shellId: 'shell-123'
}
```

#### kill_shell
Terminate running process
```javascript
{
  shellId: 'shell-123'
}
```

### Web Tools

#### web_fetch
Fetch web content
```javascript
{
  url: 'https://example.com',
  timeout: 30000
}
```

#### web_search
Search the web
```javascript
{
  query: 'search query',
  maxResults: 10
}
```

### Task Management

#### task
Spawn sub-agent
```javascript
{
  description: 'Task description',
  context: 'Additional context',
  model: 'claude-sonnet-4'  // Optional
}
```

#### todo_write
Update project todos
```javascript
{
  todos: [
    { content: 'Task 1', status: 'pending' },
    { content: 'Task 2', status: 'completed' }
  ]
}
```

### User Interaction

#### ask_user_question
Prompt user for input
```javascript
{
  questions: [
    {
      question: 'What is your name?',
      options: [
        { label: 'Option 1', description: 'First option' },
        { label: 'Option 2', description: 'Second option' }
      ]
    }
  ]
}
```

## Tool Development Best Practices

### 1. Clear Tool Descriptions

```javascript
{
  name: 'calculate_metrics',
  description: 'Calculate code metrics for a file or directory. ' +
               'Returns lines of code, complexity score, and maintainability index.',
  // ...
}
```

### 2. Comprehensive Input Schemas

```javascript
inputSchema: {
  type: 'object',
  properties: {
    path: {
      type: 'string',
      description: 'File or directory path to analyze',
      pattern: '^[a-zA-Z0-9/_.-]+$'
    },
    includeTests: {
      type: 'boolean',
      description: 'Include test files in analysis',
      default: false
    },
    metrics: {
      type: 'array',
      items: {
        type: 'string',
        enum: ['loc', 'complexity', 'maintainability']
      },
      description: 'Metrics to calculate',
      default: ['loc', 'complexity']
    }
  },
  required: ['path']
}
```

### 3. Error Handling

```javascript
handler: async (params) => {
  try {
    // Validate inputs
    if (!params.path) {
      throw new Error('Path is required');
    }
    
    // Perform operation
    const result = await performOperation(params);
    
    // Return structured response
    return {
      success: true,
      data: result
    };
  } catch (error) {
    // Log error
    console.error('Tool error:', error);
    
    // Return error response
    return {
      success: false,
      error: error.message,
      code: error.code || 'UNKNOWN_ERROR'
    };
  }
}
```

### 4. Progress Reporting

```javascript
handler: async (params, context) => {
  const files = await getFiles(params.path);
  
  for (let i = 0; i < files.length; i++) {
    // Report progress
    await context.reportProgress({
      current: i + 1,
      total: files.length,
      message: `Processing ${files[i]}`
    });
    
    await processFile(files[i]);
  }
  
  return { processed: files.length };
}
```

### 5. Caching

```javascript
const cache = new Map();

handler: async (params) => {
  const cacheKey = JSON.stringify(params);
  
  // Check cache
  if (cache.has(cacheKey)) {
    const cached = cache.get(cacheKey);
    if (Date.now() - cached.timestamp < 300000) { // 5 min
      return cached.result;
    }
  }
  
  // Compute result
  const result = await expensiveOperation(params);
  
  // Cache result
  cache.set(cacheKey, {
    result,
    timestamp: Date.now()
  });
  
  return result;
}
```

## Tool Composition Patterns

### Sequential Execution

```javascript
// Agent uses multiple tools in sequence
1. grep → Find relevant files
2. read → Read file contents
3. edit → Make changes
4. bash → Run tests
```

### Parallel Execution

```javascript
// Agent uses tools in parallel
await Promise.all([
  callTool('grep', { pattern: 'TODO' }),
  callTool('glob', { pattern: '*.test.js' }),
  callTool('bash', { command: 'git status' })
]);
```

### Conditional Execution

```javascript
// Agent decides which tools to use
if (needsWebData) {
  await callTool('web_fetch', { url });
} else {
  await callTool('read', { path });
}
```

## Plugin Distribution

### Publishing to npm

```bash
# Prepare package
cd my-plugin
npm init
npm publish
```

### Package.json for Plugin

```json
{
  "name": "opencode-plugin-myname",
  "version": "1.0.0",
  "description": "My OpenCode plugin",
  "keywords": ["opencode", "plugin", "ai"],
  "main": "index.js",
  "scripts": {
    "test": "jest"
  },
  "peerDependencies": {
    "opencode": "^1.0.0"
  }
}
```

### Plugin Testing

```javascript
// test/plugin.test.js
const plugin = require('../index');

describe('My Plugin', () => {
  let context;
  
  beforeEach(() => {
    context = createMockContext();
    plugin.initialize(context);
  });
  
  test('tool returns correct result', async () => {
    const result = await plugin.tools[0].handler({
      input: 'test'
    });
    
    expect(result).toEqual({ result: 'Processed: test' });
  });
});
```

## Community Resources

### Plugin Repositories
- [awesome-opencode](https://github.com/awesome-opencode/awesome-opencode)
- [OpenCode Plugin Directory](https://opencode.ai/plugins)
- [Community Plugins](https://github.com/topics/opencode-plugin)

### Development Resources
- [Plugin Development Guide](https://opencode.ai/docs/plugins/development)
- [Plugin API Reference](https://opencode.ai/docs/plugins/api)
- [Example Plugins](https://github.com/opencode-ai/example-plugins)

### Getting Help
- [OpenCode Discord](https://discord.gg/opencode)
- [GitHub Discussions](https://github.com/opencode-ai/opencode/discussions)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/opencode)

## Next Steps

- Review [Configuration Guide](./configuration-guide.md) for plugin configuration
- Explore [Advanced Use Cases](./advanced-use-cases.md) for real-world examples
- Check [MCP Server Integration](./mcp-server-integration.md) for external tools
- Read [Migration Strategy](./migration-strategy.md) for adapting existing tools

## References

- [OpenCode Plugin Documentation](https://opencode.ai/docs/plugins/)
- [Awesome OpenCode Repository](https://github.com/awesome-opencode/awesome-opencode)
- [Plugin Development Tutorial](https://opencode.ai/docs/tutorials/plugin-development)

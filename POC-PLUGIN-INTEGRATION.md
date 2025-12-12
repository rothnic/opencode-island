# POC: OpenCode Plugin Integration for Session Monitoring

> **✅ CORRECTED APPROACH**: OpenCode uses **plugins** with **event hooks**, not standalone hook scripts.

## Objective
Implement session monitoring for OpenCode Island using OpenCode's plugin system and SDK event subscriptions.

## OpenCode Plugin System Architecture

### Plugin Location
```
~/.config/opencode/plugins/
└── opencode-island-monitor/
    ├── plugin.json        # Plugin metadata
    ├── index.js           # Main entry point with hooks
    └── package.json       # Dependencies
```

### Plugin Capabilities

OpenCode plugins can register **lifecycle hooks** that fire on events:

```javascript
module.exports = {
  name: 'opencode-island-monitor',
  version: '1.0.0',
  
  async initialize(context) {
    this.context = context;
    // Connect to OpenCode Island socket
    this.socket = this.connectToIsland();
  },
  
  // Lifecycle hooks - these ARE the event system
  hooks: {
    // Called before any tool execution
    beforeToolCall: async (tool, params) => {
      // Send event to OpenCode Island
      this.socket.send({
        event: 'PreToolUse',
        tool: tool,
        params: params
      });
    },
    
    // Called after tool completes
    afterToolCall: async (tool, result) => {
      // Send event to OpenCode Island
      this.socket.send({
        event: 'PostToolUse',
        tool: tool,
        result: result
      });
    },
    
    // Session lifecycle
    onSessionStart: async (session) => {
      this.socket.send({
        event: 'SessionStart',
        sessionId: session.id
      });
    },
    
    onSessionEnd: async (session) => {
      this.socket.send({
        event: 'SessionEnd',
        sessionId: session.id
      });
    }
  }
};
```

## Implementation Approach

### Option 1: Custom Plugin (Recommended)

Create a lightweight plugin that bridges OpenCode events to OpenCode Island:

**Benefits:**
- Native integration with OpenCode
- Access to full event lifecycle
- Can use OpenCode SDK
- Real-time event delivery

**Implementation:**
```javascript
// ~/.config/opencode/plugins/opencode-island-monitor/index.js
const net = require('net');

module.exports = {
  name: 'opencode-island-monitor',
  version: '1.0.0',
  description: 'Bridges OpenCode events to OpenCode Island menu bar app',
  
  async initialize(context) {
    this.context = context;
    this.socketPath = '/tmp/opencode-island.sock';
    this.connected = false;
    
    // Attempt to connect to OpenCode Island
    this.connectToIsland();
  },
  
  connectToIsland() {
    try {
      const client = net.connect(this.socketPath, () => {
        this.connected = true;
        this.context.log.info('Connected to OpenCode Island');
      });
      
      client.on('error', (err) => {
        // Silent fail - OpenCode Island may not be running
        this.connected = false;
      });
      
      this.client = client;
    } catch (err) {
      this.connected = false;
    }
  },
  
  sendEvent(event) {
    if (!this.connected) return;
    
    try {
      const data = JSON.stringify(event);
      this.client.write(data + '\n');
    } catch (err) {
      this.context.log.debug('Failed to send event to OpenCode Island');
    }
  },
  
  hooks: {
    beforeToolCall: async function(tool, params) {
      const event = {
        session_id: this.context.sdk.getSession().id,
        cwd: process.cwd(),
        event: 'PreToolUse',
        status: 'running_tool',
        tool: tool,
        tool_input: params
      };
      this.sendEvent(event);
    }.bind(this),
    
    afterToolCall: async function(tool, result) {
      const event = {
        session_id: this.context.sdk.getSession().id,
        cwd: process.cwd(),
        event: 'PostToolUse',
        status: 'idle',
        tool: tool
      };
      this.sendEvent(event);
    }.bind(this),
    
    onSessionStart: async function(session) {
      const event = {
        session_id: session.id,
        cwd: session.cwd || process.cwd(),
        event: 'SessionStart',
        status: 'starting',
        pid: process.pid
      };
      this.sendEvent(event);
    }.bind(this),
    
    onSessionEnd: async function(session) {
      const event = {
        session_id: session.id,
        cwd: session.cwd || process.cwd(),
        event: 'SessionEnd',
        status: 'ended'
      };
      this.sendEvent(event);
    }.bind(this)
  }
};
```

**Plugin metadata:**
```json
// ~/.config/opencode/plugins/opencode-island-monitor/plugin.json
{
  "name": "opencode-island-monitor",
  "version": "1.0.0",
  "description": "Bridges OpenCode events to OpenCode Island menu bar app",
  "author": "OpenCode Island",
  "license": "Apache-2.0",
  "main": "index.js",
  "opencode": {
    "minVersion": "1.0.0"
  },
  "capabilities": [
    "hooks"
  ]
}
```

### Option 2: Session File Watching (Fallback)

If plugin approach is not feasible, use file watching:

```
~/.config/opencode/sessions/
└── [session-id]/
    └── conversation.jsonl    # Watch this file
```

**Benefits:**
- No plugin required
- Works with any OpenCode version
- Proven approach (Claude Island uses this)

**Drawbacks:**
- Polling overhead
- Delayed event delivery
- No beforeToolCall events

## Comparison: Plugins vs File Watching

| Aspect | Plugin with Hooks | File Watching |
|--------|------------------|---------------|
| **Real-time events** | ✅ Immediate | ⚠️ Delayed (polling) |
| **Tool lifecycle** | ✅ Before + After | ❌ After only |
| **Performance** | ✅ Event-driven | ⚠️ CPU for polling |
| **Reliability** | ✅ Direct integration | ✅ Proven |
| **Setup complexity** | ⚠️ Plugin install | ✅ None |
| **OpenCode dependency** | ⚠️ Requires plugin support | ✅ Just files |

## Recommended Implementation

### Phase 1: Plugin-based (Primary)
1. Create `opencode-island-monitor` plugin
2. Bundle with OpenCode Island installer
3. Auto-install on first launch

### Phase 2: File watching (Fallback)
1. If plugin fails to load
2. Fall back to session file watching
3. Same approach as Claude Island

### Phase 3: Hybrid
Use both:
- Plugin for real-time tool events
- File watching for conversation history

## Installation Steps

### For Plugin Approach

1. **Create plugin directory:**
   ```bash
   mkdir -p ~/.config/opencode/plugins/opencode-island-monitor
   ```

2. **Copy plugin files:**
   - `index.js` - Main plugin code
   - `plugin.json` - Metadata
   - `package.json` - Dependencies (if any)

3. **Enable in OpenCode config:**
   ```jsonc
   // ~/.config/opencode/opencode.jsonc
   {
     "plugins": {
       "opencode-island-monitor": {
         "enabled": true
       }
     }
   }
   ```

4. **Verify installation:**
   ```bash
   opencode plugin list
   # Should show: opencode-island-monitor
   ```

### For File Watching Approach

1. **Watch session directory:**
   ```swift
   // ClaudeIsland/Services/Session/OpenCodeSessionWatcher.swift
   let sessionDir = "~/.config/opencode/sessions/"
   // Use FSEvents or similar to watch for changes
   ```

2. **Parse JSONL files:**
   - Same format as Claude Code
   - Parse conversation.jsonl for events

## Event Format Compatibility

Both approaches produce the same event format for HookSocketServer:

```json
{
  "session_id": "abc123",
  "cwd": "/path/to/project",
  "event": "PreToolUse",
  "status": "running_tool",
  "pid": 12345,
  "tool": "read",
  "tool_input": {"path": "file.txt"}
}
```

The existing `HookSocketServer.swift` is **already compatible** - no changes needed.

## Testing

### Test Plugin Installation
```bash
# 1. Install plugin
cp -r plugin-files ~/.config/opencode/plugins/opencode-island-monitor

# 2. Enable plugin
# Edit ~/.config/opencode/opencode.jsonc

# 3. Test OpenCode
opencode "list files"

# 4. Check OpenCode Island receives events
# OpenCode Island should show session activity
```

### Test File Watching
```bash
# 1. Start OpenCode session
opencode "test command"

# 2. Check session files
ls ~/.config/opencode/sessions/

# 3. Verify OpenCode Island picks up session
# Should appear in menu bar
```

## Success Criteria

### Plugin Approach
- ✅ Plugin installs without errors
- ✅ Events sent to socket in real-time
- ✅ beforeToolCall and afterToolCall fire
- ✅ Session lifecycle events captured
- ✅ No impact on OpenCode performance

### File Watching Approach
- ✅ Session files detected
- ✅ JSONL parsing works
- ✅ Events delivered (with delay)
- ✅ Memory usage acceptable
- ✅ Compatible with plugin approach

## Known Limitations

### Plugin Approach
1. **Requires plugin support** - OpenCode must support plugins (appears to based on docs)
2. **Version compatibility** - Plugin API may change
3. **Installation step** - Users must enable plugin

### File Watching Approach
1. **Delayed events** - Not real-time
2. **No pre-tool events** - Can't intercept before execution
3. **Polling overhead** - CPU/disk usage
4. **File format dependency** - JSONL format must remain stable

## Next Steps

1. **Validate plugin API** - Test with OpenCode to confirm hooks work
2. **Implement plugin** - Create opencode-island-monitor plugin
3. **Bundle with app** - Include plugin in OpenCode Island installer
4. **Add fallback** - Implement file watching as backup
5. **Document for users** - Clear setup instructions

## References

- **Plugin system**: `docs/plugins-and-tools.md`
- **Advanced examples**: `docs/advanced-use-cases.md`
- **OpenCode SDK**: `docs/opencode-sdk-fundamentals.md`
- **Existing hook server**: `ClaudeIsland/Services/Hooks/HookSocketServer.swift` (compatible)

## Conclusion

**Correct approach**: Use OpenCode's **plugin system** with **lifecycle hooks**, not standalone hook scripts.

- Primary: Plugin with event hooks (real-time, native)
- Fallback: Session file watching (proven, simple)
- Both compatible with existing HookSocketServer
- No breaking changes to Swift code needed

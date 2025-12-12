# POC Testing Guide

This guide provides step-by-step instructions for manually testing the Phase 1 POC implementations.

## Prerequisites

1. **macOS System** (12.0+)
2. **Xcode** (for building the app)
3. **OpenCode CLI** (optional, for full integration testing)
   ```bash
   npm install -g opencode
   # or
   bun install -g opencode
   ```

## Quick Start

Run the automated test setup:
```bash
./test-poc.sh
```

This script will:
- Create test configuration files
- Install hook scripts
- Test hook execution
- Verify prerequisites
- Test socket communication

## Manual Testing Procedures

### Test 1: Configuration Discovery & Merging

#### Setup Test Configurations

1. **Create global configuration:**
   ```bash
   mkdir -p ~/.config/opencode
   cat > ~/.config/opencode/opencode.jsonc << 'EOF'
   {
     "model": {
       "provider": "anthropic",
       "name": "claude-sonnet-4",
       "api_key": "sk-ant-test-preserved"
     },
     "ui": {
       "theme": "dark"
     }
   }
   EOF
   ```

2. **Create project configuration:**
   ```bash
   mkdir -p /tmp/test-project/.opencode
   cat > /tmp/test-project/.opencode/opencode.jsonc << 'EOF'
   {
     "model": {
       "name": "claude-opus-4"
     },
     "mcp": {
       "filesystem": {
         "type": "local",
         "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/tmp"]
       }
     }
   }
   EOF
   ```

#### Test Configuration Loading

The configuration loader should:
- ✅ Find global config at `~/.config/opencode/opencode.jsonc`
- ✅ Find project config at `/tmp/test-project/.opencode/opencode.jsonc`
- ✅ Merge configs with project overriding global
- ✅ Preserve API key from global config
- ✅ Use model name from project config

**Expected merged result:**
```jsonc
{
  "model": {
    "provider": "anthropic",      // from global
    "name": "claude-opus-4",       // from project (overrides)
    "api_key": "sk-ant-test-preserved"  // from global (preserved)
  },
  "mcp": {
    "filesystem": { ... }           // from project
  },
  "ui": {
    "theme": "dark"                 // from global
  }
}
```

#### Test JSONC Comment Support

1. **Create config with comments:**
   ```bash
   cat > /tmp/test-comments.jsonc << 'EOF'
   {
     // This is a single-line comment
     "model": {
       "provider": "anthropic",  // inline comment
       "name": "claude-sonnet-4"
     },
     /* This is a
        multi-line comment */
     "ui": {
       "theme": "dark"
     }
   }
   EOF
   ```

2. **Verify parsing:**
   - Comments should be stripped before JSON parsing
   - Configuration should load successfully
   - All fields should be present

#### Test Validation

Create invalid configs and verify error detection:

1. **Missing model provider:**
   ```jsonc
   {
     "model": {
       "name": "claude-sonnet-4"
       // provider is missing
     }
   }
   ```
   Expected error: "Model provider not specified"

2. **Local MCP server without command:**
   ```jsonc
   {
     "mcp": {
       "server": {
         "type": "local"
         // command is missing
       }
     }
   }
   ```
   Expected error: "MCP server 'server' is local but has no command"

### Test 2: Memory Monitoring

#### Test Process Discovery

1. **Start a Node.js process (simulating OpenCode):**
   ```bash
   # In a separate terminal
   node -e "setInterval(() => console.log('running'), 5000)"
   ```

2. **Verify process can be found:**
   - Process should be discoverable by name ("node")
   - Process should be discoverable by command line ("node")
   - PID should be correctly identified
   - Memory usage should be readable

#### Test Memory Reading

1. **Get memory for a known process:**
   ```bash
   # Note the PID from Activity Monitor or ps
   ps aux | grep node
   ```

2. **Verify memory reading:**
   - Memory should be in MB
   - Value should match Activity Monitor (within 1-2 MB)
   - Reading should complete in < 1ms

#### Test Memory Tracking

1. **Track memory over time:**
   - Start tracking for 60 seconds
   - Take readings every 5 seconds
   - Should collect 12 readings
   - Calculate min, max, avg

2. **Verify statistics:**
   - Min should be <= all readings
   - Max should be >= all readings
   - Avg should be between min and max

#### Test Threshold Detection

Test memory thresholds:

| Memory | Expected Threshold |
|--------|-------------------|
| 500 MB | Normal |
| 2500 MB | Warning |
| 5000 MB | Critical |

#### Test Real-Time Monitoring

1. **Start monitoring with 10-second interval:**
   ```swift
   let timer = OpenCodeMonitorPOC.startMonitoring(pid: process.pid, interval: 10.0) { memory, threshold in
       print("Memory: \(memory)MB - \(threshold)")
   }
   ```

2. **Verify callbacks:**
   - Callback should fire every 10 seconds
   - Memory should be current reading
   - Threshold should match memory level

### Test 3: Hook Compatibility

#### Install Hook Scripts

1. **Create hooks directory:**
   ```bash
   mkdir -p ~/.config/opencode/hooks
   mkdir -p ~/.config/opencode/logs
   ```

2. **Install hooks:**
   ```bash
   cp /tmp/opencode-hooks/*.sh ~/.config/opencode/hooks/
   chmod +x ~/.config/opencode/hooks/*.sh
   ```

3. **Verify installation:**
   ```bash
   ls -la ~/.config/opencode/hooks/
   # Should show: session-start.sh, before-tool.sh, after-tool.sh
   ```

#### Test Hook Execution

1. **Start OpenCode Island:**
   - Build and run the app
   - Verify socket is created at `/tmp/opencode-island.sock`
   ```bash
   ls -la /tmp/opencode-island.sock
   # Expected: srwxrwxrwx ... /tmp/opencode-island.sock
   ```

2. **Test session-start hook:**
   ```bash
   export OPENCODE_SESSION_ID="test-session-$(date +%s)"
   export OPENCODE_CWD="$(pwd)"
   export OPENCODE_PID=$$
   export OPENCODE_TTY=$(tty)
   
   ~/.config/opencode/hooks/session-start.sh
   ```

3. **Verify hook execution:**
   - Check log file: `cat ~/.config/opencode/logs/hooks.log`
   - Should contain: `[timestamp] SessionStart: test-session-XXX`
   - OpenCode Island UI should show new session

4. **Test before-tool hook:**
   ```bash
   export OPENCODE_TOOL_NAME="read"
   export OPENCODE_TOOL_USE_ID="tool-$(date +%s)"
   export OPENCODE_TOOL_INPUT='{"path":"/tmp/test.txt"}'
   
   ~/.config/opencode/hooks/before-tool.sh
   ```

5. **Verify tool event:**
   - Check log file for `PreToolUse` entry
   - UI should show tool execution indicator

6. **Test after-tool hook:**
   ```bash
   ~/.config/opencode/hooks/after-tool.sh
   ```

7. **Verify completion:**
   - Check log file for `PostToolUse` entry
   - UI should clear tool execution indicator

#### Test Socket Communication

1. **Manual socket test:**
   ```bash
   echo '{"session_id":"manual-test","cwd":"/tmp","event":"Test","status":"idle"}' | \
     nc -U /tmp/opencode-island.sock
   ```

2. **Verify message received:**
   - Check app logs for message receipt
   - No errors should be logged

#### Test Error Handling

1. **Test without socket:**
   ```bash
   # Stop OpenCode Island
   # Run hooks - should complete silently without errors
   ~/.config/opencode/hooks/session-start.sh
   echo $?  # Should be 0 (success)
   ```

2. **Test with invalid JSON:**
   ```bash
   echo 'invalid json' | nc -U /tmp/opencode-island.sock || true
   # App should log error but not crash
   ```

### Test 4: Integration Testing with OpenCode CLI

**Note:** This requires OpenCode CLI to be installed and properly configured.

#### Setup OpenCode

1. **Install OpenCode:**
   ```bash
   npm install -g opencode
   # or
   bun install -g opencode
   ```

2. **Configure OpenCode:**
   - Use the test configuration created earlier
   - Or use existing OpenCode configuration

#### Test Full Workflow

1. **Start OpenCode Island**

2. **Start OpenCode session:**
   ```bash
   cd /tmp/test-project
   opencode "List files in current directory"
   ```

3. **Verify session detection:**
   - Session should appear in OpenCode Island UI
   - Session ID should be displayed
   - CWD should show `/tmp/test-project`

4. **Verify tool execution:**
   - Tools (ls, read, etc.) should be tracked
   - Tool names should appear in UI
   - Tool completion should be detected

5. **Verify memory monitoring:**
   - OpenCode process should be found
   - Memory usage should be displayed
   - Memory should update periodically

6. **Test multiple sessions:**
   - Open second terminal
   - Start another OpenCode session
   - Both sessions should appear in UI
   - Each should be tracked independently

## Verification Checklist

### Configuration (POC-CONFIG-VALIDATION.md)
- [ ] Discovers global config from `~/.config/opencode/`
- [ ] Discovers project config from project root
- [ ] Merges configs with correct priority
- [ ] Preserves authentication tokens
- [ ] Strips JSONC comments correctly
- [ ] Validates required fields
- [ ] Provides helpful error messages

### Memory Monitoring (POC-MEMORY-MONITORING.md)
- [ ] Finds OpenCode process by name
- [ ] Finds OpenCode process by command line
- [ ] Reads memory usage accurately
- [ ] Tracks memory over time
- [ ] Calculates statistics correctly
- [ ] Detects thresholds (normal/warning/critical)
- [ ] Provides real-time monitoring
- [ ] Handles process not found gracefully

### Hook Compatibility (POC-HOOKS-COMPATIBILITY.md)
- [ ] Hook scripts are executable
- [ ] Hooks send correct JSON format
- [ ] Socket communication works
- [ ] HookSocketServer receives events
- [ ] Events are parsed correctly
- [ ] Session tracking works
- [ ] Tool tracking works
- [ ] Error handling is graceful

### Integration
- [ ] App starts without errors
- [ ] Socket is created on startup
- [ ] OpenCode sessions are detected
- [ ] Multiple sessions are tracked
- [ ] Memory is monitored in real-time
- [ ] UI updates on events
- [ ] Logs are written correctly

## Common Issues

### Issue: Socket permission denied
**Solution:** Ensure socket permissions are 0777:
```bash
chmod 777 /tmp/opencode-island.sock
```

### Issue: Hook not executing
**Solution:** Check hook permissions:
```bash
chmod +x ~/.config/opencode/hooks/*.sh
```

### Issue: Process not found
**Solution:** 
- Verify OpenCode is running: `ps aux | grep opencode`
- Check process name variations: `node`, `bun`, `opencode`

### Issue: Memory reading fails
**Solution:** 
- Requires same user as target process
- Cannot read system processes without elevated permissions

### Issue: Config not loading
**Solution:**
- Check file exists: `ls -la ~/.config/opencode/opencode.jsonc`
- Verify JSON syntax: `cat file.jsonc | grep -v '//' | jq .`
- Check for JSONC comments that weren't stripped

## Success Criteria

All POC objectives should be met:

1. **Configuration:** ✅
   - Discovers configs from all standard locations
   - Merges with correct priority
   - Preserves authentication
   - Validates schema

2. **Memory Monitoring:** ✅
   - Process discovery works
   - Memory reading is accurate
   - Real-time monitoring functional
   - Thresholds detect correctly

3. **Hook Compatibility:** ✅
   - Hook scripts execute
   - Socket communication works
   - Events are received and parsed
   - Compatible with existing HookSocketServer

## Next Steps

After POC validation:

1. **Integrate with main app:**
   - Add config UI
   - Add memory display
   - Enable hooks by default

2. **Phase 2: Core Integration**
   - Replace ClaudeSessionMonitor
   - Update for OpenCode paths
   - Full OpenCode CLI support

3. **Production readiness:**
   - Comprehensive testing
   - Error handling improvements
   - Performance optimization

## Documentation

See POC documentation for detailed results:
- [POC-CONFIG-VALIDATION.md](./POC-CONFIG-VALIDATION.md)
- [POC-MEMORY-MONITORING.md](./POC-MEMORY-MONITORING.md)
- [POC-HOOKS-COMPATIBILITY.md](./POC-HOOKS-COMPATIBILITY.md)

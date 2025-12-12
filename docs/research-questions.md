# Research Questions & Proof of Concepts

This document outlines research questions and proof-of-concept (POC) validation needed before full implementation of OpenCode Island.

## Overview

Before migrating from Claude Island to OpenCode Island, we need to validate key assumptions and technical approaches through focused POCs.

## POC 1: Configuration Schema Validation

### Research Questions

1. **Does OpenCode's configuration format work as documented?**
   - Can we successfully parse `opencode.jsonc`?
   - Does the Zod validation catch errors?
   - Are environment variables properly substituted?

2. **How does configuration hierarchy work?**
   - Which config takes precedence?
   - How do project and global configs merge?
   - Can we override specific keys?

3. **What happens with invalid configurations?**
   - Error messages clear?
   - Graceful degradation?
   - Recovery possible?

### Test Cases

#### TC1: Basic Configuration

**Setup:**
```jsonc
// test-basic.jsonc
{
  "model": {
    "provider": "anthropic",
    "name": "claude-sonnet-4"
  }
}
```

**Test:**
```bash
opencode config validate --config test-basic.jsonc
```

**Expected:** ✅ Configuration valid

**Actual:** _To be filled during POC_

#### TC2: MCP Server Configuration

**Setup:**
```jsonc
{
  "mcp": {
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/tmp"]
    },
    "github": {
      "type": "remote",
      "url": "https://api.github.com/mcp",
      "headers": {
        "Authorization": "******"
      }
    }
  }
}
```

**Test:**
```bash
opencode config show --config test-mcp.jsonc
opencode "List files" --config test-mcp.jsonc
```

**Expected:** Both servers connect and work

**Actual:** _To be filled during POC_

#### TC3: Invalid Configuration

**Setup:**
```jsonc
{
  "mcp": {
    "bad-server": {
      "type": "invalid-type",  // Should fail
      "command": "not-an-array"  // Should fail
    }
  }
}
```

**Test:**
```bash
opencode config validate --config test-invalid.jsonc
```

**Expected:** Clear error messages

**Actual:** _To be filled during POC_

#### TC4: Environment Variables

**Setup:**
```jsonc
{
  "mcp": {
    "github": {
      "type": "remote",
      "url": "${GITHUB_MCP_URL}",
      "headers": {
        "Authorization": "******{GITHUB_TOKEN}"
      }
    }
  }
}
```

**Test:**
```bash
export GITHUB_MCP_URL="https://api.github.com/mcp"
export GITHUB_TOKEN="ghp_xxxx"
opencode config show --config test-env.jsonc
```

**Expected:** Variables properly substituted

**Actual:** _To be filled during POC_

### Validation Criteria

- [ ] All test cases pass
- [ ] Error messages are clear
- [ ] Configuration hierarchy understood
- [ ] Environment substitution works
- [ ] Edge cases handled gracefully

### Deliverable

**Document:** `POC-CONFIG-VALIDATION.md`

**Contents:**
- Test results for each case
- Screenshots of error messages
- Configuration file examples
- Lessons learned
- Recommendations

---

## POC 2: Process & Memory Monitoring

### Research Questions

1. **How can we reliably identify the OpenCode process?**
   - By process name?
   - By command line arguments?
   - By parent process?

2. **What's the best method to track memory usage?**
   - `task_info` API?
   - `ps` command?
   - Activity Monitor integration?

3. **How does memory usage behave?**
   - Baseline memory?
   - Growth over time?
   - Peak usage scenarios?
   - Memory leaks?

4. **When should we trigger warnings?**
   - Absolute thresholds?
   - Relative growth?
   - Trend analysis?

### Test Cases

#### TC1: Process Discovery

**Setup:**
```bash
# Start OpenCode in different ways
opencode --daemon
node /path/to/opencode/cli.js
bun run opencode
```

**Test:**
```swift
func testProcessDiscovery() {
    let methods: [(String, () -> Process?)] = [
        ("By name 'opencode'", { findProcessByName("opencode") }),
        ("By name 'node'", { findProcessByName("node") }),
        ("By name 'bun'", { findProcessByName("bun") }),
        ("By command line", { findProcessByCommandLine("opencode") })
    ]
    
    for (method, finder) in methods {
        if let process = finder() {
            print("✅ \(method): PID \(process.processIdentifier)")
        } else {
            print("❌ \(method): Not found")
        }
    }
}
```

**Expected:** At least one method finds the process

**Actual:** _To be filled during POC_

#### TC2: Memory Reading Accuracy

**Setup:**
```swift
func testMemoryAccuracy() {
    guard let process = findOpenCodeProcess() else {
        XCTFail("Process not found")
        return
    }
    
    // Compare different methods
    let taskInfoMemory = getMemoryViaTaskInfo(process)
    let psMemory = getMemoryViaPS(process)
    let activityMonitorMemory = getMemoryViaActivityMonitor(process)
    
    print("task_info: \(taskInfoMemory)MB")
    print("ps: \(psMemory)MB")
    print("Activity Monitor: \(activityMonitorMemory)MB")
    
    // They should be within 10% of each other
    let variance = max(taskInfoMemory, psMemory) - min(taskInfoMemory, psMemory)
    XCTAssert(variance < taskInfoMemory * 0.1, "Methods disagree")
}
```

**Expected:** Methods agree within 10%

**Actual:** _To be filled during POC_

#### TC3: Memory Growth Tracking

**Setup:**
```swift
func testMemoryGrowth() {
    guard let process = findOpenCodeProcess() else { return }
    
    var readings: [(time: Date, memory: Int)] = []
    
    // Track for 5 minutes
    for _ in 0..<30 {
        let memory = getProcessMemory(process)
        readings.append((Date(), memory))
        sleep(10)
    }
    
    // Analyze growth
    let initial = readings.first!.memory
    let final = readings.last!.memory
    let growth = final - initial
    let growthPercent = Double(growth) / Double(initial) * 100
    
    print("Initial: \(initial)MB")
    print("Final: \(final)MB")
    print("Growth: \(growth)MB (\(growthPercent)%)")
    
    // Log all readings
    for reading in readings {
        print("\(reading.time): \(reading.memory)MB")
    }
}
```

**Expected:** Understand normal growth pattern

**Actual:** _To be filled during POC_

#### TC4: Stress Test

**Setup:**
```bash
# Generate high memory usage
for i in {1..100}; do
  opencode "Read large file and process it" &
done
wait
```

**Test:**
```swift
func testStressScenario() {
    // Monitor during stress
    let initialMemory = getProcessMemory(process)
    
    // Trigger stress (100 concurrent operations)
    triggerStressTest()
    
    var peakMemory = initialMemory
    for _ in 0..<60 {
        let current = getProcessMemory(process)
        peakMemory = max(peakMemory, current)
        sleep(1)
    }
    
    print("Initial: \(initialMemory)MB")
    print("Peak: \(peakMemory)MB")
    print("Increase: \(peakMemory - initialMemory)MB")
}
```

**Expected:** Understand peak memory usage

**Actual:** _To be filled during POC_

### Validation Criteria

- [ ] Can reliably find OpenCode process
- [ ] Memory readings are accurate
- [ ] Growth patterns understood
- [ ] Peak usage known
- [ ] Warning thresholds defined

### Deliverable

**Document:** `POC-MEMORY-MONITORING.md`

**Contents:**
- Process discovery methods and results
- Memory tracking accuracy comparison
- Normal vs stress memory patterns
- Recommended thresholds
- Code examples

---

## POC 3: Hook System Compatibility

### Research Questions

1. **Do OpenCode hooks work like Claude hooks?**
   - Same event types?
   - Same timing?
   - Same data format?

2. **Can we reuse the Unix socket approach?**
   - Does OpenCode support custom hooks?
   - Can hooks communicate via socket?
   - Message format compatible?

3. **What events are available?**
   - Session lifecycle?
   - Tool execution?
   - Error handling?

### Test Cases

#### TC1: Hook Installation

**Setup:**
```bash
mkdir -p ~/.config/opencode/hooks

cat > ~/.config/opencode/hooks/session-start.sh << 'EOF'
#!/bin/bash
echo "HOOK_FIRED: session-start" >> /tmp/opencode-hooks.log
echo "SESSION_START|$1|$(date)" | nc -U /tmp/opencode-island.sock
EOF

chmod +x ~/.config/opencode/hooks/session-start.sh
```

**Test:**
```bash
# Start OpenCode
opencode "Test command"

# Check log
cat /tmp/opencode-hooks.log
```

**Expected:** Hook fires and logs

**Actual:** _To be filled during POC_

#### TC2: Tool Hooks

**Setup:**
```bash
cat > ~/.config/opencode/hooks/before-tool.sh << 'EOF'
#!/bin/bash
TOOL_NAME="$1"
TOOL_INPUT="$2"
echo "TOOL_START|$TOOL_NAME|$(date)" | nc -U /tmp/opencode-island.sock
EOF

cat > ~/.config/opencode/hooks/after-tool.sh << 'EOF'
#!/bin/bash
TOOL_NAME="$1"
TOOL_RESULT="$2"
echo "TOOL_END|$TOOL_NAME|$(date)" | nc -U /tmp/opencode-island.sock
EOF

chmod +x ~/.config/opencode/hooks/*.sh
```

**Test:**
```bash
opencode "Read the README file"
```

**Expected:** before-tool and after-tool hooks fire

**Actual:** _To be filled during POC_

#### TC3: Socket Communication

**Setup:**
```python
# socket_receiver.py
import socket
import os

sock_path = "/tmp/opencode-island.sock"
if os.path.exists(sock_path):
    os.remove(sock_path)

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
sock.bind(sock_path)
sock.listen(1)

print(f"Listening on {sock_path}")

while True:
    conn, _ = sock.accept()
    data = conn.recv(1024).decode('utf-8')
    print(f"Received: {data}")
    conn.close()
```

**Test:**
```bash
# Terminal 1
python socket_receiver.py

# Terminal 2
opencode "Test command"
```

**Expected:** Socket receives messages

**Actual:** _To be filled during POC_

#### TC4: Error Handling

**Setup:**
```bash
cat > ~/.config/opencode/hooks/error-hook.sh << 'EOF'
#!/bin/bash
echo "ERROR|$1|$(date)" | nc -U /tmp/opencode-island.sock
exit 0  # Don't fail the main process
EOF

chmod +x ~/.config/opencode/hooks/error-hook.sh
```

**Test:**
```bash
# Trigger an error
opencode "Read a file that doesn't exist"
```

**Expected:** Error hook fires, OpenCode continues

**Actual:** _To be filled during POC_

### Validation Criteria

- [ ] Hooks can be installed
- [ ] Hooks fire on correct events
- [ ] Socket communication works
- [ ] Message format understood
- [ ] Error handling works

### Deliverable

**Document:** `POC-HOOKS-COMPATIBILITY.md`

**Contents:**
- Hook installation process
- Available hook events
- Message format specification
- Socket protocol
- Error handling approach

---

## POC 4: MCP Server Coordination

### Research Questions

1. **Can OpenCode coordinate multiple MCP servers efficiently?**
   - Single server pattern work?
   - Performance acceptable?
   - Context shared properly?

2. **How does tool routing work?**
   - Priority-based?
   - Round-robin?
   - Custom routing?

3. **What happens when a server fails?**
   - Fallback mechanisms?
   - Error propagation?
   - Recovery process?

### Test Cases

#### TC1: Multi-Server Setup

**Setup:**
```jsonc
{
  "mcp": {
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/workspace"],
      "priority": 1
    },
    "github": {
      "type": "remote",
      "url": "https://api.github.com/mcp",
      "priority": 2
    },
    "database": {
      "type": "local",
      "command": ["python", "-m", "mcp_server_sqlite", "test.db"],
      "priority": 3
    }
  }
}
```

**Test:**
```bash
opencode "List files, check GitHub issues, and query database"
```

**Expected:** All three servers used

**Actual:** _To be filled during POC_

#### TC2: Server Failure Handling

**Setup:**
```bash
# Start OpenCode with intentionally broken server
cat > test-failure.jsonc << 'EOF'
{
  "mcp": {
    "working": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/tmp"]
    },
    "broken": {
      "type": "local",
      "command": ["non-existent-command"]
    }
  }
}
EOF
```

**Test:**
```bash
opencode --config test-failure.jsonc "List files"
```

**Expected:** Working server still functions

**Actual:** _To be filled during POC_

#### TC3: Performance Measurement

**Setup:**
```bash
# Measure latency with different numbers of servers
test_performance() {
    local num_servers=$1
    local start=$(date +%s%N)
    
    opencode "Perform test operation"
    
    local end=$(date +%s%N)
    local duration=$(( (end - start) / 1000000 ))
    echo "With $num_servers servers: ${duration}ms"
}
```

**Test:**
```bash
test_performance 1
test_performance 3
test_performance 5
test_performance 10
```

**Expected:** Understand overhead

**Actual:** _To be filled during POC_

### Validation Criteria

- [ ] Multiple servers work together
- [ ] Failure handling graceful
- [ ] Performance acceptable
- [ ] Routing mechanism understood

### Deliverable

**Document:** `POC-MCP-COORDINATION.md`

**Contents:**
- Multi-server configuration
- Performance benchmarks
- Failure scenarios
- Best practices

---

## POC 5: Skills Integration

### Research Questions

1. **Do we need OpenCode-skills?**
   - Are skills currently used?
   - Would skills benefit the project?
   - Integration complexity?

2. **How do skills affect performance?**
   - Loading time?
   - Memory usage?
   - Context impact?

3. **Can skills be shared across team?**
   - Git repository approach?
   - Version management?
   - Update mechanism?

### Test Cases

#### TC1: Skills Installation

**Setup:**
```bash
# Install OpenSkills
npm install -g openskills

# Create test skill
mkdir -p .agent/skills
cat > .agent/skills/test-skill.md << 'EOF'
---
name: test-skill
description: Test skill for POC
triggers:
  - "test skill"
---

## Instructions
When asked to test the skill, respond with "Skill activated!"
EOF
```

**Test:**
```bash
opencode "Test skill"
```

**Expected:** Skill activates

**Actual:** _To be filled during POC_

#### TC2: Skill Performance

**Setup:**
```bash
# Create 10 skills
for i in {1..10}; do
  cat > .agent/skills/skill-$i.md << EOF
---
name: skill-$i
description: Test skill $i
triggers: ["skill $i"]
---
Test skill $i content
EOF
done
```

**Test:**
```bash
time opencode "Use skill 5"
```

**Expected:** Reasonable performance

**Actual:** _To be filled during POC_

### Validation Criteria

- [ ] Skills install correctly
- [ ] Triggers work
- [ ] Performance acceptable
- [ ] Decision on using skills

### Deliverable

**Document:** `POC-SKILLS-INTEGRATION.md`

**Contents:**
- Skills setup process
- Performance measurements
- Use case analysis
- Recommendation (use or skip)

---

## Summary Table

| POC | Duration | Complexity | Priority | Status |
|-----|----------|------------|----------|--------|
| Configuration Schema | 2 days | Low | High | Pending |
| Memory Monitoring | 3 days | Medium | High | Pending |
| Hook Compatibility | 2 days | Medium | High | Pending |
| MCP Coordination | 3 days | High | Medium | Pending |
| Skills Integration | 2 days | Low | Low | Pending |

## Timeline

**Week 1:**
- POC 1: Configuration (Mon-Tue)
- POC 2: Memory Monitoring (Wed-Fri)

**Week 2:**
- POC 3: Hooks (Mon-Tue)
- POC 4: MCP Coordination (Wed-Fri)

**Week 3:**
- POC 5: Skills (Mon-Tue)
- Document findings (Wed-Thu)
- Review and plan Phase 2 (Fri)

## Success Criteria

Each POC must produce:
1. ✅ Test cases executed
2. ✅ Results documented
3. ✅ Code examples
4. ✅ Recommendations
5. ✅ Clear go/no-go decision

## Next Steps

1. Execute POCs in priority order
2. Document findings in POC-*.md files
3. Review results with team
4. Adjust migration strategy based on learnings
5. Proceed to Phase 2 (Core Migration)

## Related Documentation

- [Migration Strategy](./migration-strategy.md) - Implementation plan
- [Advanced Use Cases](./advanced-use-cases.md) - Real-world examples
- [OpenCode-Specific Config](./opencode-specific-config.md) - Technical details

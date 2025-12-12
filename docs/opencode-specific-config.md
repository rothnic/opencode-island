# OpenCode-Specific Configuration & Implementation Notes

This document covers OpenCode-specific configuration requirements, schema validation, OpenCode-skills integration, and technical implementation notes for the OpenCode Island project.

## OpenCode Configuration Schema

### Unique Aspects of OpenCode Configuration

OpenCode uses a **different configuration format** compared to standard MCP implementations:

#### Standard MCP Format
```json
{
  "mcpServers": {
    "server-name": {
      "command": "executable",
      "args": ["arg1"]
    }
  }
}
```

#### OpenCode Format
```jsonc
{
  "mcp": {
    "server-name": {
      "type": "local",  // or "remote"
      "command": ["executable", "arg1"]  // Array format, not command + args
    }
  }
}
```

### Key Differences

| Aspect | Standard MCP | OpenCode |
|--------|-------------|----------|
| Top-level key | `mcpServers` | `mcp` |
| Command format | `command` + `args` | `command` array |
| Type specification | Implicit | Explicit `type` field |
| File location | Multiple locations | `opencode.jsonc` at project root or `~/.config/opencode/` |

### OpenCode Configuration Schema (Zod-based)

OpenCode uses Zod for schema validation. The configuration schema is defined in `packages/opencode/parsers-config.ts`.

**Core Configuration Structure:**
```typescript
{
  // Model configuration
  model?: {
    provider?: string;
    name?: string;
    apiKey?: string;
    temperature?: number;
    maxTokens?: number;
  };
  
  // MCP servers
  mcp?: Record<string, {
    type: "local" | "remote";
    command?: string[];  // For local servers
    url?: string;        // For remote servers
    env?: Record<string, string>;
    disabled?: boolean;
  }>;
  
  // Plugins
  plugins?: Record<string, {
    enabled?: boolean;
    config?: Record<string, any>;
  }>;
  
  // Tools configuration
  tools?: {
    enabled?: string[];
    disabled?: string[];
  };
  
  // UI settings
  ui?: {
    theme?: string;
    fontSize?: number;
  };
}
```

### Configuration File Discovery

OpenCode searches for configuration in this order:
1. `OPENCODE_CONFIG_CONTENT` environment variable (inline JSON)
2. Project-specific: `<project-root>/opencode.jsonc`
3. Project-specific: `<project-root>/.opencode/opencode.jsonc`
4. Global: `~/.config/opencode/opencode.jsonc`
5. Global: `~/.config/opencode/opencode.json`

**Note:** Configuration files must be at project root or in `~/.config/opencode/`, not in subdirectories.

### Schema Validation Tool

Use OpenCode CLI to validate configuration:

```bash
# Validate current configuration
opencode config validate

# View resolved configuration
opencode config show

# Show configuration schema
opencode config schema
```

## OpenCode-Skills Integration

### What are OpenCode-Skills?

OpenCode-skills is an implementation that brings Claude's Skills system to OpenCode and other AI coding agents. It provides:

- **Progressive disclosure**: Skills loaded only when needed
- **Universal compatibility**: Works across Claude, OpenCode, Cursor, Windsurf, Aider
- **Version control**: Skills stored in Git repositories
- **Team sharing**: Shared skill registries

### Installation

```bash
# Install OpenSkills CLI
npm install -g openskills

# Or using the plugin
opencode plugin install opencode-skills
```

### Skill Structure

Skills are defined in SKILL.md files:

```markdown
---
name: experiment-runner
description: Run ML experiments with tracking
triggers:
  - "run experiment"
  - "train model"
---

## Instructions

When asked to run experiments:
1. Set up experiment tracking
2. Configure hyperparameters
3. Run training loop
4. Log metrics
5. Save model artifacts

## Examples

...
```

### Using Skills in OpenCode

**Install skills from repository:**
```bash
openskills install organization/skill-repo
```

**List available skills:**
```bash
openskills list
```

**Activate a skill:**
```
Use the [skill-name] skill to complete this task
```

**Skills automatically activate based on triggers in user prompts.**

### Skills vs Plugins

| Feature | Skills | Plugins |
|---------|--------|---------|
| **Purpose** | Instructions/workflows | Code/tools |
| **Format** | Markdown | JavaScript/TypeScript |
| **Loading** | Progressive (on-demand) | Always loaded |
| **Sharing** | Git repositories | npm packages |
| **Modification** | Edit markdown | Code changes |

### Configuring Skills in OpenCode

```jsonc
{
  "plugins": {
    "opencode-skills": {
      "enabled": true,
      "config": {
        "skillsPath": ".claude/skills",  // Or .agent/skills for universal
        "autoSync": true,
        "repositories": [
          "organization/team-skills",
          "user/personal-skills"
        ]
      }
    }
  }
}
```

## Memory Monitoring Strategy

### Problem
OpenCode servers can consume excessive memory over time, especially with:
- Long-running sessions
- Large codebases
- Multiple MCP servers
- Heavy LSP usage

### Solution Architecture

**Components:**
1. **Memory Monitor Service** (macOS app)
2. **OpenCode Process Tracker**
3. **User Notification System**
4. **Graceful Restart Handler**

### Implementation Plan

#### 1. Process Monitoring

```swift
// Swift code for macOS app
class OpenCodeMonitor {
    func monitorMemoryUsage() {
        // Get OpenCode process
        let process = findOpenCodeProcess()
        
        // Check memory usage
        let memoryMB = getProcessMemory(process)
        
        // Define thresholds
        let warningThreshold = 2048  // 2GB
        let criticalThreshold = 4096 // 4GB
        
        if memoryMB > criticalThreshold {
            notifyUser(.critical)
            suggestRestart()
        } else if memoryMB > warningThreshold {
            notifyUser(.warning)
        }
    }
    
    func findOpenCodeProcess() -> Process? {
        // Find process by name or command
        // Look for: opencode, node (with opencode args), or bun
    }
    
    func getProcessMemory(_ process: Process) -> Int {
        // Use task_info or ps command
        // Return resident memory in MB
    }
}
```

#### 2. Restart Mechanism

**Safe Restart Steps:**
1. Save current session state
2. Notify user of restart
3. Gracefully terminate OpenCode process
4. Wait for clean shutdown
5. Restart OpenCode with saved session
6. Restore context

**Implementation:**
```swift
func restartOpenCode() {
    // 1. Save session
    saveCurrentSession()
    
    // 2. Send SIGTERM to OpenCode
    process.terminate()
    
    // 3. Wait for graceful shutdown (timeout: 10s)
    waitForShutdown(timeout: 10)
    
    // 4. Force kill if needed
    if !isShutdown() {
        process.kill()
    }
    
    // 5. Restart
    let newProcess = startOpenCode(withSession: savedSession)
    
    // 6. Monitor new process
    monitorProcess(newProcess)
}
```

#### 3. Configuration

```jsonc
{
  "monitoring": {
    "enabled": true,
    "memoryWarningThreshold": 2048,    // MB
    "memoryCriticalThreshold": 4096,   // MB
    "checkInterval": 60,               // seconds
    "autoRestartOnCritical": false,    // Require user confirmation
    "notifications": {
      "warning": true,
      "critical": true,
      "sound": true
    }
  }
}
```

## Auto-Update Strategy

### Update Flow

**1. Check for Updates:**
```swift
func checkForUpdates() {
    // Check GitHub releases API
    let latestVersion = fetchLatestRelease()
    let currentVersion = Bundle.main.version
    
    if latestVersion > currentVersion {
        notifyUserOfUpdate(latestVersion)
    }
}
```

**2. Download Update:**
```swift
func downloadUpdate(version: String) {
    // Download from GitHub releases
    let url = "https://github.com/rothnic/opencode-island/releases/download/\(version)/OpenCodeIsland.dmg"
    downloadFile(from: url, progress: updateProgress)
}
```

**3. Install Update:**
```swift
func installUpdate() {
    // 1. Verify download signature
    verifySignature(dmgPath)
    
    // 2. Mount DMG
    mountDMG(dmgPath)
    
    // 3. Replace app bundle
    replaceAppBundle()
    
    // 4. Restart app
    restartApplication()
}
```

### Update Configuration

```swift
// Info.plist or configuration
{
  "SUFeedURL": "https://github.com/rothnic/opencode-island/releases.atom",
  "SUEnableAutomaticChecks": true,
  "SUScheduledCheckInterval": 86400,  // Daily
  "SUAllowsAutomaticUpdates": true
}
```

### Using Sparkle Framework

```swift
import Sparkle

let updater = SPUStandardUpdaterController(
    startingUpdater: true,
    updaterDelegate: nil,
    userDriverDelegate: nil
)

// Check for updates
updater.checkForUpdates()
```

## Universal Binary for macOS

### Build Configuration

Ensure Xcode project builds for both Intel and Apple Silicon:

**1. Xcode Project Settings:**
```
Build Settings > Architectures
- Architectures: Standard (arm64, x86_64)
- Build Active Architecture Only: NO (for Release)
- Valid Architectures: arm64 x86_64
```

**2. Build Script:**
```bash
#!/bin/bash
# build-universal.sh

xcodebuild \
  -scheme ClaudeIsland \
  -configuration Release \
  -arch arm64 -arch x86_64 \
  ONLY_ACTIVE_ARCH=NO \
  build
```

**3. Verify Universal Binary:**
```bash
# Check architectures
lipo -info OpenCodeIsland.app/Contents/MacOS/OpenCodeIsland

# Expected output:
# Architectures in the fat file: OpenCodeIsland are: x86_64 arm64
```

**4. Code Signing:**
```bash
# Sign for both architectures
codesign --force --deep --sign "Developer ID Application" \
  --options runtime \
  --entitlements OpenCodeIsland.entitlements \
  OpenCodeIsland.app
```

### Testing on Both Architectures

**Intel Mac (Rosetta on Apple Silicon):**
```bash
arch -x86_64 /Applications/OpenCodeIsland.app/Contents/MacOS/OpenCodeIsland
```

**Apple Silicon (Native):**
```bash
arch -arm64 /Applications/OpenCodeIsland.app/Contents/MacOS/OpenCodeIsland
```

### CI/CD for Universal Builds

```yaml
# .github/workflows/build.yml
name: Build Universal Binary

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Universal Binary
        run: |
          xcodebuild \
            -scheme ClaudeIsland \
            -configuration Release \
            -arch arm64 -arch x86_64 \
            ONLY_ACTIVE_ARCH=NO \
            build
      
      - name: Verify Architectures
        run: |
          lipo -info build/Release/OpenCodeIsland.app/Contents/MacOS/OpenCodeIsland
      
      - name: Create DMG
        run: |
          create-dmg \
            --volname "OpenCode Island" \
            --window-size 600 400 \
            --icon-size 100 \
            --app-drop-link 450 150 \
            OpenCodeIsland.dmg \
            build/Release/OpenCodeIsland.app
      
      - name: Upload Release
        uses: softprops/action-gh-release@v1
        with:
          files: OpenCodeIsland.dmg
```

## Implementation Checklist

### Phase 1: Configuration
- [ ] Update configuration parser to support OpenCode schema
- [ ] Add schema validation
- [ ] Create configuration migration tool from Claude format
- [ ] Add config file templates

### Phase 2: Skills Integration
- [ ] Research opencode-skills dependency
- [ ] Determine if skills are currently used
- [ ] Add skills support if needed
- [ ] Document skill creation workflow

### Phase 3: Monitoring
- [ ] Implement memory monitoring service
- [ ] Add process tracking
- [ ] Create notification system
- [ ] Build restart mechanism
- [ ] Add user preferences for monitoring

### Phase 4: Auto-Update
- [ ] Integrate Sparkle framework
- [ ] Set up release feed
- [ ] Implement update download/install
- [ ] Add update preferences
- [ ] Test update flow

### Phase 5: Universal Binary
- [ ] Configure Xcode for universal build
- [ ] Update build scripts
- [ ] Set up CI/CD for universal builds
- [ ] Test on both architectures
- [ ] Update release process

## Testing Strategy

### Configuration Testing
```bash
# Test valid config
opencode config validate

# Test invalid config
# Expected: Error messages

# Test schema detection
opencode config show
```

### Memory Monitoring Testing
```swift
// Simulate high memory usage
func testMemoryWarning() {
    monitor.simulateMemoryUsage(3000) // 3GB
    XCTAssertTrue(warningShown)
}

func testMemoryRestart() {
    monitor.simulateMemoryUsage(5000) // 5GB
    XCTAssertTrue(restartSuggested)
}
```

### Universal Binary Testing
```bash
# Test Intel
arch -x86_64 ./test-suite

# Test Apple Silicon  
arch -arm64 ./test-suite

# Verify both work correctly
```

## Next Steps

1. Review [Configuration Guide](./configuration-guide.md) for detailed config options
2. Explore [OpenCode Tools Reference](./opencode-tools-reference.md) for tool usage
3. Check [Migration Strategy](./migration-strategy.md) for transition plan
4. Read [Research Questions](./research-questions.md) for POC planning

## References

- [OpenCode Configuration System](https://deepwiki.com/sst/opencode/3-configuration-system)
- [OpenSkills GitHub](https://github.com/numman-ali/openskills)
- [Sparkle Framework](https://sparkle-project.org/)
- [Xcode Universal Binaries](https://developer.apple.com/documentation/apple-silicon/building-a-universal-macos-binary)

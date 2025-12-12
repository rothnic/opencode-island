# Phase 3: Advanced Capabilities

## Phase Overview

**Timeline:** 2 weeks  
**Dependencies:** Phase 1 and Phase 2 complete  
**Upstream Sync Impact:** Low - Self-contained features that don't affect core functionality

## Objectives

- [ ] Implement process memory monitoring with warnings
- [ ] Add auto-update system using Sparkle framework
- [ ] Integrate OpenSkills support (optional)
- [ ] Add performance optimizations
- [ ] Implement advanced session management features

## Tasks

### Task Group 1: Memory Monitoring

**Goal:** Monitor OpenCode process memory usage and alert users to potential issues.

#### 1.1 Memory Monitor Implementation
- [ ] Create `MemoryMonitor` service
- [ ] Find and track OpenCode process(es)
- [ ] Poll memory usage at regular intervals
- [ ] Calculate memory statistics (current, peak, average)
- [ ] Detect memory leaks or unusual growth

**Implementation:**
```swift
// Services/Monitoring/MemoryMonitor.swift
import Foundation

class MemoryMonitor: ObservableObject {
    @Published var currentMemoryMB: Int = 0
    @Published var peakMemoryMB: Int = 0
    @Published var warningActive: Bool = false
    @Published var criticalActive: Bool = false
    
    // Configurable thresholds (MB)
    var warningThreshold: Int = 2048   // 2 GB
    var criticalThreshold: Int = 4096  // 4 GB
    var checkInterval: TimeInterval = 60  // 60 seconds
    
    private var timer: Timer?
    private var processId: pid_t?
    private var memoryHistory: [Int] = []
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(
            withTimeInterval: checkInterval,
            repeats: true
        ) { [weak self] _ in
            self?.checkMemory()
        }
        
        // Check immediately
        checkMemory()
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkMemory() {
        guard let pid = findOpenCodeProcess() else {
            currentMemoryMB = 0
            return
        }
        
        processId = pid
        
        let memoryMB = getProcessMemory(pid)
        currentMemoryMB = memoryMB
        
        // Update peak
        if memoryMB > peakMemoryMB {
            peakMemoryMB = memoryMB
        }
        
        // Update history
        memoryHistory.append(memoryMB)
        if memoryHistory.count > 60 {  // Keep last hour
            memoryHistory.removeFirst()
        }
        
        // Check thresholds
        updateWarnings(memoryMB)
    }
    
    private func findOpenCodeProcess() -> pid_t? {
        // Find OpenCode process by:
        // 1. Process named "opencode"
        // 2. Node/Bun with "opencode" in command line
        let task = Process()
        task.launchPath = "/bin/ps"
        task.arguments = ["-ax", "-o", "pid,command"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return nil }
        
        for line in output.split(separator: "\n") {
            if line.contains("opencode") {
                let parts = line.split(separator: " ", maxSplits: 1)
                if let pidStr = parts.first, let pid = pid_t(pidStr) {
                    return pid
                }
            }
        }
        
        return nil
    }
    
    private func getProcessMemory(_ pid: pid_t) -> Int {
        var info = task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<task_basic_info>.size) / 4
        var task: mach_port_t = 0
        
        guard task_for_pid(mach_task_self_, pid, &task) == KERN_SUCCESS else {
            return 0
        }
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(task, task_flavor_t(TASK_BASIC_INFO), $0, &count)
            }
        }
        
        guard result == KERN_SUCCESS else { return 0 }
        
        // Convert to MB
        return Int(info.resident_size) / 1024 / 1024
    }
    
    private func updateWarnings(_ memoryMB: Int) {
        let wasCritical = criticalActive
        let wasWarning = warningActive
        
        criticalActive = memoryMB >= criticalThreshold
        warningActive = memoryMB >= warningThreshold && !criticalActive
        
        // Alert on threshold crossing
        if criticalActive && !wasCritical {
            showCriticalAlert(memoryMB)
        } else if warningActive && !wasWarning {
            showWarningNotification(memoryMB)
        }
    }
    
    var averageMemoryMB: Int {
        guard !memoryHistory.isEmpty else { return 0 }
        return memoryHistory.reduce(0, +) / memoryHistory.count
    }
}
```

#### 1.2 Memory Alerts
- [ ] Create warning notification (2GB threshold)
- [ ] Create critical alert with restart option (4GB threshold)
- [ ] Add memory display in menu bar (optional)
- [ ] Show memory trend in settings

**UI Components:**
```swift
// UI/Components/MemoryWarningView.swift
struct MemoryWarningView: View {
    let memoryMB: Int
    let level: WarningLevel
    let onRestart: () -> Void
    
    enum WarningLevel {
        case warning
        case critical
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: level == .critical ? "exclamationmark.triangle.fill" : "exclamationmark.triangle")
                    .foregroundColor(level == .critical ? .red : .orange)
                Text(level == .critical ? "Critical Memory Usage" : "High Memory Usage")
                    .font(.headline)
            }
            
            Text("OpenCode is using \(memoryMB) MB of memory.")
                .font(.body)
            
            if level == .critical {
                Text("Performance may be degraded. Consider restarting OpenCode.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                if level == .critical {
                    Button("Restart OpenCode") {
                        onRestart()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                Button(level == .critical ? "Dismiss" : "OK") {
                    // Dismiss
                }
            }
        }
        .padding()
        .frame(maxWidth: 400)
    }
}

// UI/Components/MemoryStatusView.swift
struct MemoryStatusView: View {
    @ObservedObject var monitor: MemoryMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Memory Usage")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current: \(monitor.currentMemoryMB) MB")
                    Text("Peak: \(monitor.peakMemoryMB) MB")
                    Text("Average: \(monitor.averageMemoryMB) MB")
                }
                .font(.caption)
                
                Spacer()
                
                memoryIndicator
            }
            
            MemoryChartView(history: monitor.memoryHistory)
                .frame(height: 60)
        }
        .padding()
    }
    
    var memoryIndicator: some View {
        Circle()
            .fill(indicatorColor)
            .frame(width: 12, height: 12)
    }
    
    var indicatorColor: Color {
        if monitor.criticalActive {
            return .red
        } else if monitor.warningActive {
            return .orange
        } else {
            return .green
        }
    }
}
```

#### 1.3 Memory Preferences
- [ ] Add memory monitoring settings
- [ ] Configurable thresholds
- [ ] Enable/disable monitoring
- [ ] Enable/disable auto-restart option

### Task Group 2: Auto-Update System

**Goal:** Implement automatic updates using Sparkle framework.

#### 2.1 Sparkle Integration
- [ ] Add Sparkle framework via SPM or manual integration
- [ ] Configure Info.plist for Sparkle
- [ ] Set up update feed URL
- [ ] Configure automatic check schedule
- [ ] Add "Check for Updates" menu item

**Info.plist Configuration:**
```xml
<!-- Info.plist -->
<key>SUFeedURL</key>
<string>https://github.com/rothnic/opencode-island/releases.atom</string>

<key>SUEnableAutomaticChecks</key>
<true/>

<key>SUScheduledCheckInterval</key>
<integer>86400</integer> <!-- 24 hours -->

<key>SUPublicEDKey</key>
<string>YOUR_PUBLIC_KEY_HERE</string>

<key>SUAllowsAutomaticUpdates</key>
<true/>
```

**Implementation:**
```swift
// Services/Update/UpdateManager.swift
import Sparkle

class UpdateManager {
    private let updaterController: SPUStandardUpdaterController
    
    init() {
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: NotchUserDriver()
        )
    }
    
    func checkForUpdates() {
        updaterController.checkForUpdates(nil)
    }
    
    var automaticallyChecksForUpdates: Bool {
        get { updaterController.updater.automaticallyChecksForUpdates }
        set { updaterController.updater.automaticallyChecksForUpdates = newValue }
    }
    
    var automaticallyDownloadsUpdates: Bool {
        get { updaterController.updater.automaticallyDownloadsUpdates }
        set { updaterController.updater.automaticallyDownloadsUpdates = newValue }
    }
}

// AppDelegate.swift enhancement
class AppDelegate: NSObject, NSApplicationDelegate {
    var updateManager: UpdateManager!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // ... existing code ...
        
        // Initialize update manager
        updateManager = UpdateManager()
        
        // Check for updates on launch (after 3 seconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.updateManager.checkForUpdates()
        }
    }
}
```

#### 2.2 Update UI Integration
- [ ] Add "Check for Updates" to app menu
- [ ] Show update status in settings
- [ ] Customize update notifications for notch UI
- [ ] Add update preferences

**Menu Integration:**
```swift
// Add to app menu
let appMenu = NSMenu()
appMenu.addItem(withTitle: "About OpenCode Island", action: #selector(showAbout), keyEquivalent: "")
appMenu.addItem(NSMenuItem.separator())
appMenu.addItem(withTitle: "Check for Updates...", action: #selector(checkForUpdates), keyEquivalent: "")
appMenu.addItem(NSMenuItem.separator())
appMenu.addItem(withTitle: "Preferences...", action: #selector(showPreferences), keyEquivalent: ",")
```

#### 2.3 Release Automation
- [ ] Create GitHub Actions workflow for releases
- [ ] Generate appcast XML for Sparkle
- [ ] Sign releases with EdDSA key
- [ ] Automate DMG creation
- [ ] Upload to GitHub Releases

**GitHub Actions:**
```yaml
# .github/workflows/release.yml
name: Release

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
          xcodebuild -scheme OpenCodeIsland \
            -configuration Release \
            -arch arm64 -arch x86_64 \
            ONLY_ACTIVE_ARCH=NO \
            build
      
      - name: Create DMG
        run: |
          ./scripts/create-dmg.sh
      
      - name: Sign DMG
        run: |
          codesign --force --sign "Developer ID" OpenCodeIsland.dmg
      
      - name: Generate Appcast
        run: |
          ./scripts/generate-appcast.sh
      
      - name: Upload to Release
        uses: actions/upload-release-asset@v1
        with:
          upload_url: ${{ github.event.release.upload_url }}
          asset_path: ./OpenCodeIsland.dmg
          asset_name: OpenCodeIsland.dmg
          asset_content_type: application/x-apple-diskimage
```

### Task Group 3: OpenSkills Integration (Optional)

**Goal:** Support OpenCode skills and Claude skills via OpenSkills loader.

#### 3.1 Skills Detection
- [ ] Detect skills directory (`~/.config/opencode/skills/`)
- [ ] Parse skills metadata
- [ ] List available skills
- [ ] Show active skills in UI

#### 3.2 Skills UI
- [ ] Add skills tab to settings
- [ ] Show installed skills
- [ ] Display skill descriptions
- [ ] Enable/disable skills
- [ ] Link to skills documentation

**Reference:** [OpenSkills](https://github.com/numman-ali/openskills) - Universal skills loader

### Task Group 4: Performance Optimizations

**Goal:** Optimize app performance for long-running sessions.

#### 4.1 Conversation Parsing Optimization
- [ ] Implement lazy loading for large conversations
- [ ] Add pagination for conversation history
- [ ] Cache parsed messages
- [ ] Optimize JSONL parsing
- [ ] Reduce memory footprint

#### 4.2 File Watching Optimization
- [ ] Debounce file change events
- [ ] Batch session file updates
- [ ] Optimize directory watching
- [ ] Reduce CPU usage during idle

#### 4.3 UI Performance
- [ ] Lazy load session list items
- [ ] Virtualize long conversation lists
- [ ] Optimize view updates
- [ ] Reduce animation overhead

### Task Group 5: Advanced Session Management

**Goal:** Add advanced features for managing multiple sessions.

#### 5.1 Session Organization
- [ ] Add session tags/labels
- [ ] Add session notes
- [ ] Star/favorite sessions
- [ ] Archive old sessions
- [ ] Search across sessions

#### 5.2 Session Export
- [ ] Export session as markdown
- [ ] Export conversation history
- [ ] Export session configuration
- [ ] Batch export multiple sessions

#### 5.3 Session Analytics
- [ ] Track tool usage statistics
- [ ] Track session duration
- [ ] Track tokens used (if available from provider)
- [ ] Show cost estimates (if provider data available)

## Technical Details

### Implementation Approach

Phase 3 adds **advanced, self-contained features**:

1. **Memory Monitoring:** Separate service, optional feature
2. **Auto-Update:** Standard Sparkle integration
3. **Skills:** Optional feature, separate UI
4. **Optimizations:** Incremental improvements
5. **Session Management:** Enhanced existing features

### Key Files to Create

**Memory Monitoring:**
- `OpenCodeIsland/Services/Monitoring/MemoryMonitor.swift`
- `OpenCodeIsland/UI/Components/MemoryWarningView.swift`
- `OpenCodeIsland/UI/Components/MemoryStatusView.swift`

**Auto-Update:**
- `OpenCodeIsland/Services/Update/UpdateManager.swift` (enhance existing)
- `.github/workflows/release.yml`
- `scripts/generate-appcast.sh`

**Skills (Optional):**
- `OpenCodeIsland/Services/Skills/SkillsManager.swift`
- `OpenCodeIsland/UI/Views/SkillsView.swift`

**Performance:**
- Optimize existing files (ConversationParser, SessionMonitor, etc.)

### Dependencies

**Sparkle Framework:**
```swift
// Package.swift or manual integration
dependencies: [
    .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.0.0")
]
```

## Documentation

### References

**Required:**
- [OpenCode-Specific Configuration](../docs/opencode-specific-config.md) - Memory monitoring details
- [Migration Strategy](../docs/migration-strategy.md) - Phase 3 details

**Optional:**
- [OpenSkills](https://github.com/numman-ali/openskills) - Skills integration
- [Sparkle Documentation](https://sparkle-project.org/) - Auto-update setup

### To Update

- [ ] README.md - Add memory monitoring and auto-update features
- [ ] AGENTS.md - Document Phase 3 features
- [ ] Create user guide for memory monitoring

### To Create

- [ ] Phase 3 completion report
- [ ] Auto-update setup guide for maintainers
- [ ] Performance optimization guide

## Success Criteria

- [ ] ✅ Memory monitoring tracks OpenCode process
- [ ] ✅ Warning shows at 2GB threshold
- [ ] ✅ Critical alert shows at 4GB threshold
- [ ] ✅ Memory chart displays in settings
- [ ] ✅ Sparkle framework integrated
- [ ] ✅ "Check for Updates" works
- [ ] ✅ Automatic updates work
- [ ] ✅ Release workflow automated
- [ ] ✅ Skills support functional (if implemented)
- [ ] ✅ Conversation parsing optimized
- [ ] ✅ No performance regressions
- [ ] ✅ Session export works
- [ ] ✅ All Phase 1 & 2 features still work

## Rollback Plan

Phase 3 features are optional:

1. **Disable memory monitoring:** Remove timer, skip checks
2. **Disable auto-update:** Remove Sparkle initialization
3. **Remove skills:** Comment out skills manager
4. **Revert optimizations:** Git cherry-pick if needed

Core app still works without Phase 3 features.

## Timeline

**Week 1:**
- Days 1-3: Memory monitoring
- Days 4-5: Sparkle integration

**Week 2:**
- Days 1-2: Release automation
- Days 3-4: Performance optimizations
- Day 5: Testing and documentation

## Notes

### Feature Priorities

**Must Have:**
- ✅ Memory monitoring (unique to OpenCode)
- ✅ Auto-update (industry standard)
- ✅ Performance optimizations

**Optional:**
- ⭐ OpenSkills integration
- ⭐ Advanced session management
- ⭐ Session analytics

### Why Memory Monitoring?

OpenCode can have higher memory usage than Claude Code due to:
- Multiple MCP servers running
- Node.js/Bun runtime overhead
- Potential memory leaks in long sessions

Memory monitoring helps users:
- Detect performance issues early
- Know when to restart
- Track memory trends

### Upstream Sync

Phase 3 is completely additive and self-contained. Easy to merge upstream changes.

## Related Issues

**Depends on:**
- Phase 1: MVP OpenCode Integration
- Phase 2: Enhanced Features & MCP Integration

**Blocks:**
- Phase 4: Polish & Production Ready

## Labels

`phase-3`, `enhancement`, `performance`, `monitoring`, `auto-update`

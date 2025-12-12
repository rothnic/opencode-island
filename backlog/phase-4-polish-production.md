# Phase 4: Polish & Production Ready

## Phase Overview

**Timeline:** 1-2 weeks  
**Dependencies:** Phases 1, 2, and 3 complete  
**Upstream Sync Impact:** None - This is final polish and deployment

## Objectives

- [ ] Comprehensive testing across all features
- [ ] Build universal binary (Intel + Apple Silicon)
- [ ] Code signing and notarization
- [ ] Create polished installer (DMG)
- [ ] Complete all documentation
- [ ] Release to production

## Tasks

### Task Group 1: Comprehensive Testing

**Goal:** Ensure all features work correctly and no regressions exist.

#### 1.1 Unit Testing
- [ ] Write unit tests for new components
- [ ] Test configuration parser thoroughly
- [ ] Test memory monitor calculations
- [ ] Test provider detection
- [ ] Test MCP server parsing
- [ ] Test tool formatter
- [ ] Achieve >80% code coverage for new code

**Test Structure:**
```swift
// Tests/OpenCodeIslandTests/
├── Config/
│   ├── OpenCodeConfigParserTests.swift
│   ├── ConfigurationManagerTests.swift
│   └── MCPServerConfigTests.swift
├── Monitoring/
│   ├── MemoryMonitorTests.swift
│   └── ProcessFinderTests.swift
├── Services/
│   ├── SessionMonitorTests.swift
│   └── HookSystemTests.swift
└── Utilities/
    ├── ToolFormatterTests.swift
    └── ProviderInfoTests.swift
```

#### 1.2 Integration Testing
- [ ] Test full session lifecycle
- [ ] Test hook system end-to-end
- [ ] Test configuration reload
- [ ] Test multiple simultaneous sessions
- [ ] Test MCP server lifecycle
- [ ] Test memory monitoring integration
- [ ] Test auto-update flow (staging)

#### 1.3 UI Testing
- [ ] Test all settings panels
- [ ] Test session list interactions
- [ ] Test conversation view
- [ ] Test notch animations
- [ ] Test menu bar interactions
- [ ] Test keyboard shortcuts
- [ ] Test accessibility

#### 1.4 Cross-Platform Testing
- [ ] Test on macOS 12.0 (minimum supported)
- [ ] Test on macOS 13.x
- [ ] Test on macOS 14.x (Sonoma)
- [ ] Test on macOS 15.x (Sequoia) if available
- [ ] Test on Intel Mac
- [ ] Test on Apple Silicon (M1/M2/M3)

#### 1.5 Provider Testing
- [ ] Test with Anthropic Claude (Opus, Sonnet, Haiku)
- [ ] Test with OpenAI (GPT-4, GPT-3.5)
- [ ] Test with Google Gemini
- [ ] Test with DeepSeek
- [ ] Test with local model (Ollama)
- [ ] Test with multiple providers sequentially
- [ ] Test provider switching

#### 1.6 Performance Testing
- [ ] Long-running session (hours)
- [ ] Large conversation history (1000+ messages)
- [ ] Multiple concurrent sessions
- [ ] Memory usage over time
- [ ] CPU usage monitoring
- [ ] App launch time
- [ ] Configuration reload time

#### 1.7 Stress Testing
- [ ] 10+ concurrent sessions
- [ ] Very large files in conversation
- [ ] Rapid tool executions
- [ ] Quick provider switches
- [ ] Configuration file corruption handling
- [ ] Network interruptions (for remote MCP)

### Task Group 2: Universal Binary Build

**Goal:** Create a single app that runs on both Intel and Apple Silicon Macs.

#### 2.1 Build Configuration
- [ ] Configure Xcode for universal build
- [ ] Set architectures: `arm64 x86_64`
- [ ] Disable `ONLY_ACTIVE_ARCH`
- [ ] Verify all dependencies support universal
- [ ] Test build on both architectures

**Build Command:**
```bash
xcodebuild \
  -scheme OpenCodeIsland \
  -configuration Release \
  -arch arm64 \
  -arch x86_64 \
  ONLY_ACTIVE_ARCH=NO \
  -derivedDataPath ./build \
  build
```

#### 2.2 Binary Verification
- [ ] Verify architectures with `lipo`
- [ ] Check binary size
- [ ] Test on Intel Mac
- [ ] Test on Apple Silicon Mac
- [ ] Verify performance on both

**Verification:**
```bash
# Check architectures
lipo -info build/Release/OpenCodeIsland.app/Contents/MacOS/OpenCodeIsland
# Expected: Architectures in the fat file: x86_64 arm64

# Extract architectures
lipo build/Release/OpenCodeIsland.app/Contents/MacOS/OpenCodeIsland \
  -thin x86_64 -output OpenCodeIsland-x86_64
lipo build/Release/OpenCodeIsland.app/Contents/MacOS/OpenCodeIsland \
  -thin arm64 -output OpenCodeIsland-arm64
```

### Task Group 3: Code Signing & Notarization

**Goal:** Sign and notarize the app for distribution outside the Mac App Store.

#### 3.1 Developer Certificates
- [ ] Obtain Developer ID Application certificate
- [ ] Install certificate in Keychain
- [ ] Configure Xcode signing
- [ ] Set up provisioning profile

#### 3.2 Code Signing
- [ ] Sign app bundle
- [ ] Sign all frameworks/libraries
- [ ] Enable hardened runtime
- [ ] Set entitlements

**Signing Command:**
```bash
codesign --force --sign "Developer ID Application: Your Name (TEAM_ID)" \
  --options runtime \
  --entitlements OpenCodeIsland/OpenCodeIsland.entitlements \
  --timestamp \
  --deep \
  build/Release/OpenCodeIsland.app
```

**Entitlements:**
```xml
<!-- OpenCodeIsland.entitlements -->
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <false/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.network.server</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
</dict>
</plist>
```

#### 3.3 Notarization
- [ ] Create app archive
- [ ] Submit to Apple notarization service
- [ ] Wait for approval
- [ ] Staple notarization ticket
- [ ] Verify notarization

**Notarization Commands:**
```bash
# Create zip for notarization
ditto -c -k --keepParent build/Release/OpenCodeIsland.app OpenCodeIsland.zip

# Submit for notarization
xcrun notarytool submit OpenCodeIsland.zip \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password" \
  --wait

# Staple ticket
xcrun stapler staple build/Release/OpenCodeIsland.app

# Verify
spctl -a -t exec -vv build/Release/OpenCodeIsland.app
```

### Task Group 4: Installer Creation

**Goal:** Create a polished DMG installer for easy distribution.

#### 4.1 DMG Design
- [ ] Design DMG background image
- [ ] Add app icon
- [ ] Add Applications folder symlink
- [ ] Set window size and position
- [ ] Configure icon positions

#### 4.2 DMG Creation Script
- [ ] Create automated DMG build script
- [ ] Include README/license
- [ ] Set DMG volume name
- [ ] Compress DMG

**Script:**
```bash
#!/bin/bash
# scripts/create-dmg.sh

set -e

APP_NAME="OpenCodeIsland"
VERSION=$(defaults read build/Release/$APP_NAME.app/Contents/Info.plist CFBundleShortVersionString)
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
VOLUME_NAME="$APP_NAME $VERSION"

# Create temporary directory
TMP_DIR=$(mktemp -d)
mkdir -p "$TMP_DIR"

# Copy app
cp -R "build/Release/$APP_NAME.app" "$TMP_DIR/"

# Create symlink to Applications
ln -s /Applications "$TMP_DIR/Applications"

# Copy additional files
cp README.md "$TMP_DIR/"
cp LICENSE.md "$TMP_DIR/"

# Create DMG
hdiutil create -volname "$VOLUME_NAME" \
  -srcfolder "$TMP_DIR" \
  -ov -format UDZO \
  "$DMG_NAME"

# Clean up
rm -rf "$TMP_DIR"

echo "✅ Created $DMG_NAME"
```

#### 4.3 DMG Testing
- [ ] Test DMG mounts correctly
- [ ] Test drag-to-install works
- [ ] Test installed app launches
- [ ] Verify all files included
- [ ] Test on clean system

### Task Group 5: Documentation

**Goal:** Complete all documentation for users and developers.

#### 5.1 User Documentation
- [ ] Update README.md with final feature list
- [ ] Create USER_GUIDE.md
- [ ] Document system requirements
- [ ] Add troubleshooting section
- [ ] Create FAQ
- [ ] Add screenshots and GIFs
- [ ] Document keyboard shortcuts
- [ ] Document menu bar features

**User Guide Structure:**
```markdown
# User Guide

## Installation
## Getting Started
## Configuration
## Using OpenCode Island
## Features
  - Session Monitoring
  - Multi-Provider Support
  - MCP Server Management
  - Memory Monitoring
  - Tool Executions
## Settings
## Keyboard Shortcuts
## Troubleshooting
## FAQ
```

#### 5.2 Developer Documentation
- [ ] Update AGENTS.md for completeness
- [ ] Create CONTRIBUTING.md
- [ ] Document build process
- [ ] Document testing procedures
- [ ] Create architecture diagram
- [ ] Document code organization
- [ ] Add inline code documentation

#### 5.3 Release Documentation
- [ ] Write release notes
- [ ] Create CHANGELOG.md
- [ ] Document migration from Claude Island
- [ ] Create upgrade guide
- [ ] Document breaking changes (if any)

#### 5.4 Upstream Documentation
- [ ] Update UPSTREAM_SYNC.md
- [ ] Document differences from Claude Island
- [ ] Create merge conflict resolution guide
- [ ] Document customization points

### Task Group 6: Release Preparation

**Goal:** Prepare for public release on GitHub.

#### 6.1 Version Management
- [ ] Set final version number (e.g., 1.0.0)
- [ ] Update Info.plist version
- [ ] Update CFBundleVersion
- [ ] Tag release in git
- [ ] Create release branch

#### 6.2 Release Assets
- [ ] Build final universal binary
- [ ] Sign and notarize
- [ ] Create DMG
- [ ] Generate checksums (SHA-256)
- [ ] Create Sparkle appcast XML
- [ ] Prepare release notes

**Release Checklist:**
```bash
# Version
VERSION=1.0.0

# Build
./scripts/build-universal.sh

# Sign and notarize
./scripts/sign-and-notarize.sh

# Create DMG
./scripts/create-dmg.sh

# Generate checksums
shasum -a 256 OpenCodeIsland-${VERSION}.dmg > checksums.txt

# Generate appcast
./scripts/generate-appcast.sh

# Tag release
git tag -a "v${VERSION}" -m "Release ${VERSION}"
git push origin "v${VERSION}"
```

#### 6.3 GitHub Release
- [ ] Create GitHub release draft
- [ ] Upload DMG
- [ ] Upload checksums
- [ ] Add release notes
- [ ] Add screenshots
- [ ] Publish release

#### 6.4 Release Communication
- [ ] Announce on GitHub Discussions
- [ ] Post to relevant communities
- [ ] Update project website (if any)
- [ ] Share on social media (optional)

### Task Group 7: Post-Release

**Goal:** Monitor release and handle feedback.

#### 7.1 Monitoring
- [ ] Monitor GitHub issues
- [ ] Track download statistics
- [ ] Monitor crash reports (if analytics enabled)
- [ ] Watch for user feedback
- [ ] Monitor memory usage reports

#### 7.2 Hotfix Preparation
- [ ] Create hotfix branch strategy
- [ ] Document hotfix release process
- [ ] Set up rapid deployment pipeline
- [ ] Prepare rollback procedure

#### 7.3 Success Metrics
- [ ] Track downloads
- [ ] Collect user feedback
- [ ] Monitor crash rate
- [ ] Track feature usage (if analytics)
- [ ] Measure user satisfaction

## Technical Details

### Build Scripts

Create comprehensive build scripts:

**scripts/build-universal.sh**
```bash
#!/bin/bash
set -e

echo "🔨 Building Universal Binary..."
xcodebuild \
  -scheme OpenCodeIsland \
  -configuration Release \
  -arch arm64 -arch x86_64 \
  ONLY_ACTIVE_ARCH=NO \
  -derivedDataPath ./build \
  clean build

echo "✅ Build complete"
lipo -info build/Release/OpenCodeIsland.app/Contents/MacOS/OpenCodeIsland
```

**scripts/sign-and-notarize.sh**
```bash
#!/bin/bash
set -e

IDENTITY="Developer ID Application: Your Name (TEAM_ID)"
APP_PATH="build/Release/OpenCodeIsland.app"

echo "🔐 Signing app..."
codesign --force --sign "$IDENTITY" \
  --options runtime \
  --entitlements OpenCodeIsland/OpenCodeIsland.entitlements \
  --timestamp \
  --deep \
  "$APP_PATH"

echo "📦 Creating archive..."
ditto -c -k --keepParent "$APP_PATH" OpenCodeIsland.zip

echo "📤 Submitting for notarization..."
xcrun notarytool submit OpenCodeIsland.zip \
  --apple-id "$APPLE_ID" \
  --team-id "$TEAM_ID" \
  --password "$APP_PASSWORD" \
  --wait

echo "📎 Stapling ticket..."
xcrun stapler staple "$APP_PATH"

echo "✅ Notarization complete"
rm OpenCodeIsland.zip
```

### Automated Testing

**CI/CD Pipeline:**
```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build
        run: |
          xcodebuild -scheme OpenCodeIsland \
            -configuration Debug \
            build-for-testing
      
      - name: Test
        run: |
          xcodebuild -scheme OpenCodeIsland \
            -configuration Debug \
            test-without-building
      
      - name: Upload Coverage
        uses: codecov/codecov-action@v3
```

## Documentation

### References

**Required:**
- [Migration Strategy](../docs/migration-strategy.md) - Phase 4 details
- All previous phase documentation

### To Create

- [ ] USER_GUIDE.md
- [ ] CONTRIBUTING.md
- [ ] CHANGELOG.md
- [ ] Release notes
- [ ] Migration guide

### To Update

- [ ] README.md - Final version
- [ ] AGENTS.md - Complete
- [ ] All docs/ files - Review and polish

## Success Criteria

- [ ] ✅ All unit tests pass
- [ ] ✅ All integration tests pass
- [ ] ✅ Universal binary builds successfully
- [ ] ✅ App runs on Intel Mac
- [ ] ✅ App runs on Apple Silicon Mac
- [ ] ✅ App is signed and notarized
- [ ] ✅ DMG installs correctly
- [ ] ✅ All documentation complete
- [ ] ✅ Release published on GitHub
- [ ] ✅ No critical bugs
- [ ] ✅ < 1% crash rate in first week
- [ ] ✅ Positive user feedback

## Rollback Plan

If critical issues found after release:

1. **Immediate:**
   - Pull release from GitHub
   - Add warning to README
   - Communicate issue to users

2. **Hotfix:**
   - Create hotfix branch from release tag
   - Fix critical issue
   - Fast-track testing
   - Release hotfix version

3. **Rollback:**
   - Users can download previous version
   - Provide downgrade instructions
   - Investigate root cause

## Timeline

**Week 1:**
- Days 1-3: Comprehensive testing
- Days 4-5: Universal binary, signing, notarization

**Week 2:**
- Days 1-2: DMG creation, documentation
- Days 3-4: Release preparation
- Day 5: Release and monitoring

## Notes

### Quality Checklist

Before release, verify:
- ✅ No compiler warnings
- ✅ No analyzer warnings
- ✅ No memory leaks (Instruments)
- ✅ Accessibility labels set
- ✅ Dark mode works
- ✅ All strings localized (if applicable)
- ✅ Help menu populated
- ✅ About dialog complete
- ✅ License included
- ✅ Third-party attributions included

### Release Versioning

Use semantic versioning:
- **1.0.0** - Initial OpenCode Island release
- **1.0.x** - Hotfixes
- **1.x.0** - Minor features
- **2.0.0** - Major changes

### Support Strategy

Post-release support:
- GitHub Issues for bug reports
- GitHub Discussions for questions
- Email support (optional)
- Community Discord (optional)

## Related Issues

**Depends on:**
- Phase 1: MVP OpenCode Integration
- Phase 2: Enhanced Features & MCP Integration
- Phase 3: Advanced Capabilities

**Blocks:**
- Nothing - this is the final phase!

## Labels

`phase-4`, `testing`, `release`, `documentation`, `deployment`

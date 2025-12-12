# Phase 1 POC - Setup Instructions

## Adding POC Files to Xcode Project

The Phase 1 POC implementation includes new Swift files that need to be added to the Xcode project before building.

### New Swift Files

#### Models
- `ClaudeIsland/Models/OpenCodeConfig.swift` - OpenCode configuration data structures

#### Utilities
- `ClaudeIsland/Utilities/OpenCodeConfigLoader.swift` - Configuration discovery and loading

#### Services
- `ClaudeIsland/Services/Shared/OpenCodeMonitorPOC.swift` - Process and memory monitoring

### Adding Files to Xcode

1. **Open the project in Xcode:**
   ```bash
   open ClaudeIsland.xcodeproj
   ```

2. **Add OpenCodeConfig.swift:**
   - Right-click on `ClaudeIsland/Models` folder
   - Select "Add Files to ClaudeIsland..."
   - Navigate to `ClaudeIsland/Models/OpenCodeConfig.swift`
   - Ensure "Copy items if needed" is **unchecked** (file is already in place)
   - Ensure "Add to targets: ClaudeIsland" is **checked**
   - Click "Add"

3. **Add OpenCodeConfigLoader.swift:**
   - Right-click on `ClaudeIsland/Utilities` folder
   - Select "Add Files to ClaudeIsland..."
   - Navigate to `ClaudeIsland/Utilities/OpenCodeConfigLoader.swift`
   - Ensure "Copy items if needed" is **unchecked**
   - Ensure "Add to targets: ClaudeIsland" is **checked**
   - Click "Add"

4. **Add OpenCodeMonitorPOC.swift:**
   - Right-click on `ClaudeIsland/Services/Shared` folder
   - Select "Add Files to ClaudeIsland..."
   - Navigate to `ClaudeIsland/Services/Shared/OpenCodeMonitorPOC.swift`
   - Ensure "Copy items if needed" is **unchecked**
   - Ensure "Add to targets: ClaudeIsland" is **checked**
   - Click "Add"

5. **Verify files are added:**
   - Check Project Navigator - all three files should appear in their respective folders
   - Build the project (⌘B) to ensure no compilation errors

### Alternative: Using Xcode Command Line

If you prefer command line, you can use `xcodebuild` to verify the project:

```bash
cd /path/to/opencode-island
xcodebuild -project ClaudeIsland.xcodeproj -scheme ClaudeIsland -configuration Debug clean build
```

**Note:** Files must be manually added through Xcode GUI as the .pbxproj format is complex and binary-based.

## Testing the POC

After adding the files and building successfully:

1. **Run automated setup:**
   ```bash
   ./test-poc.sh
   ```

2. **Build and run the app:**
   ```bash
   xcodebuild -project ClaudeIsland.xcodeproj -scheme ClaudeIsland -configuration Debug
   # or open in Xcode and click Run
   ```

3. **Follow the testing guide:**
   See [POC-TESTING-GUIDE.md](./POC-TESTING-GUIDE.md) for detailed testing procedures.

## Hook Scripts Installation

The hook scripts are provided in `/tmp/opencode-hooks/` but should be installed to:
```
~/.config/opencode/hooks/
```

To install manually:
```bash
mkdir -p ~/.config/opencode/hooks
cp /tmp/opencode-hooks/*.sh ~/.config/opencode/hooks/
chmod +x ~/.config/opencode/hooks/*.sh
```

Or use the automated test script which handles this for you.

## Configuration Files

Test configuration is provided at:
- `test-opencode.jsonc` - Test OpenCode configuration

The configuration loader will search for configs at:
1. `~/.config/opencode/opencode.jsonc` (global)
2. `<project-root>/opencode.jsonc` (project)
3. `<project-root>/.opencode/opencode.jsonc` (project)

## Expected Build Outcome

After adding the files, the project should:
- ✅ Compile without errors
- ✅ Include new configuration models
- ✅ Include configuration loader utility
- ✅ Include memory monitoring POC

The app functionality remains unchanged (no UI integration yet), but the POC code is ready for Phase 2 integration.

## Troubleshooting

### File not found errors
- Ensure files are in the correct directories
- Verify file paths in Xcode Project Navigator
- Clean build folder (⌘⇧K) and rebuild

### Compilation errors
- Check Swift version compatibility (5.0+)
- Ensure all required frameworks are linked
- Verify no namespace conflicts

### Missing imports
All POC files use only Foundation framework, which should already be imported in the project.

## Next Steps

Once files are added and project builds successfully:

1. Run the POC test script: `./test-poc.sh`
2. Follow the testing guide: [POC-TESTING-GUIDE.md](./POC-TESTING-GUIDE.md)
3. Review POC results:
   - [POC-CONFIG-VALIDATION.md](./POC-CONFIG-VALIDATION.md)
   - [POC-MEMORY-MONITORING.md](./POC-MEMORY-MONITORING.md)
   - [POC-HOOKS-COMPATIBILITY.md](./POC-HOOKS-COMPATIBILITY.md)
4. Proceed to Phase 2: Core Integration

## Support

For issues or questions:
- Check [POC-TESTING-GUIDE.md](./POC-TESTING-GUIDE.md) for common issues
- Review [AGENTS.md](./AGENTS.md) for architecture details
- See [Migration Strategy](./docs/migration-strategy.md) for context

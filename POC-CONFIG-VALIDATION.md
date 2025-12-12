# POC: Configuration Schema Validation & Discovery

## Objective
Validate OpenCode configuration format, discovery, and merging of existing user configurations.

## Implementation

### Configuration Discovery
Implemented `OpenCodeConfigLoader` that discovers configuration files in standard locations:

1. **Project-specific** (highest priority):
   - `<project-root>/opencode.jsonc`
   - `<project-root>/.opencode/opencode.jsonc`

2. **Global user config**:
   - `~/.config/opencode/opencode.jsonc`
   - `~/.config/opencode/opencode.json`

### Configuration Merging
The loader merges configurations with the following priority:
1. Global config (base)
2. Project config (overrides global)
3. Test config (overrides project)

**Key Features:**
- Preserves authentication tokens from existing configs
- Preserves model selection from existing configs
- Merges MCP server configurations (additive)
- JSONC comment support (single-line `//` and multi-line `/* */`)

### Configuration Models

#### OpenCodeConfig
```swift
struct OpenCodeConfig: Codable {
    let model: OpenCodeModelConfig?
    let mcp: [String: OpenCodeMCPServer]?
    let plugins: [String: [String: AnyCodableValue]]?
    let tools: OpenCodeToolsConfig?
    let ui: OpenCodeUIConfig?
}
```

#### OpenCodeMCPServer
```swift
struct OpenCodeMCPServer: Codable {
    let type: String  // "local" or "remote"
    let command: [String]?  // For local servers
    let url: String?  // For remote servers
    let env: [String: String]?
    let disabled: Bool?
}
```

### Validation
Implemented `validateConfig()` that checks:
- ✅ Model provider is specified
- ✅ Model name is specified
- ✅ Local MCP servers have command arrays
- ✅ Remote MCP servers have URLs

## Test Configuration

Created `test-opencode.jsonc` with:
- Fallback model: `github-copilot/gpt-4o-mini`
- Test MCP servers: `filesystem` and `git`
- Basic UI and tools configuration

## Usage Example

```swift
// Discover existing configuration
let existingConfig = OpenCodeConfigLoader.discoverConfiguration()

// Load test configuration
let testConfig = OpenCodeConfigLoader.loadConfigFile(at: "test-opencode.jsonc")

// Merge configurations (test overrides existing)
let mergedConfig = existingConfig?.merging(with: testConfig) ?? testConfig

// Validate merged configuration
let validation = OpenCodeConfigLoader.validateConfig(mergedConfig)
if !validation.isValid {
    print("Validation errors: \(validation.errors)")
}
```

## Results

### ✅ Configuration Discovery
- Successfully discovers configs from all standard locations
- Properly expands `~` in paths
- Handles missing config files gracefully

### ✅ JSONC Comment Support
- Strips single-line `//` comments
- Strips multi-line `/* */` comments
- Preserves strings with comment-like content

### ✅ Configuration Merging
- Merges multiple configs with correct priority
- Preserves authentication tokens (not overwritten)
- Preserves model selection (not overwritten)
- Additively merges MCP server configurations

### ✅ Schema Validation
- Validates required model fields
- Validates MCP server configurations
- Provides detailed error messages

## OpenCode-Specific Format

OpenCode uses a **different format** than standard MCP:

**Standard MCP:**
```json
{
  "mcpServers": {
    "server": {
      "command": "executable",
      "args": ["arg1"]
    }
  }
}
```

**OpenCode:**
```jsonc
{
  "mcp": {
    "server": {
      "type": "local",
      "command": ["executable", "arg1"]
    }
  }
}
```

**Key Differences:**
1. Top-level key: `mcp` (not `mcpServers`)
2. Command format: Array `["cmd", "arg1", "arg2"]` (not `command` + `args`)
3. Type field: Required `"type": "local"` or `"remote"`

## Testing

### Manual Testing Steps

1. **Create global config:**
   ```bash
   mkdir -p ~/.config/opencode
   cat > ~/.config/opencode/opencode.jsonc << 'EOF'
   {
     "model": {
       "provider": "anthropic",
       "name": "claude-sonnet-4",
       "api_key": "sk-ant-test123"
     }
   }
   EOF
   ```

2. **Create project config:**
   ```bash
   mkdir -p .opencode
   cat > .opencode/opencode.jsonc << 'EOF'
   {
     "model": {
       "name": "claude-opus-4"
     }
   }
   EOF
   ```

3. **Test discovery:**
   - Global config should be discovered
   - Project config should override model name
   - API key should be preserved from global config
   - Test config MCP servers should be added

### Expected Merged Result

```jsonc
{
  "model": {
    "provider": "anthropic",  // from global
    "name": "claude-opus-4",  // from project (overrides)
    "api_key": "sk-ant-test123"  // from global (preserved)
  },
  "mcp": {
    "filesystem": { ... },  // from test config
    "git": { ... }  // from test config
  }
}
```

## Files Created

- `/ClaudeIsland/Models/OpenCodeConfig.swift` - Configuration models
- `/ClaudeIsland/Utilities/OpenCodeConfigLoader.swift` - Discovery and loading logic
- `/test-opencode.jsonc` - Test configuration for validation

## Next Steps

1. Integrate with main application
2. Add UI for configuration management
3. Test with OpenCode CLI
4. Add configuration validation to app startup

## Conclusion

✅ **POC Successful**

Configuration schema validation and discovery is working as designed:
- Discovers configs from all standard locations
- Properly merges configurations with correct priority
- Preserves authentication and model settings
- Validates OpenCode-specific format requirements
- Supports JSONC comments

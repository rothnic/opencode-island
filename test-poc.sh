#!/bin/bash
#
# Manual testing script for OpenCode Island POC
# Tests configuration discovery, memory monitoring, and hook compatibility
#

set -e

echo "========================================="
echo "OpenCode Island POC Manual Testing"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test 1: Configuration File Discovery
echo "Test 1: Configuration File Discovery"
echo "-------------------------------------"

# Check if user has existing OpenCode config
if [ -f ~/.config/opencode/opencode.jsonc ] || [ -f ~/.config/opencode/opencode.json ]; then
    echo -e "${YELLOW}⚠${NC}  Existing OpenCode configuration detected"
    echo "  This test will NOT modify your existing configuration."
    echo "  Using test directory instead: /tmp/test-opencode-config"
    TEST_CONFIG_DIR="/tmp/test-opencode-config"
else
    echo -e "${GREEN}✓${NC} No existing OpenCode configuration found"
    TEST_CONFIG_DIR="$HOME/.config/opencode"
fi

# Create test global config in safe location
mkdir -p "$TEST_CONFIG_DIR"
cat > "$TEST_CONFIG_DIR/opencode.jsonc" << 'EOF'
{
  // Global test config
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

echo -e "${GREEN}✓${NC} Created test config at $TEST_CONFIG_DIR/opencode.jsonc"

# Create test project config
mkdir -p /tmp/test-opencode-project/.opencode
cat > /tmp/test-opencode-project/.opencode/opencode.jsonc << 'EOF'
{
  // Project test config - should override model name
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

echo -e "${GREEN}✓${NC} Created project config at /tmp/test-opencode-project/.opencode/opencode.jsonc"

echo ""
echo "Expected merged config:"
echo "  - model.provider: anthropic (from global)"
echo "  - model.name: claude-opus-4 (from project, overrides global)"
echo "  - model.api_key: sk-ant-test-preserved (from global, preserved)"
echo "  - mcp.filesystem: defined (from project)"
echo "  - ui.theme: dark (from global)"
echo ""
echo "Note: Test config is at $TEST_CONFIG_DIR (safe, non-destructive)"
echo ""

# Test 2: Memory Monitoring Prerequisites
echo "Test 2: Memory Monitoring Prerequisites"
echo "----------------------------------------"

# Check if we can find common processes
if pgrep -x "node" > /dev/null; then
    NODE_PID=$(pgrep -x "node" | head -1)
    echo -e "${GREEN}✓${NC} Found Node.js process (PID: $NODE_PID)"
    echo "  This validates process discovery capability"
else
    echo -e "${YELLOW}⚠${NC}  No Node.js process found (OpenCode not running)"
fi

echo ""

# Test 3: Socket Communication Test
echo "Test 3: Socket Communication Test"
echo "----------------------------------"

SOCKET_PATH="/tmp/opencode-island.sock"

if [ -S "$SOCKET_PATH" ]; then
    echo -e "${GREEN}✓${NC} Unix socket exists at $SOCKET_PATH"
    ls -la "$SOCKET_PATH"
    
    # Try sending a test message
    TEST_JSON='{"session_id":"test","cwd":"/tmp","event":"Test","status":"idle"}'
    echo "$TEST_JSON" | nc -U "$SOCKET_PATH" 2>/dev/null && \
        echo -e "${GREEN}✓${NC} Successfully sent test message to socket" || \
        echo -e "${YELLOW}⚠${NC}  Socket exists but couldn't send message (app may not be running)"
else
    echo -e "${YELLOW}⚠${NC}  Unix socket not found (OpenCode Island not running)"
    echo "  Expected location: $SOCKET_PATH"
    echo "  Start OpenCode Island to create the socket"
fi

echo ""

# Summary
echo "========================================="
echo "POC Testing Summary"
echo "========================================="
echo ""
echo "Configuration Discovery:"
echo "  - Test config: $TEST_CONFIG_DIR/opencode.jsonc"
echo "  - Project config: /tmp/test-opencode-project/.opencode/opencode.jsonc"
echo "  - Project test config: test-opencode.jsonc"
echo ""
echo "Note: OpenCode does NOT have a hooks system"
echo "  - Session monitoring will use file watching instead"
echo "  - Watch: ~/.config/opencode/sessions/"
echo ""
echo "Socket Communication:"
echo "  - Socket path: /tmp/opencode-island.sock"
echo "  - Format: JSON over Unix domain socket"
echo "  - Used for internal app communication"
echo ""
echo "Next Steps:"
echo "  1. Build and run OpenCode Island app"
echo "  2. Verify socket is created"
echo "  3. Start OpenCode CLI session"
echo "  4. App will monitor session files (no hooks in OpenCode)"
echo "  5. Monitor memory usage in app UI"
echo ""
echo "See POC documentation for detailed results:"
echo "  - POC-CONFIG-VALIDATION.md"
echo "  - POC-MEMORY-MONITORING.md"
echo ""
echo "Note: POC-HOOKS-COMPATIBILITY.md is OUTDATED"
echo "  OpenCode does not support hooks - will use session file monitoring"
echo ""

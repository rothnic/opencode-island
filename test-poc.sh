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

# Create test global config
mkdir -p ~/.config/opencode
cat > ~/.config/opencode/opencode.jsonc << 'EOF'
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

echo -e "${GREEN}✓${NC} Created global config at ~/.config/opencode/opencode.jsonc"

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

# Test 2: Hook Script Installation
echo "Test 2: Hook Script Installation"
echo "---------------------------------"

mkdir -p ~/.config/opencode/hooks
mkdir -p ~/.config/opencode/logs

# Copy hooks from temp location if they exist
if [ -d "/tmp/opencode-hooks" ]; then
    cp /tmp/opencode-hooks/*.sh ~/.config/opencode/hooks/ 2>/dev/null || true
fi

# Create hooks if they don't exist
if [ ! -f ~/.config/opencode/hooks/session-start.sh ]; then
    cat > ~/.config/opencode/hooks/session-start.sh << 'HOOK_EOF'
#!/bin/bash
SOCKET_PATH="/tmp/opencode-island.sock"
SESSION_ID="${OPENCODE_SESSION_ID:-unknown}"
CWD="${OPENCODE_CWD:-$(pwd)}"
PID="${OPENCODE_PID:-$$}"
TTY="${OPENCODE_TTY:-$(tty 2>/dev/null || echo 'unknown')}"

EVENT_JSON=$(cat <<EOF
{
  "session_id": "$SESSION_ID",
  "cwd": "$CWD",
  "event": "SessionStart",
  "status": "starting",
  "pid": $PID,
  "tty": "$TTY"
}
EOF
)

if [ -S "$SOCKET_PATH" ]; then
    echo "$EVENT_JSON" | nc -U "$SOCKET_PATH" 2>/dev/null || true
fi

LOG_DIR="$HOME/.config/opencode/logs"
mkdir -p "$LOG_DIR"
echo "[$(date -Iseconds)] SessionStart: $SESSION_ID" >> "$LOG_DIR/hooks.log"
HOOK_EOF
fi

chmod +x ~/.config/opencode/hooks/*.sh 2>/dev/null || true

if [ -f ~/.config/opencode/hooks/session-start.sh ]; then
    echo -e "${GREEN}✓${NC} Hooks installed at ~/.config/opencode/hooks/"
    ls -la ~/.config/opencode/hooks/
else
    echo -e "${YELLOW}⚠${NC}  Hooks not found, but directory structure created"
fi

echo ""

# Test 3: Hook Execution Test
echo "Test 3: Hook Execution Test"
echo "----------------------------"

if [ -f ~/.config/opencode/hooks/session-start.sh ]; then
    export OPENCODE_SESSION_ID="test-session-$(date +%s)"
    export OPENCODE_CWD="/tmp"
    export OPENCODE_PID=$$
    export OPENCODE_TTY=$(tty 2>/dev/null || echo "unknown")
    
    ~/.config/opencode/hooks/session-start.sh
    
    if [ -f ~/.config/opencode/logs/hooks.log ]; then
        echo -e "${GREEN}✓${NC} Hook executed successfully"
        echo "Last log entry:"
        tail -1 ~/.config/opencode/logs/hooks.log
    else
        echo -e "${YELLOW}⚠${NC}  Hook executed but no log file created"
    fi
else
    echo -e "${YELLOW}⚠${NC}  Skipping hook test (hooks not installed)"
fi

echo ""

# Test 4: Memory Monitoring Prerequisites
echo "Test 4: Memory Monitoring Prerequisites"
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

# Test 5: Socket Communication Test
echo "Test 5: Socket Communication Test"
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
echo "  - Global config: ~/.config/opencode/opencode.jsonc"
echo "  - Project config: /tmp/test-opencode-project/.opencode/opencode.jsonc"
echo "  - Test config: test-opencode.jsonc"
echo ""
echo "Hook System:"
echo "  - Hooks location: ~/.config/opencode/hooks/"
echo "  - Logs location: ~/.config/opencode/logs/hooks.log"
echo ""
echo "Socket Communication:"
echo "  - Socket path: /tmp/opencode-island.sock"
echo "  - Format: JSON over Unix domain socket"
echo ""
echo "Next Steps:"
echo "  1. Build and run OpenCode Island app"
echo "  2. Verify socket is created"
echo "  3. Start OpenCode CLI session"
echo "  4. Verify hooks fire and events are received"
echo "  5. Monitor memory usage in app UI"
echo ""
echo "See POC documentation for detailed results:"
echo "  - POC-CONFIG-VALIDATION.md"
echo "  - POC-MEMORY-MONITORING.md"
echo "  - POC-HOOKS-COMPATIBILITY.md"
echo ""

#!/bin/bash
#
# POC Validation Script
# Validates that POC files are present and structured correctly
#
# This script does NOT build the app (requires Xcode project updates)
# See POC-SETUP.md for instructions on adding files to Xcode
#

set -e

echo "========================================="
echo "Phase 1 POC - File Validation"
echo "========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Check Swift implementation files
echo "Checking Swift Implementation Files..."
echo "--------------------------------------"

check_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        local size=$(wc -c < "$file")
        echo -e "${GREEN}✓${NC} $description ($size bytes)"
    else
        echo -e "${RED}✗${NC} $description - MISSING"
        ERRORS=$((ERRORS + 1))
    fi
}

check_file "ClaudeIsland/Models/OpenCodeConfig.swift" "OpenCodeConfig.swift"
check_file "ClaudeIsland/Utilities/OpenCodeConfigLoader.swift" "OpenCodeConfigLoader.swift"
check_file "ClaudeIsland/Services/Shared/OpenCodeMonitorPOC.swift" "OpenCodeMonitorPOC.swift"

echo ""
echo "Checking Documentation Files..."
echo "--------------------------------"

check_file "POC-CONFIG-VALIDATION.md" "Configuration POC"
check_file "POC-MEMORY-MONITORING.md" "Memory Monitoring POC"
check_file "POC-HOOKS-COMPATIBILITY.md" "Hooks POC (OUTDATED - OpenCode has no hooks)"
check_file "POC-TESTING-GUIDE.md" "Testing Guide"
check_file "POC-SETUP.md" "Setup Instructions"
check_file "PHASE1-SUMMARY.md" "Implementation Summary"

echo ""
echo "Checking Test Resources..."
echo "--------------------------"

check_file "test-poc.sh" "POC test script"
check_file "test-opencode.jsonc" "Test configuration"

echo ""
echo "Checking for Hook Scripts (reference only)..."
echo "----------------------------------------------"

if [ -d "/tmp/opencode-hooks" ]; then
    echo -e "${GREEN}✓${NC} Hook scripts exist in /tmp/opencode-hooks/"
    ls -la /tmp/opencode-hooks/*.sh 2>/dev/null | head -3
else
    echo -e "${YELLOW}⚠${NC}  Hook scripts not in /tmp/opencode-hooks/"
    echo "  This is OK - they're reference examples only (OpenCode has no hooks)"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "Checking Swift Syntax..."
echo "------------------------"

# Basic syntax check for Swift files
for swift_file in ClaudeIsland/Models/OpenCodeConfig.swift \
                  ClaudeIsland/Utilities/OpenCodeConfigLoader.swift \
                  ClaudeIsland/Services/Shared/OpenCodeMonitorPOC.swift; do
    if [ -f "$swift_file" ]; then
        # Check for basic Swift syntax (class/struct definitions)
        if grep -q "class\|struct\|enum" "$swift_file"; then
            echo -e "${GREEN}✓${NC} $swift_file has Swift definitions"
        else
            echo -e "${RED}✗${NC} $swift_file appears malformed"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

echo ""
echo "Checking for Xcode Project Integration..."
echo "------------------------------------------"

# Check if files are in Xcode project (pbxproj file)
if grep -q "OpenCodeConfig.swift" ClaudeIsland.xcodeproj/project.pbxproj 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Swift files are in Xcode project"
else
    echo -e "${YELLOW}⚠${NC}  Swift files NOT in Xcode project yet"
    echo "  This is EXPECTED for POC stage"
    echo "  See POC-SETUP.md for instructions to add them"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "========================================="
echo "Validation Summary"
echo "========================================="
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Phase 1 POC files are valid and ready for Phase 2"
    echo ""
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s)${NC}"
    echo ""
    echo "Phase 1 POC files are valid"
    echo "Warnings are expected at POC stage (e.g., not in Xcode project yet)"
    echo ""
else
    echo -e "${RED}✗ $ERRORS error(s), $WARNINGS warning(s)${NC}"
    echo ""
    echo "Some POC files are missing or invalid"
    echo ""
    exit 1
fi

echo "Next Steps:"
echo "  1. Review POC documentation (POC-*.md files)"
echo "  2. Add Swift files to Xcode project (see POC-SETUP.md)"
echo "  3. Build and test (see POC-TESTING-GUIDE.md)"
echo "  4. Proceed to Phase 2: Core Integration"
echo ""

#!/bin/bash
# Setup daily-planner-mcp MCP after chezmoi apply
# Hash: {{ include "dot_config/opencode/config.json" | sha256sum }}

AGENT_DIR="$HOME/.agents/daily-planner-mcp"

if [ ! -d "$AGENT_DIR" ]; then
    echo "⚠️  Personal planner not found at $AGENT_DIR"
    echo "   Clone it manually:"
    echo "   git clone https://github.com/devSos17/daily-planner-mcp.git ~/.agents/daily-planner-mcp"
    exit 0
fi

echo "🔧 Setting up daily-planner-mcp MCP..."

# Create venv if it doesn't exist
if [ ! -d "$AGENT_DIR/.venv" ]; then
    echo "📦 Creating virtual environment..."
    cd "$AGENT_DIR"
    python3 -m venv .venv
fi

# Install/update dependencies
echo "📦 Installing dependencies..."
cd "$AGENT_DIR"
.venv/bin/pip install --upgrade pip -q
.venv/bin/pip install -e . -q

echo "✅ Personal planner MCP setup complete"

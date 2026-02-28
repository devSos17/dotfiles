.PHONY: help mcp mcp-list mcp-personal-planner mcp-playwright mcp-context7 mcp-obsidian mcp-todoist mcp-status

# ============================================================================
# MCP Server Installer
# ============================================================================
# Install and manage MCP servers for OpenCode.
#
# Usage:
#   make mcp                  - Install ALL MCP servers
#   make mcp-personal-planner - Install personal-planner MCP (custom, Python)
#   make mcp-playwright       - Install Playwright MCP (browser automation)
#   make mcp-context7         - Install Context7 MCP (docs search, remote)
#   make mcp-obsidian         - Install Obsidian MCP (vault access)
#   make mcp-todoist          - Install Todoist MCP (official, task management)
#   make mcp-list             - List available MCP servers
#   make mcp-status           - Check status of installed MCPs
# ============================================================================

AGENTS_DIR := $(HOME)/.agents
NPX := $(shell command -v npx 2>/dev/null)
NODE := $(shell command -v node 2>/dev/null)
PYTHON := $(shell command -v python3 2>/dev/null)

# Colors
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
CYAN   := \033[0;36m
RESET  := \033[0m

help:
	@echo ""
	@echo "$(CYAN)╔══════════════════════════════════════════╗$(RESET)"
	@echo "$(CYAN)║       MCP Server Installer               ║$(RESET)"
	@echo "$(CYAN)╚══════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo "$(GREEN)MCP Targets:$(RESET)"
	@echo "  make mcp                    Install ALL MCP servers"
	@echo "  make mcp-personal-planner   Install personal-planner (Python MCP)"
	@echo "  make mcp-playwright         Install Playwright (browser automation)"
	@echo "  make mcp-context7           Context7 (remote, no install needed)"
	@echo "  make mcp-obsidian           Obsidian vault access"
	@echo "  make mcp-todoist            Todoist (official, task management)"
	@echo "  make mcp-list               List available MCP servers"
	@echo "  make mcp-status             Check MCP installation status"
	@echo ""

# ============================================================================
# Install ALL MCPs
# ============================================================================
mcp: mcp-personal-planner mcp-playwright mcp-obsidian mcp-todoist mcp-context7
	@echo ""
	@echo "$(GREEN)✓ All MCP servers installed!$(RESET)"
	@echo "  Restart OpenCode to load new MCPs."
	@echo ""

# ============================================================================
# List available MCPs
# ============================================================================
mcp-list:
	@echo ""
	@echo "$(CYAN)Available MCP Servers:$(RESET)"
	@echo ""
	@echo "  $(GREEN)LOCAL (stdio):$(RESET)"
	@echo "    personal-planner   Custom Python MCP for Todoist + Obsidian"
	@echo "    playwright         Browser automation via Playwright"
	@echo "    obsidian           Obsidian vault read/write/search"
	@echo "    todoist            Official Todoist task management"
	@echo ""
	@echo "  $(GREEN)REMOTE (no install):$(RESET)"
	@echo "    context7           Documentation search (context7.com)"
	@echo ""

# ============================================================================
# Check MCP status
# ============================================================================
mcp-status:
	@echo ""
	@echo "$(CYAN)MCP Server Status:$(RESET)"
	@echo ""
	@printf "  personal-planner:  "; \
	if [ -f "$(AGENTS_DIR)/daily-planner-mcp/.venv/bin/python" ]; then \
		echo "$(GREEN)✓ installed$(RESET)"; \
	else \
		echo "$(RED)✗ not installed$(RESET)"; \
	fi
	@printf "  playwright:        "; \
	if $(NPX) -y @playwright/mcp@latest --help >/dev/null 2>&1; then \
		echo "$(GREEN)✓ available via npx$(RESET)"; \
	elif [ -n "$(NPX)" ]; then \
		echo "$(YELLOW)~ npx available, will install on first use$(RESET)"; \
	else \
		echo "$(RED)✗ npx not found$(RESET)"; \
	fi
	@printf "  obsidian:          "; \
	if [ -n "$(NPX)" ]; then \
		echo "$(GREEN)✓ available via npx$(RESET)"; \
	else \
		echo "$(RED)✗ npx not found$(RESET)"; \
	fi
	@printf "  todoist:           "; \
	if [ -n "$(NPX)" ]; then \
		echo "$(GREEN)✓ available via npx$(RESET)"; \
	else \
		echo "$(RED)✗ npx not found$(RESET)"; \
	fi
	@printf "  context7:          "; \
	echo "$(GREEN)✓ remote (no install needed)$(RESET)"
	@echo ""

# ============================================================================
# personal-planner MCP (Custom Python MCP)
# ============================================================================
mcp-personal-planner:
	@echo "$(CYAN)Installing personal-planner MCP...$(RESET)"
	@if [ ! -d "$(AGENTS_DIR)/daily-planner-mcp" ]; then \
		echo "$(RED)✗ Error: $(AGENTS_DIR)/daily-planner-mcp not found$(RESET)"; \
		echo "  Clone the repo first:"; \
		echo "    git clone <repo-url> $(AGENTS_DIR)/daily-planner-mcp"; \
		exit 1; \
	fi
	@if [ -z "$(PYTHON)" ]; then \
		echo "$(RED)✗ Error: python3 not found$(RESET)"; \
		exit 1; \
	fi
	@cd $(AGENTS_DIR)/daily-planner-mcp && $(MAKE) install
	@echo "$(GREEN)✓ personal-planner MCP installed$(RESET)"

# ============================================================================
# Playwright MCP (Browser automation)
# ============================================================================
mcp-playwright: _check-node
	@echo "$(CYAN)Installing Playwright MCP...$(RESET)"
	@echo "  Pre-caching @playwright/mcp..."
	@npx -y @playwright/mcp@latest --help >/dev/null 2>&1 || true
	@echo "  Installing browser (chromium)..."
	@npx -y playwright install chromium 2>/dev/null || echo "$(YELLOW)  Warning: Could not install chromium. It will be installed on first use.$(RESET)"
	@echo "$(GREEN)✓ Playwright MCP installed$(RESET)"
	@echo "  Uses: npx @playwright/mcp@latest"
	@echo "  Browser: chromium (headed by default)"

# ============================================================================
# Obsidian MCP (Vault access)
# ============================================================================
mcp-obsidian: _check-node
	@echo "$(CYAN)Installing Obsidian MCP...$(RESET)"
	@echo "  Pre-caching @mauricio.wolff/mcp-obsidian..."
	@npx -y @mauricio.wolff/mcp-obsidian@latest --help >/dev/null 2>&1 || true
	@echo "$(GREEN)✓ Obsidian MCP installed$(RESET)"
	@echo "  Uses: npx @mauricio.wolff/mcp-obsidian@latest ~/A-Mann"
	@echo "  Tools: read/write/search notes, manage tags, vault stats"

# ============================================================================
# Todoist MCP (Official - task management)
# ============================================================================
mcp-todoist: _check-node
	@echo "$(CYAN)Installing Todoist MCP (official @doist/todoist-ai)...$(RESET)"
	@echo "  Pre-caching @doist/todoist-ai..."
	@TODOIST_API_KEY=dummy npx -y @doist/todoist-ai --version >/dev/null 2>&1 || true
	@echo "$(GREEN)✓ Todoist MCP installed$(RESET)"
	@echo "  Uses: npx @doist/todoist-ai"
	@echo "  Requires: TODOIST_API_KEY env var (set in opencode config)"

# ============================================================================
# Context7 MCP (Remote - docs search)
# ============================================================================
mcp-context7:
	@echo "$(CYAN)Context7 MCP$(RESET)"
	@echo "$(GREEN)✓ Remote MCP - no installation needed$(RESET)"
	@echo "  URL: https://mcp.context7.com/mcp"
	@echo "  Add 'use context7' to prompts for docs search"

# ============================================================================
# Helper targets
# ============================================================================
_check-node:
	@if [ -z "$(NODE)" ]; then \
		echo "$(RED)✗ Error: node not found. Install Node.js 18+ first.$(RESET)"; \
		exit 1; \
	fi
	@if [ -z "$(NPX)" ]; then \
		echo "$(RED)✗ Error: npx not found. Install Node.js 18+ first.$(RESET)"; \
		exit 1; \
	fi

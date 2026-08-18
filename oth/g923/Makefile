REPO_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

MODESWITCH_CONF_SRC := $(REPO_DIR)etc/usb_modeswitch.d/046d:c26d
UDEV_RULE_SRC       := $(REPO_DIR)etc/udev/rules.d/41-g923-modeswitch.rules

MODESWITCH_CONF_DST := /etc/usb_modeswitch.d/046d:c26d
UDEV_RULE_DST       := /etc/udev/rules.d/41-g923-modeswitch.rules

.PHONY: help install status uninstall

help:
	@echo ""
	@echo "Logitech G923 (Xbox) USB mode switch installer"
	@echo ""
	@echo "  make install    Install package + config files + reload udev (idempotent)"
	@echo "  make status     Check current state"
	@echo "  make uninstall  Remove config files and reload udev"
	@echo ""

install: _install-pkg _install-modeswitch _install-udev-rule _reload-udev
	@echo ""
	@echo "Done. Unplug and replug the G923 to trigger the mode switch."
	@echo ""

# -- Package -----------------------------------------------------------------

_install-pkg:
	@if pacman -Q usb_modeswitch > /dev/null 2>&1; then \
		echo "[pkg] usb_modeswitch already installed — skip"; \
	else \
		echo "[pkg] Installing usb_modeswitch via pkexec pacman..."; \
		pkexec pacman -S --noconfirm usb_modeswitch; \
	fi

# -- Config files ------------------------------------------------------------

_install-modeswitch:
	@if [ -f "$(MODESWITCH_CONF_DST)" ] && diff -q "$(MODESWITCH_CONF_SRC)" "$(MODESWITCH_CONF_DST)" > /dev/null 2>&1; then \
		echo "[conf] $(MODESWITCH_CONF_DST) already up to date — skip"; \
	else \
		echo "[conf] Installing $(MODESWITCH_CONF_DST)..."; \
		pkexec install -Dm644 "$(MODESWITCH_CONF_SRC)" "$(MODESWITCH_CONF_DST)"; \
	fi

_install-udev-rule:
	@if [ -f "$(UDEV_RULE_DST)" ] && diff -q "$(UDEV_RULE_SRC)" "$(UDEV_RULE_DST)" > /dev/null 2>&1; then \
		echo "[udev] $(UDEV_RULE_DST) already up to date — skip"; \
	else \
		echo "[udev] Installing $(UDEV_RULE_DST)..."; \
		pkexec install -Dm644 "$(UDEV_RULE_SRC)" "$(UDEV_RULE_DST)"; \
	fi

# -- Reload udev -------------------------------------------------------------

_reload-udev:
	@echo "[udev] Reloading udev rules..."
	@pkexec udevadm control --reload-rules
	@pkexec udevadm trigger --subsystem-match=usb --action=add
	@echo "[udev] Rules reloaded"

# -- Status ------------------------------------------------------------------

status:
	@echo ""
	@echo "=== G923 mode switch status ==="
	@echo ""
	@printf "  usb_modeswitch pkg:  "; \
	if pacman -Q usb_modeswitch > /dev/null 2>&1; then \
		echo "installed ($(shell pacman -Q usb_modeswitch 2>/dev/null))"; \
	else \
		echo "NOT installed"; \
	fi
	@printf "  modeswitch conf:     "; \
	if [ -f "$(MODESWITCH_CONF_DST)" ]; then \
		if diff -q "$(MODESWITCH_CONF_SRC)" "$(MODESWITCH_CONF_DST)" > /dev/null 2>&1; then \
			echo "present and up to date"; \
		else \
			echo "present but DIFFERS from source"; \
		fi; \
	else \
		echo "NOT present"; \
	fi
	@printf "  udev rule:           "; \
	if [ -f "$(UDEV_RULE_DST)" ]; then \
		if diff -q "$(UDEV_RULE_SRC)" "$(UDEV_RULE_DST)" > /dev/null 2>&1; then \
			echo "present and up to date"; \
		else \
			echo "present but DIFFERS from source"; \
		fi; \
	else \
		echo "NOT present"; \
	fi
	@printf "  G923 Xbox PID (c26d):"; \
	if lsusb 2>/dev/null | grep -q "046d:c26d"; then \
		echo " DETECTED (not switched yet)"; \
	else \
		echo " not seen"; \
	fi
	@printf "  G923 PC PID (c26e):  "; \
	if lsusb 2>/dev/null | grep -q "046d:c26e"; then \
		echo " DETECTED (switched, PC mode active)"; \
	else \
		echo " not seen"; \
	fi
	@echo ""

# -- Uninstall ---------------------------------------------------------------

uninstall:
	@echo "[uninstall] Removing config files..."
	@pkexec rm -f "$(MODESWITCH_CONF_DST)"
	@pkexec rm -f "$(UDEV_RULE_DST)"
	@pkexec udevadm control --reload-rules
	@echo "[uninstall] Done"

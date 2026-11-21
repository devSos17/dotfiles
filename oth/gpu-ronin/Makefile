# Instala los symlinks udev de GPU para ronin (/dev/dri/amd-igpu, /dev/dri/nvidia-dgpu).
RULE := 61-gpu-symlinks.rules

all: install

install:
	@pkexec sh -c 'install -Dm644 $(CURDIR)/$(RULE) /etc/udev/rules.d/$(RULE) && udevadm control --reload && udevadm trigger --subsystem-match=drm --action=change && udevadm settle'
	@ls -l /dev/dri/amd-igpu /dev/dri/nvidia-dgpu

uninstall:
	@pkexec rm -f /etc/udev/rules.d/$(RULE)

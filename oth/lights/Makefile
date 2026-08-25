UNIT := lights-restore.service
DEST := /etc/systemd/system/$(UNIT)

install:
	pkexec sh -c 'cp $(UNIT) $(DEST) && systemctl daemon-reload && systemctl enable $(UNIT)'

uninstall:
	pkexec sh -c 'systemctl disable $(UNIT); rm -f $(DEST); systemctl daemon-reload'

status:
	systemctl status $(UNIT) --no-pager

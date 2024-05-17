sysconfdir=/etc
unitdir=$(sysconfdir)/systemd/system
prefix=/usr/local
sbindir=$(prefix)/sbin

UNITS = \
	ipwatchdog-reboot.service \
	ipwatchdog-reboot.timer \
	ipwatchdog@.service

SCRIPTS = \
					ipwatchdog.sh
all:

install: install-units install-scripts

install-units: $(UNITS)
	install -d $(DESTDIR)$(unitdir)
	install -m 644 $(UNITS) $(DESTDIR)$(unitdir)

install-scripts: $(SCRIPTS)
	install -d $(DESTDIR)$(sbindir)
	install -m 755 $(SCRIPTS) $(DESTDIR)$(sbindir)

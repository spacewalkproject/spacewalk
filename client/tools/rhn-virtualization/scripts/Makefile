PKGDIR0 = /etc/rc.d/init.d
PKGDIR1 = /etc/cron.d
CONF_DIR = /etc/sysconfig/rhn/virt
CONF_DIR_AUTO = /etc/sysconfig/rhn/virt/auto

SCRIPTS = rhn-virtualization-host
OTHER = rhn-virtualization.cron

all: 
	echo "Nothing to do"

clean:
	echo "No cleaning to do"

install:
	mkdir -p $(DESTDIR)/$(PKGDIR0)
	mkdir -p $(DESTDIR)/$(PKGDIR1)
	mkdir -p $(DESTDIR)/$(CONF_DIR)
	mkdir -p $(DESTDIR)/$(CONF_DIR_AUTO)
	for p in $(SCRIPTS) ; do \
		install -m 755 $$p $(DESTDIR)/$(PKGDIR0)/$$p; \
	done
	for q in $(OTHER) ; do \
		install -m 755 $$q $(DESTDIR)/$(PKGDIR1)/$$q; \
	done

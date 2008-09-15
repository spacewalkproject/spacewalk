all:
	echo "Nothing to do"

clean:
	rm -f *~

install:
	mkdir -p $(PREFIX)/usr/share/man/man{5,8}
	install -m 644 rhnplugin.conf.5 $(PREFIX)/usr/share/man/man5/rhnplugin.conf.5
	install -m 644 rhnplugin.8 $(PREFIX)/usr/share/man/man8/rhnplugin.8
	ln -s rhnplugin.8 $(PREFIX)/usr/share/man/man8/yum-rhn-plugin.8

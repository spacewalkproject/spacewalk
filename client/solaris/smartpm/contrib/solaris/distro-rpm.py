print "In distro.py"

if not sysconf.getReadOnly():
    if not sysconf.has("rpm-root"):
        sysconf.set("rpm-root", "/opt/redhat/rpm/solaris/")
    if not sysconf.has("channels"):
        sysconf.set(("channels", "myrpm-db"),
                    {"alias": "myrpm-db",
                     "type": "rpm-sys",
                     "name": "RPM Database"})

        sysconf.set(("channels", "myrpm-dir"),
                    {"alias": "myrpm-dir",
                     "type": "rpm-dir",
                     "name": "Solaris Sparc RPM Directory",
                     "path": "/export/home/jmartin/rpms/"})

        sysconf.set(("channels", "myrhn"),
                    {"alias": "myrhn",
                     "type": "rpm-rhn",
                     "name": "RHN Channel",
                     "baseurl": "http://rlx-2-06.rhndev.redhat.com/XMLRPC"})


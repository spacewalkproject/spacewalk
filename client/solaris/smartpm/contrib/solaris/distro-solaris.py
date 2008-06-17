if not sysconf.getReadOnly():
    if not sysconf.has("solaris-adminfile"):
        sysconf.set("solaris-adminfile", "/opt/redhat/rhn/solaris/var/lib/smart/adminfile")
    if not sysconf.has("channels"):
        sysconf.set(("channels", "mysol-rhn"),
                    {"alias": "mysol-rhn",
                     "type": "solaris-rhn",
                     "name": "My RHN Channel",
                     "baseurl": "http://rlx-3-20.rhndev.redhat.com/XMLRPC"})

        sysconf.set(("channels", "mysol-db"),
                    {"alias": "mysol-db",
                     "type": "solaris-sys",
                     "name": "Solaris Package Database"})

#        sysconf.set(("channels", "mysol-dir"),
#                    {"alias": "mysol-dir",
#                     "type": "solaris-dir",
#                     "name": "Solaris Package Directory",
#                     "path": "/export/home/jmartin/pkgs/"})
#

import sys
sys.argv = ["./smart.py", "test"]
execfile('./smart.py')
import user

# Check if upgrading a package would require upgrading another
# package which is in a higher numbered CD.

from smart.transaction import *

set = ChangeSet()

# Mark every CL9 package as installed, and being removed.
for pkg in cache.getPackages():
    for loader in pkg.loaderinfo:
        if loader.getRepository().getName().startswith("cl9"):
            pkg.installed = True
            set[pkg] = REMOVE

# Now mark for installing every package in CL10 CDs.
for pkg in cache.getPackages():
    for loader in pkg.loaderinfo:
        if loader.getRepository().getName().startswith("cl10"):
            set[pkg] = INSTALL

#trans = Transaction(cache, PolicyUpgrade)
#trans.setPolicy(PolicyUpgrade)
#trans.upgrade([x for x in cache.getPackages() if x.installed])
#for pkg in cache.getPackages():
#    if pkg.installed:
#        trans.enqueue(pkg, UPGRADE)
#try:
#    trans.run()
#except KeyboardInterrupt:
#    pass
#trans.install([x for x in cache.getPackages() if not x.installed and x.name == "openssl-devel"][0])

# Now build a subset, and check if including each package in the
# first CD would require installing a package in CDs 2 or 3.

splitter = ChangeSetSplitter(set)
subset = set.copy()

cl10cd1 = []
for pkg in cache.getPackages():
    for loader in pkg.loaderinfo:
        if loader.getRepository().getName() == "cl10.001":
            cl10cd1.append(pkg)
cl10cd2 = []
for pkg in cache.getPackages():
    for loader in pkg.loaderinfo:
        if loader.getRepository().getName() == "cl10.002":
            cl10cd2.append(pkg)
cl10cd3 = []
for pkg in cache.getPackages():
    for loader in pkg.loaderinfo:
        if loader.getRepository().getName() == "cl10.003":
            cl10cd3.append(pkg)

krb5 = [x for x in subset if x.name == "krb5"][0]
krb5server = [x for x in subset if x.name == "krb5-server"][0]
coreutils = [x for x in subset if x.name == "coreutils"][0]

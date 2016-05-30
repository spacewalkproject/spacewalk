import socket

hostname = socket.gethostname()
if '.' not in hostname:
    hostname = socket.getfqdn()

# namespace prefixes for parsing SUSE patches XML files
YUM = "{http://linux.duke.edu/metadata/common}"
RPM = "{http://linux.duke.edu/metadata/rpm}"
SUSE = "{http://novell.com/package/metadata/suse/common}"
PATCH = "{http://novell.com/package/metadata/suse/patch}"

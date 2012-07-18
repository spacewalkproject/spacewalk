import os
import sys
sys.path.append("/usr/share/rhn/")

__rhnexport__ = [ 'check' ]

ABRT_DIR = '/var/spool/abrt'

def check(version):
    if not os.path.isdir(ABRT_DIR):
        return (1, 'no ABRT_DIR "%s" found' % ABRT_DIR)

    if not os.access(ABRT_DIR, os.R_OK):
        return (2, 'no permission to read ABRT_DIR "%s"' % ABRT_DIR)

    crash_dirs = [ name for name in os.listdir(ABRT_DIR) if
        os.path.isdir(os.path.join(ABRT_DIR, name)) ]

    return (0, 'abrt check completed', {
        'num_crashes': len(crash_dirs),
    })

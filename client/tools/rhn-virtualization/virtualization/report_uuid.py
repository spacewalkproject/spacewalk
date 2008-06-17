#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#

import sys
sys.path.append("/usr/share/rhn/")

import os

from virtualization.constants       import StateType, \
                                           IdentityType, \
                                           PropertyType
from virtualization.notification    import Plan, \
                                           EventType, \
                                           TargetType
from virtualization.util            import dehyphenize_uuid


def report_uuid():
    """
    Uploads the guests uuid to the satellite it's registered to.
    """
    if _is_guest_domain():
        my_uuid = _fetch_uuid()
        domain_identity = IdentityType.GUEST
    else:
        return None

    plan = Plan() 

    plan.add(
        EventType.EXISTS,
        TargetType.SYSTEM,
        { PropertyType.IDENTITY : domain_identity,
          PropertyType.UUID     : my_uuid           })   

    plan.execute()

def _is_guest_domain():
    """
    This function returns true if this system is currently a guest domain.
    """
    return _fetch_uuid() is not None

 
def _fetch_uuid():
    """
    This function returns the UUID of this system, if it is a guest.  Otherwise,
    it returns None.  To figure this out, we'll look for the existence of a 
    UUID in one of the following (in order of precedence):

      - The kernel exporting it in sysfs, under /sys
      - The BIOS DMI data area accessible with dmidecode
      - An administrator simply sticking it in a plain text file /etc/uuid
    """

    # First check the /sys area.
    try:
        uuid_file = open('/sys/hypervisor/uuid', 'r')
        uuid = uuid_file.read()
        uuid_file.close()
        return dehyphenize_uuid(uuid)
    except IOError:
        # Failed.  Move on to the next strategy.
        pass

    # Look in the BIOS DMI area.
    try:
        pass
    except:
        # Failed.  Move on to the next strategy.
        pass

    # One more try -- a plain text file called /etc/uuid.
    try:
        uuid_text_file = open('/etc/uuid', 'r')
        uuid = uuid_text_file.read().strip()
        uuid_text_file.close()
        return uuid
    except IOError:
        # Failed.  Guess we're not a guest.
        pass

    return None

if __name__ == "__main__":
    report_uuid()


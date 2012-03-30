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

import random
from virtualization.errors import UUIDError

def generate_uuid():
    """Generate a random UUID and return it."""

    uuid_list = [ random.randint(0, 255) for _ in range(0, 16) ]
    return ("%02x" * 16) % tuple(uuid_list)

def hyphenize_uuid(uuid):
    # Determine whether the string is already hyphenized.
    if len(uuid) == 36 and len(uuid.replace('-', '')) == 32:
        return uuid[:]

    if len(uuid) != 32:
        raise UUIDError("UUID %s is not 32 characters long." % (uuid,))

    formatstr = "%s-%s-%s-%s-%s"
    new_uuid = formatstr % (uuid[0:8],
                            uuid[8:12],
                            uuid[12:16],
                            uuid[16:20],
                            uuid[20:])
    return new_uuid

def dehyphenize_uuid(uuid):
    if uuid is None: 
        return uuid

    return uuid.replace('-', '')

def is_host_uuid(uuid):
    """
    Returns true if the given UUID represents a host.  We can tell because
    host UUIDs are always 0.
    """
    return int(eval("0x" + dehyphenize_uuid(uuid))) == 0

def is_fully_virt(domain):
    """
    Returns true if the given domain is a fully-virt domain.
    """
    return domain.OSType().lower() == 'hvm'


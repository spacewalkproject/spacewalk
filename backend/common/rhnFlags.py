# Copyright (c) 2008--2012 Red Hat, Inc.
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
# Small class that handles a global flags structure. the globale dictionary
# used to hold the flags gets initialized on demand
#

__F = {}

def set(name, value = 1):
    """
    set value
    """
    # pylint: disable=W0622,W0602
    global __F
    if not name:
        return None
    name = name.lower()
    __F[name] = value
    return None

def get(name):
    """
    get value
    """
    if not name:
        return None
    name = name.lower()
    return __F.get(name)


def test(name):
    """
    test value
    """
    if not name:
        return 0
    name = name.lower()
    return __F.has_key(name) and __F[name]


def reset():
    """
    reset all
    """
    __F.clear()


def all():
    """
    return all flags in a dict
    """
    # pylint: disable=W0622
    return __F

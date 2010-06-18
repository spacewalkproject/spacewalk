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
# Small class that handles a global flags structure. the globale dictionary
# used to hold the flags gets initialized on demand
#


import string


def set(name, value = 1):
    """
    set value
    """

    global __F
    if not name:
        return None
    name = string.lower(name)
    try:
        __F[name] = value
    except NameError:
        __F = {name: value}
    return None


def get(name):
    """
    get value
    """
    global __F
    if not name:
        return None
    name = string.lower(name)
    try:
        return __F.get(name)
    except NameError:
        __F = {}
    return None


def test(name):
    """
    test value
    """
    global __F
    if not name:
        return 0
    name = string.lower(name)
    try:
        return __F.has_key(name) and __F[name]
    except NameError:
        __F = {}
    return 0


def reset():
    """
    reset all
    """
    global __F
    try:
        __F.clear()
    except NameError:
        __F = {}
    return


def all():
    """
    return all flags in a dict
    """
    global __F
    try:
        return __F
    except NameError:
        __F = {}
    return __F

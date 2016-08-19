#
# Copyright (c) 2001--2016 Red Hat, Inc.
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
#
# This file implements a case insensitive dictionary on top of the
# UserDict standard python class
#


try: # python2
    from UserDict import UserDict
    from types import StringType
except ImportError: # python3
    from collections import UserDict
    StringType = bytes
    from functools import reduce

# A dictionary with case insensitive keys
class UserDictCase(UserDict):
    def __init__(self, data = None):
        self.kcase = {}
        UserDict.__init__(self, data)

    def __lower_string(self, key):
        """ Return the lower() of key if it is a string. """
        if isinstance(key, StringType):
            return key.lower()
        else:
            return key

    # some methods used to make the class work as a dictionary
    def __setitem__(self, key, value):
        lkey = self.__lower_string(key)
        self.data[lkey] = value
        self.kcase[lkey] = key

    def __getitem__(self, key):
        key = self.__lower_string(key)
        return self.data[key]

    get = __getitem__

    def __delitem__(self, key):
        key = self.__lower_string(key)
        del self.data[key]
        del self.kcase[key]

    def __contains__(self, key):
        key = self.__lower_string(key)
        return key in self.data

    def keys(self):
        return self.kcase.values()

    def items(self):
        return self.get_hash().items()

    def has_key(self, key):
        # obsoleted, left for compatibility with older python
        return key in self

    def clear(self):
        self.data.clear()
        self.kcase.clear()

    # return this data as a real hash
    def get_hash(self):
        return reduce(lambda a, t, hc=self.kcase:
                      a.update({ hc[t[0]] : t[1]}) or a, self.data.items(), {})

    # return the data for marshalling
    def __getstate__(self):
        return self.get_hash()

    # we need a setstate because of the __getstate__ presence screws up deepcopy
    def __setstate__(self, state):
        self.__init__(state)

    # get a dictionary out of this instance ({}.update doesn't get instances)
    def dict(self):
        return self.get_hash()

    def update(self, dict):
        for (k, v) in dict.items():
            self[k] = v

    # Expose an iterator. This would normally fail if there is no iter()
    # function defined - but __iter__ will never be called on python 1.5.2
    def __iter__(self):
        return iter(self.data)

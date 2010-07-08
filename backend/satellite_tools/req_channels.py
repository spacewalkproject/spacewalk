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
#

import types

class RequestedChannels:
    """Bookkeeping of the state of various channels
    Argument to constructor is the list of requested channels
    """
    # Simplify the getters/setters/resetters
    __lists = [
        '_requested_imported', # requested and previously imported
        '_requested_new', # requested and NOT previously imported
        '_requested_channels', # Union of the above two
        '_not_requested', # not requested but available channels
        '_end_of_service', # requested, once available, but no longer supported
        '_typos', # requested, but probably a typo
    ]
    def __init__(self, requested=[]):
        # All the requested channels
        self._requested = {}
        # All available channels
        self._available = {}
        # All imported channels
        self._imported = {}
        
        # These will be computed
        # We could have initialized them in a loop, but pychecker would
        # complain that the data member does not exist
        self._requested_imported = []
        self._requested_new = []
        self._requested_channels = []
        self._not_requested = []
        self._end_of_service = []
        self._typos = []
        
        for l in self.__lists:
            assert hasattr(self, l), "Class does not initialize %s" % l
            assert isinstance(getattr(self, l), types.ListType)
        
        # Initialize the requested channels
        self.request(requested)

    def request(self, requested):
        assert isinstance(requested, types.ListType)

        self._requested.clear()
        for c in requested:
            self._requested[c] = None
        return self

    def _add(self, name, channel):
        if name not in ['_available', '_imported']:
            raise AttributeError('add' + name)
        getattr(self, name)[channel] = None
        return self

    def _set(self, name, channel_list):
        if name not in ['_available', '_imported']:
            raise AttributeError('set' + name)
        assert isinstance(channel_list, types.ListType)
        h = getattr(self, name)
        h.clear()
        for c in channel_list:
            h[c] = None
        return self

    def _reset(self, name):
        del getattr(self, name)[:]
        return self

    def _get(self, name):
        return getattr(self, name)

    def reset(self):
        self._available.clear()
        self._imported.clear()
        self._reset_computed()

    def _reset_computed(self):
        for name in self.__lists:
            del getattr(self, name)[:]
        return self

    def _print_values(self):
        for name in self.__lists:
            print "Contents of %s: %s" % (name, getattr(self, name))
        return self

    def compute(self):
        self._reset_computed()
        available = self._available.copy()
        imported = self._imported.copy()
        for c in self._requested.keys():
            if self._available.has_key(c):
                del available[c]
                # Channel exists
                if self._imported.has_key(c):
                    del imported[c]
                    self._requested_imported.append(c)
                    continue
                self._requested_new.append(c)
                continue
            # Requested channel not available
            if self._imported.has_key(c):
                del imported[c]
                self._end_of_service.append(c)
                continue
            # Typo
            self._typos.append(c)

        for c in available.keys():
            if imported.has_key(c):
                # Available, already imported
                del imported[c]
            # Available, not imported
            self._not_requested.append(c)

        # The rest are channels that were once imported, but now are
        # unavailable
        self._end_of_service.extend(imported.keys())

        self._requested_channels.extend(self._requested_new)
        self._requested_channels.extend(self._requested_imported)

        # Sort the lists
        for name in self.__lists:
            getattr(self, name).sort()
        return self

    def __getattr__(self, name):
        if startswith(name, 'add'):
            return Method(name[3:], self._add)
        if startswith(name, 'get'):
            return Method(name[3:], self._get)
        if startswith(name, 'set'):
            return Method(name[3:], self._set)
        if startswith(name, 'reset'):
            return Method(name[5:], self._reset)
        raise AttributeError(name)

def startswith(s, prefix):
    if s[:len(prefix)] == prefix:
        return 1
    return 0

class Method:
    def __init__(self, name, func):
        self._func = func
        self._name = name

    def __call__(self, *args, **kwargs):
        return apply(self._func, (self._name, ) + args, kwargs)

# Test functions

def _verify_expectations(c, expectations):
    for k, expected in expectations.items():
        method_name = 'get' + k
        val = getattr(c, method_name)()
        if val == expected:
            print "ok: %s = %s" % (method_name, expected)
        else:
            print "FAILED: %s: expected %s, got %s" % (method_name, expected,
                val)


def test1(requested, available, imported, expectations):
    c = RequestedChannels(requested)
    # Available channels
    for av in available:
        c.add_available(av)
    # Already impoted
    for i in imported:
        c.add_imported(i)

    c.compute()
    _verify_expectations(c, expectations)

def test2(requested, available, imported, expectations):
    c = RequestedChannels(requested)
    # Available channels
    c.set_available(available)
    # Already impoted
    c.set_imported(imported)

    c.compute()
    _verify_expectations(c, expectations)

def test():
    requested = ['a', 'b', 'c', 'd']
    available = ['a', 'd', 'e', 'f']
    imported = ['d', 'e', 'h']
    expectations = {
        '_requested_imported'   : ['d'],
        '_requested_new'        : ['a'],
        '_not_requested'        : ['e', 'f'],
        '_end_of_service'       : ['h'],
        '_typos'                : ['b', 'c'],
        '_requested_channels'   : ['a', 'd'],
    }
    print "Running test1"
    test1(requested, available, imported, expectations)
    print "Running test2"
    test2(requested, available, imported, expectations)

if __name__ == '__main__':
    test()

#
# Copyright (c) 2008--2016 Red Hat, Inc.
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

import os
import sys

from spacewalk.common.rhnLog import log_debug, log_error


class Loader:
    # Class that saves the state of imported objects
    _imports = {}

    def load(self, dir, interface_signature='rpcClasses'):
        # The key we use for caching
        root_dir = "/usr/share/rhn"
        key = (dir, root_dir, interface_signature)

        if key in self._imports:
            return self._imports[key]

        dirname = "%s/%s" % (root_dir, dir)

        # We need to import things
        if root_dir is not None and root_dir not in sys.path:
            sys.path.append(root_dir)

        fromcomps = dir.split('/')
        _imports = {}

        # Keep track of the modules we've already tried to load, to avoid loading
        # them twice
        modules = []
        # Load each module (that is not internal - i.e. doesn't start with _)
        for module in os.listdir(dirname):
            log_debug(5, "Attempting to load module %s from %s %s" % (
                module, '.'.join(fromcomps), dirname))
            if module[0] in ('_', '.'):
                # We consider it 'internal' and we don't load it
                log_debug(6, "Ignoring module %s" % module)
                continue

            # Importing files or directories with . in them is broken, so keep
            # only the first part
            module = module.split('.', 1)[0]
            if module in modules:
                log_debug(6, "Already tried to load Module %s" % (module, ))
                continue

            # Add it to the list, so we don't load it again
            modules.append(module)

            # We use fromclause to build the full module path
            fromclause = '.'.join(fromcomps + [module])

            # Try to import the module
            try:
                m = __import__(fromclause, {}, {}, [module])
            except ImportError:
                e = sys.exc_info()[1]
                log_error("Error importing %s: %s" % (module, e))
                log_debug(6, "Details: sys.path: %s" % (sys.path, ))
                continue

            if not hasattr(m, interface_signature):
                # The module does not support our API
                log_error("Module %s doesn't support our API" % (module, ))
                continue
            log_debug(5, "Module %s loaded" % (module, ))

            _imports[module] = getattr(m, interface_signature)

        self._imports[key] = _imports
        return _imports


def load(dir, root_dir=None, interface_signature='rpcClasses'):
    """
    Load modules (handlers) beneath the handlers/ tree.

    root_dir: which directory to use as a top-level directory
    """

    l = Loader()
    return l.load(dir, interface_signature=interface_signature)

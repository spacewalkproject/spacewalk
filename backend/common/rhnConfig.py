#
# Copyright (c) 2008--2015 Red Hat, Inc.
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

import os
import sys
import glob
import stat
import re

from rhn.UserDictCase import UserDictCase


_CONFIG_ROOT = '/etc/rhn'
_CONFIG_FILE = '%s/rhn.conf' % _CONFIG_ROOT
_CONFIG_DEFAULTS_ROOT = '/usr/share/rhn/config-defaults'


def warn(*args):
    """
    Function used for debugging purposes
    """
    sys.stderr.write("CONFIG PARSE WARNING: %s\n" % " ".join(map(str, args)))


class ConfigParserError(Exception):

    """
    Exception class we're using to expose fatal errors
    """
    pass


# TODO: need to be able to specify "" component and parse all files in
#       the directory and form a _complete_ mapping structure.
#       Or, if that is too difficult, take in a list of components...
class RHNOptions:

    """ Main options class
        The basic idea is to share the important pieces of information - the
        component and the configuration tree - across all instances of this
        class.
    """

    def __init__(self, component=None, root=None, filename=None):
        self.__component = None
        # Defaults for each option, keyed on tuples
        self.__defaults = {}
        # Parsed config file, keyed on tuples
        self.__parsedConfig = {}
        # Dictionary used as a cache (to avoid looking up options all over the
        # place). Keyed on strings (component names)
        self.__configs = {}
        # Last modification date for the config file
        self.__timestamp = 0
        # NOTE: root: root directory location of config files.
        self.root = None
        self.filename = None
        self.init(component, root, filename)

    def init(self, component, root=None, filename=None):
        """
        Visible function, so that we can re-init the object without
        losing the reference to it
        """
        if root is None:
            root = _CONFIG_ROOT
        self.filename = filename
        if self.filename is None:
            self.filename = _CONFIG_FILE
        self.setComponent(component)
        self.root = root

    def setComponent(self, comp):
        if not comp:
            comp = ()
        self.__component = comp

    def getComponent(self):
        return self.__component

    def is_initialized(self):
        return (self.__component is not None) and \
            self.__configs.has_key(self.__component)

    def modifiedYN(self):
        """returns last modified time diff if rhn.conf has changed."""

        try:
            si = os.stat(self.filename)
        except OSError, e:
            raise ConfigParserError("config file read error",
                                    self.filename, e.args[1]), None, sys.exc_info()[2]
        lm = si[stat.ST_MTIME]
        # should always be positive, but a non-zero result is still
        # indication that the file has changed.
        return lm - self.__timestamp

    def updateLastModified(self, timeDiff=None):
        """ update the last modified time of the rhn.conf file. """
        if timeDiff is None:
            timeDiff = self.modifiedYN()
        self.__timestamp = self.__timestamp + timeDiff

    def parse(self):
        """
        This function parses the config file, if needed, and populates
        the configuration cache self.__configs
        """
        # Speed up the most common case
        timeDiff = self.modifiedYN()
        if not timeDiff and self.is_initialized():
            # Nothing to do: the config file did not change and we already
            # have the config cached
            return
        else:
            # if the timestamp changed, clear the list of cached configs
            # and retain the new timestamp
            self.updateLastModified(timeDiff)
            self.__configs.clear()  # cache cleared

        # parse the defaults.
        self._parseDefaults(allCompsYN=0)

        # Now that we parsed the defaults, we parse the multi-key
        # self.filename configuration (ie, /etc/rhn/rhn.conf)
        self.__parsedConfig = parse_file(self.filename)

        # And now generate and cache the current component
        self.__merge()

    def _parseDefaults(self, allCompsYN=0):
        """ Parsing of the /usr/share/rhn/config-defaults/*.conf (or equivalent)
        Make sure we have all the needed default config files loaded
        We store the defaults in a dictionary, keyed on the component tuple
        """
        comps = parse_comps(self.__component)
        if allCompsYN:
            comps = getAllComponents_tuples()
        for comp in comps:
            if self.__defaults.has_key(comp):
                # We already have it loaded
                # XXX: Should we do timestamp checking for this one too?
                continue
            # Create the config file name
            conffile = "%s/rhn.conf" % (_CONFIG_DEFAULTS_ROOT)
            if comp:
                conffile = "%s/rhn_%s.conf" % (_CONFIG_DEFAULTS_ROOT,
                                               '_'.join(comp))
            # if the file is not there (or can't be read), skip
            if not os.access(conffile, os.R_OK):
                warn("File not found or can't be read", conffile)
                continue
            # store this default set of values
            _dict = parse_file(conffile, single_key=1)
            # the parsed file is keyed by component, but for a config
            # file containing only single keys we know the component
            # is going to be () and we need to override it with
            # whatever we're parsing now in the self.__defaults table
            def_dict = {}
            for k in _dict[()].keys():
                # we extract just the values and dump the line number
                # from the (values,linno) tuples which is the hash
                # value for _dict[()][k]
                def_dict[k] = _dict[()][k][0]
            self.__defaults[comp] = def_dict

    def keys(self):
        self.__check()
        return self.__configs[self.__component].keys()

    def has_key(self, key):
        self.__check()
        return self.__configs[self.__component].has_key(key)

    def values(self):
        self.__check()
        return self.__configs[self.__component].values()

    def items(self):
        self.__check()
        return self.__configs[self.__component].items()

    def set(self, key, value):
        self.__check()
        self.__configs[self.__component][key] = value
    __setitem__ = set

    def show(self):
        self.__check()
        # display the configuration read from the file(s) and exit
        vals = self.__configs[self.__component].items()
        vals.sort(lambda a, b: cmp(a[0], b[0]))
        for k, v in vals:
            if v is None:
                v = ""
            print "%-20s = %s" % (k, v)

    # polymorphic methods

    def __getattr__(self, key):
        """fetch option you want in a self.DEBUG kind of syntax
           (can force component selection)

        e.g.: say for example we have an option proxy.debug = 5
              stored in the dictionary. proxy just says that only proxy
              can access this option. So for this exmple,
              self.__component is proxy.
               cfg = RHNOptions("proxy")
               print cfg.DEBUG ---> yields 5
        """
        self.__check()
        if not self.__configs[self.__component].has_key(key):
            raise AttributeError(key)
        return self.__configs[self.__component][key]
    __getitem__ = __getattr__

    def get(self, key, default=None):
        ret = default
        if self.__configs[self.__component].has_key(key):
            ret = self.__configs[self.__component][key]
        return ret

    def __str__(self):
        s = "Uninitialized"
        if self.__component and self.__configs.has_key(self.__component):
            s = str(self.__configs[self.__component])
        return "<RHNOptions instance at %s: %s>" % (id(self), s)
    __repr__ = __str__

    # private methods

    def __check(self):
        if not self.is_initialized():
            raise ConfigParserError("Uninitialized config for component",
                                    self.__component)

    def __merge(self, component=None):
        """
        merge the config options between the default comp dictionaries
        and the file we're parsing now
        """
        # Caches this component's configuration options
        if component is None:
            component = self.__component

        opts = UserDictCase()
        comps = parse_comps(component)
        for comp in comps:
            if not self.__defaults.has_key(comp):
                warn('key not found in config default dict', comp)
                continue
            opts.update(self.__defaults[comp])

        # Now load the specific stuff, and perform syntax checking too
        for comp in comps:
            if not self.__parsedConfig.has_key(comp):
                # No such entry in the config file
                continue
            for key, (values, _lineno_) in self.__parsedConfig[comp].items():
                # we don't really want to force every item in the
                # config file to have a default value first. If we do,
                # uncomment this section
                # if not opts.has_key(key): # Unknown keyword
                #    warn("Warning: in file %s, line %s: unknown "
                #        "option name `%s'" % (self.filename, lineno, key))
                #    continue
                opts[key] = values
        # and now save it
        self.__configs[component] = opts

    # protected/test methods

    def getDefaults(self):
        """returns the __defaults dict (dictionary of parsed defaults).
        """
        self.__check()
        return self.__defaults

    def _getParsedConfig(self):
        """returns the __parsedConfig dict (dictionary of parsed
           /etc/rhn/rhn.conf file).
        """
        self.__check()
        return self.__parsedConfig

    def _getConfigs(self):
        """returns the __configs dict (dictionary of the merged options
           keyed by component.
        """
        self.__check()
        return self.__configs

    def showall(self):
        from pprint import pprint
        print "__defaults: dictionary of parsed defaults."
        pprint(self.__defaults)
        print
        print "__parsedConfig: dictionary of parsed /etc/rhn/rhn.conf file."
        pprint(self.__parsedConfig)
        print
        print "__configs: dictionary of the merged options keyed by component."
        pprint(self.__configs)


def parse_comps(component):
    """
    Splits a component name (a.b.c) into a list of tuples that can be
    joined together to determine a config file name
    Eg. a.b.c --> [(), ('a',), ('a','b'), ('a','b','c')]
    """
    # Split the component name on '.'
    if not component:
        return [()]
    comps = [c.lower() for c in component.split('.')]
    # Now generate the prefixes for this component
    return [tuple(comps[:i]) for i in range(len(comps) + 1)]


def parse_line(line):
    """
    Parse a config line...
    Returns a tuple (keys, values), or (None, None) if we don't care
    about this line
    """
    varSeparator = '.'
    optSeparator = ','

    def sanitize_value(key, val):
        """
        attempt to convert a string value to the proper type
        """
        converTable = {'proxy.http_proxy_username': str,
                       'proxy.http_proxy_password': str,
                       'server.satellite.http_proxy_username': str,
                       'server.satellite.http_proxy_password': str,
                       'server.satellite.rhn_parent': str,
                       'db_name': str,
                       'db_user': str,
                       'db_password': str,
                       'db_host': str}
        val = val.strip()

        if converTable.get(key):
            try:
                val = converTable.get(key)(val)
            except ValueError:
                pass
        else:
            try:
                val = int(val)  # make int if can.
            except ValueError:
                try:
                    val = float(val)  # make float if can.
                except ValueError:
                    pass
        if val == '':  # Empty strings treated as None
            val = None
        return val

    # Skip empty and comment-only lines
    if re.match(r'[ \t]*(#|$)', line):
        return (None, None)

    # now split it into keys and values. We allow for max one
    # split/cut (the first one)
    (keys, vals) = [c.strip() for c in line.split('=', 1)]

    # extract the keys, convert to lowercase
    keys = keys.lower()
    if not keys:
        raise ConfigParserError("Missing Key = expression")

    # extract the values, preserving case
    if not vals:
        keys = keys.split(varSeparator)
        return (keys, None)
    # split and sanitize
    vals = map(sanitize_value, [keys] * len(vals.split(optSeparator)),
               vals.split(optSeparator))
    if len(vals) == 1:
        # Single value
        vals = vals[0]
    keys = keys.split(varSeparator)
    # and now return our findings
    return (keys, vals)


def parse_file(filename, single_key=0):
    """
    parse a config file (read it in, parse its lines)
    """
    lines = read_file(filename)
    # the base case, an empty tuple component, is always present.
    ret = {(): {}}
    lineno = 0
    # okay, read the file, parse the lines one by one
    for line in lines:
        # lineno is 1-based
        lineno = lineno + 1
        try:
            (keys, values) = parse_line(line)
        except:
            raise ConfigParserError("Parse Error: <%s:%s>: '%s'" % (
                filename, lineno, line)), None, sys.exc_info()[2]
        if keys is None:  # We don't care about this line
            continue
        # now process the parsed line
        if single_key and len(keys) > 1:
            # Error, we should not have more than one key in the this
            # config file
            #            raise ConfigParserError("Parse Error: <%s:%s>: too many keys"
            #              % (filename, lineno))
            # let's fix the faulty config=file setup...
            # XXX: needs more testing!!! (2003-04-17)
            del keys[:-1]
        # Store this line in a dictionary filled by component
        comp = tuple(keys[:-1])
        key = keys[-1]
        if not ret.has_key(comp):
            # Don't make it a UserDictCase since we know exactly we
            # already used string.lower
            ret[comp] = {}
        ret[comp][key] = (values, lineno)
    return ret


def read_file(filename):
    """
    reads a text config file and returns its lines in a list
    """
    try:
        lines = open(filename, 'rb').readlines()
        new_lines = []
        combined = ''
        for line in lines:
            # if the line isn't part of a multiline, lets add it
            if line.find('\\\n') < 0:
                combined = combined + line
                new_lines.append(combined)
                combined = ''
            else:
                combined = combined + line.replace('\\\n', ' ')
        return new_lines
    except (IOError, OSError), e:
        raise ConfigParserError("Can not read config file", filename, e.args[1]), None, sys.exc_info()[2]


def getAllComponents_tree(defaultDir=None):
    """Figure out all components and return them in a tree-like structure

    {'server', {'server.app':{},
                'server.satellite':{},
                'server.applet':{}, 'server.bugzilla':{},
                'server.iss':{}, 'server.xmlrpc':{}, 'server.xp':{}},
     'web': {},
     'tools': {}}

    NOTE: this was begging for recursion... I avoided that like the plague
    """

    if defaultDir is None:
        defaultDir = _CONFIG_DEFAULTS_ROOT
    comps = glob.glob('%s/*.conf' % defaultDir)
    compTree = {}
    for comp in comps:
        comp = os.path.basename(comp)
        comp = comp[:comp.find('.')]       # left of .conf
        parts = comp.split('_')[1:]        # strip off that rhn_
        if not parts:
            continue
        d = compTree
        for i in range(len(parts)):
            key = '.'.join(parts[:i + 1])
            if not d.has_key(key):
                d[key] = {}
            d = d[key]
    return compTree


def getAllComponents(defaultDir=None, compsTree=None):
    """recursively flattens the results of getAllComponents_tree returning
       a list of all components"""

    if compsTree is None:
        compsTree = getAllComponents_tree(defaultDir)
    l = []
    for k, v in compsTree.items():
        l.extend(getAllComponents(None, v))
        l.append(k)
    return l


def getAllComponents_tuples(defaultDir=None):
    """returns a list of ALL components in the tuple-ified format:
       E.g., [(), ('a',), ('a','b'), ('a','b','c'), ...]
    """
    comps = getAllComponents(defaultDir)
    d = {}
    for comp in comps:
        for c in parse_comps(comp):
            d[c] = None
    return d.keys()


CFG = RHNOptions()


def initCFG(component=None, root=None, filename=None):
    """
    Main entry point here
    """
    # NOTE: root: root directory location of config files.
    CFG.init(component, root, filename)
    CFG.parse()

ALL_CFG = RHNOptions('')
ALL_CFG.parse()
PRODUCT_NAME = ALL_CFG.PRODUCT_NAME


def runTest():
    print "Test script:"
    import pprint
    print "Component tree of all installed components:"
    pprint.pprint(getAllComponents_tree())
    print
    test_cfg = RHNOptions(sys.argv[1])
#    test_cfg = RHNOptions('server.app')
#    test_cfg = RHNOptions('proxy.broker')
#    test_cfg = RHNOptions('proxy.redirect', _CONFIG_ROOT)
#    test_cfg = RHNOptions('proxy.redirect', '/tmp')
#    test_cfg.filename = 'empty.conf'
    test_cfg.parse()
    print "=============== the object's repr ================================"
    print test_cfg
    print "=============== the object's defaults ============================"
    pprint.pprint(test_cfg.getDefaults())
    print "=============== an erronous lookup example ======================="
    print "testing __getattr__"
    try:
        print test_cfg.lkasjdfxxxxxxxxxxxxxx
    except AttributeError, e:
        print 'Testing: "AttributeError: %s"' % e
    print
    print "=============== the object's merged settings ======================"
    test_cfg.show()
    print "=============== dump of all relevant dictionaries ================="
    test_cfg.showall()
    print "==================================================================="


#------------------------------------------------------------------------------
# Usage:  rhnConfig.py [ { get | list } component [ key ] ]
#    No args assumes test mode.


if __name__ == "__main__":
    do_list = 0
    comp_arg = None
    key_arg = None

    if len(sys.argv) == 4 and sys.argv[1] == "get":
        comp_arg = sys.argv[2]
        key_arg = sys.argv[3]
    elif len(sys.argv) == 3 and sys.argv[1] == "list":
        comp_arg = sys.argv[2]
        do_list = 1
    else:
        # Assume test mode.
        runTest()
        sys.exit(1)

    cfg = RHNOptions(comp_arg)
    cfg.parse()

    if do_list:
        cfg.show()
    else:
        print cfg.get(key_arg)

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
# Templating code for the configuration management project
#
# $Id$

import re
import string

from common import log_error

class BaseTemplatedDocument:
    compiled_regexes = {}

    def __init__(self, start_delim=None, end_delim=None):
        self.start_delim = None
        self.end_delim = None
        self.set_delims(start_delim, end_delim)
        self.functions = {}
        # To be overridden in a child class
        self.set_functions()

    def set_functions(self):
        pass

    def set_delims(self, start_delim=None, end_delim=None):
        if '%' in (start_delim, end_delim):
            raise ValueError, "Cannot use `%' as a delimiter"
        if self.start_delim is None and start_delim is None:
            start_delim = '{{'
        if self.start_delim is None or start_delim is not None:
            self.start_delim = start_delim
        # if start_delim is None and self.start_denim is set, don't overwrite

        if self.end_delim is None and end_delim is None:
            end_delim = '{{'
        if self.end_delim is None or end_delim is not None:
            self.end_delim = end_delim

        # delims might have special characters that are regexp-relevant,
        # need to escape those
        escaped_start_delim = re.escape(self.start_delim)
        escaped_end_delim = re.escape(self.end_delim)
        
        regex_key = (self.start_delim, self.end_delim)
        
        # At this point, self.start_delim and self.end_delim are non-null
        if self.compiled_regexes.has_key(regex_key):
            # We already have the regex compiled
            self.regex = self.compiled_regexes[regex_key]
            return

        # We have to convince .* to match as few repetitions as possible,
        # otherwise it's possible to match end_delims too; using .*? then
        self.regex = re.compile(escaped_start_delim + r"(.*?)" + escaped_end_delim)
        self.compiled_regexes[regex_key] = self.regex

        self.compiled_regexes[self.start_delim] = re.compile("(%s)" % escaped_start_delim)
        self.compiled_regexes[self.end_delim] = re.compile("(%s)" % escaped_end_delim)

    def repl_func(self, match_object):
        try:
            return self._repl_func(match_object)
        except ValueError, e:
            log_error("cfg variable interpolation error", e)
            return match_object.group()

    def _repl_func(self, match_object):
        return ""

    def interpolate(self, data):
        return self.regex.sub(self.repl_func, data)


class TemplatedDocument(BaseTemplatedDocument):
    func_regex = re.compile("^(?P<fname>[^=]+)(=(?P<defval>.*))?$")
    funcname_regex = re.compile("^[A-Za-z][\w._]*$")

    def _repl_func(self, match_object):
        funcname = match_object.groups()[0]
        funcname = string.strip(funcname)
        fname, params, defval = self.parse_func_name(funcname)
        return self.call(fname, params, defval)

    def parse_func_name(self, fstr):
        mo = self.func_regex.match(fstr)
        if not mo:
            # XXX raise exceptions
            return (None, None, None)
        dict = mo.groupdict()
        fname = dict.get('fname')
        defval = dict.get('defval')
        
        fname = self.strip(fname)
        defval = self.unquote(defval)
        params = None

        if fname[-1] == ')':
            # Params are present
            i = string.rfind(fname, '(')
            if i < 0:
                raise ValueError, "Missing ("

            params = fname[i+1:-1]
            fname = string.strip(fname[:i])

            # Parse the params
            params = map(self.unquote, filter(None, string.split(params, ',')))

        # Validate the function name
        if not self.funcname_regex.match(fname):
            raise ValueError, "Invalid function name %s" % fname
        
        return fname, params, defval

    def null_call(self, fname, params, defval):
        val = fname
        if params:
            val = "%s(%s)" % (val, string.join(params, ', '))
        if defval is not None:
            val = "%s = %s" % (val, defval)
        return "%s %s %s" % (self.start_delim, val, self.end_delim)

    def lookup_function(self, fname):
        return self.functions.get(fname)

    def call(self, fname, params, defval):
        f = self.lookup_function(fname)
        if f is None:
            return str(self.fallback_call(fname, params, defval))
        if params is None:
            params = ()

        result = apply(f, params)

        if result == None:
            if defval:
                return defval
            return ''

        return str(result)

    # What to do when the function was not found?
    # To be overridden in subclasses
    def fallback_call(self, fname, params, defval):
        raise InvalidFunctionError(fname)

    def test(self):
        escaped = self.regex.sub(self.repl_func, 'abc @@ aa @@ def')
        print escaped

    def strip(self, s):
        if s is None:
            return None
        return string.strip(s)

    def unquote(self, s):
        if s is None:
            return None
        s = string.strip(s)
        if len(s) <= 1:
            # Nothing to unquote
            return s
            
        if s[0] == s[-1] and s[0] in ['"', "'"]:
            # Strip quotes
            return s[1:-1]

        return s

class InvalidFunctionError(Exception):
    pass

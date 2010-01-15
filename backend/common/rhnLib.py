#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
import pwd
import grp
import time
import types
import shutil
import string
import popen2
import select
import urlparse
from common import log_debug, log_error
from spacewalk.common.checksum import getFileChecksum

def setHeaderValue(mp_table, name, values):
    """
    Function that correctly sets headers in an Apache-like table
    The values may be a string (which are set as for a dictionary),
    or an array.
    """
    # mp_table is an Apache mp_table (like headers_in or headers_out)
    # Sets the header name to the values
    if type(values) in (types.ListType, types.TupleType):
        for v in values:
            mp_table.add(name, str(v))
    else:
        mp_table[name] = str(values)


rfc822_days = ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')
rfc822_mons = ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', \
               'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')


def rfc822time(arg):
    """
    Return time as a string formatted such as: 'Wed, 23 Jun 2001 23:08:35 GMT'.
    We must not use locale-specific functions such as strftime here because
    the RFC explicitly requires C-locale only formatting.  To satisfy this
    requirement, we declare our own days and months here and do the formatting
    manually.

    This function accepts a single argument.  If it is a List or Tuple type,
    it is assumed to be of the form struct_time, as specified in the Python
    time module reference.  If the argument is a float, it is expected to be
    the number of seconds from the epoch.

    NOTE:  In all cases, the argument is assumed to be in local time.  It will
           be translated to GMT in the return value.
    """

    if type(arg) in (types.ListType, types.TupleType):
        # Convert to float.
        arg = time.mktime(arg)

    # Now, the arg must be a float.

    (tm_year, tm_mon, tm_mday, tm_hour, tm_min, \
         tm_sec, tm_wday, tm_yday, tm_isdst) = time.gmtime(arg)

    return \
        "%s, %02d %s %04d %02d:%02d:%02d %s" % \
            (rfc822_days[tm_wday], tm_mday, rfc822_mons[tm_mon - 1], tm_year, \
             tm_hour, tm_min, tm_sec, "GMT")


def timestamp(s):
    """
    Converts the string in format YYYYMMDDHHMISS to seconds from the epoch
    """
    if type(s) in (types.IntType, types.FloatType):
        # Presumably already a timestamp
        return s
    if len(s) == 14:
        format_string = "%Y%m%d%H%M%S"
    elif len(s) == 19:
        format_string = "%Y-%m-%d %H:%M:%S"
    else:
        raise TypeError("String '%s' is not a YYYYMMDDHHMISS" % s)
    # Get the current DST setting
    timeval = list(time.strptime(s, format_string))
    # No daylight information available
    timeval[8] = -1
    return time.mktime(timeval)


def checkValue(val, *args):
    """ A type/value checker
        Check value against the list of acceptable values / types
    """

    for a in args:
        if type(a) is types.TypeType:
            # Is val of type a?
            if type(val) is a:
                return 1
        else:
            # This is an actual value we allow
            if val == a:
                return 1
    return 0


def parseUrl(url):
    """ urlparse is more complicated than what we need.

        We make the assumption that the URL has real URL information.
        NOTE: http/https ONLY for right now.

        The normal behavior of urlparse:
            - if no {http[s],file}:// then the string is considered everything
              that normally follows the URL, e.g. /XMLRPC
            - if {http[s],file}:// exists, anything between that and the next /
              is the URL.

        The behavior of *this* function:
            - if no {http[s],file}:// then the string is simply assumed to be a
              URL without the {http[s],file}:// attached. The parsed info is
              reparsed as one would think it would be:

            - returns: (addressing scheme, network location, path,
                        parameters, query, fragment identifier).

              NOTE: netloc (or network location) can be HOSTNAME:PORT
    """
    schemes = ('http', 'https')
    if url is None:
        return None
    parsed = list(urlparse.urlparse(url))
    if not parsed[0] or parsed[0] not in schemes:
        url = 'https://' + url
        parsed = list(urlparse.urlparse(url))
        parsed[0] = ''
    return tuple(parsed)


class InvalidUrlError(Exception):
    pass


def fix_url(url, scheme="http", path="/"):
    if string.lower(scheme) not in ('http', 'https'):
        # Programmer error
        raise ValueError("Unknown URL scheme %s" % scheme)
    _scheme, _netloc, _path, _params, _query, _fragment = \
        urlparse.urlparse(url)

    if not _netloc:
        # No schema - trying to patch it up
        new_url = scheme + '://' + url
        _scheme, _netloc, _path, _params, _query, _fragment = \
            urlparse.urlparse(new_url)

    if string.lower(_scheme) not in ('http', 'https'):
        raise InvalidUrlError("Invalid scheme %s for URL %s" % (_scheme, url))

    if not _netloc:
        raise InvalidUrlError(url)

    if _path == '':
        _path = path

    url = urlparse.urlunparse((_scheme, _netloc, _path, _params, _query,
        _fragment))
    return url


def startswith(s, prefix):
    """
    Trivial function that I wish existed in python 1.5
    """
    return s[:len(prefix)] == prefix



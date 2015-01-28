#
# Copyright (c) 2004 Conectiva, Inc.
#
# Written by Gustavo Niemeyer <niemeyer@conectiva.com>
#
# This file is part of Smart Package Manager.
#
# Smart Package Manager is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published
# by the Free Software Foundation; either version 2 of the License, or (at
# your option) any later version.
#
# Smart Package Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Smart Package Manager; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
from smart.option import OptionParser, append_all
from smart.channel import *
from smart import *
import textwrap
import sys, os

USAGE=_("smart mirror [options]")

DESCRIPTION=_("""
This command allows one to manipulate mirrors. Mirrors are URLs
that supposedly provide the same contents as are available in
other URLs, named origins in this help text. There is no internal
restriction on the kind of information which is mirrored. Once
an origin URL is provided, and one or more mirror URLs are
provided, these mirrors will be considered for any file which
is going to be fetched from an URL starting with the origin URL.
Whether the mirror will be chosen or not will depend on the
history of downloads from this mirror and from other mirrors for
the same URL, since mirrors are automatically balanced so that
the fastest mirror and with less errors is chosen. When errors
occur, the next mirror is tried.

For instance, if a mirror "http://mirror.url/path/" is provided
for the origin "ftp://origin.url/other/path/", and a file in
"ftp://origin.url/other/path/subpath/somefile" is going to be
fetched, the mirror will be considered for being used, and the
URL "http://mirror.url/path/subpath/somefile" will be used if
the mirror is chosen. Notice that strings are compared and
replaced without any pre-processing, so that it's possible to
use URLs ending in prefixes of directory entries.
""")

EXAMPLES=_("""
smart mirror --show
smart mirror --add ftp://origin.url/some/path/ http://mirror.url/path/
smart mirror --remove ftp://origin.url/some/path/ http://mirror.url/path/
smart mirror --add http://some.url/path/to/mirrors.txt
smart mirror --sync http://some.url/path/to/mirrors.txt
smart mirror --clear-history ftp://origin.url/some/path/
smart mirror --clear-history ftp://mirror.url/path/
smart mirror --clear-history
""")

def parse_options(argv):
    parser = OptionParser(usage=USAGE,
                          description=DESCRIPTION,
                          examples=EXAMPLES)
    parser.defaults["add"] = []
    parser.defaults["remove"] = []
    parser.defaults["remove_all"] = []
    parser.defaults["clear_history"] = None
    parser.add_option("--show", action="store_true",
                      help=_("show current mirrors"))
    parser.add_option("--add", action="callback", callback=append_all,
                      help=_("add to the given origin URL the given mirror "
                             "URL, provided either in pairs, or in a given "
                             "file/url in the format used by --show"))
    parser.add_option("--remove", action="callback", callback=append_all,
                      help=_("remove from the given origin URL the given "
                             "mirror URL, provided either in pairs, or in a "
                             "given file/url in the format used by --show"))
    parser.add_option("--remove-all", action="callback", callback=append_all,
                      help=_("remove all mirrors for the given origin URLs"))
    parser.add_option("--sync", action="store", metavar="FILE",
                      help=_("synchronize mirrors from the given file/url, "
                             "so that origins in the given file will have "
                             "exactly the specified mirrors"))
    parser.add_option("--clear-history", action="callback", callback=append_all,
                      help=_("clear history for the given origins/mirrors, or "
                             "for all mirrors"))
    parser.add_option("--show-penalities", action="store_true",
                      help=_("show current penalities for origins/mirrors, "
                             "based on the history information"))
    opts, args = parser.parse_args(argv)
    opts.args = args
    return opts

def read_mirrors(ctrl, filename):
    fetched = False
    if ":/" in filename:
        url = filename
        succ, fail = ctrl.downloadURLs([url], _("mirror descriptions"))
        if fail:
            raise Error, _("Failed to download mirror descriptions:\n") + \
                         "\n".join(["    %s: %s" % (url, fail[url])
                                    for url in fail])
        filename = succ[url]
        fetched = True
    elif not os.path.isfile(filename):
        raise Error, _("File not found: %s") % filename
    try:
        result = []
        origin = None
        mirror = None
        for line in open(filename):
            url = line.strip()
            if not url:
                continue
            if line[0].isspace():
                mirror = url
            else:
                if origin and mirror is None:
                    result.append(origin)
                    result.append(None)
                origin = url
                mirror = None
                continue
            if not origin:
                raise Error, _("Invalid mirrors file")
            result.append(origin)
            result.append(mirror)
        if origin and mirror is None:
            result.append(origin)
            result.append(None)
    finally:
        if fetched and filename.startswith(sysconf.get("data-dir")):
            os.unlink(filename)
    return result

def main(ctrl, opts):

    if opts.add:
        if len(opts.add) == 1:
            opts.add = read_mirrors(ctrl, opts.add[0])
        if len(opts.add) % 2 != 0:
            raise Error, _("Invalid arguments for --add")
        for i in range(0,len(opts.add),2):
            origin, mirror = opts.add[i:i+2]
            if mirror:
                sysconf.add(("mirrors", origin), mirror, unique=True)

    if opts.remove:
        if len(opts.remove) == 1:
            opts.remove = read_mirrors(ctrl, opts.remove[0])
        if len(opts.remove) % 2 != 0:
            raise Error, _("Invalid arguments for --remove")
        for i in range(0,len(opts.remove),2):
            origin, mirror = opts.remove[i:i+2]
            if not sysconf.has(("mirrors", origin)):
                iface.waring(_("Origin not found: %s") % origin)
            if not sysconf.remove(("mirrors", origin), mirror):
                iface.waring(_("Mirror not found: %s") % mirror)

    if opts.remove_all:
        for origin in opts.remove_all:
            if not sysconf.remove(("mirrors", origin)):
                iface.waring(_("Origin not found: %s") % origin)

    if opts.sync:
        reset = {}
        lst = read_mirrors(ctrl, opts.sync)
        for i in range(0,len(lst),2):
            origin, mirror = lst[i:i+2]
            if origin not in reset:
                reset[origin] = True
                sysconf.remove(("mirrors", origin))
            if mirror:
                sysconf.add(("mirrors", origin), mirror, unique=True)

    if opts.clear_history is not None:
        if opts.clear_history:
            history = sysconf.get("mirrors-history", [])
            history[:] = [x for x in history if x[0] not in opts.clear_history]
            sysconf.set("mirrors-history", history)
        else:
            history = sysconf.remove("mirrors-history")

    if opts.show:
        mirrors = sysconf.get("mirrors", ())
        for origin in mirrors:
            print origin
            for mirror in mirrors[origin]:
                print "   ", mirror
            print

    if opts.show_penalities:
        ctrl.reloadMirrors()
        mirrorsystem = ctrl.getFetcher().getMirrorSystem()
        penalities = mirrorsystem.getPenalities().copy()
        mirrors = sysconf.get("mirrors", ())
        for origin in mirrors:
            if origin not in penalities:
                penalities[origin] = 0
            for mirror in mirrors[origin]:
                if mirror not in penalities:
                    penalities[origin] = 0
        penalities = [(y, x) for x, y in penalities.items()]
        penalities.sort()
        for penality, url in penalities:
            print "%s %d" % (url, penality)

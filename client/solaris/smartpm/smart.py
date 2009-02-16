#!/usr/bin/python
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
import sys
from smart.const import VERSION, DEBUG, DATADIR
from smart.option import OptionParser
from smart import init, initPlugins
from smart import *
if sys.version_info < (2, 3):
    sys.exit(_("error: Python 2.3 or later required"))

import pwd
import os

# Avoid segfault due to strange linkage order. Remove this ASAP.
if sys.platform[:5] != "sunos":
    import pyexpat

USAGE=_("smart command [options] [arguments]")

DESCRIPTION=_("""
Action commands:
    update
    install
    reinstall
    upgrade
    remove
    check
    fix
    download

Query commands:
    search
    query
    info
    stats

Setup commands:
    channel
    priority
    mirror
    flag

Run "smart command --help" for more information.
""")

EXAMPLES = _("""
smart install --help
smart install pkgname
smart --gui
smart --gui install pkgname
smart --shell
""")

def parse_options(argv):
    parser = OptionParser(usage=USAGE,
                          description=DESCRIPTION,
                          examples=EXAMPLES,
                          version="smart %s" % VERSION)
    parser.disable_interspersed_args()
    parser.add_option("--config-file", metavar=_("FILE"),
                      help=_("configuration file "
                             "(default is <data-dir>/config)"))
    parser.add_option("--data-dir", metavar=_("DIR"),
                      help=_("data directory (default is %s)") % DATADIR)
    parser.add_option("--log-level", metavar=_("LEVEL"),
                      help=_("set the log level to LEVEL (debug, info, "
                             "warning, error)"))
    parser.add_option("--gui", action="store_true",
                      help=_("use the default graphic interface"))
    parser.add_option("--shell", action="store_true",
                      help=_("use the default shell interface"))
    parser.add_option("--interface", metavar=_("NAME"),
                      help=_("use the given interface"))
    parser.add_option("--ignore-locks", action="store_true",
                      help=_("don't respect locking"))
    parser.add_option("-o", "--option", action="append", default=[],
                      metavar=_("OPT"),
                      help=_("set the option given by a name=value pair"))
    opts, args = parser.parse_args()
    if args:
        opts.command = args[0]
        opts.argv = args[1:]
    else:
        opts.command = None
        opts.argv = []
    if not (opts.command or opts.gui or opts.shell):
        parser.print_help()
        sys.exit(1)
    return opts

def set_config_options(options):
    import re, copy

    globals = {}
    globals["__builtins__"] = {}
    globals["True"] = True
    globals["true"] = True
    globals["yes"] = True
    globals["False"] = False
    globals["false"] = False
    globals["no"] = False

    SETRE = re.compile(r"^(\S+?)(\+?=)(.*)$")

    for opt in options:
        m = SETRE.match(opt)
        if not m:
            raise Error, _("Invalid option: %s") % opt
        path, assign, value = m.groups()
        try:
            value = int(value)
        except ValueError:
            try:
                value = eval(value, globals)
            except:
                pass
        if assign == "+=":
            sysconf.add(path, value, soft=True)
        else:
            sysconf.set(path, value, soft=True)

def main(argv):
    # Get the right $HOME, even when using sudo.
    if os.getuid() == 0:
        os.environ["HOME"] = pwd.getpwuid(0)[5]
    opts = None
    ctrl = None
    exitcode = 1
    try:
        opts = parse_options(argv)
        ctrl = init(command=opts.command, argv=opts.argv,
                    datadir=opts.data_dir, configfile=opts.config_file,
                    gui=opts.gui, shell=opts.shell, interface=opts.interface,
                    forcelocks=opts.ignore_locks, loglevel=opts.log_level)
        if opts.option:
            set_config_options(opts.option)
        initPlugins()
        exitcode = iface.run(opts.command, opts.argv)
        if exitcode is None:
            exitcode = 0
        ctrl.saveSysConf()
        ctrl.restoreMediaState()
    except Error, e:
        if opts and opts.log_level == "debug":
            import traceback
            traceback.print_exc()
        if iface.object:
            iface.error(unicode(e))
        else:
            sys.stderr.write(_("error: %s\n") % e)
        if ctrl:
            ctrl.saveSysConf()
            ctrl.restoreMediaState()
    except KeyboardInterrupt:
        if opts and opts.log_level == "debug":
            import traceback
            traceback.print_exc()
            sys.exit(1)
        sys.stderr.write(_("\nInterrupted\n"))
    print
    if exitcode != 0:
        sys.exit(exitcode)

if __name__ == "__main__":
    main(sys.argv[1:])

# vim:ts=4:sw=4:et

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
from smart.interfaces.text.interface import TextInterface, getScreenWidth
from smart.const import VERSION, NEVER
from smart.option import OptionParser
from smart.transaction import *
from smart import *
from cmd import Cmd
import sys, os
import shlex


class TextInteractiveInterface(TextInterface):

    def run(self, command=None, argv=None):
        print "Smart Package Manager %s - Shell Mode" % VERSION
        print
        self._ctrl.reloadChannels()
        Interpreter(self._ctrl).cmdloop()

    def confirmChange(self, oldchangeset, newchangeset, expected=0):
        if newchangeset == oldchangeset:
            return False
        changeset = newchangeset.difference(oldchangeset)
        keep = []
        for pkg in oldchangeset:
            if pkg not in newchangeset:
                keep.append(pkg)
        if len(keep)+len(changeset) <= expected:
            self.showChangeSet(changeset, keep=keep)
            return True
        return self.showChangeSet(changeset, keep=keep, confirm=True)

class Interpreter(Cmd):

    prompt = "smart> "
    ruler = "-"

    doc_header = _("Documented commands (type help <topic>):")
    undoc_header = _("Undocumented commands:")
    misc_header = _("Miscelaneous help topics:")
    nohelp = _("*** No help on %s")

    def __init__(self, ctrl):
        Cmd.__init__(self)
        self._ctrl = ctrl
        self._changeset = ChangeSet(ctrl.getCache())

        self._undo = []
        self._redo = []

    def completeAll(self, text, line, begidx, endidx):
        matches = []
        for pkg in self._ctrl.getCache().getPackages():
            value = str(pkg)
            if value.startswith(text):
                matches.append(value)
        return matches

    def completeInstalled(self, text, line, begidx, endidx):
        matches = []
        for pkg in self._ctrl.getCache().getPackages():
            if pkg.installed:
                value = str(pkg)
                if value.startswith(text):
                    matches.append(value)
        return matches

    def completeAvailable(self, text, line, begidx, endidx):
        matches = []
        for pkg in self._ctrl.getCache().getPackages():
            if not pkg.installed:
                value = str(pkg)
                if value.startswith(text):
                    matches.append(value)
        return matches

    def completeMarked(self, text, line, begidx, endidx):
        matches = []
        for pkg in self._ctrl.getCache().getPackages():
            if pkg in self._changeset:
                value = str(pkg)
                if value.startswith(text):
                    matches.append(value)
        return matches

    def saveUndo(self):
        state = self._changeset.getPersistentState()
        if not self._undo or state != self._undo[0]:
            self._undo.insert(0, self._changeset.getPersistentState())
            del self._redo[:]
            del self._undo[20:]

    def pkgsFromLine(self, line):
        args = shlex.split(line)
        for arg in args:
            ratio, results, suggestions = self._ctrl.search(arg,
                                                            addprovides=False)
            if not results:
                if suggestions:
                    dct = {}
                    for r, obj in suggestions:
                        if isinstance(obj, Package):
                            dct[obj] = True
                        else:
                            dct.update(dct.fromkeys(obj.packages, True))
                    raise Error, _("'%s' matches no packages. "
                                   "Suggestions:\n%s") % \
                                 (arg, "\n".join(["    "+str(x) for x in dct]))
                else:
                    raise Error, _("'%s' matches no packages") % arg
            else:
                pkgs = {}
                for obj in results:
                    if isinstance(obj, Package):
                        pkgs[obj] = True
                    else:
                        pkgs.update(dict.fromkeys(obj.packages, True))
            pkgs = pkgs.keys()
            if len(pkgs) > 1:
                sortUpgrades(pkgs)
            yield arg, pkgs

    def preloop(self):
        Cmd.preloop(self)
        if self.completekey:
            try:
                import readline
                delims = readline.get_completer_delims()
                delims = "".join([x for x in delims if x not in "-:@"])
                readline.set_completer_delims(delims)
            except ImportError:
                pass

    def emptyline(self):
        pass

    def onecmd(self, line):
        try:
            cmd, arg, line = self.parseline(line)
            if arg in ("-h", "--help"):
                try:
                    getattr(self, "help_"+cmd)()
                    return None
                except AttributeError:
                    pass
            return Cmd.onecmd(self, line)
        except Error, e:
            iface.error(unicode(e))
            return None
        except KeyboardInterrupt:
            sys.stderr.write(_("\nInterrupted\n"))
            return None

    def print_topics(self, header, cmds, cmdlen, maxcol):
        if cmds:
            # The header may be a unicode string. That's the only
            # reason to implement our own print_topics()
            self.stdout.write(header)
            self.stdout.write("\n")
            if self.ruler:
                self.stdout.write("%s\n"%str(self.ruler * len(header)))
            self.columnize(cmds, maxcol-1)
            self.stdout.write("\n")

    def help_help(self):
        print _("What would you expect!? ;-)")

    def help_EOF(self):
        print _("The exit/quit/EOF command returns to the system.")
    help_exit = help_EOF
    help_quit = help_EOF

    def do_EOF(self, line):
        print
        return True
    do_exit = do_EOF
    do_quit = do_EOF

    def help_shell(self):
        print _("The shell command offers execution of system commands.")
        print
        print _("Usage: shell [<cmd>]")
        print _("       ![<cmd>]")

    def do_shell(self, line):
        if not line.strip():
            line = os.environ.get("SHELL", "/bin/sh")
        os.system(line)

    def help_status(self):
        print _("The status command shows currently marked changes.")
        print
        print _("Usage: status")

    def do_status(self, line):
        if line.strip():
            raise Error, _("Invalid arguments")
        if not self._changeset:
            print _("There are no marked changes.")
        else:
            iface.showChangeSet(self._changeset)

    def help_install(self):
        print _("The install command marks packages for installation.")
        print
        print _("Usage: install <pkgname> ...")

    complete_install = completeAvailable
    def do_install(self, line):
        cache = self._ctrl.getCache()
        transaction = Transaction(cache, policy=PolicyInstall)
        transaction.setState(self._changeset)
        changeset = transaction.getChangeSet()
        expected = 0
        for arg, pkgs in self.pkgsFromLine(line):
            expected += 1
            names = {}
            found = False
            for pkg in pkgs:
                names.setdefault(pkg.name, []).append(pkg)
            for name in names:
                pkg = names[name][0]
                if pkg.installed:
                    iface.warning(_("%s is already installed") % pkg)
                else:
                    found = True
                    transaction.enqueue(pkg, INSTALL)
            if not found:
                raise Error, _("No uninstalled packages matched '%s'") % arg
        transaction.run()
        if iface.confirmChange(self._changeset, changeset, expected):
            self.saveUndo()
            self._changeset.setState(changeset)

    def help_reinstall(self):
        print _("The reinstall command marks packages for reinstallation.")
        print
        print _("Usage: reinstall <pkgname> ...")

    complete_reinstall = completeInstalled
    def do_reinstall(self, line):
        cache = self._ctrl.getCache()
        transaction = Transaction(cache, policy=PolicyInstall)
        transaction.setState(self._changeset)
        changeset = transaction.getChangeSet()
        expected = 0
        for arg, pkgs in self.pkgsFromLine(line):
            expected += 1
            if not pkgs:
                raise Error, _("'%s' matches no installed packages") % arg
            if len(pkgs) > 1:
                raise Error, _("'%s' matches multiple installed packages")%arg
            transaction.enqueue(pkgs[0], REINSTALL)
        transaction.run()
        if iface.confirmChange(self._changeset, changeset, expected):
            self.saveUndo()
            self._changeset.setState(changeset)

    def help_upgrade(self):
        print _("The upgrade command marks packages for upgrading.")
        print
        print _("Usage: upgrade <pkgname> ...")

    complete_upgrade = completeInstalled
    def do_upgrade(self, line):
        cache = self._ctrl.getCache()
        transaction = Transaction(cache, policy=PolicyUpgrade)
        transaction.setState(self._changeset)
        changeset = transaction.getChangeSet()
        expected = 0
        if not line.strip():
            for pkg in cache.getPackages():
                if pkg.installed:
                    transaction.enqueue(pkg, UPGRADE)
        else:
            for arg, pkgs in self.pkgsFromLine(line):
                expected += 1
                found = False
                for pkg in pkgs:
                    if pkg.installed:
                        found = True
                        transaction.enqueue(pkg, UPGRADE)
                if not found:
                    raise Error, _("'%s' matches no installed packages") % arg
        transaction.run()
        if changeset == self._changeset:
            print _("No interesting upgrades available!")
        elif iface.confirmChange(self._changeset, changeset, expected):
            self.saveUndo()
            self._changeset.setState(changeset)

    def help_remove(self):
        print _("The remove command marks packages for being removed.")
        print
        print _("Usage: remove <pkgname> ...")

    complete_remove = completeInstalled
    def do_remove(self, line):
        cache = self._ctrl.getCache()
        transaction = Transaction(cache, policy=PolicyRemove)
        transaction.setState(self._changeset)
        changeset = transaction.getChangeSet()
        policy = transaction.getPolicy()
        expected = 0
        for arg, pkgs in self.pkgsFromLine(line):
            expected += 1
            found = False
            for pkg in pkgs:
                if pkg.installed:
                    found = True
                    transaction.enqueue(pkg, REMOVE)
                    for _pkg in cache.getPackages(pkg.name):
                        if not _pkg.installed:
                            policy.setLocked(_pkg, True)
            if not found:
                raise Error, _("'%s' matches no installed packages") % arg
        transaction.run()
        if iface.confirmChange(self._changeset, changeset, expected):
            self.saveUndo()
            self._changeset.setState(changeset)

    def help_keep(self):
        print _("The keep command unmarks currently marked packages.")
        print
        print _("Usage: keep <pkgname> ...")

    complete_keep = completeMarked
    def do_keep(self, line):
        cache = self._ctrl.getCache()
        transaction = Transaction(cache, policy=PolicyInstall)
        transaction.setState(self._changeset)
        changeset = transaction.getChangeSet()
        expected = 0
        for arg, pkgs in self.pkgsFromLine(line):
            expected += 1
            pkgs = [x for x in pkgs if x in changeset]
            if not pkgs:
                raise Error, _("'%s' matches no marked packages") % arg
            for pkg in pkgs:
                transaction.enqueue(pkg, KEEP)
        transaction.run()
        if iface.confirmChange(self._changeset, changeset, expected):
            self.saveUndo()
            self._changeset.setState(changeset)

    def help_fix(self):
        print _("The fix command verifies relations of given packages\n"
                "and marks the necessary changes for fixing them.")
        print
        print _("Usage: fix <pkgname> ...")

    complete_fix = completeAll
    def do_fix(self, line):
        cache = self._ctrl.getCache()
        transaction = Transaction(cache, policy=PolicyInstall)
        transaction.setState(self._changeset)
        changeset = transaction.getChangeSet()
        expected = 0
        for arg, pkgs in self.pkgsFromLine(line):
            expected += 1
            for pkg in pkgs:
                transaction.enqueue(pkg, FIX)
        transaction.run()
        if changeset == self._changeset:
            print _("No problems to resolve!")
        elif iface.confirmChange(self._changeset, changeset, expected):
            self.saveUndo()
            self._changeset.setState(changeset)

    def help_download(self):
        print _("The download command fetches the given packages\n"
                "to the local filesystem.")
        print
        print _("Usage: download <pkgname> ...")

    complete_download = completeAll
    def do_download(self, line):
        packages = []
        for arg, pkgs in self.pkgsFromLine(line):
            if len(pkgs) > 1:
                iface.warning(_("'%s' matches multiple packages, "
                                "selecting: %s") % (arg, pkgs[0]))
            packages.append(pkgs[0])
        if packages:
            self._ctrl.downloadPackages(packages, targetdir=os.getcwd())

    def help_commit(self):
        print _("The commit command applies marked changes in the system.")
        print
        print _("Usage: commit")

    def do_commit(self, line):
        transaction = Transaction(self._ctrl.getCache(),
                                  changeset=self._changeset)
        if self._ctrl.commitTransaction(transaction):
            del self._undo[:]
            del self._redo[:]
            self._changeset.clear()
            self._ctrl.reloadChannels()

    def help_undo(self):
        print _("The undo command reverts marked changes.")
        print
        print _("Usage: undo")

    def do_undo(self, line):
        if not self._undo:
            return
        newchangeset = ChangeSet(self._ctrl.getCache())
        newchangeset.setPersistentState(self._undo[0])
        if iface.confirmChange(self._changeset, newchangeset):
            state = self._undo.pop(0)
            self._redo.insert(0, self._changeset.getPersistentState())
            self._changeset.setPersistentState(state)

    def help_redo(self):
        print _("The redo command reapplies undone changes.")
        print
        print _("Usage: redo")

    def do_redo(self, line):
        if not self._redo:
            return
        newchangeset = ChangeSet(self._ctrl.getCache())
        newchangeset.setPersistentState(self._redo[0])
        if iface.confirmChange(self._changeset, newchangeset):
            state = self._redo.pop(0)
            self._undo.insert(0, self._changeset.getPersistentState())
            self._changeset.setPersistentState(state)

    def help_ls(self):
        print _("The ls command lists packages by name. Wildcards\n"
                "are accepted.")
        print
        print _("Options:")
        print _("   -i  List only installed packages")
        print _("   -a  List only available but not installed packages")
        print _("   -n  List only new packages")
        print _("   -v  Show versions")
        print _("   -s  Show summaries")
        print
        print _("Usage: ls [options] [<string>] ...")

    complete_ls = completeAll
    def do_ls(self, line):
        args = shlex.split(line)
        parser = OptionParser(add_help_option=False)
        parser.add_option("-i", action="store_true", dest="installed")
        parser.add_option("-a", action="store_true", dest="available")
        parser.add_option("-v", action="store_true", dest="version")
        parser.add_option("-s", action="store_true", dest="summary")
        parser.add_option("-n", action="store_true", dest="new")
        opts, args = parser.parse_args(args)
        if args:
            pkgs = {}
            for arg in args:
                ratio, results, suggestions = self._ctrl.search(arg,
                                                         addprovides=False)
                if not results:
                    if suggestions:
                        dct = {}
                        for r, obj in suggestions:
                            if isinstance(obj, Package):
                                dct[obj] = True
                            else:
                                dct.update(dct.fromkeys(obj.packages, True))
                        raise Error, _("'%s' matches no packages. "
                                       "Suggestions:\n%s") % \
                                     (arg, "\n".join(["    "+str(x)
                                                      for x in dct]))
                    else:
                        raise Error, _("'%s' matches no packages") % arg
                else:
                    for obj in results:
                        if isinstance(obj, Package):
                            pkgs[obj] = True
                        else:
                            pkgs.update(dict.fromkeys(obj.packages, True))
        else:
            pkgs = self._ctrl.getCache().getPackages()
        if opts.installed and opts.available:
            raise Error, _("-i and -a options conflict") % arg
        if opts.installed:
            pkgs = [x for x in pkgs if x.installed]
        if opts.available:
            pkgs = [x for x in pkgs if not x.installed]
        if opts.new:
            pkgs = pkgconf.filterByFlag("new", pkgs)
        pkgs = dict.fromkeys(pkgs).keys()
        pkgs.sort()

        if opts.summary:
            for pkg in pkgs:
                if opts.version:
                    print str(pkg), "-",
                else:
                    print pkg.name, "-",
                for loader in pkg.loaders:
                    info = loader.getInfo(pkg)
                    summary = info.getSummary()
                    if summary:
                        print summary
                        break
                else:
                    print
            return

        maxnamelen = 0
        for pkg in pkgs:
            if opts.version:
                namelen = len(str(pkg))
            else:
                namelen = len(pkg.name)
            if namelen > maxnamelen:
                maxnamelen = namelen

        screenwidth = getScreenWidth()
        perline = screenwidth/(maxnamelen+2)
        if perline == 0:
            perline = 1
        columnlen = screenwidth/perline
        numpkgs = len(pkgs)
        numlines = (numpkgs+perline-1)/perline
        blank = " "*columnlen
        out = sys.stdout
        for line in range(numlines):
            for entry in range(perline):
                k = line+(entry*numlines)
                if k >= numpkgs:
                    break
                pkg = pkgs[k]
                s = opts.version and str(pkg) or pkg.name
                out.write(s)
                out.write(" "*(columnlen-len(s)))
            print

    def help_update(self):
        print _("The update command will update channel information.")
        print
        print _("Usage: update [<alias>] ...")

    def complete_update(self, text, line, begidx, endidx):
        matches = []
        for channel in self._ctrl.getChannels():
            alias = channel.getAlias()
            if alias.startswith(text):
                matches.append(alias)
        return matches

    def do_update(self, line):
        args = shlex.split(line)
        if args:
            channels = [x for x in self._ctrl.getChannels()
                        if x.getAlias() in args]
            if not channels:
                return
        else:
            channels = None
        self._ctrl.reloadChannels(channels, caching=NEVER)
        cache = self._ctrl.getCache()
        newpackages = pkgconf.filterByFlag("new", cache.getPackages())
        if not newpackages:
            iface.showStatus(_("Channels have no new packages."))
        else:
            if len(newpackages) <= 10:
                newpackages.sort()
                info = ":\n"
                for pkg in newpackages:
                    info += "    %s\n" % pkg
            else:
                info = "."
            iface.showStatus(_("Channels have %d new packages%s")
                             % (len(newpackages), info))

    def help_flag(self):
        print _("The flag command allows configuring, removing and\n"
                "verifying package flags, and accepts the same options\n"
                "available in the command line interface.")
        print
        print _("Usage: flag [options]")

    complete_flag = completeAll
    def do_flag(self, line):
        from smart.commands import flag
        try:
            try:
                opts = flag.parse_options(shlex.split(line))
            except ValueError, e:
                raise Error, str(e)
            flag.main(self._ctrl, opts)
        except SystemExit:
            pass

    def help_query(self):
        print _("The query command allows querying package information,\n"
                "and accepts the same options available in the command\n"
                "line interface.")
        print
        print _("Usage: query [options] [<pkgname>] ...")

    complete_query = completeAll
    def do_query(self, line):
        from smart.commands import query
        try:
            try:
                opts = query.parse_options(shlex.split(line))
            except ValueError, e:
                raise Error, str(e)
            query.main(self._ctrl, opts, reloadchannels=False)
        except SystemExit:
            pass

    def help_search(self):
        print _("The search command allows searching for packages.")
        print
        print _("Usage: search <string> ...")

    complete_search = completeAll
    def do_search(self, line):
        from smart.commands import search
        try:
            try:
                opts = search.parse_options(shlex.split(line))
            except ValueError, e:
                raise Error, str(e)
            search.main(self._ctrl, opts, reloadchannels=False)
        except SystemExit:
            pass

    def help_info(self):
        print _("The info command shows information about packages.")
        print
        print _("Usage: info <pkgname> ...")

    complete_info = completeAll
    def do_info(self, line):
        from smart.commands import info
        try:
            try:
                opts = info.parse_options(shlex.split(line))
            except ValueError, e:
                raise Error, str(e)
            info.main(self._ctrl, opts, reloadchannels=False)
        except SystemExit:
            pass

    def help_stats(self):
        print _("The stats command shows some statistics.")
        print
        print _("Usage: stats")

    def do_stats(self, line):
        from smart.commands import stats
        try:
            try:
                opts = stats.parse_options(shlex.split(line))
            except ValueError, e:
                raise Error, str(e)
            stats.main(self._ctrl, opts, reloadchannels=False)
        except SystemExit:
            pass

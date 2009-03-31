#!/usr/bin/python2

# copied from fedora releng git
# modified by Dennis Gilmore for spacewalk needs.
#
# Copyright (c) 2009 Red Hat

import base64
try:
    import koji
except:
    import brew as koji
import md5
import os
import os.path
import shutil
import sys
import tempfile
import time
import optparse
import inspect
import getpass

# AbstractTool class
#     parent for all classes, just to define the options only once
#
# Copyright (c) 2006 Red Hat
#
# Authors:
#     Daniel Mach <dmach@redhat.com>

class AbstractTool:
    def __init__(self):
        # create 'options' instance just once
        if not hasattr(self, 'options'):
            self.options = optparse.Values()

        # fill some default values
        self.options.verbose = False
        self.options.debug = False
        self.options.show_time = False
        self.options.retries = 5

# CliTool
# Copyright (c) 2006 Red Hat
#
# Authors:
#     Daniel Mach <dmach@redhat.com>

class CliTool(AbstractTool):

    def __init__(self, opts=None):
        AbstractTool.__init__(self)
        
        # option parser
        usage = "%prog [help] <command> [options and arguments] ...]"
        self.parser = optparse.OptionParser(usage)

        self.parser.add_option("-v", "--verbose", action="store_true", default=False,
            help="Increase verbosity")
        self.parser.add_option("-d", "--debug", action="store_true", default=False,
            help="Show debug output")
        self.parser.add_option("-Y", "--yes", action="store_true", default=False,
            help="Answer 'yes' for all [y/N] questions. Use carefully!")



    ################################################################################
    # methods for printing to the output

    def print_msg(self, msg):
        if self.options.show_time:
            print "%s %s" % (time.asctime(), msg)
        else:
            print msg


    def print_verbose(self, msg):
        if self.options.verbose or self.options.debug:
            self.print_msg(msg)


    def print_debug(self, msg):
        if self.options.debug:
            self.print_msg("DEBUG: %s" % (msg))


    def process_cmd_options(self):
        command = 'default'

        # first argument is the command; it cannot begin begin with '-'
        if len(sys.argv) > 1 and not sys.argv[1].startswith('-'):
            command = sys.argv[1]
            del sys.argv[1]
        
#        # replace '-' by '_'
#        command = command.replace('-', '_')
        
        # add command-specific options
        self.run_options(command, self.parser)

        # parse arguments
        (opts, args) = self.parser.parse_args()

        opts.options = args
        opts.command = command

        # copy opts to self.options
        self.options.__dict__.update(opts.__dict__)

        self.print_debug('command is "%s"' % command)



    ################################################################################
    # check_admin
    #
    # checks if the user is admin
    # override to make it really work

    def check_admin(self):
        return False



    ################################################################################
    # userconfirm
    #
    # gets a yes or no from the user, defaults to No
    # this function is originally from yum

    def userconfirm(self):
        # skip the question and answer 'yes' automatically
        if (self.options.yes):
            return True

        while True:
            choice = raw_input('Is this ok? [y/N]: ')
            choice = choice.lower()
            if len(choice) == 0 or choice[0] in ['y', 'n']:
                break

        if len(choice) == 0 or choice[0] != 'y':
            return False
        
        return True



    ################################################################################
    # getuserpass
    #
    # prompt user for his password
    # if 'defaultPass' is set, no prompt will be done and 'defaultPass' is returned

    def getuserpass(self, prompt=None, defaultPass=None):
        if defaultPass != None:
            return defaultPass

        if prompt == None:
            prompt = "Enter your password: "

        return getpass.getpass(prompt)
                


    ################################################################################
    # default command
    #
    # default action when no (or wrong) command is going to be executed
    # override if you need some custom default action handling
    # can be used also to handle scripts with no commands
    
    def parse_default(self):
        pass


    def help_default(self):
        return "Error: command '%s' not found.\n" % self.options.command + \
            "Use 'help' command to get help."


    def cmd_default(self):
        print self.help_default()
        sys.exit(1)



    ################################################################################
    # help command
    #
    # just handle everything about help ;)

    def parse_help(self):
        self.options.help = self.options.options


    def help_help(self):
        return "Print this help."


    def cmd_help(self):
        self.parser.print_help()
        commands = {}

        # help for all commands
        result = "\ncommands:\n"
        for (key, value) in inspect.getmembers(self):
            if key != "cmd_commands" and key != "cmd_default":
                if key.startswith('cmd_'):
                    # admin commands have greater priority, skip the normal ones
                    if not commands.has_key(key[4:]):
                        commands[key[4:]] = ' '
                elif key.startswith('admincmd_'):
                    if not self.check_admin():
                        continue
                    # mark admin commands with '*'
                    commands[key[9:]] = '*'
        
        commandlist = commands.keys()
        commandlist.sort()
        
        for cmd in commandlist:
            parser = optparse.OptionParser()
            self.run_options(cmd, parser)
            
            # remove 'help' option
            parser.remove_option('-h')
            
            parser.formatter.indent()
            parser.formatter.indent()
            
            # this ugly command splits the option help and joins it excluding the first line (containing 'options:')
            result += "\n".join(parser.format_option_help().split('\n')[1:])

            help  = self.run_help(cmd)
            usage = self.run_usage(cmd)
            result += "%s %-21s %-45s %-30s\n" % (commands[cmd], cmd.replace('_', '-'), usage, help)
        print result



    ################################################################################
    # run_* commands
    
    def run_help(self, command):
        help = getattr(self, 'help_%s' % command, None)
        if callable(help):
            return help()
        return ""


    def run_usage(self, command):
        help = getattr(self, 'usage_%s' % command, None)
        if callable(help):
            return help()
        return ""


    def run_options(self, command, optparser):
        opts = getattr(self, 'options_%s' % command, None)
        if callable(opts):
            opts(optparser)


    def run_parse(self, command):
        parse = getattr(self, 'parse_%s' % command, None)
        if callable(parse):
            parse()


    def run_command(self, command=None):
        if command == None:
            command = self.options.command.replace('-', '_')
        
        # get command-specific options
#        self.run_options(command, self.parser)

        # parse arguments for given command
        self.run_parse(command)
    

        # try to run the ADMIN command (method: admincmd_*)
        if self.check_admin():
            cmd = getattr(self, 'admincmd_%s' % command, None)
            if callable(cmd):
                cmd()
                return

        # try to run the command (method: cmd_*)
        cmd = getattr(self, 'cmd_%s' % command, None)
        if callable(cmd):
            cmd()
            return

        # try to run the 'default' command
        cmd = getattr(self, 'cmd_default')
        if callable(cmd):
            cmd()
            return

        # die if everything fails
        self.print_msg("ERROR: cannot run command '%s'!" % command.replace('_', '-'))
        self.print_msg("ERROR: There's definitely something wrong with the script, even the default command handler is missing!")
        sys.exit(1)

# KojiTool class
#     interface to Koji
#
# Copyright (c) 2007 Red Hat
#
# Authors:
#     Daniel Mach <dmach@redhat.com>
#     Jesse Keating <jkeating@redhat.com>

class KojiTool(AbstractTool):
    def __init__(self,):
        AbstractTool.__init__(self)
        self.options.debug_xmlrpc = False
        self.options.password = None
        self.options.user = None
        self.options.kojihub = 'http://koji.rhndev.redhat.com/kojihub'
        self.options.regex = False
        self.options.ignore = []

    def create_koji_session(self):
        # used options: debug, debug_xmlrpc, user, password
        self.koji_session = koji.ClientSession(self.options.kojihub, self.options.__dict__)

    def close_koji_session(self):
        self.koji_session.logout()

    def get_latest_rpms(self, tag, archlist, pkglist=[None]):
        result = []
        for pkg in pkglist:
            for arch in archlist:
                self.print_debug("Getting latest for %s (%s-%s)" % (tag, pkg, arch))
                rpmlist, buildlist = self.koji_session.getLatestRPMS(tag, package=pkg, arch=arch)
                self.print_debug("Got %s rpms (%s builds)" % (len(rpmlist), len(buildlist)))
                for rpm in rpmlist:
                    rpm['tag']       = tag
                    rpm['filename']  = '%s-%s-%s.%s.rpm' % (rpm['name'], rpm['version'], rpm['release'], rpm['arch'])
                    rpm['name-arch'] = '%s-%s' % (rpm['name'], rpm['arch'])
                    result.append(rpm)
        return result

    def pattern_match(self, x, patternlist):
        '''
        determine if x matches some pattern from patternlist
        this function switches between glob and regex matching, depending on options
        '''

        # patternlist must be a list of patterns -> convert single pattern to a list
        if not isinstance(patternlist, list):
            patternlist = [patternlist]

        for pattern in patternlist:
            if self.options.regex:
            # use RE matching
                if re.compile(pattern).match(x):
                    return True
            else:
            # use glob matching
                if fnmatch.fnmatchcase(x, pattern):
                    return True

        # nothing matched
        return False

class SignUnsigned(CliTool, KojiTool):
    def __init__(self):
        CliTool.__init__(self)
        KojiTool.__init__(self)

        self.parser.add_option("--builds", action="store_true")
        self.parser.add_option("--exact", action="store_true")
        self.parser.add_option("--inherit", action="store_true")
        self.parser.add_option("--just-show", action="store_true") # deprecated
        self.parser.add_option("--just-write-rpms", action="store_true")
        self.parser.add_option("--level")
        self.parser.add_option("--server", action="store_true")
        self.parser.add_option("--test", action="store_true")
        self.parser.add_option("--show-time", action="store_true")
        self.parser.add_option("--workdir")
        self.parser.add_option("--write-rpms", action="store_true")
        self.gpg_keys = {'430A1C35': { 'name': 'spacewalk',
                          'description': 'Spacewalk <spacewalk-devel@redhat.com>',
                          'size': 1024 },
            }
        self.body_header_tags = ['siggpg', 'sigpgp']
        self.head_header_tags = ['dsaheader', 'rsaheader']


    def get_key_name(self, keyid):
        return self.gpg_keys[keyid.upper()]['name']

    def sig_level(self, sigs, level='spacewalk', exact=False):
        """Check if signature(s) satisfy required level"""

        orderings = [['spacewalk']]
        if not sigs:
             return False
        sigs = [ x for x in sigs if x ]
        if not sigs:
             return False
        for i in range(0, len(sigs)):
             try:
                  sigs[i] = self.get_key_name(sigs[i])
             except KeyError:
                  pass
        if exact:
            valid = [level]
        else:
            valid = None
            for ordering in orderings:
                if level in ordering:
                    valid = ordering[ordering.index(level):]
                    break
            if not valid:
                 #raise RuntimeError, "could not find level %s" % level
                 valid = [level]
        for lvl in valid:
             if lvl.lower() in sigs or lvl.upper() in sigs:
                  return True
        return False

    def find_uncached(self, rpms, level='rawhide'):
        """Return the rpms that do not have a cached signature of sufficient level"""
        ret = []
        self.print_debug("Reading signature data")
        sigdata = []
        self.koji_session.multicall = True
        for rinfo in rpms:
            self.koji_session.queryRPMSigs(rpm_id=rinfo['id'])
        results = self.koji_session.multiCall()
        for result in results:
            sigdata.extend(result[0])
        sig_idx = {}
        #index by rpm and sigkey
        self.print_debug("Indexing %d signatures" % len(sigdata))
        for row in sigdata:
            sig_idx.setdefault(row['rpm_id'], []).append(row['sigkey'])
        i = 0
        for rpminfo in rpms:
            i += 1
            self.print_debug("%d/%d: checking %s" % (i, len(rpms), self.rpm_nvra(rpminfo)))
            sigs = sig_idx.get(rpminfo['id'], [])
            self.print_debug("found sigs: %r" % sigs)
            if not self.sig_level(sigs, level=level):
                self.print_debug("uncached")
                ret.append(rpminfo)
        return ret

    def rpm_path(self, rpminfo):
        build = rpminfo['build']
        return os.path.join(koji.pathinfo.build(build), koji.pathinfo.rpm(rpminfo))

    def rpm_nvra(self, rpminfo):
        return "%(name)s-%(version)s-%(release)s.%(arch)s" % rpminfo

    def rip_sighdr(self, path):
        sigkey = ""
        sighdr = koji.rip_rpm_sighdr(path)
        rawhdr = koji.RawHeader(sighdr)
        sigpkt = rawhdr.get(koji.RPM_SIGTAG_GPG)
        if not sigpkt:
            sigpkt = rawhdr.get(koji.RPM_SIGTAG_PGP)
        if sigpkt:
            sigkey = koji.get_sigpacket_key_id(sigpkt)
        return sighdr, sigkey

    def write_sigs(self, rpmlist, sigkey):
        self.koji_session.multicall = True
        signable = False
        for rpminfo in rpmlist:
            x = os.path.join(koji.pathinfo.build(rpminfo['build']),
                             koji.pathinfo.signed(rpminfo, sigkey))
            if not os.path.exists(x):
                signable = True
                if self.options.test:
                    self.print_msg("Would have written: %s" % x)
                    continue
                self.koji_session.writeSignedRPM(rpminfo, sigkey)

        if signable:
            self.print_debug("Writing rpms...")
            results = self.koji_session.multiCall()

            for rpm, result in zip(rpmlist, results):
                if isinstance(result, dict):
                    print "Error writing out %s" % self.rpm_nvra(rpm)

    def write_sig(self, rpminfo, sigkey):
        x = os.path.join(koji.pathinfo.build(rpminfo['build']),
                         koji.pathinfo.signed(rpminfo, sigkey))
        if not os.path.exists(x):
            if self.options.test:
                self.print_msg("Would have written: %s" % x)
                return
            self.print_debug("Writing %s" % x)
            try:
                self.koji_session.writeSignedRPM(rpminfo, sigkey)
            except koji.KojiError, e:
                self.print_msg(e)

    def import_sig(self, rpminfo, sighdr, sigkey):
        previous = self.koji_session.queryRPMSigs(rpminfo['id'], sigkey=sigkey)
        if previous:
            sighash = md5.new(sighdr).hexdigest()
            if previous[0]['sighash'] != sighash:
                self.print_msg("Warning: signature hash mismatch: %s" % rpminfo)
            else:
                self.print_msg("Warning: signature already imported: %r" % previous)
        elif self.options.test:
            self.print_msg("Would have imported signature '%s' from %s" % (sigkey, self.rpm_nvra(rpminfo)))
        else:
            self.koji_session.addRPMSig(rpminfo['id'], base64.encodestring(sighdr))

    def import_sigs(self, importdict, sigkey):
        self.koji_session.multicall = True
        for rpm in importdict.keys():
            if self.options.test:
                self.print_msg("Would have imported signature '%s' from %s" % (sigkey, importdict[rpm][2]))
            else:
                self.koji_session.addRPMSig(rpm, base64.encodestring(importdict[rpm][0]))

        self.koji_session.multiCall()

    def get_key_id(self, keyname):
         for id, data in self.gpg_keys.items():
              if keyname.lower() in (data.get('name', ""), data.get('signing_server_id', "")):
                   return id

    def import_sig_from_files(self, rpminfos, level, workdir):
        importdict = {}
        # Verify that sigs are correct
        for rpm in rpminfos:
            src = self.rpm_path(rpm)
            fn = "%s.rpm" % self.rpm_nvra(rpm)
            path = "%s/%s" % (workdir, fn)
            sighdr, sigkey = self.rip_sighdr(path)
            if self.get_key_id(level).lower() != sigkey.lower():
                self.print_msg("Error: unexpected signature key [%s], skipping import from %s" % (sigkey, path))
                continue
            importdict[rpm['id']] = (sighdr, sigkey.lower(), self.rpm_nvra(rpm))
        self.import_sigs(importdict, self.get_key_id(level).lower())

    def import_sig_from_file(self, rpminfo, path=None, level=None):
        if path is None:
            path = self.rpm_path(rpminfo)
        sighdr, sigkey = self.rip_sighdr(path)
        if level is not None:
            #verify that signature is what we expect
            if self.get_key_id(level).lower() != sigkey.lower():
                self.print_msg("Error: unexpected signature key [%s], skipping import from %s" % (sigkey, path))
                return
        self.import_sig(rpminfo, sighdr, sigkey)

    def try_import(self, rpms, level='rawhide'):
        """See if the main copy of the rpm has the signature we need

        If sufficient signature is found, it is imported
        Returns the rpms still without needed signature
        """
        ret = []
        for rpminfo in rpms:
            path = self.rpm_path(rpminfo)
            sighdr, sigkey = self.rip_sighdr(path)
            self.print_debug("Current sig '%s' for %s" % (sigkey,  path))
            if self.sig_level([sigkey], level=level):
                #key is sufficient, import it
                self.import_sig(rpminfo, sighdr, sigkey)
            else:
                ret.append(rpminfo)
        return ret

    def get_key_id(self, keyname):
         for id, data in self.gpg_keys.items():
              if keyname.lower() in (data.get('name', ""), data.get('signing_server_id', "")):
                   return id

    def get_key_description(self, keyid):
        return self.gpg_keys.get(keyid.upper(), {}).get('description')

    def get_signing_command(self, key, paths, server=False):
         keyid = self.get_key_id(key)
         if server:
              ssid = self.gpg_keys[keyid].get('signing_server_id')
              if not ssid:
                   raise RuntimeError, "%s is not set up for the signing server" % key
              cmd = "rpm-sign --key=%s %s" % (ssid, ' '.join(paths))
         else:
              if self.gpg_keys[keyid]['size'] == 4096:
                  cmd = """rpm --define '__gpg_sign_cmd %%{__gpg} gpg --force-v3-sigs --digest-algo sha256 --batch --no-verbose --no-armor --passphrase-fd 3 --no-secmem-warning -u "%%{_gpg_name}" -sbo %%{__signature_filename} %%{__plaintext_filename}' --define '_gpg_name %s' --define '_signature gpg' --resign %s"""  % (self.get_key_description(keyid), ' '.join(paths))
              else:
                  cmd = "rpm --define '_gpg_name %s' --define '_signature gpg' --resign %s"  % (self.get_key_description(keyid), ' '.join(paths))
         return cmd

    def do_signing(self, pathargs, level):
        """Use rpm to sign packages"""
        mypaths = list(pathargs)
        while len(mypaths):
            if self.options.server:
                nlen = 25
            else:
                nlen = 1000
            cmd = self.get_signing_command(level, mypaths[:nlen], server=self.options.server)
            del mypaths[:nlen]
            if self.options.test:
                self.print_msg("would have run: %s" % cmd)
            else:
                self.print_debug("Running: %s" % cmd)
                # loop in case password is mistyped
                while os.system(cmd):
                    # sleep briefly (give user a chance to ctrl-C)
                    time.sleep(2)

    def sign_to_cache(self, rpms, level):
        """Sign and cache the signatures

        We sign duplicate copies and import the signature headers. The original rpms
        remain unchanged.
        """
        if not rpms:
            self.print_debug("No unsigned rpms")
            if not self.options.write_rpms:
                return
        if self.options.test:
            self.print_msg("Would have signed:")
            for rpminfo in rpms:
                self.print_msg(self.rpm_nvra(rpminfo))
        workdir = tempfile.mkdtemp(prefix='sign_unsigned.', dir=self.options.workdir)
        self.print_debug("Using workdir: %s" % workdir)
        self.print_debug("Copying packages")
        pkglist = []
        for rpminfo in rpms:
            src = self.rpm_path(rpminfo)
            fn = "%s.rpm" % self.rpm_nvra(rpminfo)
            dst = "%s/%s" % (workdir, fn)
            if not self.options.test:
                shutil.copyfile(src, dst)
            pkglist.append(dst)
        self.print_debug("Signing copies")
        self.do_signing(pkglist, level)
        if self.options.test:
            return
        self.print_msg("Importing signatures")
        self.import_sig_from_files(rpms, level, workdir)
        if self.options.write_rpms:
            self.print_msg("Writing RPMs")
            self.write_sigs(rpms, self.get_key_id(level).lower())
        #clean up
        for fn in os.listdir(workdir):
            path = "%s/%s" % (workdir,fn)
            os.unlink(path)
        os.rmdir(workdir)

    def get_build_rpms(self, builds):
        ret = []
        self.koji_session.multicall = True
        for b in builds:
            self.koji_session.getBuild(b, strict=True)
        binfos = self.koji_session.multiCall()
        self.koji_session.multicall = True
        for binfo in binfos:
            self.koji_session.listRPMs(buildID=binfo[0]['id'])
        results = self.koji_session.multiCall()
        for binfo, rpms in zip(binfos, results):
            for r in rpms[0]:
                r['build'] = binfo[0]
            ret.extend(rpms[0])
        return ret

    def get_koji_rpms(self, tag, pkg=None):
        rpms, builds = self.koji_session.listTaggedRPMS(tag, latest=True, inherit=self.options.inherit, package=pkg)
        build_idx = {}
        for build in builds:
            build['name'] = build['package_name']
            build_idx[build['id']] = build
        for rpminfo in rpms:
            rpminfo['build'] = build_idx[rpminfo['build_id']]
        return rpms

    def is_fedora(self, tag):
        if tag.startswith('dist-fc') or tag.startswith('f'):
            return True
        return False

    def tweak_options(self):
        if self.options.just_show:
            self.options.test = True
        if self.options.builds:
            self.options.builds = self.options.options
            if not self.options.level:
                self.parser.error("--level required unless a tag is specified")
        else:
            args = self.options.options
            if len(args) < 1 or len(args) > 2:
                self.parser.error("incorrect number of arguments")
            if len(args) == 2:
                self.options.pkg = args[1]
            else:
                self.options.pkg = None
            self.options.tag = args[0]
            if not self.options.level:
                if self.is_fedora(self.options.tag):
                    self.options.level = 'fedora-gold'
                else:
                    self.options.level = 'gold'

    def cmd_default(self):
        self.tweak_options()
        clientcert = os.path.join(os.path.expanduser('~'), ".spacewalk.cert")
        clientca = os.path.join(os.path.expanduser('~'), ".spacewalk-ca.cert")
        serverca = os.path.join(os.path.expanduser('~'), ".spacewalk-ca.cert")
        self.koji_session.ssl_login(clientcert, clientca, serverca) # NEEDSWORK
        self.print_msg("Getting rpm list from koji")
        if self.options.builds:
            rpms = self.get_build_rpms(self.options.builds)
        else:
            rpms = self.get_koji_rpms(self.options.tag, self.options.pkg)
        rpms.sort(lambda a,b: cmp(a['name'], b['name']))
        self.print_debug("got %d rpms" % len(rpms))
        if self.options.just_write_rpms:
            sigkey = self.get_key_id(self.options.level).lower()
            self.write_sigs(rpms, sigkey)
        else:
            self.print_debug("Checking cached signatures")
            uncached = self.find_uncached(rpms, level=self.options.level)
            #because we're in transition, some rpms may be signed, but not have that signature cached
            #self.print_debug("Checking for uncached signatures (%d rpms)" % len(uncached))
            #unsigned = self.try_import(uncached, level=self.options.level)
            self.print_debug("Signing to cache (%d rpms)" % len(uncached))
            self.sign_to_cache(uncached, self.options.level)

if __name__ == '__main__':
    x = SignUnsigned()
    x.process_cmd_options()
    x.create_koji_session()
    x.run_command()
    x.close_koji_session()


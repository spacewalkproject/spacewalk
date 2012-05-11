#
# Copyright (c) 2008--2011 Red Hat, Inc.
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
import string

import local_config
import rhn_log
import utils
import cfg_exceptions
from urlparse import urlsplit

try:
    from socket import gaierror
except:
    from socket import error
    gaierror = error

from ConfigParser import InterpolationError

sys.path.append('/usr/share/rhn')
from up2date_client import config

class BaseMain:
    modes = []
    repository_class_name = "Repository"
    plugins_dir = 'config_common'
    mode_prefix = None
    config_section = None

    def usage(self, exit_code):
        print "Usage: %s MODE [ --server-name name ] [ params ]" % sys.argv[0]
        print "Valid modes are:"
        for mode in self.modes:
            print "\t%s" % mode
        sys.exit(exit_code)

    def main(self):
        args = []

        show_help = None
        debug_level = 3
        mode = None
        server_name = None
        server_name_opt = "--server-name"
        needs_server_name = 0
        for arg in sys.argv[1:]:
            if needs_server_name:
                server_name = arg
                needs_server_name = 0
                continue

            if arg in ('--help', '-h'):
                show_help = 1
                continue

            if arg.startswith(server_name_opt):
                rarg = arg[len(server_name_opt):]
                if not rarg:
                    needs_server_name = 1
                    continue
                if rarg[0] == '=':
                    server_name = rarg[1:]
                    continue
                print "Unknown option %s" % arg
                return 1

            if mode is None:
                # This should be the mode
                mode = arg
                if mode == '':
                    # Bad
                    self.usage(1)

                if mode[0] == '-':
                    # Mode can't be an option
                    self.usage(1)

                if mode not in self.modes:
                    print "Unknown mode %s" % mode
                    self.usage(1)

                continue

            args.append(arg)

        if needs_server_name:
            print "No argument specified to %s" % server_name_opt
            return 1

        rhn_log.set_debug_level(debug_level)

        if mode is None:
            # No args were specified
            self.usage(0)

        execname = os.path.basename(sys.argv[0])
        # Class names cannot have dot in them, so strip the extension
        execname = string.split(execname, '.', 1)[0]

        mode_module = string.replace(mode, '-', '_')
        module_name = "%s_%s" % (self.mode_prefix, mode_module)
        full_module_name = "%s.%s" % (self.plugins_dir, module_name)

        try:
            module = __import__(full_module_name)
        except ImportError, e:
            rhn_log.die(1, "Unable to load plugin for mode '%s': %s" % (mode, e))

        module = getattr(module, module_name)

        if show_help:
            # Display the per-module help
            handler = module.Handler(args, None, mode=mode, exec_name=execname)
            handler.usage()
            return 0

        cfg = config.initUp2dateConfig()
        up2date_cfg = dict(cfg.items())

        if server_name:
            local_config.init(self.config_section, defaults=up2date_cfg, server_name=server_name)
        else:
            local_config.init(self.config_section, defaults=up2date_cfg)

            try:
                server_name = local_config.get('server_url')
            except InterpolationError, e:
                if e.option == 'server_url':
                    server_name = config.getServerlURL()
                    up2date_cfg['proto'] = urlsplit(server_name[0])[0]
                    if up2date_cfg['proto'] == '':
                        up2date_cfg['proto'] = 'https'
                        up2date_cfg['server_list'] = map(lambda x: urlsplit(x)[2], server_name)
                    else:
                        up2date_cfg['server_list'] = map(lambda x: urlsplit(x)[1], server_name)
                    server_name = (up2date_cfg['server_list'])[0]
                    local_config.init(self.config_section, defaults=up2date_cfg, server_name=server_name)

        print "Using server name", server_name

        # set the debug level through the config
        rhn_log.set_debug_level(int(local_config.get('debug_level') or 0))
        rhn_log.set_logfile(local_config.get('logfile') or "/var/log/rhncfg")

        # Multi-level import - __import__("foo.bar") does not return the bar
        # module, but the foo module with bar loaded
        # XXX Error checking
        repo_class = local_config.get('repository_type')
        if repo_class is None:
            rhn_log.die(1, "repository_type not set (missing configuration file?)")

        repo_module_name = "%s.%s" % (self.plugins_dir, repo_class)
        try:
            repo_module = __import__(repo_module_name)
        except ImportError, e:
            rhn_log.die(1, "Unable to load repository module:  %s" % e)

        try:
            repo_module = getattr(repo_module, repo_class)
        except AttributeError:
            rhn_log.die(1, "Malformed repository module")

        try:
            repo = getattr(repo_module, self.repository_class_name)()
        except AttributeError:
            rhn_log.die(1, "Missing repository class")
        except InterpolationError, e:
            if e.option == 'server_url':
                #pkilambi: bug#179367# backtic is replaced with single quote
                rhn_log.die(1, "Missing 'server_url' configuration variable; please refer to the config file")
            raise
        except cfg_exceptions.ConfigurationError, e:
            rhn_log.die(e)
        except gaierror, e:
            print "Socket Error: %s" % (e.args[1],)
            sys.exit(1)

        handler = module.Handler(args, repo, mode=mode, exec_name=execname)
        try:
            handler.authenticate()
            handler.run()
        except cfg_exceptions.AuthenticationError, e:
            rhn_log.die(1, "Authentication failed: %s" % e)
        except Exception, e:
            raise
        repo.cleanup()
        return 0

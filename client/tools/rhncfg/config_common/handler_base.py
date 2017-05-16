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

import sys
import getpass
from optparse import OptionParser, Option

from config_common import rhn_log
from config_common import cfg_exceptions
from config_common import local_config
from rhn.i18n import bstr

class HandlerBase:
    _options_table = []
    _option_parser_class = OptionParser
    _usage_options = "[options]"
    _option_class = Option
    def __init__(self, args, repository, mode=None, exec_name=None):
        self.repository = repository
        self.set_mode(mode)
        self.set_exec_name(exec_name)
        self.options, self.args = self._parse_args(args)

    def set_mode(self, mode):
        self.mode = mode

    def set_exec_name(self, exec_name):
        self.exec_name = exec_name

    def _prog(self):
        return "%s %s" % (sys.argv[0], self.mode or "<unknown>")

    def _parse_args(self, args):
        # Parses the arguments and returns a tuple (options, args)
        usage = " ".join(["%prog", self.mode, self._usage_options])
        self._parser = self._option_parser_class(
            option_list=self._options_table,
            usage=usage)
        return self._parser.parse_args(args)

    def usage(self):
        return self._parser.print_help()

    def authenticate(self, username=None, password=None):
        # entry point for repository authentication

        try:
            self.repository.login()
        except cfg_exceptions.InvalidSession:
            if not username :
                username=local_config.get('username')
            if not password :
                password=local_config.get('password')

            if not password :
                (username, password) = self.get_auth_info(username)
            try:
                self.repository.login(username=username, password=password)
            except cfg_exceptions.InvalidSession:
                e = sys.exc_info()[1]
                rhn_log.die(1, "Session error: %s\n" % e)

    def get_auth_info(self, username=None):
        if username is None:
            username = self._read_username()

        password = getpass.getpass()

        return (username, password)

    def _read_username(self):
        tty = open("/dev/tty", "rb+", buffering=0)
        tty.write(bstr("Username: "))
        try:
            username = tty.readline()
        except KeyboardInterrupt:
            tty.write(bstr("\n"))
            sys.exit(0)
        if username is None:
            # EOF
            tty.write(bstr("\n"))
            sys.exit(0)
        return username.strip()


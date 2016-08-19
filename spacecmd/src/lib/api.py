#
# Licensed under the GNU General Public License Version 3
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# Copyright 2011 Satoru SATOH <ssato@redhat.com>
#

# wildcard import
# pylint: disable=W0401,W0614

# unused argument
# pylint: disable=W0613

from optparse import Option
import logging
import sys
import xmlrpclib
from spacecmd.utils import *


def help_api(self):
    print 'api: call RHN API with arguements directly'
    print '''usage: api [options] API_STRING

options:
  -A, --args  Arguments for the API other than session id in comma separated
              strings or JSON expression
  -F, --format   Output format
  -o, --output   Output file

examples:
  api api.getApiCallList
  api --args "sysgroup_A" systemgroup.listSystems
  api -A "rhel-i386-server-5,2011-04-01,2011-05-01" -F "%(name)s" \\
      channel.software.listAllPackages
'''


def do_api(self, args):
    options = [Option('-A', '--args', default=''),
               Option('-F', '--format', default=''),
               Option('-o', '--output', default='')]

    (args, options) = parse_arguments(args, options)

    if not args:
        self.help_api()
        return

    api_name = args[0]
    api_args = parse_api_args(options.args)

    if options.output:
        try:
            output = open(options.output, "w")
        except IOError:
            logging.warn("Could not open to write: " + options.output)
            logging.info("Fallback output to stdout")

            output = sys.stdout
    else:
        output = sys.stdout

    api = getattr(self.client, api_name, None)

    if not callable(api):
        logging.warn("No such API: " + api_name)
        return

    try:
        res = api(self.session, *api_args)

        if not isinstance(res, list):
            res = [res]

        if options.format:
            for r in res:
                output.write(options.format % r + "\n")
        else:
            json_dump(res, output, indent=2)

        if (output != sys.stdout):
            output.close()

    except xmlrpclib.Fault:
        if (output != sys.stdout):
            output.close()

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

from optparse import OptionParser, Option

#Not strictly necessary, but makes them easier to type
option_parser = OptionParser
option = Option

class UI:
    def __init__(self):
        self.optiontable =  [ 
            option("-d",    "--dir",                    action="store",     
                help="This is the directory that the information that you want to sync gets dumped in."),
            option(         "--hard-links",             action="store_true",        default=0,
                help="Exported RPM and kickstart are hard linked to original files."),
            option(         "--list-channels",          action="store_true",    default=0,  
                help="List all of the channels that can be exported."),
            option(         "--list-steps",             action="store_true",    default=0,
                help="List all of the steps that rhn-satellite-exporter takes while exporting data. These can be used as values for --step"),
            option("-c",    "--channel",                action="append",
                help="Include this channel in the export."),
            option("-a",    "--all-channels",            action="store_true",    default=0,
                help="Export all channels."),
	    option(         "--start-date",             action="store",
	        help="The start date limit that the last modified dates are compared against. Should be in the format 'YYYYMMDDHH24MISS'."),
	    option(         "--end-date",                action="store",
	        help="The end date limit that the last modified dates are compared against. Should be in the format 'YYYYMMDDHH24MISS'."),
	    option(         "--use-rhn-date",            action="store_true",
	        help="Limit exported packages according to the date when they appeared at Red Hat Network."),
	    option(         "--use-sync-date",            action="store_true",
	        help="Limit exported packages according to the date they where pulled into satellite."),
        option(         "--whole-errata",            action="store_true",
            help="Always include package if it belongs to errata which is withing start/end-date range."),
	    option(         "--make-isos",               action="store",
	        help="Create channel dump isos a directory called satellite-isos. Usage: --make-isos=cd or dvd"),
            option("-p",    "--print-configuration",    action="store_true",    default=0,
                help="Print the configuration and exit."),
            option(         "--print-report",           action="store_true",    default=0,
                help="Print the report to the terminal when the export is complete."),
            option(         "--step",                   action="store",
                help="Export only up to this step."),
            option(         "--no-rpms",                action="store_true",
                help="Do not export RPMs."),
            option(         "--no-packages",            action="store_true",
                help="Do not export package metadata."),
            option(         "--no-errata",              action="store_true",
                help="Do not export errata data."),
            option(         "--no-kickstarts",          action="store_true",
                help="Do not export kickstart data."),
            option(         "--debug-level",            action="store",
                help="Set the debug level to this value. Overrides the value in rhn.conf."),
             option("-v",   "--verbose",                action="store_true",
                help="Set debug level to 3. Overrides the value in rhn.conf.."),
            option(         "--email",                  action="store_true",
                help="Email a report of what was exported."),
            option(         "--traceback-mail",        action="store",
                help="Alternative email address for --email."),
            option(         "--db",                     action="store",
                help="Connect to this database."),   
                            ]
        self.optionparser = option_parser(option_list=self.optiontable)
        self.options, self.args = self.optionparser.parse_args()
        if self.options.verbose and not self.options.debug_level:
            self.options.debug_level=3
         
        for i in self.options.__dict__.keys():
            if not self.__dict__.has_key(i):
                self.__dict__[i] = self.options.__dict__[i]

if __name__ == "__main__":
    a = UI() 
    print str(a.no_errata)

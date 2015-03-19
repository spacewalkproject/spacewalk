#
# Copyright (c) 2008--2015 Red Hat, Inc.
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

use strict;
package Dobby::Log;
use Fcntl;
use POSIX qw/strftime/;

sub log {
  my $class = shift;

  my $fh = $class->fetch_logger;

  my $str = (@_ > 1 ? sprintf @_ : $_[0]);
  $str .= "\n" unless $str =~ /\n$/;

  $str = strftime("[%a %b %d %H:%M:%S %Y]", localtime time) . " $str";
  print $fh $str;
}

my $global_fh;
my $global_logfile = "/var/log/rhn/rhn_database.log";

sub fetch_logger {
  my $class = shift;

  if (not defined $global_fh) {
    sysopen $global_fh, "$global_logfile", O_WRONLY | O_APPEND | O_CREAT
      or die "open $global_logfile: $!";
  }

  return $global_fh;
}

1;

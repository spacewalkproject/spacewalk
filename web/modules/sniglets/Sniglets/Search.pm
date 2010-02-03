#
# Copyright (c) 2008--2009 Red Hat, Inc.
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
package Sniglets::Search;

use Sniglets::Packages;

use RHN::SearchTypes;
use RHN::Server;
use PXT::Utils;

my @integer_types = qw/search_id search_cpu_mhz_lt search_cpu_mhz_gt search_ram_lt search_ram_gt search_checkin search_registered/;

# Utility functions

sub strip_rpm_extensions { #strips the extensions off of an rpm file name
#e.g. 'kernel-2.2-19.i686.rpm' becomes 'kernel-2.2-19'

  my $string = shift;

  my @archs = sort { length($b) <=> length($a) } RHN::Package->valid_package_archs;
  my $rxp = join "|", map { ".$_" } @archs, 'rpm';
  $rxp = qr/$rxp/;
  $string =~ s/$rxp//g;

  return $string;

}

sub strip_invalid_chars {
  my $class = shift;
  my $search_string = shift;
  my $view_mode = shift;

  if ($view_mode =~ /package/) {
    $search_string = strip_rpm_extensions($search_string);
  }

  if (grep { $view_mode eq $_ } @integer_types) {
    $search_string =~ s/\D//g;
  }

  return $search_string;
}

1;

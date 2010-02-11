#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

package Sniglets::ListView::ProfileList;

use Sniglets::ListView::List;
use RHN::DataSource::Simple;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:profile_list_cb";
}

sub _register_modes {
  Sniglets::ListView::List->add_mode(-mode => "profile_overview",
				     -datasource => new RHN::DataSource::Simple(-querybase => "profile_queries"));

  Sniglets::ListView::List->add_mode(-mode => "profile_package_overview",
				     -datasource => new RHN::DataSource::Simple(-querybase => "profile_queries"));
}


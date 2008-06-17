#
# Copyright (c) 2008 Red Hat, Inc.
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


# represents packages on servers.  we only know nvre about these things, apparently...

use strict;

package RHN::ServerPackage;

use RHN::DB::ServerPackage;

# given a server id, spit back the entire list of packages on a server...
sub package_list_by_server {
  my $class = shift;

  return RHN::DB::ServerPackage->package_list_by_server(@_);
}

# given a server id and package group, spit back the list of packages on a server in a package group...
sub package_list_by_group_by_server {
  my $class = shift;

  return RHN::DB::ServerPackage->package_list_by_group_by_server(@_);
}

sub package_list_by_server_overview {
  my $class = shift;

  return RHN::DB::ServerPackage->package_list_by_server_overview(@_);
}

1;

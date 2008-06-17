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

use strict;
package Cypress::Search;
use Grail::Component;

@Cypress::Search::ISA = qw/Grail::Component/;

# sigh.  because of the stuff we're doing w/ parameters, there's almost no sense
# in having multiple modes.  :(
my @component_modes =
  (
   [ 'server_search', 'server_search', undef, undef ],
   [ 'user_search', 'user_search', undef, undef ],
   [ 'package_install_search', 'package_install_search', undef, undef ],
   [ 'package_removal_search', 'package_removal_search', undef, undef ],
#   [ 'errata_search', 'errata_search', undef, undef ],
  );

sub component_modes {
  return @component_modes;
}

sub server_search {
  my $self = shift;
  my $pxt = shift;

  return $pxt->include('/network/components/search/server_search.pxi');
}

sub user_search {
  my $self = shift;
  my $pxt = shift;

  return $pxt->include('/network/components/search/user_search.pxi');
}

sub package_install_search {
  my $self = shift;
  my $pxt = shift;

  return $pxt->include('/network/components/search/package_install_search.pxi');
}

sub package_removal_search {
  my $self = shift;
  my $pxt = shift;

  return $pxt->include('/network/components/search/package_removal_search.pxi');
}


#sub errata_search {
#  my $self = shift;
#  my $pxt = shift;
#
#  return $pxt->include('/network/components/search/errata_search.pxi');
#}

1;

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
package Cypress::Package;
use Grail::Component;

@Cypress::Package::ISA = qw/Grail::Component/;


# the search modes ought to be pushed to the search component i think...
my @component_modes =
  (

   # this segment is where I'm starting to do the newer, better Cypress coding
#   [ 'details', 'details', undef, undef ],
#   [ 'dependencies', 'dependencies', undef, undef ],
#   [ 'change_log', 'change_log', undef, undef ],
#   [ 'file_list', 'file_list', undef, undef ],
#   [ 'system_list', 'system_list', undef, undef ],


   # older stuff that should eventually be pushed to other components
   [ 'package_list', 'package_list', undef, undef ],
   [ 'package_installable_search_list', 'package_installable_search_list', undef, undef ],
   [ 'package_installable_list', 'package_installable_list', undef, undef ],
#   [ 'package_installable_list_no_search', 'package_installable_list_no_search', undef, undef ],
   [ 'package_removable_list', 'package_removable_list', undef, undef ],
   [ 'package_removal_search_list', 'package_removal_search_list', undef, undef ]
  );

sub component_modes {
  return @component_modes;
}


sub package_list {
  my $self = shift;
  my $pxt = shift;

  return $pxt->include('/network/components/packages/package_list.pxi');
}

sub package_installable_search_list {
  my $self = shift;
  my $pxt = shift;

  $pxt->context(package_installable_list_view_mode => 'search_set');
  $pxt->context(package_installable_list_view_mode_param => 'package_install_search');
  return $pxt->include('/network/components/packages/installable_package_list.pxi');
}

sub package_installable_list {
  my $self = shift;
  my $pxt = shift;

  $pxt->context(package_installable_list_view_mode => 'set');
  $pxt->context(package_installable_list_view_mode_param => 'package_installable_list');
  return $pxt->include('/network/components/packages/installable_package_list.pxi');
}

#sub package_installable_list_no_search {
#  my $self = shift;
#  my $pxt = shift;
#
#  $pxt->context(package_installable_list_view_no_search => 1);
#  $pxt->context(package_installable_list_view_mode => 'set');
#  $pxt->context(package_installable_list_view_mode_param => 'package_installable_list');
#  return $pxt->include('/network/components/packages/installable_package_list.pxi');
#}

sub package_removable_list {
  my $self = shift;
  my $pxt = shift;

  $pxt->context(package_removable_list_view_mode => 'set');
  $pxt->context(package_removable_list_view_mode_param => 'package_removable_list');
  return $pxt->include('/network/components/packages/removable_package_list.pxi');
}

sub package_removal_search_list {
  my $self = shift;
  my $pxt = shift;

  $pxt->context(package_removable_list_view_mode => 'search_set');
  $pxt->context(package_removable_list_view_mode_param => 'package_removal_search');
  return $pxt->include('/network/components/packages/removable_package_list.pxi');
}

1;

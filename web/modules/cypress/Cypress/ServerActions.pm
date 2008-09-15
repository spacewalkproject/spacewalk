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
package Cypress::ServerActions;
use Grail::Component;

use Carp;

@Cypress::ServerActions::ISA = qw/Grail::Component/;

my @component_modes =
  (
   [ 'servergroup_add_remove', 'add_remove_servers_to_groups', undef, undef ],
   [ 'system_set_package_set_actions', 'system_set_package_set_actions', undef, undef],
   [ 'system_set_errata_set_actions', 'system_set_errata_set_actions', undef, undef],
   [ 'package_install_details', 'package_install_details', undef, undef ],
   [ 'package_install_package_list', 'package_install_package_list', undef, undef ],
   [ 'package_install_system_list', 'package_install_system_list', undef, undef ],
   [ 'package_removal_details', 'package_removal_details', undef, undef ],
   [ 'package_removal_package_list', 'package_removal_package_list', undef, undef ],
   [ 'package_removal_system_list', 'package_removal_system_list', undef, undef ],
   [ 'errata_update_details', 'errata_update_details', undef, undef ],
   [ 'errata_update_errata_list', 'errata_update_errata_list', undef, undef ],
   [ 'errata_update_system_list', 'errata_update_system_list', undef, undef ]
  );

sub component_modes {
  return @component_modes;
}

sub add_remove_servers_to_groups {
  my $self = shift;
  my $pxt = shift;

  my $user = $pxt->user;

  # what are the rules about adding/removing servers to a group?
  croak "attempt to add/remove servers from servergroups by a non-orgadmin " unless $user->is('org_admin');

  return $pxt->include('/network/components/systemactions/system_set_group_assign.pxi');
}

# speedy interface when you have a set of systems and a set of packages...
sub system_set_package_set_actions {
  my $self = shift;
  my $pxt = shift;

  # hrm.  what priviledge checking should we do here?

  return $pxt->include('/network/components/systemactions/system_set_package_set_actions.pxi');
}

# speedy interface when you have a set of systems and a set of packages...
sub system_set_errata_set_actions {
  my $self = shift;
  my $pxt = shift;

  # hrm.  what priviledge checking should we do here?

  return $pxt->include('/network/components/systemactions/system_set_errata_set_actions.pxi');
}

sub package_install_details {
  my $self = shift;
  my $pxt = shift;


  return $pxt->include('/network/components/systemactions/package_install_details.pxi');
}

sub package_install_package_list {
  my $self = shift;
  my $pxt = shift;

  # faking out the ServerList sniglet.  woot!
  $pxt->context(package_installable_list_view_mode => 'install_action');
  $pxt->context(package_installable_list_view_mode_param => $pxt->param('aid'));
  return $pxt->include('/network/components/systemactions/package_install_package_list.pxi');
}

sub package_install_system_list {
  my $self = shift;
  my $pxt = shift;

  # faking out the ServerList sniglet.  woot!
  $pxt->context(system_list_view_mode => 'action');
  $pxt->context(system_list_view_mode_param => $pxt->param('aid'));

  return $pxt->include('/network/components/systemactions/package_install_system_list.pxi');
}

sub package_removal_details {
  my $self = shift;
  my $pxt = shift;


  return $pxt->include('/network/components/systemactions/package_removal_details.pxi');
}

sub package_removal_package_list {
  my $self = shift;
  my $pxt = shift;

  # faking out the ServerList sniglet.  woot!
  $pxt->context(package_removable_list_view_mode => 'remove_action');
  $pxt->context(package_removable_list_view_mode_param => $pxt->param('aid'));
  return $pxt->include('/network/components/systemactions/package_removal_package_list.pxi');
}

sub package_removal_system_list {
  my $self = shift;
  my $pxt = shift;

  # faking out the ServerList sniglet.  woot!
  $pxt->context(system_list_view_mode => 'action');
  $pxt->context(system_list_view_mode_param => $pxt->param('aid'));

  return $pxt->include('/network/components/systemactions/package_removal_system_list.pxi');
}

sub errata_update_details {
  my $self = shift;
  my $pxt = shift;


  return $pxt->include('/network/components/systemactions/errata_update_details.pxi');
}

sub errata_update_errata_list {
  my $self = shift;
  my $pxt = shift;

  $pxt->context(errata_list_view_mode => 'action');
  $pxt->context(errata_list_view_mode_param => $pxt->param('aid'));

  #return $pxt->include('/network/components/errata/errata_list.pxi');
  return $pxt->include('/network/components/systemactions/errata_update_errata_list.pxi');
}

sub errata_update_system_list {
  my $self = shift;
  my $pxt = shift;

  # faking out the ServerList sniglet.  woot!
  $pxt->context(system_list_view_mode => 'action');
  $pxt->context(system_list_view_mode_param => $pxt->param('aid'));

  return $pxt->include('/network/components/systemactions/errata_update_system_list.pxi');
}

1;

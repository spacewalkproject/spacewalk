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
package Cypress::ServerGroupList;
use Grail::Component;

@Cypress::ServerGroupList::ISA = qw/Grail::Component/;

my @component_modes =
  (
   [ 'sgroups_in_org_full', 'sgroups_in_org_full', undef, undef ],
   [ 'sgroups_in_org_partial', 'sgroups_in_org_partial', 'System Group List Summary', undef ],
   [ 'groups_for_a_server', 'groups_for_a_server', undef, undef ],
   [ 'groups_for_a_user_group', 'groups_for_a_user_group', undef, undef ],
   [ 'groups_for_a_user', 'groups_for_a_user', undef, undef ],
   [ 'sgroups_in_org_no_header', 'sgroups_in_org_no_header', undef, undef],
   [ 'sgroups_set_no_header', 'sgroups_set_no_header', undef, undef]
  );

sub component_modes {
  return @component_modes;
}

sub groups_for_a_user_group {
  my $self = shift;
  my $pxt = shift;

  $pxt->context(server_group_list_view_mode => 'ugroup');
  $pxt->context(server_group_list_view_mode_param => $pxt->param('ugid'));
  return $pxt->include('/network/components/systemgroups/system_group_list_no_header.pxi');
}

sub sgroups_set_no_header {
  my $self = shift;
  my $pxt = shift;

  $pxt->context(server_group_list_view_mode => 'set');
  $pxt->context(server_group_list_view_mode_param => 'server_group_list');
  return $pxt->include('/network/components/systemgroups/system_group_list_no_header.pxi');
}

sub groups_for_a_user {
  my $self = shift;
  my $pxt = shift;

  $pxt->context(server_group_list_view_mode => 'user');
  $pxt->context(server_group_list_view_mode_param => $pxt->param('uid'));
  return $pxt->include('/network/components/systemgroups/system_group_list_no_header.pxi');
}

sub sgroups_in_org_no_header {
  my $self = shift;
  my $pxt = shift;

  return $pxt->include('/network/components/systemgroups/system_group_list_no_header.pxi');
}

sub sgroups_in_org_full {
  my $self = shift;
  my $pxt = shift;

  return guts($pxt);
}

sub sgroups_in_org_partial {
  my $self = shift;
  my $pxt = shift;

  # this is going to the ServerList sniglet...
  $pxt->context(server_group_lower => 1);
  $pxt->context(server_group_upper => 5);

  return windowed_guts($pxt);
}

sub groups_for_a_server {
  my $self = shift;
  my $pxt = shift;

  return guts($pxt);
}

sub guts {
  my $pxt = shift;
  return  $pxt->include("/network/components/systemgroups/system_group_list.pxi");
}

sub windowed_guts {
  my $pxt = shift;
  return $pxt->include("/network/components/systemgroups/system_group_list_partial.pxi");
}

1;

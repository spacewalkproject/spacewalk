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
package Cypress::UserGroupList;
use Grail::Component;

@Cypress::UserGroupList::ISA = qw/Grail::Component/;

my @component_modes =
  (
   [ 'user_group_list', 'ugroups_in_org', undef, undef ],
   [ 'user_group_list_windowed', 'ugroups_in_org_partial', 'User Group List Summary', undef ],
   [ 'groups_for_a_user', 'groups_for_a_user', undef, undef ],
   [ 'ugroups_in_org_no_header', 'ugroups_in_org_no_header', undef, undef],
   [ 'ugroups_set_no_header', 'ugroups_set_no_header', undef, undef]
  );

sub component_modes {
  return @component_modes;
}

sub ugroups_set_no_header {
  my $self = shift;
  my $pxt = shift;

  $pxt->context(user_group_list_view_mode => 'set');
  $pxt->context(user_group_list_view_mode_param => 'user_group_list');
  return $pxt->include('/network/components/usergroups/user_group_list_no_header.pxi');
}

sub ugroups_in_org_no_header {
  my $self = shift;
  my $pxt = shift;

  return $pxt->include('/network/components/usergroups/user_group_list_no_header.pxi');
}


sub ugroups_in_org {
  my $self = shift;
  my $pxt = shift;

  return guts($pxt);
}

sub ugroups_in_org_partial {
  my $self = shift;
  my $pxt = shift;

  # this is going to the UserList sniglet...
  $pxt->context(user_group_lower => 1);
  $pxt->context(user_group_upper => 5);

  return windowed_guts($pxt);
}

sub groups_for_a_user {
  my $self = shift;
  my $pxt = shift;

  $pxt->context(user_group_list_view_mode => 'user');
  $pxt->context(user_group_list_view_mode_param => $pxt->param('uid'));
  return $pxt->include('/network/components/usergroups/user_group_list_no_header.pxi');
}


sub guts {
  my $pxt = shift;
  return  $pxt->include("/network/components/usergroups/user_group_list.pxi");
}

sub windowed_guts {
  my $pxt = shift;
  $pxt->include("/network/components/usergroups/user_group_list_partial.pxi");
}

1;

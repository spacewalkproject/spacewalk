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
package Cypress::UserActions;
use Grail::Component;

use Carp;

@Cypress::UserActions::ISA = qw/Grail::Component/;

my @component_modes =
  (
   [ 'usergroup_add_remove', 'add_remove_to_groups', undef, undef ]
  );

sub component_modes {
  return @component_modes;
}

sub add_remove_to_groups {
  my $self = shift;
  my $pxt = shift;

  my $user = $pxt->user;

  # what are the rules about adding/removing servers to a group?
  croak "attempt to add/remove users from usergroups by a non-orgadmin " unless $user->is('org_admin');

  return $pxt->include('/network/components/useractions/user_set_group_assign.pxi');
}

1;

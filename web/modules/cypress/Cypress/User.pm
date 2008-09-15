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
package Cypress::User;
use Grail::Component;

@Cypress::User::ISA = qw/Grail::Component/;

my @component_modes =
  (

   # revised modes:
   [ 'need_more_info', 'need_more_info', undef, undef ],

   [ 'user_search', 'user_search', undef, undef ],
   [ 'selection_list', 'selection_list', undef, undef ]
  );

sub component_modes {
  return @component_modes;
}

sub check_access_or_die {
  my $pxt = shift;

  my $user = $pxt->user;
  if(!$user->is('org_admin') and $pxt->param('uid') and $user->id != $pxt->param('uid')) {
    die "Insufficinet access rights";
  }
}

sub need_more_info {
  my $self = shift;
  my $pxt = shift;

  check_access_or_die($pxt);

  $pxt->redirect('/network/user/user_addresses.pxt?uid=' . $pxt->user->id);
}


sub selection_list {
  my $self = shift;
  my $pxt = shift;

  return '' unless $pxt->user;

  return $pxt->include('/network/components/user/user_selections.pxi') . $pxt->include('/network/components/user/recent_wizards.pxi');

  #return "Current Selections:<br><ul>" . join("", map { exists $pretty{$_->[0]} ? "<li>$_->[1] $pretty{$_->[0]}</li>" : () } $pxt->user->selection_details) . "</ul>";
}

sub user_search {
  my $self = shift;
  my $pxt = shift;

  return $pxt->include('/network/components/search/user_search.pxi');
}

1;

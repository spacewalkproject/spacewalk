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

package RHN::Access::Action;

use strict;
use RHN::Exception qw/throw/;
use PXT::ACL;
use RHN::Action ();

sub register_acl_handlers {
  my $self = shift;
  my $acl = shift;

  $acl->register_handler(action_type => \&action_type);
  $acl->register_handler(generic_action_type => \&generic_action_type);
}

sub action_type {
  my $pxt = shift;
  my $type = shift;

  throw 'acl test with no $pxt->user authenticated' unless $pxt->user;

  my $aid = $pxt->param('aid');
  throw 'action acl test called with no aid param' unless $aid;

  my $action = RHN::Action->lookup(-id => $aid);

  throw 'no action' unless $action;

  return 0 unless $action->action_type_label eq $type;

  return 1;
}


sub generic_action_type {
  my $pxt = shift;
  my $generic_type = shift;

  throw 'acl test with no $pxt->user authenticated' unless $pxt->user;

  my $aid = $pxt->param('aid');
  throw 'action acl test called with no aid param' unless $aid;

  my $action = RHN::Action->lookup(-id => $aid);

  throw 'no action' unless $action;

  return 0 unless $action->is_type_of($generic_type);

  return 1;
}

1;

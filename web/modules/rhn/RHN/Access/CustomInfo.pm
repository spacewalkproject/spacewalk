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

package RHN::Access::CustomInfo;

use strict;
use RHN::Exception qw/throw/;
use PXT::ACL;


sub register_acl_handlers {
  my $self = shift;
  my $acl = shift;

  $acl->register_handler(can_delete_custominfokey => \&can_delete_key);
}

sub can_delete_key {
  my $pxt = shift;
  my $key_id = shift;

  throw 'acl test with no $pxt->user authenticated' unless $pxt->user;

  unless ($pxt->user->can_delete_custominfokey($key_id)) {
    return 0;
  }

  return 1;
}

1;

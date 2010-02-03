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

package RHN::Access::Token;

use strict;

use RHN::Exception qw/throw/;
use RHN::Token;

use PXT::ACL;


sub register_acl_handlers {
  my $self = shift;
  my $acl = shift;

  $acl->register_handler(token_has_entitlement => \&has_entitlement);
}

sub has_entitlement {
  my $pxt = shift;
  my $entitlement = shift;

  my $tid = $pxt->param('tid');

  return 0 unless $tid;
  return 0 unless $pxt->user;

  throw 'no entitlement to test' unless $entitlement;

  my $token = RHN::Token->lookup(-id => $tid);
  return 1 if $token->has_entitlement($entitlement);

  return 0;
}

1;

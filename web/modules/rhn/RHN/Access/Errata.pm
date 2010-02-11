#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

package RHN::Access::Errata;

use strict;
use RHN::ErrataTmp;
use PXT::ACL;

sub register_acl_handlers {
  my $self = shift;
  my $acl = shift;

  $acl->register_handler(errata_exists => \&errata_exists);
  $acl->register_handler(errata_published => \&errata_published);
  $acl->register_handler(errata_owned => \&errata_owned);
}

#really just looks to see if the 'eid' formvar is present
sub errata_exists {
  my $pxt = shift;
  my $eid = $pxt->param('eid');

  return 0 unless $eid;

  return 1;
}

sub errata_published {
  my $pxt = shift;
  my $eid = $pxt->param('eid');

  return 0 unless $eid;

  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  return 0 if ($errata->isa('RHN::DB::ErrataTmp'));

  return 1;
}

sub errata_owned {
  my $pxt = shift;
  my $eid = $pxt->param('eid');

  return 0 unless $eid;

  my $errata = RHN::ErrataTmp->lookup_managed_errata(-id => $eid);

  return 0 unless ( ($errata->org_id || 0) == ($pxt->user->org_id || 0) );

  return 1;
}

1;

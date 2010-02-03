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

package RHN::Access::Package;

use strict;
use RHN::Package;
use PXT::ACL;

sub register_acl_handlers {
  my $self = shift;
  my $acl = shift;

  $acl->register_handler(package_packaging_type => \&package_packaging_type);
  $acl->register_handler(package_type_capable => \&package_type_capable);
}

# Does the packaging type of the package match the input?  (rpm, sysv-solaris, tar)
sub package_packaging_type {
  my $pxt = shift;
  my $type = shift;

  my $pid = $pxt->param('pid');
  return 0 unless $pid;

  return 1 if (RHN::Package->packaging_type($pid) eq $type);

  return 0;
}

# UI bits to turn on or off based upon the package type (rpm, solaris, tar, etc)
sub package_type_capable {
  my $pxt = shift;
  my $cap = shift;

  my $pid = $pxt->param('pid');
  return 0 unless $pid;

  return 1 if (RHN::Package->package_type_capable($pid, $cap));

  return 0;
}

1;

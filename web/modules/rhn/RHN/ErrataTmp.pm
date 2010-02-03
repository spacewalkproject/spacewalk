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

package RHN::ErrataTmp;

use RHN::DB::ErrataTmp;
our @ISA = qw/RHN::DB::ErrataTmp/;

use RHN::Exception;

sub lookup_managed_errata {
  my $class = shift;
  my @params = @_;
  my $errata;

  $errata = eval { RHN::Errata->lookup(@params) };
  return $errata if $errata;

  $errata = eval { RHN::ErrataTmp->lookup(@params) };
  return $errata if $errata;

  throw "Could not find managed errata '@params' - $@";
}

1;

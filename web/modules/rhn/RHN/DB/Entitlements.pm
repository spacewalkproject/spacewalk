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

package RHN::DB::Entitlements;

use RHN::DB;
use RHN::DataSource::General;
use RHN::Exception qw/throw/;

sub valid_system_entitlements {
  my $class = shift;

  my $ds = new RHN::DataSource::General(-mode => 'valid_system_entitlements');

  return @{$ds->execute_query()};
}

sub valid_system_entitlements_for_org {
  my $class = shift;
  my $oid = shift;

  throw "No org id" unless $oid;

  my $ds = new RHN::DataSource::General(-mode => 'valid_system_entitlements_for_org');

  return @{$ds->execute_query(-oid => $oid)};
}

sub is_valid_entitlement {
  my $class = shift;
  my $target_entitlement = shift;

  my @valid_entitlements = $class->valid_system_entitlements();

  return (grep { $_->{LABEL} eq $target_entitlement } @valid_entitlements) ? 1 : 0;
}


sub entitlement_feature_map {
  my $class = shift;

  my $ds = new RHN::DataSource::General(-mode => 'entitlement_feature_map');

  my $data = $ds->execute_full();

  my %ret;

  foreach my $row (@{$data}) {
    push @{$ret{$row->{ENTITLEMENT}}}, $row->{FEATURE};
  }

  return %ret;
}

sub entitlement_grants_feature {
  my $class = shift;
  my $entitlement = shift;
  my $feature = shift;

  throw "$class->entitlement_grants_feature needs an entitlement and a feature"
    unless ($entitlement and $feature);

  my %entitlement_feature_map = $class->entitlement_feature_map();

  throw "Unknown entitlement '$entitlement'"
    unless exists $entitlement_feature_map{$entitlement};

  my @feats = @{$entitlement_feature_map{$entitlement}};

  return 1 if grep { $feature eq $_ } @feats;

  return 0;
}

1;

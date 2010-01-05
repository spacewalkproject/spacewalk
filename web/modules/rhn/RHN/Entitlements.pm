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
package RHN::Entitlements;
use Carp qw/croak confess/;

use RHN::DB::Entitlements;

our @ISA = qw/RHN::DB::Entitlements/;

my %updates_features = map { $_ => 1 }
  qw/ftr_package_updates ftr_errata_updates ftr_hardware_refresh
     ftr_package_refresh ftr_package_remove ftr_auto_errata_updates/;

my %management_features = map { $_ => 1 }
  qw/ftr_system_grouping ftr_package_verify ftr_profile_compare
     ftr_proxy_capable ftr_sat_capable ftr_reboot
     ftr_satellite_applet ftr_osa_bus/;

my %provisioning_features = map { $_ => 1 }
  qw/ftr_kickstart ftr_config ftr_custom_info ftr_delta_action
     ftr_snapshotting ftr_agent_smith ftr_remote_command/;

my %monitoring_features = map { $_ => 1 }
  qw/ftr_schedule_probe ftr_probes/;

my %nonlinux_features = map { $_ => 1 }
  qw/ftr_nonlinux_support/;

my %entitlement_feature_map =
  ( none => { },
    sw_mgr_entitled => { map { $_ => 1 } (keys %updates_features) },
    enterprise_entitled => { map { $_ => 1 } (keys %updates_features,
					      keys %management_features) },
    provisioning_entitled => { map { $_ => 1 } (keys %updates_features,
						keys %management_features,
						keys %provisioning_features,
# When we add monitoring entitlements back for systems, remove this line:
					        keys %monitoring_features) },
    monitoring_entitled => { map { $_ => 1 } (keys %monitoring_features) },
    nonlinux_entitled => { map { $_ => 1 } (keys %updates_features,
					    keys %management_features,
					    keys %provisioning_features,
					    keys %nonlinux_features) },
  );

# What type of feature is this?  Management, provisioning, monitoring, etc.
sub feature_type {
  my $class = shift;
  my $feature = shift;

  if (exists $updates_features{$feature}) {
    return 'updates';
  }
  elsif (exists $management_features{$feature}) {
    return 'management';
  }
  elsif (exists $provisioning_features{$feature}) {
    return 'provisioning';
  }
  elsif (exists $monitoring_features{$feature}) {
    return 'monitoring';
  }
  elsif (exists $nonlinux_features{$feature}) {
    return 'nonlinux';
  }
  else {
    die "Invalid feature '$feature'";
  }

}

1;

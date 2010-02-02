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

package RHN::Access;

use strict;
use RHN::Exception qw/throw/;
use PXT::ACL;
use PXT::Config;

use RHN::Server;
use RHN::User;

sub register_acl_handlers {
  my $self = shift;
  my $acl = shift;

  $acl->register_handler(user_role => \&user_role_acl_test);
  $acl->register_handler(user_authenticated => \&user_auth_acl_test);
  $acl->register_handler(user_can_manage_channels => \&user_can_manage_channels_acl_test);
  $acl->register_handler(global_config => \&global_config_acl_test);
  $acl->register_handler(org_role => \&org_role_acl_test);
  $acl->register_handler(org_entitlement => \&org_entitlement_acl_test);
  $acl->register_handler(org_is_paying_customer => \&org_is_paying_customer_acl_test);
  $acl->register_handler(system_entitled => \&system_entitled_acl_test);
  $acl->register_handler(system_locked => \&system_locked_acl_test);
  $acl->register_handler(system_feature => \&system_feature_acl_test);
  $acl->register_handler(system_is_proxy => \&system_is_proxy_acl_test);
  $acl->register_handler(system_is_satellite => \&system_is_satellite_acl_test);
  $acl->register_handler(org_channel_family => \&org_channel_family_acl_test);
  $acl->register_handler(formvar_exists => \&formvar_exists_acl_test);
  $acl->register_handler(org_has_scouts => \&org_has_scouts);
  $acl->register_handler(show_monitoring => \&show_monitoring);
  $acl->register_handler(is_solaris => \&is_solaris_acl_test);
  $acl->register_handler(user_has_access_to_servergroup => \&user_has_access_to_servergroup_acl_test);
  $acl->register_handler(need_first_user => \&need_first_user);
  $acl->register_handler(system_is_virtual => \&system_is_virtual_acl_test);
  $acl->register_handler(system_is_virtual_host => \&system_is_virtual_host_acl_test);
  $acl->register_handler(system_has_virtualization_entitlement => \&system_has_virtualization_entitlement_acl_test);
}

sub user_role_acl_test {
  my $pxt = shift;
  my $role = shift;

  die "user_role_acl_test called with no \$pxt->user authenticated" unless $pxt->user;
  return $pxt->user->is($role) ? 1 : 0;
}

sub user_has_access_to_servergroup_acl_test {
    my $pxt = shift;
    die "user_role_acl_test called with no \$pxt->user authenticated" unless $pxt->user;
    my $sgid = $pxt->passthrough_param('sgid');
    return $pxt->user->access_to_servergroup($sgid) ? 1 : 0;
}

sub need_first_user {
    my $pxt = shift;
    my $foo = not RHN::User->satellite_has_users();
    return $foo;
}

sub user_auth_acl_test {
  my $pxt = shift;

  return ($pxt->user) ? 1 : 0;
}

sub global_config_acl_test {
  my $pxt = shift;
  my $var = shift;

  return PXT::Config->get($var) ? 1 : 0;
}

sub org_role_acl_test {
  my $pxt = shift;
  my $role = shift;

  die "org_role_acl_test called with no \$pxt->user authenticated" unless $pxt->user;
  return $pxt->user->org->has_role($role) ? 1 : 0;
}

sub org_entitlement_acl_test {
  my $pxt = shift;
  my $ent = shift;

  die "org_entitlement_acl_test called with no \$pxt->user authenticated" unless $pxt->user;

  return $pxt->user->org->has_entitlement($ent) ? 1 : 0;
}

sub org_is_paying_customer_acl_test {
  my $pxt = shift;

  die "org_is_paying_customer_acl_test called with no \$pxt->user authenticated" unless $pxt->user;

  return $pxt->user->org->is_paying_customer() ? 1 : 0;
}

sub org_has_scouts {
  my $pxt = shift;

  die "org_has_scouts called with no \$pxt->user authenticated" unless $pxt->user;

  return $pxt->user->org->get_scout_options() ? 1 : 0;
}

sub show_monitoring {
  my $pxt = shift;

  die "show_monitoring called with no \$pxt->user authenticated" unless $pxt->user;

  # if they have the monitoring entitlement as well as this instance
  # has monitoring turned on.
  return (check_monitoring($pxt->user) and $pxt->user->is('monitoring_admin')) ? 1 : 0;
}

sub check_monitoring {
    my $user = shift;

    my $org_has_monitoring = $user->org->has_entitlement("rhn_monitor");
    my $monitoring_backend = PXT::Config->get('is_monitoring_backend');
    return ($org_has_monitoring and $monitoring_backend) ? 1 : 0;
}

sub org_channel_family_acl_test {
  my $pxt = shift;
  my $cfam = shift;

  die "org_channel_family_acl_test called with no \$pxt->user authenticated" unless $pxt->user;

  return $pxt->user->org->has_channel_family_entitlement($cfam) ? 1 : 0;
}

sub system_entitled_acl_test {
  my $pxt = shift;
  my $ent = shift;

  throw "No entitlement level specified in system_entitled_acl_test"
    unless $ent;

  my ($sid) = $pxt->param('sid');
  throw "No sid parameter when testing for system entitlement level '$ent'"
    unless $sid;

  my $server = lookup_system_fast($pxt, $sid);
  if ($ent) {
    my $current_entitlement = $server->is_entitled;
    return ($current_entitlement and $current_entitlement eq $ent) ? 1 : 0;
  }
  else {
    return $server->is_entitled ? 1 : 0;
  }
}

sub system_locked_acl_test {
  my $pxt = shift;

  my ($sid) = $pxt->param('sid');
  throw "No sid parameter when testing to see if the system is locked"
    unless $sid;

  my $server = lookup_system_fast($pxt, $sid);
  if ($server->check_lock) {
    return 1;
  }
  else {
    return 0;
  }
}

sub is_solaris_acl_test {
  my $pxt = shift;
  
  my ($sid) = $pxt->param('sid');
  throw "No sid parameter when testing to see if the system is locked"
    unless $sid;

  my $server = lookup_system_fast($pxt, $sid);
  
  return $server->is_solaris ? 1 : 0;
}

sub lookup_system_fast {
  my $pxt = shift;
  my $sid = shift;

  my $note_name = 'system_acl_cache_' . $sid;
  my $server = $pxt->pnotes($note_name) || RHN::Server->lookup(-id => $sid);
  $pxt->pnotes($note_name, $server);

  return $server;
}

sub system_feature_acl_test {
  my $pxt = shift;
  my $feature = shift;

  my ($sid) = $pxt->param('sid');
  throw "No sid parameter when testing for system feature '$feature'"
    unless $sid;

  my $server = lookup_system_fast($pxt, $sid);

  if (RHN::Entitlements->feature_type($feature) eq 'monitoring') {
    return 0 unless ($pxt->user->org->has_entitlement('rhn_monitor')
		     and check_monitoring($pxt->user));
  }

  return $server->has_feature($feature);
}

sub system_is_proxy_acl_test {
  my $pxt = shift;

  my ($sid) = $pxt->param('sid');
  throw "No sid parameter when testing to see if system is a proxy"
    unless $sid;

  my $server = lookup_system_fast($pxt, $sid);
  return $server->is_proxy() ? 1 : 0;
}

sub system_is_satellite_acl_test {
  my $pxt = shift;

  my ($sid) = $pxt->param('sid');
  throw "No sid parameter when testing to see if system is a satellite"
    unless $sid;

  my $server = lookup_system_fast($pxt, $sid);
  return $server->is_satellite() ? 1 : 0;
}

sub system_is_virtual_acl_test {
  my $pxt = shift;

  my ($sid) = $pxt->param('sid');
  throw "No sid parameter when testing to see if system is a guest"
    unless $sid;

  my $server = lookup_system_fast($pxt, $sid);
  return $server->is_virtual() ? 1 : 0;
}

sub system_is_virtual_host_acl_test {
  my $pxt = shift;

  my ($sid) = $pxt->param('sid');
  throw "No sid parameter when testing to see if system is a vhost"
    unless $sid;

  my $server = lookup_system_fast($pxt, $sid);
  return $server->is_virtual_host() ? 1 : 0;
}

sub system_has_virtualization_entitlement_acl_test {
  my $pxt = shift;

  my ($sid) = $pxt->param('sid');
  throw "No sid parameter when testing to see if system is a vhost"
    unless $sid;

  my $server = lookup_system_fast($pxt, $sid);
  return $server->has_virtualization_entitlement() ? 1 : 0;
}


sub formvar_exists_acl_test {
  my $pxt = shift;
  my $formvar = shift;

  PXT::Debug->log(7, "testing formvar $formvar...");

  return ($pxt->passthrough_param($formvar) ? 1 : 0);
}

sub user_can_manage_channels_acl_test {
  my $pxt = shift;

  return ($pxt->user->is("channel_admin") or $pxt->user->manages_a_channel);
}

1;

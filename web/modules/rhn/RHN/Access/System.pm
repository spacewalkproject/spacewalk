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

package RHN::Access::System;

use strict;
use RHN::Exception qw/throw/;
use RHN::Package;
use RHN::DataSource::System;
use RHN::DataSource::Action ();
use RHN::Entitlements;
use RHN::Kickstart::Session ();
use RHN::Server ();

use PXT::ACL;

sub register_acl_handlers {
  my $self = shift;
  my $acl = shift;

  $acl->register_handler(child_channel_candidate => \&child_channel_candidate);
  $acl->register_handler(client_capable => \&client_capable);
  $acl->register_handler(system_kickstart_in_progress => \&kickstart_in_progress);
  $acl->register_handler(system_kickstart_session_exists => \&kickstart_session_exists);
  $acl->register_handler(system_packaging_type => \&system_packaging_type);
  $acl->register_handler(system_profile_capable => \&system_profile_capable);
  $acl->register_handler(proxy_evr_at_least => \&proxy_evr_at_least);
  $acl->register_handler(org_proxy_evr_at_least => \&org_proxy_evr_at_least);
  $acl->register_handler(package_available => \&package_available_to_system);
  $acl->register_handler(action_pending_named => \&action_pending_named);
  $acl->register_handler(last_action_attempt_failed => \&last_action_attempt_failed);
  $acl->register_handler(system_entitlement_possible => \&system_entitlement_possible);
}

sub child_channel_candidate {
  my $pxt = shift;
  my $family = shift;

  throw 'system_base_channel acl test with no $pxt->user authenticated' unless $pxt->user;

  my $sid = $pxt->param('sid');
  throw 'system_channel acl test called with no sid param' unless $sid;

  my @channel_infos = RHN::Server->child_channel_candidates(-server_id => $sid,
							    -channel_family_label => $family);
  return 0 unless @channel_infos;

  return 1;
}


sub client_capable {
  my $pxt = shift;
  my $cap = shift;

  my $sid = $pxt->param('sid');
  throw 'client_capable acl test called with no sid param' unless $sid;
  my $server = RHN::Server->lookup(-id => $sid);

  return 1 if defined $server->client_capable($cap);
  return 0;
}

#Is there a kickstart ongoing for this system?
sub kickstart_in_progress {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  throw 'kickstart_in_progress acl test called with no sid param' unless $sid;

  my $session = RHN::Kickstart::Session->lookup(-sid => $sid, -org_id => $pxt->user->org_id, -soft => 1);
  my $state = $session ? $session->session_state_label : '';
  return 1 if ($session and $state ne 'complete' and $state ne 'failed');

  return 0;
}

#Is there a kickstart in progress, failed, or completed for this system?
sub kickstart_session_exists {
  my $pxt = shift;

  my $sid = $pxt->param('sid');
  throw 'kickstart_session_exists acl test called with no sid param' unless $sid;

  my $session = RHN::Kickstart::Session->lookup(-sid => $sid, -org_id => $pxt->user->org_id, -expired => 1, -soft => 1);
  return 1 if ($session);

  return 0;
}

# Does the packaging type of the system match the input?  (rpm, sysv-solaris, tar)
sub system_packaging_type {
  my $pxt = shift;
  my $type = shift;

  my $sid = $pxt->param('sid');
  return 0 unless $sid;

  return 1 if (RHN::Server->packaging_type($sid) eq $type);

  return 0;
}

# Different from client_capable - this is for UI bits to turn on or off based upon the system type
sub system_profile_capable {
  my $pxt = shift;
  my $cap = shift;

  my $sid = $pxt->param('sid');
  return 0 unless $sid;

  return 1 if (RHN::Server->system_profile_capable($sid, $cap));

  return 0;
}

# Returns true if system is a proxy, and it reports an evr in
# rhnProxyInfo, and that evr is greater than or equal to the input
sub proxy_evr_at_least {
  my $pxt = shift;
  my $version = shift;

  my $sid = $pxt->param('sid');

  return 0 unless $sid;
  return 0 unless $version;

  my @system_evr = RHN::Server->proxy_evr($sid);
  my @target_evr = version_string_to_evr_array($version);

  return 0 unless (@system_evr);

  return 1 if RHN::Package->vercmp(@system_evr, @target_evr) >= 0;

  return 0;
}

# Return true if the org has at least one registered proxy whose
# version is greater than the provided version
sub org_proxy_evr_at_least {
  my $pxt = shift;
  my $version = shift;

  my @target_evr = version_string_to_evr_array($version);

  my $ds = new RHN::DataSource::System (-mode => 'org_proxy_servers');
  my $data = $ds->execute_query(-org_id => $pxt->user->org_id);

  foreach my $row (@{$data}) {
    my @system_evr = RHN::Server->proxy_evr($row->{ID});

    next unless (@system_evr);
    return 1 if RHN::Package->vercmp(@system_evr, @target_evr) >= 0;
  }

  return 0;
}

# Given a string of the form 'version-release(:epoch)', return an
# array of (epoch, version, release)
sub version_string_to_evr_array {
  my $version = shift;

  my @vre = split(/[-:]/, $version);
  my @target_evr = ((exists $vre[2] ? $vre[2] : '0'), $vre[0], $vre[1]);

  return @target_evr;
}

sub package_available_to_system {
  my $pxt = shift;
  my $package_name = shift;

  my $sid = $pxt->param('sid');

  return 0 unless $sid;
  return 0 unless $package_name;

  my $base_channel_id = RHN::Server->base_channel_id($sid);

  return 0 unless $base_channel_id;

  my @packages = RHN::Package->latest_packages_in_channel_tree(-uid => $pxt->user->id,
							       -packages => [ $package_name ],
							       -base_cid => $base_channel_id,
							      );

  return 0 unless (@packages);

  return 1;
}

sub action_pending_named {
  my $pxt = shift;
  my $action_name = shift;

  my $sid = $pxt->param('sid');

  throw "(missing_param) Missing parameter 'sid'" unless $sid;
  throw "(missing_acl_param) Missing acl parameter" unless $action_name;

  my $ds = new RHN::DataSource::Action (-mode => 'actions_for_system_named');
  my $data = $ds->execute_full(-sid => $sid, -action_name => $action_name);

  return 0 unless (grep { $_->{STATUS} eq 'Queued' or $_->{STATUS} eq 'Picked Up' } @{$data});

  return 1;
}

sub last_action_attempt_failed {
  my $pxt = shift;
  my $action_name = shift;

  my $sid = $pxt->param('sid');

  throw "(missing_param) Missing parameter 'sid'" unless $sid;
  throw "(missing_acl_param) Missing acl parameter" unless $action_name;

  my $ds = new RHN::DataSource::Action (-mode => 'actions_for_system_named');
  my $data = $ds->execute_full(-sid => $sid, -action_name => $action_name);

  return 0 unless (@{$data});
  return 0 unless ($data->[0]->{STATUS} eq 'Failed');

  return 1;
}

sub system_entitlement_possible {
  my $pxt = shift;
  my $target_entitlement = shift;

  throw "(invalid_entitlement) Invalid entitlement: $target_entitlement"
    unless RHN::Entitlements->is_valid_entitlement($target_entitlement);

  my ($sid) = $pxt->param('sid');
  throw "No sid parameter when testing for system entitlement level '$target_entitlement'"
    unless $sid;

  my $server = RHN::Server->lookup(-id => $sid);

  if ($server->has_entitlement($target_entitlement) or
      $server->can_entitle_server($target_entitlement)) {
    return 1;
  }

  return 0;
}


1;

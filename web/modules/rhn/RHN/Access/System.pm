#
# Copyright (c) 2008--2012 Red Hat, Inc.
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
  $acl->register_handler(org_has_proxies => \&org_has_proxies);
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

# Return true if the org has at least one registered proxy
sub org_has_proxies {
  my $pxt = shift;

  my $ds = new RHN::DataSource::System (-mode => 'org_proxy_servers');
  my $data = $ds->execute_query(-org_id => $pxt->user->org_id);

  if (@{$data}) {
    return 1;
  }

  return 0;
}

1;

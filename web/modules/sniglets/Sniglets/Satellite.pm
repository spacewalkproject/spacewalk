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

package Sniglets::Satellite;

use RHN::Exception;
use MIME::Lite;
use MIME::Base64;
use RHN::Mail;
use PXT::Config;

sub register_xmlrpc {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_xmlrpc('satellite.send_debug_data', \&send_debug_data);
  $pxt->register_xmlrpc('satellite.server_set_base_channel', \&server_set_base_channel);
  $pxt->register_xmlrpc('satellite.server_clear_groups', \&server_clear_groups);
  $pxt->register_xmlrpc('satellite.server_clear_channels', \&server_clear_channels);
  $pxt->register_xmlrpc('satellite.server_join_groups', \&server_join_groups);
  $pxt->register_xmlrpc('satellite.server_subscribe_channels', \&server_subscribe_channels);
}



sub server_join_groups {
  my $pxt = shift;
  my $system_id = shift;
  my @server_groups = @{+shift};

  my $server;
  eval {
    $server = RHN::Server->lookup_by_cert($system_id);
  };

  my $E = $@;
  if ($E) {
    warn "lookup_cert: $E";

    $pxt->rpc_fault('invalid_certificate');
  }

  my %server_groups = map { $_ => 1 } @server_groups;
  my @group_ids = map { $_->[1] } grep { $_->[0] == 0 and exists $server_groups{$_->[2]} } $server->visible_group_list_for_server();

  RHN::Server->add_servers_to_groups([$server->id], \@group_ids);

  return [];
}

sub server_clear_groups {
  my $pxt = shift;
  my $system_id = shift;

  my $server;
  eval {
    $server = RHN::Server->lookup_by_cert($system_id);
  };

  my $E = $@;
  if ($E) {
    warn "lookup_cert: $E";

    $pxt->rpc_fault('invalid_certificate');
  }

  my @group_ids = map { $_->[1] } grep { $_->[0] == 1 } $server->visible_group_list_for_server();

  RHN::Server->remove_servers_from_groups([$server->id], \@group_ids);

  return [];
}

sub server_set_base_channel {
  my $pxt = shift;
  my $system_id = shift;
  my $channel_label = shift;

  my $server;
  eval {
    $server = RHN::Server->lookup_by_cert($system_id);
  };

  my $E = $@;
  if ($E) {
    warn "lookup_cert: $E";

    $pxt->rpc_fault('invalid_certificate');
  }

  my $channel_id = RHN::Channel->channel_id_by_label($channel_label);

  return [ 'Error', "No such base channel '$channel_label'" ]
    unless defined $channel_id;

  $server->change_base_channel($channel_id);

  return [];
}

sub server_subscribe_channels {
  my $pxt = shift;
  my $system_id = shift;
  my @channel_labels = @{+shift};

  my $server;
  eval {
    $server = RHN::Server->lookup_by_cert($system_id);
  };

  my $E = $@;
  if ($E) {
    warn "lookup_cert: $E";

    $pxt->rpc_fault('invalid_certificate');
  }

  my @channel_ids = map { RHN::Channel->channel_id_by_label($_) } @channel_labels;

  my @errors;
  for my $i (0 .. $#channel_labels) {
    push @errors, [ 'Error', "No such channel '$channel_labels[$i]'" ]
      unless defined $channel_ids[$i];
  }

  $server->subscribe_to_channel($_) for grep { defined $_ } @channel_ids;

  return @errors;
}

sub server_clear_channels {
  my $pxt = shift;
  my $system_id = shift;

  my $server;
  eval {
    $server = RHN::Server->lookup_by_cert($system_id);
  };

  my $E = $@;
  if ($E) {
    warn "lookup_cert: $E";

    $pxt->rpc_fault('invalid_certificate');
  }

  $server->unsubscribe_from_channel($_) for $server->server_channel_ids;

  return [];
}


sub send_debug_data {
  my $pxt = shift;
  my $debug_file = MIME::Base64::decode_base64(shift);

  my $to = PXT::Config->get('traceback_mail');
  my $mime = MIME::Lite->new(From => PXT::Config->get('product_name') . " <rhn-admin\@rhn.redhat.com>",
			     To => $to,
			     Subject => PXT::Config->get('product_name') . " Debug Dump",
			     Type => "application/octet-stream",
			     Data => $debug_file,
			     Encoding => "base64",
			     Filename => "satellite-debug.tar.bz2");

  RHN::Mail->send_raw($mime->as_string);

  return 1;
}

1;

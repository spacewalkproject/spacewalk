# Copyright (c) 2005--2012 Red Hat, Inc.

package NOCpulse::MonitoringAccessHandler;

use strict;
use warnings;
use Apache2::Const ':common';
use NOCpulse::CF_DB;
use Apache2::RequestRec;
use Apache2::RequestUtil;
use Apache2::Connection ();

# Get the valid ip addresses for satellites/proxies allowed
# to talk to this satellite

my @valid_ips      = &get_scout_ips;
my $last_check     = time();
my $check_interval = 60;               #one minute

###################
sub get_scout_ips {
###################
  my $cf_db    = NOCpulse::CF_DB->new;
  my $node_ref = $cf_db->getNodes;
  $cf_db->rollback;
  my @values   = values(%$node_ref);
  my @result   = map { $_->{ip} } @values;
  push(@result, '127.0.0.1');          #add local loop
  return @result;
}

#############
sub handler {
#############
  my $r = shift;
  return DECLINED unless $r->is_initial_req;    # don't handle sub-requests

  # Update the list of valid ips in case someone added another monitoring
  # satellite or proxy
  my $current_time = time();
  if ($current_time >= $last_check + $check_interval) {
    @valid_ips  = &get_scout_ips;
    $last_check = $current_time;
  }

  # Check to ensure the remote request is from an allowed monitoring satellite
  # or proxy
  my $remote_ip = $r->connection->remote_ip;
  my ($valid_ip) = grep { $_ eq $remote_ip } @valid_ips;

  unless ($valid_ip) {
    return FORBIDDEN;
  }

  return OK;
} ## end sub handler

1;

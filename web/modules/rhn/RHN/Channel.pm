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

package RHN::Channel;

use strict;
use RHN::DB::Channel;

our @ISA = qw/RHN::DB::Channel/;

sub lookup {
  my $class = shift;
  my $first_arg = $_[0];

  die "No argument to $class->lookup"
    unless $first_arg;

  if (substr($first_arg,0,1) eq '-') {
    return $class->SUPER::lookup(@_);
  }
  else {
    warn "deprecated use of unparameterized $class->lookup from (" . join(', ', caller) . ")\n";
    return $class->SUPER::lookup(-id => $first_arg);
  }
}

sub user_subscribable_bases_for_system {
  my $class = shift;
  my $system = shift;
  my $user = shift;

  my $ds = new RHN::DataSource::Channel(-mode => 'base_channels_owned_by_org');
  my $channels = $ds->execute_query(-org_id => $user->org_id);
  my @ret = @$channels;

  my $default_base = $system->default_base_channel;
  if (defined $default_base) {
    my $channel = RHN::Channel->lookup(-id => $default_base);
    unshift @ret, { map { uc $_ => $channel->$_() } qw/id name label/ };
  }

  # filter out the channels a user doesn't have access to...
  @ret = grep { $user->verify_channel_subscribe($_->{ID}) } @ret;
  @ret = grep { $system->verify_channel_arch_compat($_->{ID}) } @ret;

  return @ret;
}

1;

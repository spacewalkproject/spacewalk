#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

package RHN::SatelliteCert;

use RHN::Cert;

our @ISA = qw/RHN::Cert/;

sub _init {
  my $self = shift;

  my @fields = qw/product owner issued expires slots/;

  $self->add_field($_) foreach @fields;
  $self->set_required_fields(@fields);

  my @optional_fields = qw/monitoring-slots provisioning-slots nonlinux-slots virtualization_host virtualization_host_platform channel-families satellite-version generation/;
  $self->add_field($_) foreach @optional_fields;

  return;
}

sub clear_channel_families {
  my $self = shift;

  $self->clear_field("channel-families");
}

sub set_channel_family {
  my $self = shift;
  my $label = shift;
  my $quantity = shift;

  $self->push_field(name => 'channel-families', family => $label, quantity => $quantity);
}

sub get_channel_families {
  my $self = shift;

  my $a = $self->get_field('channel-families');

  return map { [ $_->{family}, $_->{quantity} ] } @$a;
}

sub version {
  my $self = shift;

  return $self->get_field('satellite-version');
}

1;

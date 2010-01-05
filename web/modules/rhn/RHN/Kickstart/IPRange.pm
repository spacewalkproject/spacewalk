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

package RHN::Kickstart::IPRange;

# A range of IP Addresses.

use RHN::Kickstart::IPAddress;
use RHN::DataSource::General;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

# takes (-min => <int or arrayref or RHN::KickStart::IPAddress>, -max => <same>)
sub new {
  my $class = shift;
  my %params = validate(@_, { min => { optional => 0 },
			      max => { optional => 0 },
			      ksid => { optional => 1 },
			      org_id => { optional => 1 },
			    } );

  my ($min, $max) = @params{qw/min max/};

  $min = _to_ip($min);
  $max = _to_ip($max);

  my $self = bless { min => $min, max => $max, ksid => undef, org_id => undef }, $class;

  $self->ksid($params{ksid});
  $self->org_id($params{org_id});

  $self->_check or die "Invalid range: (" . $self->min->as_string . " - " . $self->max->as_string . ")";;

  return $self;
}

# covert input to an RHN::Kickstart::IPAddress
sub _to_ip {
  my $input = shift;

  return new RHN::Kickstart::IPAddress($input) if (not ref $input);
  return new RHN::Kickstart::IPAddress(@{$input}) if (ref $input eq 'ARRAY');
  return $input if (ref $input eq 'RHN::Kickstart::IPAddress');

  die "Invalid ip: '$input'";
}

# Make sure it is a valid range
sub _check {
  my $self = shift;

  return 0 unless ($self->max >= $self->min);

  return 1;
}

sub as_string {
  my $self = shift;

  return $self->min . "-" . $self->max;
}

# get or set the minimum value
sub min {
  my $self = shift;
  my $min = shift;

  if (ref $min and $min->isa('RHN::Kickstart::IPAddress')) {
    $self->{min} = $min;
  }

  return $self->{min};
}

# get or set the max
sub max {
  my $self = shift;
  my $max = shift;

  if (ref $max and $max->isa('RHN::Kickstart::IPAddress')) {
    $self->{max} = $max;
  }

  return $self->{max};
}

# get or set the ksid
sub ksid {
  my $self = shift;
  my $ksid = shift;

  if (defined $ksid) {
    $self->{ksid} = $ksid;
  }

  return $self->{ksid};
}

# get or set the org_id
sub org_id {
  my $self = shift;
  my $org_id = shift;

  if (defined $org_id) {
    $self->{org_id} = $org_id;
  }

  return $self->{org_id};
}

# This range contains the IP
sub contains {
  my $self = shift;
  my ($ip) = validate_pos(@_, { isa => "RHN::Kickstart::IPAddress" });

  return 1 if ($ip >= $self->min and $ip <= $self->max);

  return 0;
}

# This range comes before the other one
sub before {
  my $self = shift;
  my ($other) = validate_pos(@_, { isa => "RHN::Kickstart::IPRange" });

  return 1 if ($self->max < $other->min);

  return 0;
}

# This range comes after the other one
sub after {
  my $self = shift;
  my ($other) = validate_pos(@_, { isa => "RHN::Kickstart::IPRange" });

  return 1 if ($self->min > $other->max);

  return 0;
}

1;

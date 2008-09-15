package NOCpulse::Probe::Utils::IPAddressRange;

use strict;

# Octets: XL = extreme left, ML = mid left, MR mid right, XR extreme right
use Class::MethodMaker
  get_set =>
  [qw(
      ip
      XL_LO
      XL_HI
      ML_LO
      ML_HI
      MR_LO
      MR_HI
      XR_LO
      XR_HI
     )],
  new_with_init => 'new',
  ;

sub init {
    my ($self, %args) = @_;

    my @octets;

    if ($args{ip}) {
        $self->ip($args{ip});
        @octets = split('\.', $args{ip});

    } elsif ($args{octets}) {
        @octets = @{$args{octets}};
        $self->ip("$octets[0].$octets[1].$octets[2].$octets[3]");
    }

    my $xl = $self->octet_range($octets[0]);
    my $ml = $self->octet_range($octets[1]);
    my $mr = $self->octet_range($octets[2]);
    my $xr = $self->octet_range($octets[3]);

    $self->XL_LO($xl->[0]);
    $self->XL_HI($xl->[1]);
    $self->ML_LO($ml->[0]);
    $self->ML_HI($ml->[1]);
    $self->MR_LO($mr->[0]);
    $self->MR_HI($mr->[1]);
    $self->XR_LO($xr->[0]);
    $self->XR_HI($xr->[1]);

    return $self;
}

sub octet_range {
    my ($self, $octet) = @_;

    my ($lo, $hi);

    if ($octet =~ /^\d+$/) { $lo = $hi = $octet; };
    if ($octet eq '*') { $lo = 0; $hi = 255; };
    if ($octet =~ /^\d+-\d+$/) { ($lo, $hi) = split(/-/, $octet); };

    return [$lo, $hi];
}

sub matches {
    my ($self, $ip) = @_;

    if (ref($ip)) {
        return ($self->XL_LO <= $ip->XL_LO && $ip->XL_HI <= $self->XL_HI
                && $self->ML_LO <= $ip->ML_LO && $ip->ML_HI <= $self->ML_HI
                && $self->MR_LO <= $ip->MR_LO && $ip->MR_HI <= $self->MR_HI
                && $self->XR_LO <= $ip->XR_LO && $ip->XR_HI <= $self->XR_HI);
    } else {
        my @octets = split('\.', $ip);
        return ($self->XL_LO <= $octets[0] && $octets[0] <= $self->XL_HI
                && $self->ML_LO <= $octets[1] && $octets[1] <= $self->ML_HI
                && $self->MR_LO <= $octets[2] && $octets[2] <= $self->MR_HI
                && $self->XR_LO <= $octets[3] && $octets[3] <= $self->XR_HI);
    }
}

1;

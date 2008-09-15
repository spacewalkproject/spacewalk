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

package Moon::Dataset::Function;

use strict;

use Moon::Dataset;

our @ISA = qw/Moon::Dataset/;

my $VERSION = '0.01';

my @known_fields = qw/function x_vals/;

#new - can set interpolation method, and coordinates - either as two
#array refs (x_vals, y_vals) or a nested arrayref (coords)
sub new {
  my $class = shift;
  my %attr = @_;

  my $self = bless { function => '$_',
		     x_vals => [ ] }, $class;

  foreach (@known_fields) {
    if (exists $attr{"-$_"}) {
      $self->{$_} = $attr{"-$_"};
    }
  }

  $self->_validate;
  $self->_order if @{$self->{x_vals}};

  return $self;
}

#getter/setter for function
sub function {
  my $self = shift;
  my $func = shift;

  if (defined $func) {
    $self->{function} = $func;
  }

  return $self->{function};
}

#getter/setter for x_vals
sub x_vals {
  my $self = shift;
  my $x_vals = shift;

  if (defined $x_vals) {
    $self->{x_vals} = $x_vals;
    $self->_order;
  }

  return $self->{x_vals};
}

#smallest x value -always the first, as the set is always-ordered
sub min_x {
  my $self = shift;

  return $self->{x_vals}->[0];
}

#biggest x -always the last
sub max_x {
  my $self = shift;

  return $self->{x_vals}->[-1];
}

#smallest y value -has to scan the full set right now
sub min_y {
  my $self = shift;

  my @vals = @{$self->y_vals};
  my $min = $vals[0];

  foreach my $y (@vals) {

    if ( $y < $min ) {
      $min = $y;
    }
  }

  return $min;
}

#biggest y -has to scan the full set right now
sub max_y {
  my $self = shift;

  my @vals = @{$self->y_vals};
  my $max = $vals[0];

  foreach my $y (@vals) {

    if ( $y > $max ) {
      $max = $y;
    }
  }

  return $max;
}

#call with a scaler to find the y value for a given x
#call with an array ref to find y values for given xes
sub value_at {
  my $self = shift;
  my $input = shift;

  my $xes;

  if (ref $input eq 'ARRAY') {
    $xes = $input;
  }
  else {
    $xes = [ $input ];
  }

  my @ret;

  foreach my $x ( @{$xes} ) {
    push @ret, eval $self->{function};
    if ($@) {
      die "Error evaluating '$x' in '",$self->{function},"': $@";
    }
  }

  if (ref $input eq 'ARRAY') {
    return \@ret;
  }
  else {
    return $ret[0];
  }

}

#y values for all xes
sub y_vals {
  my $self = shift;

  return $self->value_at($self->{x_vals});
}

#remesh the set over a given domain - domain must be - min_x <= domain >= max_x
sub remesh {
  my $self = shift;
  my $samples = shift;
  my $lower_bound = shift || $self->min_x;
  my $upper_bound = shift || $self->max_x;

  my $width = $upper_bound - $lower_bound;

  my $new_xs = [ map { $lower_bound + ($width / ($samples - 1)) * $_  } (0 .. ($samples - 1)) ];

  return new Moon::Dataset::Function (-function => $self->{function}, -x_vals => $new_xs);
}

#private function ordering the set - should be called whenever set is changed
sub _order {
  my $self = shift;

  $self->{x_vals} = [ sort { $a <=> $b } @{$self->{x_vals}} ];

  return;
}

#does some basic sanity checking - called by constructor, and wherever contents are changed
sub _validate {
  my $self = shift;

  foreach my $n (@{$self->{x_vals}}) {
    die "x value '$n' is not numeric enough." if $n =~ /[^\d.-]/;
  }

  return 1;
}

1;

__END__
# Below is stub documentation for your module. You better edit it!
# Nag, nag nag...

=head1 NAME

Moon::Dataset - Implementation of a Dataset class for use with RHN Monitoring.

=head1 SYNOPSIS

  use Moon::Dataset;

  my $ds = new Moon::Dataset (interpolate => 'Linear');

  $ds->coords([ [1,2], [3,4], [5,6] ]);

  print $ds->value_at(1.5); # 2.5
  print join ", ", @{$ds->value_at([1,1.5,2,3,4,5])}; # 2, 2.5, 3, 4, 5, 6

  print $ds->mix_x; # 1
  print $ds->max_y; # 6

  print join ", ", @{$ds->x_vals}; # 1, 3, 5
  print join ", ", @{$ds->y_vals}; # 2, 4, 6

=head1 DESCRIPTION

Provides a set of data - also interpolation, sampling and perhaps statistical analysis for use with the Spacewalk monitoring code.

=head2 EXPORT

No.

=head1 AUTHOR

Spacewalk Team <rhn-feedback@redhat.com>

=head1 SEE ALSO

rhn.redhat.com

L<perl>.

=cut

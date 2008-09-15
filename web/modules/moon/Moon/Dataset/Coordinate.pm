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

package Moon::Dataset::Coordinate;

use strict;

use lib '/var/www/lib';

use Moon::Dataset;
use RHN::DB;
use Date::Parse;
use Math::FFT;
use Data::Dumper;

our @ISA = qw/Moon::Dataset/;

my $VERSION = '0.01';

my @valid_interpolation_methods = qw/Linear/;
my @known_fields = qw/interpolation x_vals y_vals max_gap label/;

#new - can set interpolation method, and coordinates - either as two
#array refs (x_vals, y_vals) or a nested arrayref (coords)
sub new {
  my $class = shift;
  my %attr = @_;

  my $self = bless { interpolation => 'Linear',
		     label => 'Set',
		     x_vals => [ ],
		     y_vals => [ ],
		     last_i => 0,
                     max_gap => undef }, $class;

  foreach (@known_fields) {
    if (exists $attr{"-$_"}) {
      $self->{$_} = $attr{"-$_"};
    }
  }

  if (exists $attr{-coords}) {
    $self->_load_coords($attr{-coords});
  }

  $self->_validate;

  $self->{interpolation} = 'Linear'
    unless grep { $_ eq $self->{interpolation} } @valid_interpolation_methods;

  $self->_order if @{$self->{x_vals}};

  return $self;
}

#gets or sets the interpolation method
sub interpolation {
  my $self = shift;
  my $interp = shift;

 if (defined $interp && grep { $_ eq $interp} @valid_interpolation_methods) {
    $self->{interpolation} = $interp;
  }

  return $self->{interpolation};
}

sub label {
  my $self = shift;
  my $label = shift;

  if (defined $label) {
    $self->{label} = $label;
  }

  return $self->{label};
}

#getter for x_vals
sub x_vals {
  my $self = shift;

  return $self->{x_vals};
}

#getter for y_vals
sub y_vals {
  my $self = shift;

  return $self->{y_vals};
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

  my $min = $self->{y_vals}->[0];

  foreach my $y (@{$self->{y_vals}}) {
    next unless defined $y;

    if ( $y < $min ) {
      $min = $y;
    }
  }

  return $min;
}

#biggest y -has to scan the full set right now
sub max_y {
  my $self = shift;

  my $max = $self->{y_vals}->[0];

  foreach my $y (@{$self->{y_vals}}) {
    next unless defined $y;

    if ( $y > $max ) {
      $max = $y;
    }
  }

  return $max;
}

#call with a scaler to find the (possibly interpolated) y value for a given x
#call with an array ref to find y values for given xes
sub value_at {
  my $self = shift;
  my $xes = shift;

  if (ref $xes eq 'ARRAY') {
    $self->{last_i} = 0;	#clean the cache

    my $low_mark = 0;

    while ($xes->[$low_mark] < $self->{x_vals}->[0] and $low_mark < $#{$xes}) {
      $low_mark++;
    }

    my $high_mark = $#{$xes};
    while ($xes->[$high_mark] > $self->{x_vals}->[-1] and $high_mark > 0) {
      $high_mark--;
    }

    my $ret = $self->_values_in([ @{$xes}[$low_mark .. $high_mark] ]);

    my $pre = [ ];
    my $post = [ ];

    if ($low_mark > 0) {
      $pre = $self->_values_out([ @{$xes}[0 .. $low_mark - 1] ]);
    }

    if ($high_mark < $#{$xes}) {
      $post = $self->_values_out([ @{$xes}[$high_mark + 1 .. $#{$xes}] ]);
    }

    $self->{last_i} = 0;	#clean the cache
    return [ @{$pre}, @{$ret}, @{$post} ];
  } else {
    #    $self->{last_i} = 0; #clean the cache
    my $ret;

    if ($xes < $self->{x_vals}->[0] or $xes > $self->{x_vals}->[-1]) {
      $ret = $self->_values_out([ $xes ]);
    }
    else {
      $ret = $self->_values_in([ $xes ]);
    }
    #    $self->{last_i} = 0; #clean the cache
    return $ret->[0];
  }
}

sub derivative_set {
  my $self = shift;

  my @new_y;
  my @new_x = @{$self->{x_vals}};
  shift @new_x; # throw away bottom data point
  for my $i (0 .. $#new_x) {
    push @new_y, ($self->{y_vals}->[$i + 1] - $self->{y_vals}->[$i]) / ($self->{x_vals}->[$i + 1] - $self->{x_vals}->[$i]);
  }

  my $derived_set = new Moon::Dataset::Coordinate(-x_vals => \@new_x,
						  -y_vals => \@new_y,
						  -max_gap => $self->{max_gap},
						  -interpolation => $self->{interpolation},
						  -label => $self->{label});

  return $derived_set;
}

#get or set the coords in [ [1,2], [3,4], [5,6] ] format
sub coords {
  my $self = shift;
  my $coords = shift;

  if (defined $coords) {
    $self->{last_i} = 0; #clean the cache
    $self->_load_coords($coords);
    $self->_order;
    $self->_validate;
  }

  my $num_elems = scalar @{$self->{x_vals}};
  return [ map { [ $self->{x_vals}->[$_], $self->{y_vals}->[$_] ] } ( 0 .. ($num_elems - 1) ) ];
}

#remesh the set over a given domain - domain must be - min_x <= domain >= max_x
sub remesh {
  my $self = shift;
  my $samples = shift;
  my $lower_bound = shift || $self->min_x;
  my $upper_bound = shift || $self->max_x;

  my $width = $upper_bound - $lower_bound;

  my $new_xs = [ map { $lower_bound + ($width / ($samples - 1)) * $_  } (0 .. ($samples - 1)) ];
  my $new_ys;

  if ($samples >= @{$self->{x_vals}}) { #if we are getting more values, find the value_ats
    $new_ys = $self->value_at($new_xs);
  }
  else { #if we are getting fewer values, average surrounding value_ats...
    my $bss = ($width / $samples) / 2;

    foreach my $x (@{$new_xs}) {
      my $low_sample = ($x - $bss) < $self->min_x ? $self->min_x : ($x - $bss);
      my $high_sample = ($x + $bss) > $self->max_x ? $self->max_x : ($x + $bss);

      push @{$new_ys}, _ave($self->value_at([ $low_sample, $high_sample ]));
    }
  }

  my $old_samples = scalar @{$self->{x_vals}} + 1;

  if (defined $self->{max_gap}) {
    $self->{max_gap} = $self->{max_gap} * ($old_samples / $samples);
  }

  $self->{x_vals} = $new_xs;
  $self->{y_vals} = $new_ys;

  return 1;
}

sub fft {
  my $self = shift;
  my $num_terms = shift || 96;
  my $fft = new Math::FFT($self->y_vals);
  my $coeff = $fft->ddct();

  @{$coeff}[$num_terms .. $#$coeff] = map { 0 } ($num_terms .. $#$coeff);
  my $smooth_data = $fft->invddct($coeff);

  $self->{y_vals} = $smooth_data;

  return 1;
}

#average all of the y values for multiple datasets together, over the same domain of x values
#return a dataset with averages
#the x_vals for all sets are assumed to be the same, and they are assumed to have the same number of elements
sub average {
  my $class = shift;
  my @sets = @_;

  my @ave_ys = ();
  my $num_sets = scalar @sets;

  my @aves = (0) x @{$sets[0]->{x_vals}};

  foreach my $set (@sets) {
    my $vals = $set->value_at($sets[0]->{x_vals});
    @aves = map { $aves[$_] += ($vals->[$_] / $num_sets) } (0 .. @{$vals} - 1);
  }

  return $class->new( -x_vals => [ @{$sets[0]->{x_vals}} ], -y_vals => [ @aves ],
		      -interpolation => $sets[0]->{interpolation} );
}

#private function ordering the set - should be called whenever set is changed
sub _order {
  my $self = shift;

  $self->{last_i} = 0;
  my $num_elems = scalar @{$self->{x_vals}};
  my @order = sort { $self->{x_vals}->[$a] <=> $self->{x_vals}->[$b] } ( 0 .. ($num_elems - 1) );

  @{$self->{x_vals}} = @{$self->{x_vals}}[@order];
  @{$self->{y_vals}} = @{$self->{y_vals}}[@order];

  return;
}

#private part of value_at function
sub _values_in {
  my $self = shift;
  my $xes = shift;

  die "No x values" unless @{$xes};

  my $last_i = 0;
  my @ret;

  if (($self->{last_i} > 0) and ($xes->[0] >= $self->{x_vals}->[$self->{last_i}])) {
    $last_i = $self->{last_i};
  }

  my $num_elems = scalar @{$self->{x_vals}};
  my $gap = $self->{max_gap};

  if ($xes->[0] == $self->{x_vals}->[0]) {
    push @ret, $self->{y_vals}->[0];
    shift @{$xes};
  }

  foreach my $x (@{$xes}) {
    my ($lower_x, $lower_y, $upper_x, $upper_y);

    foreach my $index ($last_i .. ($num_elems - 1)) {

      if ($self->{x_vals}->[$index] >= $x) {
	$lower_x = $self->{x_vals}->[$index - 1];
	$upper_x = $self->{x_vals}->[$index];
	$lower_y = $self->{y_vals}->[$index - 1];
	$upper_y = $self->{y_vals}->[$index];

	$last_i = $index - 1;
	last;
      }
    }

    my $slope;
    my $y;
    if (defined $gap && $upper_x - $lower_x > $gap) { #asking for a value where there is a gap in the data....

       if ($x <= $lower_x + $gap / 2) { #if we're 'pretty close' to the bottom of the gap - extrapolate
 	my $i = $last_i;
 	until (defined $self->{y_vals}->[$i--] || $i < 0) { };

 	if ($i >= 0) {
 	  $slope = ($lower_y - $self->{y_vals}->[$i]) / ($lower_x - $self->{x_vals}->[$i]);
 	  $y = ($x - $lower_x) * $slope + $lower_y;
 	}
       }
       elsif ($x >= $upper_x - $gap / 2) { #close to top of the gap
 	my $i = $last_i + 1;
 	until (defined $self->{y_vals}->[$i++] || $i > $#{$self->{y_vals}}) { };

 	if ($i <= $#{$self->{y_vals}}) {
 	  $slope = ($self->{y_vals}->[$i] - $upper_y) / ($self->{x_vals}->[$i] - $upper_x);
 	  $y = ($upper_x - $x) * $slope + $upper_y;
 	}
       }
    }
    else {
      if (defined $upper_y and defined $lower_y) {
	$slope = ($upper_y - $lower_y) / ($upper_x - $lower_x);
	$y = ($x - $lower_x) * $slope + $lower_y;
      }
    }

    if (defined $y) {
      push @ret, $y;
    }
    else {
      push @ret, 0;
    }


    }

  $self->{last_i} = $last_i;

  return \@ret;
}

sub _values_out {
  my $self = shift;
  my $xes = shift;

  die "No x values" unless @{$xes};

  my @ret;

  foreach my $x (@{$xes}) {
    if ($x < $self->{x_vals}->[0]) {
      if ($self->{x_vals}->[0] - $x > $self->{max_gap}) {
	push @ret, 0;
      }
      else {
	my $slope = ($self->{y_vals}->[1] - $self->{y_vals}->[0]) / ($self->{x_vals}->[1] - $self->{x_vals}->[0]);
	push @ret, ($x - $self->{x_vals}->[0]) * $slope + $self->{y_vals}->[0];
      }
    }
    elsif ($x > $self->{x_vals}->[-1]) {
#      if ($x - $self->{x_vals}->[-1] > $self->{max_gap}) {
	push @ret, undef; #just truncate now
#      }
#      else {
#	my $slope = ($self->{y_vals}->[-1] - $self->{y_vals}->[-2]) / ($self->{x_vals}->[-1] - $self->{x_vals}->[-2]);
#	push @ret, ($x - $self->{x_vals}->[-2]) * $slope + $self->{y_vals}->[-2];
#      }
    }
    else {
      Data::Dumper->Dump([($self)]);
      die "-values_out called with '$x'\n";
    }
  }
  return \@ret;
}

#private part of coords function - also used by constructor
sub _load_coords {
  my $self = shift;
  my $coords = shift;

  $self->{x_vals} = [ map { $_->[0] } @{$coords} ];
  $self->{y_vals} = [ map { $_->[1] } @{$coords} ];

  return;
}

#does some basic sanity checking - called by constructor, and wherever contents are changed
sub _validate {
  my $self = shift;

  foreach my $n (@{$self->{x_vals}}) {
    die "x value '$n' is not numeric enough." if $n =~ /[^\d.-]/;
  }

  foreach my $n (@{$self->{y_vals}}) {
    die "y value '$n' is not numeric enough." if $n =~ /[^\d.-]/;
  }

  die "unequal number of x and y values." unless (scalar @{$self->{x_vals}} == scalar @{$self->{y_vals}});

  return 1;
}

#average some values from an arrayref
sub _ave {
  my $vals = shift;

  my $sum = 0;

  foreach my $v (@{$vals}) {
    next unless defined $v;
    $sum += $v;
  }

  return $sum / (scalar @{$vals});
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

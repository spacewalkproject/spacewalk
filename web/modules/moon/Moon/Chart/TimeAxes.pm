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

package Moon::Chart::TimeAxes;

# class internal to Moon::Chart for rendering axes/tickmarks, etc...

# for now, this class is mainly a timestamp-x-axis Axes class until the base class is more clearly
# defined

use strict;

use Data::Dumper;

use Date::Format;
use Date::Manip;
use Moon::Image;
use RHN::Date;

my %time_formats = (
		    (60 * 1) => [ '%l:%M:%S%p', 'Minute', 10, 60],  # minute
		    2 * (60 * 60) => [ '%l:%M%p', 'Hourly', 600, 600],  # hour
		    2 * (24 * 3600) => [ '%l:%M%p', 'Daily', 14400, 3600], # day
		    2 * 7 * (24 * 3600) => [ '%b %e', 'Weekly', 86400, 24 * 3600],
		    2 * 31 * (24 * 3600) => [ '%b %e', 'Monthly', 345600, 24 * 3600], # month
		    365 * (24 * 3600) => [ '%b %y', 'Yearly', 2592000, 24 * 3600] # year
		   );


sub new {
  my $class = shift;
  my $self = bless { }, $class;

  $self->{__data_mins__} = shift;
  $self->{__data_maxes__} = shift;

  if ($self->{__data_mins__} and $self->{__data_maxes__}) {
    $self->_calc_ticks();
  }

  $self->{__y_axis_format__} = "%.2f";
  $self->{__y_axis_divisor__} = shift || 1;

  $self->{__user__} = shift || undef;

  return $self;
}

sub set_y_axis_format {
  my $self = shift;
  $self->{__y_axis_format__} = shift;
}

sub set_y_axis_divisor {
  my $self = shift;
  $self->{__y_axis_divisor__} = shift;
}

sub set_bounds {
  my $self = shift;

  $self->{__data_mins__} = shift;
  $self->{__data_maxes__} = shift;

  $self->_calc_ticks();
}


sub get_bounds {
  my $self = shift;
  return ($self->{__data_mins__}, $self->{__data_maxes__});
}

sub _calc_ticks {
  my $self = shift;

  # figure out ticks
  my $delta_x = $self->{__data_maxes__}->[0] - $self->{__data_mins__}->[0];

  my $time_scale;
  my @timescales = sort { $a <=> $b } map { int($_) } keys %time_formats;

  foreach my $timescale (@timescales) {
    if ($delta_x < $timescale) {
      $time_scale = $time_formats{$timescale};
      last;
    }
  }

  die "no time scale determined!" unless $time_scale;

  $self->{__time_scale__} = $time_scale;

  my @xs = $self->_x_ticks($time_scale->[2], $time_scale->[3],
					    $self->{__data_mins__}->[0], $self->{__data_maxes__}->[0]);

  $self->{__x_ticks__} = \@xs;

  my @ys = $self->_y_ticks();

  $self->{__y_ticks__} = \@ys;
}


sub _y_ticks {
  my $self = shift;

  my $delta_y = $self->{__data_maxes__}->[1] - $self->{__data_mins__}->[1];
  my $num_ticks = 5;

  return map { $self->{__data_mins__}->[1] + $_ * $delta_y / $num_ticks } (0..$num_ticks);
}

sub _x_ticks {
  my $self = shift;
  my $delta = shift;
  my $step_or_weird_var_that_is_not_needed_because_this_is_weird_code = shift;
  my $start = shift;
  my $end = shift;

  my @dates;
  for (my $cur = $start; $cur <= $end; $cur += $delta) {
    push @dates, $cur;
  }

  push @dates, $end if $dates[-1] != $end;

  return @dates;
}

sub _draw {
  my $self = shift;
  my $image = shift;
  my $point_mapper = shift;
  my $graph_width = shift;
  my $graph_height = shift;


  $self->_calc_ticks() if (!$self->{__x_ticks__});

  my @x_ticks = @{$self->{__x_ticks__}};
  my @y_ticks = @{$self->{__y_ticks__}};


  # make sure we have grey and black for drawing
  my $grey = $image->get_color(204, 204, 204);
  my $black = $image->get_color(0, 0, 0);

  my $font_size = $image->get_font_size_tiny();

  foreach my $x_tick (@x_ticks) {

    my $x_tick_str;
    if ($self->{__user__}) {
      #if the user object has been passed in, then set the x_ticks to be in that user's timezone
      my $timestamp = new RHN::Date(-epoch => $x_tick, user => $self->{__user__});
      $x_tick_str = $timestamp->strftime($self->{__time_scale__}->[0]);
    }
    else {
      #if not, use the default system timezone in the x_ticks
      $x_tick_str = time2str($self->{__time_scale__}->[0], $x_tick);
    }
	
    my ($pix_x, $pix_y) = $point_mapper->($x_tick, $self->{__data_mins__}->[1]);
    my $pix_x_text = $pix_x - (int(length($x_tick_str) / 2) * $font_size->[0]);

    $image->draw_tiny_text($pix_x_text, $pix_y + 5, $x_tick_str, $black);
    $image->draw_line($pix_x, $pix_y, $pix_x, $pix_y - $graph_height, $grey);
  }

  foreach my $y_tick (@y_ticks) {

    my ($pix_x, $pix_y) = $point_mapper->($self->{__data_mins__}->[0], $y_tick);

    $y_tick = sprintf($self->{__y_axis_format__}, $y_tick / $self->{__y_axis_divisor__});
    my $pix_x_text = $pix_x - (int(length($y_tick)) * $font_size->[0] + 2);

    $image->draw_tiny_text($pix_x_text, $pix_y - $font_size->[1]/2, $y_tick, $black);
    $image->draw_line($pix_x, $pix_y, $pix_x + $graph_width, $pix_y, $grey);
  }
}

1;

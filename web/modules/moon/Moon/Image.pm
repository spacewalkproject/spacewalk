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

package Moon::Image;

use strict;

use GD;
use Data::Dumper;

sub new {
  my $class = shift;
  my ($x, $y) = @_;

  my $self = bless { }, $class;

  $self->{__image__} = new GD::Image($x, $y);

  return $self;
}

# returns (size_x, size_y)
sub get_size {
  my $self = shift;
  return $self->{__image__}->getBounds();
}

# returns true/false whether image loaded from file properly
sub load_from_file {
  my $class = shift;
  my $filename = shift;

  my $self = bless { }, $class;

  $self->{__image__} = GD::Image->new($filename);

  die "Problem loading image $filename ..." unless ($self->{__image__});

  return $self;
}

sub save {
  my $self = shift;
  my $filename = shift;

  open(NEW_IMAGE, ">$filename") or die "Problem saving $filename:  $!";

  print NEW_IMAGE $self->{__image__}->png;

  close(NEW_IMAGE);

  return 1;
}

# adds a color (R, G, B) to the image's color table and returns the index of the color
# you have to use this before you can use colors
sub add_color {
  my $self = shift;
  return $self->{__image__}->colorAllocate(shift, shift, shift);
}

# probably won't need this...
sub remove_color {
  my $self = shift;
  $self->{__image__}->colorDeallocate(shift);
}

# gets (or adds and gets) desired RGB color
sub get_color {
  my $self = shift;
  return $self->{__image__}->colorResolve(@_)
}

# returns (r, g, b) for given color index
sub get_rgb {
  my $self = shift;
  my $color_index = shift;
  return $self->{__image__}->rgb($color_index);
}

# marks a certain color as transparent
sub set_transparent {
  my $self = shift;

  $self->{__image__}->transparent(shift);
}

# gets the current transparent color index
sub get_transparent {
  my $self = shift;
  return $self->{__image__}->transparent();
}


# Graphics primatives...
# =============================

# draw point given (x1, y1, color_index)
sub draw_pixel {
  my $self = shift;
  $self->{__image__}->setPixel(@_);
}

# draw a line given (x1, y1, x2, y2, color_index)
sub draw_line {
  my $self = shift;
  $self->{__image__}->line(@_);
}

# draw a dashed line given (x1, y1, x2, y2, color_index)
sub draw_dashed_line {
  my $self = shift;
  $self->{__image__}->dashedLine(@_);
}

# draw a rectangle given (x1, y1, x2, y2, color_index)
sub draw_rectangle {
  my $self = shift;
  $self->{__image__}->rectangle(@_);
}

# draw a filled rectangle given (x1, y1, x2, y2, color_index)
sub draw_filled_rectangle {
  my $self = shift;
  warn "drawing filled rectangle...";
  $self->{__image__}->filledRectangle(@_);
}

# draw text in tiny font given (x, y, string, color)
sub draw_tiny_text {
  my $self = shift;
  $self->{__image__}->string(gdTinyFont, @_);
}

# draw text in tiny font given (x, y, string, color)
sub draw_text {
  my $self = shift;
  $self->{__image__}->string(gdSmallFont, @_);
}

# return [width, height] of tiny font
sub get_font_size_tiny {
  my $self = shift;
  return [ gdTinyFont->width, gdTinyFont->height ];
}

# return [width, height] of tiny font
sub get_font_size_normal {
  my $self = shift;
  return [ gdSmallFont->width, gdSmallFont->height ];
}

my $VERSION = '0.01';

1;
__END__
#POD

=head1 NAME

Moon::Image - Implementation of a Image class for use with RHN Monitoring.

=head1 SYNOPSIS

  use Moon::Image;

=head1 DESCRIPTION

An object which will render a Chart of a Dataset in png format.

=head2 EXPORT

No.

=head1 AUTHOR

Spacewalk Team <rhn-feedback@redhat.com>

=head1 SEE ALSO

rhn.redhat.com

L<perl>.

=cut

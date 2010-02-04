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

package Grail::Canvas;
use Grail::Component;
use Carp;
use PXT::Utils ();

@Grail::Canvas::ISA = qw/Grail::Component/;

my @component_modes =
  (
   [ 'render_canvas', 'render_canvas', undef, undef ],
  );

sub component_modes {
  return @component_modes;
}

# canvas block format:
# <grail-canvas mode="left">
#
#   <grail:component name="Foo::Bar" param1="x" param2="y" ...>
#   <grail:component name="Foo::Baz" mode="hardcoded" param1="x" param2="y" ...>
#
#   <grail:header>
#     <table border=1><tr><td>
#   </grail:header>
#
#   <grail:footer>
#     </td></tr></table>
#   </grail:footer>
#
#   <grail:twixt>
#     </td></tr><tr><td>
#   </grail:twixt>
#
# </grail-canvas>

sub render_canvas {
  my $self = shift;
  my $pxt = shift;
  my $mode = shift;
  my $block = shift;


  my @component_tags = map { [ PXT::Utils::split_attributes($_) ] } $block =~ m(<grail:component (.*?)/>)gi;

#  unless (@component_tags) {
#    croak "No <grail:component> block in $mode canvas";
#  }

  if (not @component_tags) {
    return $block;
  }

  my @components;
  foreach my $c (@component_tags) {
    my %c_hash = @{$c};
    my $file = $c_hash{name};
    $file =~ s/::/\//g;
    require "$file.pm";
    push @components, [ $c_hash{name}->new(), $c_hash{mode} || $mode, $c ];
  }

  return $self->render_components($pxt, $mode, $block, @components);
}


sub render_components {
  my $self = shift;
  my $pxt = shift;
  my $mode = shift;
  my $block = shift;
  my @components = @_;

  my $header = block_guts("grail:header", $block) || "";
  my $footer = block_guts("grail:footer", $block) || "";
  my $twixt = block_guts("grail:twixt", $block) || "";
#  warn "components: " . join(", ", map { @$_ } @components);
  return $header . join($twixt, map { $_->[0]->render($pxt, -mode => $_->[1], -params => $_->[2]) } @components) . $footer;
}

sub block_guts {
  my $tag = shift;
  my $block = shift;

  return unless $tag and $block;

  return $block =~ m(<$tag>(.*?)</$tag>)gism ? $1 : ();
}

1;

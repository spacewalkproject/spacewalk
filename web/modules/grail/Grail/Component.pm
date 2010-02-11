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
package Grail::Component;

use Carp;

sub new {
  my $class = shift;

  my $self = bless {}, $class;

  $self->initialize;
  return $self;
}

sub render {
  my $self = shift;
  my $pxt = shift;
  my %params = @_;

  my $mode = $params{-mode};
  my $mode_params = $params{-params};
  Carp::croak "No mode given to Grail::Component->render" unless $mode;

  my $method = $self->render_mapping($mode);
  Carp::croak "No mapping for $self - > $mode" unless $method;
  $method = $method->[1];

  return $self->$method($pxt, @{$mode_params});
}

# current thoughts: mode and handler are required.  label and optional config
# coderef are for thumbnail components

sub register_render_mode {
  my $self = shift;
  my $mode = shift;
  my $handler = shift;
  my $label = shift;
  my $config_method = shift;

  $self->{_render_map_}->{$mode} = [ $mode, $handler, $label, $config_method ];
}

sub render_mapping {
  my $self = shift;

  Carp::croak "$self has no render map"
      unless exists $self->{_render_map_};

  return $self->{_render_map_}->{+shift};
}

sub initialize {
  my $self = shift;

  $self->register_render_mode(@$_)
    foreach $self->component_modes;
}

1;

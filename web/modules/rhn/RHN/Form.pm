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

package RHN::Form;

use strict;

use RHN::Exception qw/throw/;
use RHN::Form::Widget;

my @valid_fields = qw/name label action method widgets enctype/;

sub new {
  my $class = shift;
  my %attr = @_;

  my $self = bless { name => 'Anonymous Form',
		     label => 'anon_form',
		     action => undef,
		     method => 'POST',
		     widgets => [],
		     widgets_by_label => {},
		     acl_mixins => [],
		     enctype => "application/x-www-form-urlencoded",
		   }, $class;

  foreach (@valid_fields) {
    if (exists $attr{$_}) {
      $self->$_($attr{$_});
    }
  }

  return $self;
}

sub valid_fields {
  return @valid_fields;
}

sub name {
  my $self = shift;
  my $name = shift;

  if (defined $name) {
    $self->{name} = $name;
  }

  return $self->{name};
}

sub label {
  my $self = shift;
  my $label = shift;

  if (defined $label) {
    throw "Attempt to set invalid label '$label' for form '" . $self->label . "'."
      if $label =~ /\W/;
    $self->{label} = $label;
  }

  return $self->{label};
}

sub action {
  my $self = shift;
  my $action = shift;

  if (defined $action) {
    $self->{action} = $action;
  }

  return $self->{action};
}

sub enctype {
  my $self = shift;
  my $enctype = shift;

  if (defined $enctype) {
    $self->{enctype} = $enctype;
  }

  return $self->{enctype};
}

sub method {
  my $self = shift;
  my $method = shift;

  if (defined $method) {
    $method = uc($method);
    throw "Attempt to set invalid method '$method' for form '" . $self->label . "'."
      unless ($method eq 'POST' or $method eq 'GET');
    $self->{method} = $method;
  }

  return $self->{method};
}

sub widgets {
  my $self = shift;
  my $widgets = shift;

  if (defined $widgets and (ref $widgets eq 'ARRAY')) {
    $self->{widgets} = [];
    $self->add_widget($_) foreach (@{$widgets});
  }

  return @{$self->{widgets}};
}

sub acl_mixins {
  my $self = shift;
  my $mixins = shift;

  if (ref $mixins eq 'ARRAY') {
    $self->{acl_mixins} = $mixins;
  }
  elsif (defined $mixins) {
    $self->{acl_mixins} = [ split /,\s*/, $mixins ];
  }

  return @{$self->{acl_mixins}};
}

sub add_widget {
  my $self = shift;
  my $widget = shift;

  unless (ref $widget and $widget->isa('RHN::Form::Widget')) {
    my $widget_class = RHN::Form::Widget->find_class($widget);
    my $data = shift;
    $widget = eval "new $widget_class (\%{\$data})";
    if ($@) {
      throw $@;
    }
  }

  throw "Widget labels must be unique - adding widget '" . $widget->label . "' in form '" . $self->label . "'."
    if (grep { $widget->label eq $_->label } $self->widgets);

  push @{$self->{widgets}}, $widget;
  $self->{widgets_by_label}->{$widget->label} = $widget;

  # Forms with file input widgets must have an enctype of 'multipart/form-data'
  if ($widget->isa('RHN::Form::Widget::File')) {
    $self->enctype('multipart/form-data');
  }

  return;
}

sub remove_widget {
  my $self = shift;
  my $label = shift;

  delete $self->{widgets_by_label}->{$label};

  $self->{widgets} = [ grep { $_->label ne $label } @{$self->{widgets}} ];

  return;
}

sub lookup_widget {
  my $self = shift;
  my $label = shift;

  return $self->{widgets_by_label}->{$label};
}

sub clone_widgets {
  my $self = shift;

  my @ret;

  foreach my $widget ($self->widgets) {
    push @ret, $widget->clone;
  }

  return @ret;
}

sub compute_hmac {
  my $self = shift;

  my @hidden =
    grep { $_->label ne 'formvar_hmac' }
      grep { $_->isa('RHN::Form::Widget::Hidden') } $self->widgets;

  my $hidden = join "\0", map { $_->label . '|' . ($_->value || '') } @hidden;
  my $formvar_hmac = RHN::SessionSwap->rhn_hmac_data($hidden);

  return $formvar_hmac;
}

sub param {
  my $self = shift;
  my $label = shift;

  my $widget = $self->lookup_widget($label);

  return unless $widget;

  return $widget->raw_value;
}

1;

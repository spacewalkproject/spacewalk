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

package RHN::Form::Widget::Multiple;

use strict;
use PXT::HTML;

use RHN::Form::Widget;

our @ISA = qw/RHN::Form::Widget/;

my %valid_fields = (widgets => [],
		    joiner => '');

sub valid_fields { return (shift->SUPER::valid_fields(), %valid_fields) }

sub editable { 1 }

sub widgets {
  my $self = shift;
  my $widgets = shift;

  if (defined $widgets) {
    $self->{widgets} = $widgets;
  }

  return $self->{widgets};
}

sub joiner {
  my $self = shift;
  my $joiner = shift;

  if (defined $joiner) {
    $self->{joiner} = $joiner;
  }

  return $self->{joiner};
}

sub set_value {
  my $self = shift;
  my @values = @_;

  my @errors;

  foreach my $widget (@{$self->widgets}) {
    next if $widget->isa('RHN::Form::Widget::Literal');
    my $resp = $widget->set_value(shift @values);
    if (ref $resp == 'ARRAY') {
      push @errors, @{$resp};
    }
  }

  return @errors;
}

sub value {
  my $self = shift;

  my @ret;

  foreach my $widget (@{$self->widgets}) {
    push @ret, $widget->value(shift);
  }

  return @ret;
}

sub raw_value {
  my $self = shift;
  my $value = shift || [];

  my @ret;

  my @values = @{$value};
  foreach my $widget (@{$self->widgets}) {
    next if $widget->isa('RHN::Form::Widget::Literal');
    my $value = shift @values;

    if (defined $value) {
      $widget->{value} = $value;
    }
    push @ret, defined $widget->{value} ? $widget->{value} : $widget->{default};
  }

  return @ret;
}

sub prefill_value {
  my $self = shift;

  return $self->raw_value(@_);
}

sub render {
  my $self = shift;

  my @list_of_lists;
  my @current_list;

  foreach my $widget (@{$self->widgets}) {
    my $val = $widget->render || '';
    $val =~ s/\n//g;

    if ($widget->isa('RHN::Form::Widget::Literal')) {
      push @list_of_lists, join($self->joiner, @current_list);
      push @list_of_lists, $val;
      @current_list = ();
    }
    else {
      push @current_list, $val;
    }
  }

  push @list_of_lists, join($self->joiner, @current_list);

  return join("\n", @list_of_lists);
}

1;

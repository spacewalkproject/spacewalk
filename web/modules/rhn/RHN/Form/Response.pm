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

package RHN::Form::Response;

use strict;

use RHN::Form;
use RHN::Form::Widget;

our @ISA = qw/RHN::Form/;

sub accept_params {
  my $self = shift;
  my $params = shift;

  my @errors;

  foreach my $label ($self->widget_labels) {
    my $widget = $self->lookup_widget($label);
    next unless $widget;

    my $ret = $widget->set_value($params->{$label});
    if (ref $ret eq 'ARRAY') {
      push @errors, ( @{$ret} );
    }
  }

  my %seen;

  return [ grep { not $seen{$_}++ } @errors ];
}

sub widget_labels {
  my $self = shift;

  return map { $_->label } $self->widgets;
}

sub answers {
  my $self = shift;

  my %answers;

  foreach my $widget ($self->widgets) {
    next if $widget->errors;
    next unless $widget->editable;
    next unless defined $widget->value;
    if (ref $widget->value eq 'ARRAY') {
      next unless (@{$widget->value});
    }

    $answers{$widget->label} = $widget->raw_value;
  }

  return \%answers;
}

# do all the widgets have an answer?
sub status {
  my $self = shift;

  my %stats = (total => 0,
	       errors => 0,
	       answered => 0);

  foreach my $widget ($self->widgets) {
    next unless $widget->editable;
    $stats{total}++;
    $stats{errors}++ if $widget->errors;
    $stats{answered}++
      if (defined $widget->value or defined $widget->default);
  }

  if ($stats{answered} == 0) {
    return 'viewed';
  }

  if (not $stats{errors}) {
    return 'complete';
  }

  return 'partial';
}

1;

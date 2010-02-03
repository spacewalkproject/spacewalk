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

package RHN::Form::RealizedForm;

use strict;

use RHN::Form;
use PXT::HTML;

use RHN::Form::Widget;
use RHN::Form::Widget::Hidden;

our @ISA = qw/RHN::Form/;

sub render {
  my $self = shift;
  my $template = shift;

  my $html = $template->form_header(PXT::HTML->form_start(-method => $self->method,
							  -action => $self->action,
							  -name => $self->label,
							  -enctype => $self->enctype));

  $html .= $template->rows_header($self->name);

  my @hidden;
  my @submit;

  foreach my $widget ($self->widgets) {

    if ($widget->isa('RHN::Form::Widget::Hidden')) {
      push @hidden, $widget;
    }
    elsif ($widget->isa('RHN::Form::Widget::Submit')) {
      push @submit, $widget;
    }
    elsif ($widget->is_required) {
      $html .= $template->required_row($widget->label, $widget->name, $widget->render);
    }
    else {
      $html .= $template->row($widget->label, $widget->name, $widget->render);
    }
  }

  push @hidden, new RHN::Form::Widget::Hidden(label => 'formvar_hmac',
					      value => $self->compute_hmac);

  $html .= $template->rows_footer;

  $html .= $template->hidden_row(map { $_->render } @hidden);
  $html .= $template->submit_row(map { $_->render } @submit);

  $html .= $template->form_footer;

  return $html;
}

sub accept_params {
  my $self = shift;
  my $params = shift;

  my @errors;

  foreach my $label (keys %{$params}) {
    next unless defined $params->{$label};
    my $widget = $self->lookup_widget($label);
    next unless $widget;

    $widget->prefill_value($params->{$label});
  }

  return \@errors; # always empty
}

sub widget_labels {
  my $self = shift;

  return map { $_->label } $self->widgets;
}

1;

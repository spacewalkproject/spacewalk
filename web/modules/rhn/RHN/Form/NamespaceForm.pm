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

package RHN::Form::NamespaceForm;

use strict;

use RHN::Form::RealizedForm;
our @ISA = qw/RHN::Form::RealizedForm/;

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

  my %by_label = map {$_ => 0} qw/up down add_namespace ns_id remove_namespaces current_proposed/;

  foreach my $widget ($self->widgets) {

    if ($widget->label and exists $by_label{$widget->label}){
      $by_label{$widget->label} = $widget;
      next;
    }

    if ($widget->isa('RHN::Form::Widget::Hidden')) {
      push @hidden, $widget;
    }
    elsif ($widget->isa('RHN::Form::Widget::Submit')) {
      push @submit, $widget;
    }
  }

  push @hidden, new RHN::Form::Widget::Hidden(label => 'formvar_hmac',
                                              value => $self->compute_hmac);

  if ($by_label{ns_id}) {
    my $control = $by_label{ns_id};
    $html .= $template->column($control->label,
                               $control->name,
                               join("<br />\n", $control->render),
                              );
  }


  if ($by_label{ns_id} or $by_label{current_proposed}) {

    my @controls;

    if ($by_label{add_namespace}) {
      push @controls, ($by_label{add_namespace})->render;
    }

    if ($by_label{remove_namespaces}) {
      push @controls, ($by_label{remove_namespaces})->render;
    }

    $html .= $template->control_column(@controls);
  }

  if ($by_label{current_proposed}) {
    my $control = $by_label{current_proposed};
    $html .= $template->column($control->label,
                               $control->name,
                               $control->render,
                              );

    my @controls;
    if ($by_label{up}) {
      push @controls, ($by_label{up})->render;
    }

    if ($by_label{down}) {
      push @controls, ($by_label{down})->render;
    }

    $html .= $template->control_column(@controls);
  }


  $html .= $template->rows_footer;

  $html .= $template->hidden_row(map { $_->render } @hidden);
  $html .= $template->submit_row(map { $_->render } @submit);

  $html .= $template->form_footer;

  return $html;
}

1;

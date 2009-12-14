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

use strict;

package Sniglets::Forms;

use File::Spec;
use Digest::MD5;
use RHN::Exception qw/throw/;

use RHN::Form;
use RHN::Form::Parser;
use RHN::Form::ParsedForm;
use Sniglets::Forms::Style;

use PXT::Utils;

use PXT::ACL;

sub register_tags {
  my $class = shift;
  my $pxt = shift;
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:catch_form', \&catch_form_cb);
}

sub catch_form_cb {
  my $pxt = shift;

  my $obj = catch_form($pxt);
  my $url;

  if ($obj) {
    $obj->commit;

    my $redirect_url = $pxt->dirty_param('url');
    my $id_formvar = $pxt->dirty_param('id_formvar');
    if ($redirect_url) {
        $url = $redirect_url;
    }
    else {
        $url = $pxt->uri;
    }

    $url = $url . '?' . $id_formvar . '=' . $obj->id;
  }

  $pxt->push_message(site_info => "Item updated.");
  $pxt->redirect($url) if $url;

  return;
}

sub catch_form {
  my $pxt = shift;

  my $file = $pxt->dirty_param('form_file');

  throw "Could not load form '$file'."
    unless ($file);

  my $pform = RHN::Form::Parser->parse_file($file);

  throw "'$pform' is not a RHN::Form::ParsedForm"
    unless (ref $pform && $pform->isa('RHN::Form::ParsedForm'));

  my $file_widget = new RHN::Form::Widget::Hidden(name => 'Form File',
						  label => 'form_file',
						  default => $file);

  $pform->add_widget($file_widget);

  my $acl_parser = new PXT::ACL (mixins => [ $pform->acl_mixins ]);
# remove widgets based upon ACLs
  foreach my $widget ($pform->widgets) {
    next unless $widget->acl;

    if (not $acl_parser->eval_acl($pxt, $widget->acl)) {
      $pform->remove_widget($widget->label);
    }
  }

  my $form = $pform->prepare_response;
  my $errors = load_params($pxt, $form);
  my $source = $pxt->dirty_param('source');

  if (@{$errors}) {
    foreach my $error (@{$errors}) {
      $pxt->push_message(local_alert => $error);
    }
    return;
  }

  if ($source) {
    my $id_formvar = $pxt->dirty_param('id_formvar');

    PXT::Utils->untaint(\$source);

    eval "use $source";
    die $@ if $@;

    my $obj = $source->lookup(-id => $pxt->passthrough_param($id_formvar));

    foreach my $widget ($form->widgets) {
      my $label = $widget->label;

      next if $widget->isa('RHN::Form::Widget::Literal');
      next unless $obj->can($label);

      my $val = $widget->raw_value;
      $obj->$label($val);
    }

    return $obj;
  }

  return;
}

sub load_params {
  my $pxt = shift;
  my $form = shift;

  my @needed_params = $form->widget_labels;

  my %params;

  foreach my $param (@needed_params) {
    my @results = $pxt->passthrough_param($param);

    if (@results > 1) {
      $params{$param} = \@results;
    }
    else {
      $params{$param} = $results[0];
    }
  }

  my $errors = $form->accept_params(\%params);

  return $errors;
}

1;

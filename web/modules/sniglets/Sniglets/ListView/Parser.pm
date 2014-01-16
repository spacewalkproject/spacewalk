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

package Sniglets::ListView::Parser;
use strict;

use Sniglets::ListView::ExtraClasses;
use XML::LibXML;

sub parse {
  my $class = shift;
  my $string = shift;

  my $parser = new XML::LibXML;
  $parser->keep_blanks(0);
  $parser->expand_xinclude(1);
  my $doc = $parser->parse_string($string);
  my $root = $doc->getDocumentElement;

  die "Sniglets::ListView::Parser->parse(): root element not rhn-listview"
    unless $root->nodeName eq 'rhn-listview';

  die "Sniglets::ListView::Parser->parse(): required attribute mode not present"
    unless $root->getAttribute('mode');

  my $lv = new Sniglets::ListView::ParsedView mode => $root->getAttribute('mode');
  $lv->columns([]);
  $lv->actions([]);
  $lv->formvars([]);

  for my $xml_node (grep { $_->isa("XML::LibXML::Element") } $root->childNodes) {
    if ($xml_node->nodeName eq 'column') {
      my $column = $class->process_column($xml_node);
      $lv->push_columns($column);
    }
    elsif ($xml_node->nodeName eq 'empty_list_message') {
      my @text_nodes = $xml_node->childNodes;
      if (@text_nodes != 1) {
	warn "empty_list_message element must have exactly one child element: " . $xml_node->toString;
	next;
      }

      $lv->empty_list_message($text_nodes[0]->getData);
    }
    elsif ($xml_node->nodeName eq 'set') {
      my $set_label = $xml_node->getAttribute('label');
      my $set_acl = $xml_node->getAttribute('acl');
      die "<set> child tag encountered in <rhn-listview> without label"
	unless $set_label;

      $lv->set_label($set_label);
      $lv->set_acl($set_acl);
    }
    elsif ($xml_node->nodeName eq 'formvars') {
      $lv->push_formvars($class->process_formvars($xml_node));
    }
    elsif ($xml_node->nodeName eq 'action') {
      $lv->push_actions($class->process_action($xml_node));
    }
    else {
      warn "listview parser, unknown node: " . $xml_node->toString;
      next;
    }
  }

  return $lv;
}

sub process_formvars {
  my $class = shift;
  my $xml_node = shift;

  my @ret;
  for my $var_node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    if ($var_node->nodeName ne 'var') {
      die "non var child node of listview column node: " . $var_node->toString;
    }

    my $name = $var_node->getAttribute('name');
    my $type = $var_node->getAttribute('type') || 'propagate';
    die "Name not specified in formvars section" unless $name;

    my $formvar = new Sniglets::ListView::ParsedFormvar name => $name, type => $type;

    if ($type eq 'literal') {
      my @text_nodes = $var_node->childNodes;
      die "var section named '$formvar' should only have one child node."
	unless (@text_nodes == 1);

      $formvar->value($text_nodes[0]->getData);
    }

    push @ret, $formvar;
  }

  return @ret;
}

sub process_column {
  my $class = shift;
  my $xml_node = shift;

  foreach (qw/name label/) {
    die "Missing required column attribute: $_"
      unless $xml_node->getAttribute($_);
  }

  my $name = $xml_node->getAttribute('name');
  my $label = $xml_node->getAttribute('label');
  my $sort_by = $xml_node->getAttribute('sort_by') || 0;
  my $align = $xml_node->getAttribute('align') || 'left';
  my $width = $xml_node->getAttribute('width') || '';
  my $nowrap = $xml_node->getAttribute('nowrap') || '';
  my $acl = $xml_node->getAttribute('acl') || '';
  my $htmlify = $xml_node->getAttribute('htmlify') ? 1 : 0;
  my $is_date = $xml_node->getAttribute('is_date') || 0;

  my $column = new Sniglets::ListView::ParsedColumn name => $name, label => $label;
  $column->sort_by($sort_by);
  $column->align($align);
  $column->width($width);
  $column->nowrap($nowrap);
  $column->acl($acl);
  $column->htmlify($htmlify);
  $column->is_date($is_date);

  my %allowed_nodes = map { $_ => 1 } qw/url pre-content content post-content/;
  for my $node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    if (not exists $allowed_nodes{$node->nodeName}) {
      die "invalid child node of listview column node: " . $node->toString;
    }

    my $attribute = $node->nodeName;
    $attribute =~ s/-/_/g;

    $column->$attribute(PXT::Utils->escape_html($node->textContent));
  }

  return $column;
}

sub process_action {
  my $class = shift;
  my $xml_node = shift;

# name is required
  foreach (qw/name/) {
    die "Missing required action attribute: $_"
      unless $xml_node->getAttribute($_);
  }
  die "action element with child nodes" if $xml_node->childNodes;

  my $name = $xml_node->getAttribute('name');
  my $label = $xml_node->getAttribute('label') || '';
  my $action_class = $xml_node->getAttribute('class');
  my $action_acl = $xml_node->getAttribute('acl');

  my $action = new Sniglets::ListView::ParsedAction name => $name, label => $label, class => $action_class, acl => $action_acl;

  my $url = PXT::Utils->escape_html($xml_node->getAttribute('url') || '');
  $action->url($url) if $url;

  return $action;
}

sub Sniglets::ListView::ParsedView::push_columns {
  my $self = shift;
  my $cols = $self->columns;

  push @$cols, @_;
}

sub Sniglets::ListView::ParsedView::push_actions {
  my $self = shift;
  my $actions = $self->actions;

  push @$actions, @_;
}

sub Sniglets::ListView::ParsedView::push_formvars {
  my $self = shift;
  my $vars = $self->formvars;

  push @$vars, @_;
}

1;

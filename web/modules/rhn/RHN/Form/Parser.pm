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

package RHN::Form::Parser;

use strict;
use XML::LibXML;

use RHN::Form::ParsedForm;
use RHN::Form::Widget;
use RHN::Form::Widget::Literal;
use RHN::Form::Widget::Text;
use RHN::Form::Widget::TextArea;
use RHN::Form::Widget::Password;
use RHN::Form::Widget::Select;
use RHN::Form::Widget::Checkbox;
use RHN::Form::Widget::CheckboxGroup;
use RHN::Form::Widget::RadiobuttonGroup;
use RHN::Form::Widget::Hidden;
use RHN::Form::Widget::Submit;
use RHN::Form::Widget::File;

use RHN::Exception qw/throw/;

my %node_types = 
  ( 'rhn-form' => { required => { name => 1, label => 1 },
		    optional => { action => 1, method => 1, acl_mixins => 1 } },
    'widget'   => { required => { label => 1, type => 1 },
		    optional => { name => 1, default => 1, size => 1, maxlength => 1, multiple => 1, rows => 1, cols => 1, acl => 1, checked => 1, populate_options => 1 } },
    'opt'      => { required => { label => 1 },
		    optional => { value => 1, default => 1, multiple => 1 } },
    'filter'   => { required => { type => 1 },
		    optional => { } },
    'require'  => { permissive => 1 } # special case
  );

sub parse_file {
  my $class = shift;
  my $file = shift;

  my $parser = new XML::LibXML;
  $parser->keep_blanks(0);
  $parser->expand_xinclude(1);
  my $doc = $parser->parse_file($file);
  my $root = $doc->getDocumentElement;

  return parse_tree($root);
}

sub parse_string {
  my $class = shift;
  my $data = shift;

  my $parser = new XML::LibXML;
  $parser->keep_blanks(0);
  $parser->expand_xinclude(1);
  my $doc = $parser->parse_string($data);
  my $root = $doc->getDocumentElement;

  return parse_tree($root);
}

sub parse_tree {
  my $root = shift;

  throw "parse_tree: root element not rhn-form."
    unless $root->nodeName eq 'rhn-form';

  my %attr = parse_attributes($root);

  my $pform = new RHN::Form::ParsedForm(%attr);

  foreach my $xml_node (grep { $_->isa("XML::LibXML::Element") } $root->childNodes) {
    unless ($xml_node->nodeName eq 'widget') {
      warn "Not a widget node: '" . $xml_node->toString . "'.";
      next;
    }

    my $widget = process_widget($xml_node);
    $pform->add_widget($widget);
  }

  return $pform;
}

sub process_widget {
  my $node = shift;

  my %attr = parse_attributes($node);

  my $type = delete $attr{type};
  my $widget_class = RHN::Form::Widget->find_class($type);

  my $widget = new $widget_class (%attr);

  foreach my $child ($node->childNodes) {
    my %child_attr = parse_attributes($child);
    if ($child->nodeName eq 'filter') {
      $widget->add_filter(\%child_attr);
    }
    elsif ($child->nodeName eq 'require') {
      $widget->add_require(\%child_attr);
    }
    elsif ($child->nodeName eq 'opt') {
      $widget->add_option(\%child_attr);
    }
  }

  return $widget;
}

sub parse_attributes {
  my $node = shift;

  my $name = $node->nodeName;
  my @attrs = $node->attributes;

  unless (exists $node_types{$name}) {
    throw "Parse error: Unknown node '$name'";
  }

  my %needed = map { ($_, 1) } keys %{$node_types{$name}->{required}}; # copy needed params

  my %ret;

  foreach my $attr (@attrs) {
    delete $needed{$attr->nodeName};

    next if ($attr->nodeName eq 'xml:base' or $attr->nodeName eq 'xmlns:xi'); # xml:base comes from Xinclude

    unless ( $node_types{$name}->{required}->{$attr->nodeName} ||
	     $node_types{$name}->{optional}->{$attr->nodeName} ||
	     $node_types{$name}->{permissive} ) { # a valid attr
      throw "Parse error: Invalid attribute '" . $attr->nodeName . "' for node '$name'";
    }

    $ret{$attr->nodeName} = $attr->getValue;
  }

  if (%needed) {
    throw sprintf(q(Parse error: Missing param%s '%s' for node '%s'.),
		  keys %needed == 1 ? '' : 's',
		  join(", ", keys %needed),
		  $node->toString);
  }

  return %ret;
}

1;

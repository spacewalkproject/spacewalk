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
package RHN::API::Parser;

use RHN::API::Method;
use RHN::API::TypeHandler;

use Carp;
use XML::LibXML;

sub parse_interface {
  my $class = shift;
  my $method_prefix = shift;
  my $file = shift;

  my $parser = new XML::LibXML;
  $parser->keep_blanks(0);
  $parser->expand_xinclude(1);
  my $doc = $parser->parse_file($file);
  my $root = $doc->getDocumentElement;

  my $iface = new RHN::API::Interface $method_prefix;

  for my $xml_node (grep { $_->isa("XML::LibXML::Element") } $root->childNodes) {
    if ($xml_node->nodeName ne 'rhn-method') {
      warn "non-rhn-method node: " . $xml_node->toString;
      next;
    }

    my $method = $class->process_method($xml_node);
    $iface->add_method($method);
  }

  return $iface;
}

sub helper_find_nodes {
  my $node = shift;
  my $node_name = shift;
  my $min = shift;
  my $max = shift;

  my @nodes = grep { $_->isa("XML::LibXML::Element") and $_->nodeName eq $node_name } $node->childNodes;
  if (defined $min and scalar @nodes < $min) {
    die "Too few nodes of type '$node_name' found in node " . $node->toString(1);
  }
  if (defined $max and scalar @nodes > $max) {
    die "Too many nodes of type '$node_name' found in node " . $node->toString(1);
  }

  return @nodes;
}

sub process_method {
  my $class = shift;
  my $xml_node = shift;

  my $method_name = $xml_node->getAttribute("name");
  die "Invalid method name '$method_name' -- must not contain namespace information" if $method_name =~ /[.]/;

  my $method_version = $xml_node->getAttribute("version") || '0.1';
  my $method_sla = $xml_node->getAttribute("sla") || 'experimental';

  my $method = new RHN::API::Method $method_name, $method_version;
  $method->sla($method_sla);

  my %allowed_child_nodes = map { $_ => 1 } qw/description handler param return variant/;

  for my $node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    if (not exists $allowed_child_nodes{$node->nodeName}) {
      die "invalid rhn-method child node: " . $node->toString;
    }
  }

  for my $param_node (helper_find_nodes($xml_node, 'param')) {
    my %attrs = map { $_ => $param_node->getAttribute($_) } qw/name type required default slurp mangle/;

    # FIXME:  tie the information, not the whole node...
    my @kids = grep { $_->isa("XML::LibXML::Element") } $param_node->childNodes();
    $attrs{kids} = \@kids if @kids;

    $method->push_param(%attrs);
  }

  my ($return_node) = helper_find_nodes($xml_node, 'return', 1, 1);
  $method->return_type($return_node->getAttribute('type'));

  my @return_kids = grep { $_->isa("XML::LibXML::Element") } $return_node->childNodes();
  if (@return_kids) {
    # save 'em for rendering help...
    # FIXME:  tie the information, not the whole node...
   $method->return_kids(\@return_kids);
  }

  my ($handler_node) = helper_find_nodes($xml_node, 'handler', 1, 1);

  # use $method's name if the method attribute is not set
  $method->set_handler($handler_node->getAttribute('class'),
		       $handler_node->getAttribute('method') || $method->name)
    unless $handler_node->getAttribute('stub');


  my ($desc_node) = helper_find_nodes($xml_node, 'description', 0, 1);
  if ($desc_node) {
    $method->description($desc_node->textContent);
  }

  return $method;
}

1;

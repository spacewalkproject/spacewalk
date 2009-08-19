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

package Sniglets::Navi::Parser;

use strict;
use XML::LibXML;

use Sniglets::Navi::Tree;
use Sniglets::Navi::Node;

my %allowed_navfile_attributes = (label => 1, formvar => 1, invisible => 1, 'xmlns:xi' => 1, 'title-depth' => 1, acl_mixins => 1);

sub parse_navfile {
  my $class = shift;
  my $file = shift;

  my $parser = new XML::LibXML;
  $parser->keep_blanks(0);
  $parser->expand_xinclude(1);
  my $doc = $parser->parse_file($file);
  my $root = $doc->getDocumentElement;

  die "Sniglets::Navi::Parser->parse_navfile($file): root element not rhn-navi-tree"
    unless $root->nodeName eq 'rhn-navi-tree';

  die "Sniglets::Navi::Parser->parse_navfile($file): required attribute label not present"
    unless $root->getAttribute('label');

  for my $attr ($root->attributes) {
    die "Sniglets::Navi::Parser->parse_navfile($file): attribute named " . $attr->nodeName . " not allowed"
      unless exists $allowed_navfile_attributes{$attr->nodeName};
  }

  my %tree_attr;

  foreach (qw/label formvar acl_mixins target/) {
    $tree_attr{$_} = $root->getAttribute($_);
  }

  $tree_attr{title_depth} = $root->getAttribute('title-depth');


  # backwards compatibility...
  if (defined $tree_attr{formvar}) {
    $tree_attr{formvars} = [$tree_attr{formvar}];
  }


  my $tree = new Sniglets::Navi::Tree(%tree_attr);

  for my $xml_node (grep { $_->isa("XML::LibXML::Element") } $root->childNodes) {

    if ($xml_node->nodeName eq 'rhn-formvar') {
      $tree->add_formvar($xml_node->getAttribute('name'));
      next;
    }

    if ($xml_node->nodeName ne 'rhn-tab') {
      warn "non-rhn-tab node: " . $xml_node->toString;
      next;
    }

    my $navi_node = $class->process_node($tree, $xml_node);
    $tree->add_node($navi_node);
  }

  $tree->freeze;

  return $tree;
}

sub process_node {
  my $class = shift;
  my $tree = shift;
  my $xml_node = shift;

  my %valid_child_nodes = map {$_ => 1} qw/rhn-tab rhn-tab-url rhn-tab-name rhn-tab-directory rhn-formvar/;

  for my $node (grep { $_->isa("XML::LibXML::Element") } $xml_node->childNodes) {
    unless ($valid_child_nodes{$node->nodeName}) {
      die "non rhn-formvar/rhn-tab/rhn-tab-url/rhn-tab-directory node: " . $node->toString;
    }
  }

  # xml:base attrs pop up from Xincludes
  my @attr = map { $_->nodeName => $_->nodeValue } grep { $_->nodeName ne 'xml:base' } $xml_node->attributes;
  my $navi_node = new Sniglets::Navi::Node @attr;
  $navi_node->set_id($tree->next_id);

  for my $formvar_node (grep { $_->nodeName eq 'rhn-formvar' } $xml_node->childNodes) {
    $navi_node->add_formvar($formvar_node->getAttribute('name'));
  }

  for my $url_node (grep { $_->nodeName eq 'rhn-tab-url' } $xml_node->childNodes) {
    my @text_nodes = $url_node->childNodes;
    if (@text_nodes != 1) {
      warn "rhn-tab-url element must have exactly one child element: " . $url_node->toString;
      next;
    }
    my $url = $text_nodes[0]->getData;
    $navi_node->add_url($url);
  }

  for my $url_node (grep { $_->nodeName eq 'rhn-tab-name' } $xml_node->childNodes) {
    my $url;
    for my $text_node ($url_node->childNodes) {
      $url .= ($text_node->nodeName eq 'pxt-config') ?
               PXT::Config->get($text_node->getAttribute('var')) : $text_node->getData;
    }
    $navi_node->add_name($url);
  }

  for my $url_node (grep { $_->nodeName eq 'rhn-tab-directory' } $xml_node->childNodes) {
    my @text_nodes = $url_node->childNodes;
    if (@text_nodes != 1) {
      warn "rhn-tab-directory element must have exactly one child element: " . $url_node->toString;
      next;
    }
    my $url = $text_nodes[0]->getData;
    $navi_node->add_directory($url);
  }

  for my $child_tab (grep { $_->nodeName eq 'rhn-tab' } $xml_node->childNodes) {
    my $child_navi = $class->process_node($tree, $child_tab);
    $tree->add_node($child_navi, $navi_node);
  }

  return $navi_node;
}

1;

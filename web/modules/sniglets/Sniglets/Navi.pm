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

package Sniglets::Navi;

use strict;

use File::Spec;

use Sniglets::Navi::Parser;
use Sniglets::Navi::Style;
use RHN::Exception;

use PXT::ACL;
use PXT::Config;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-navi-nav', \&navi_nav, -100); # Should run first for on-click handlers
  $pxt->register_tag('rhn-navi-page-title', \&navi_page_title, -50);
}


sub navi_page_title {
  my $pxt = shift;

  my $i = 0;
  my @title = PXT::Config->get("product_name");

  while ($pxt->pnotes("navi_page_title_$i")) {
    push @title, @{$pxt->pnotes("navi_page_title_$i")};
    $i++;
  }

  for ($i = 0; $i <= $#title - 1; $i++) {
    if ($title[$i] eq $title[$i + 1]) {
      splice @title, $i, 1, ();
    }
  }

  return PXT::Utils->escapeHTML(join(" - ", @title));
}

my %cached_trees = ();

sub load_tree {
  my $class = shift;
  my $file = shift;

  my @file_stat = stat($file);

  my $tree;
  if ($cached_trees{$file} and $cached_trees{$file}->{mtime} == $file_stat[9]) {
    $tree = $cached_trees{$file}->{tree};
  }
  else {
    $tree = Sniglets::Navi::Parser->parse_navfile($file);
    $cached_trees{$file} = { tree => $tree, mtime => $file_stat[9] };
  }

  # remove old dynamic children and regenerate them via freezing
  $tree->clean_dynamic_children;
  $tree->freeze;

  return $tree;
}

sub navi_nav {
  my $pxt = shift;
  my %params = @_;
  my $file;
  my $depth = $params{depth} || 0;
  if ($params{file}) {
    $file = File::Spec->catfile($pxt->document_root, $pxt->derelative_path($params{file}));
  }
  else {
    $file = File::Spec->catfile($pxt->document_root, $pxt->user ? "/nav/sitenav-authenticated.xml" : "/nav/sitenav.xml");
  }

  my $tree = Sniglets::Navi->load_tree($file);
  my $style = new Sniglets::Navi::Style($params{style});

  my $prefix = $tree->label;
  $prefix = "${prefix}_";

  my $trees = $pxt->pnotes("navi_trees") || { };
  $trees->{$tree->label}->{depth} = $tree->title_depth;
  $trees->{$tree->label}->{formvars} = $tree->formvars || [];

  $pxt->pnotes('navi_trees', $trees);

  my $acl_parser = $tree->acl_parser;

  throw "no session" unless $pxt->session;

  my $active_node = $tree->active_node($pxt->parsed_uri->path,
				       $pxt->pnotes("${prefix}navi_location"),
				       $pxt->session->get("${prefix}navi_location"));

  if ($pxt->dirty_param("${prefix}navi_node")) {
    my $node_id = $pxt->dirty_param("${prefix}navi_node");
    my $node = $tree->find_node($node_id);

    if ($node) {
      # clean it so we don't double-call handlers
      $pxt->dirty_param("${prefix}navi_node" => '');
      $node->invoke_on_click($pxt);
    }
  }

  $pxt->session->set("${prefix}navi_location" => $active_node->urls->[0]);

  my @nav_trail = $active_node->node_stack;
  my $ret = format_nav($pxt, $style, $tree, \@nav_trail, $depth);

  my $n = $tree->title_depth;
  my @title;
  for my $node (@nav_trail) {
    push @title, $node->name;
    last if $node eq $active_node;
  }

  $pxt->pnotes("navi_page_title_$n" => \@title);

  return $ret;
}

sub format_nav {
  my $pxt = shift;
  my $style = shift;
  my $tree = shift;
  my $nav_trail = shift;
  my $depth = shift;

  my @todo;

  # any siblings of the current node?  if so, we render them.
  # otherwise, we render the children of the previous node.  corner
  # case: $depth = 0...  textnav doesn't work in this case.

  if ($nav_trail->[$depth]) {
    @todo = $nav_trail->[$depth]->siblings;
  }
  else {
    my $node = $nav_trail->[$depth - 1];

    if ($node) {
      @todo = $node->children;
    }
  }

  my $ret = $style->pre_nav($pxt, $depth);

  $ret .= render_nav($pxt, $style, $tree, $nav_trail, $depth, @todo);

  $ret .= $style->post_nav($pxt, $depth);

  return $ret;
}

sub is_node_active {
  my $node = shift;
  my $nav_trail = shift;
  my $depth = shift;

  return ($nav_trail->[$depth] and $nav_trail->[$depth] == $node) ? 1 : 0;
}

#potentially recursive.  Renders one level of the nav tree structure,
sub render_nav {
  my $pxt = shift;
  my $style = shift;
  my $tree = shift;
  my $nav_trail = shift;
  my $depth = shift;
  my @todo = @_;

  my @node_strings;
  my $ret = '';
  my $rendered_child = '';

  my $num_siblings = scalar @todo;
  my $i = 0;
  foreach my $navi_node (@todo) {
    # sibling counter
    $i++;

    next unless $navi_node->visible($pxt);

    my $active = is_node_active($navi_node, $nav_trail, $depth);

    my $str;
    $str .= $style->pre_item($pxt, $active, $depth, $i, $num_siblings);
    $str .= $style->render_link($pxt, $tree, $navi_node, $active, $depth, $i, $num_siblings);

    if ($style->recursive_type($pxt) and $active and $navi_node->children) {

      # in some cases, want to hide kids if none are active...
      # (try to avoid needless work)
      my $skip_kids;
       if ($navi_node->hide_all_children_unless_active) {

 	foreach my $kid ($navi_node->children) {
 	  if (is_node_active($kid, $nav_trail, $depth + 1)) {

	    $skip_kids = 0;
	    last;
	  }
 	}

 	$skip_kids = 1 if not defined $skip_kids;
       }


      unless ($skip_kids) {
	$rendered_child .= render_nav($pxt, $style, $tree, $nav_trail, $depth + 1, $navi_node->children);
	if ($style->recursive_type($pxt) eq 'in-order') {
	  $str .= $rendered_child;
	}
      }

    }

    $str .= $style->post_item($pxt, $depth);

    push @node_strings, $str;
  }

  $ret .= $rendered_child if $style->recursive_type($pxt) eq 'pre-order';
  $ret .= $style->pre_level($depth);
  $ret .= join($style->element_join($depth), @node_strings);
  $ret .= $style->post_level($depth);
  $ret .= $rendered_child if $style->recursive_type($pxt) eq 'post-order';

  return $ret;

}

1;

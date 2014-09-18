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

package Sniglets::Navi::Style;
use strict;

sub new {
  my $class = shift;
  my $style_name = shift;

  if ($style_name) {
    return bless { style_name => $style_name }, "${class}::$style_name";
  }
  else {
    return bless { style_name => "ul" }, "${class}::ul";
  }
}

package Sniglets::Navi::Style::ul;

sub pre_nav {
  my $self = shift;

    return "";

}

sub post_nav {
  return "";
}

sub pre_level {
  my $self = shift;
  my $level = shift;

  my $level_style = $self->level_style($level);
  if ($level_style) {
    return qq{\n<div class="$level_style"><ul>}
  }
  else {
    return qq{\n<div><ul>};
  }
}

sub post_level {
  return "</ul></div>\n";
}

sub pre_item {
  my $self = shift;
  my $pxt = shift;
  my $active = shift;
  my $level = shift;

  my $item_style = $active ? $self->item_style_active($level) : $self->item_style($level);
  my $item_style_type = $self->item_style_type($level);
  if ($item_style) {
    return qq{\n<li $item_style_type="$item_style">}
  }
  else {
    return qq{<li>};
  }
}
sub post_item {
  return "</li>\n";
}
sub level_style {
  return "";
}
sub link_style {
  return "";
}
sub link_style_active {
  return "";
}
sub item_style {
  return "";
}
sub item_style_active {
  return "";
}
sub item_style_type {
  return "id";
}
sub element_join {
  return "";
}

sub recursive_type { return 'in-order' }

sub render_link {
  my $self = shift;
  my $pxt = shift;
  my $tree = shift;
  my $node = shift;
  my $active = shift;
  my $depth = shift;

  my $css_style;
  if ($self->link_style($depth) or $self->link_style_active($depth)) {
    $css_style = $active ? $self->link_style_active($depth) : $self->link_style($depth);
  }

  my $url = $node->urls->[0] || '';
  my $tree_formvars = $tree->formvars;
  my $node_formvars = $node->formvars;

  my %form_params;

  # always repeat tree formvars, they span the tree
  foreach my $formvar (@{$tree_formvars}) {
    my $value = $pxt->passthrough_param($formvar);
    $form_params{$formvar} = $value if $value;
  }

  # only repeat node formvars if the node is active
  foreach my $formvar (@{$node_formvars}) {
    my $value = $pxt->passthrough_param($formvar);
    $form_params{$formvar} = $value if $value;
  }

  if ($node->node_id) {
    my $prefix = $tree->label . "_";
    $form_params{"${prefix}navi_node"} = $node->node_id;
  }

  if (keys %form_params) {
    if ($url =~ /[?]/) {
      $url .= "&amp;";
    }
    else {
      $url .= "?";
    }
    $url .= join("&amp;", map { qq{$_=} . PXT::Utils->escapeURI($form_params{$_}) } keys %form_params);
  }

  return PXT::HTML->link($url, PXT::Utils->escapeHTML($node->name), $css_style, $node->target);
}


package Sniglets::Navi::Style::contentnav;
use base qw/Sniglets::Navi::Style::ul/;

sub recursive_type {
  return 'post-order';
}

sub pre_nav {
  my $self = shift;

    return qq{\n<div class="spacewalk-content-nav">};

}
sub post_nav {
  my $self = shift;
  my $pxt = shift;

  return "</div>\n"
    . $pxt->include('/network/components/message_queues/local.pxi')
}

sub pre_level {
  my $self = shift;
  my $level = shift;

  my $ret = '';

  my $level_style = $self->level_style($level);
  if ($level_style) {
    $ret = qq{\n<ul class="nav nav-tabs $level_style">}
  }
  else {
    $ret = qq{\n<ul class="nav nav-tabs">};
  }

  return $ret;
}

sub post_level {
  my $self = shift;
  my $depth = shift;

  my $ret = "</ul>\n";

  return $ret;
}

sub item_style_active {
  return "active";
}

sub item_style_type {
  return "class";
}

package Sniglets::Navi::Style::sidenav;
use base qw/Sniglets::Navi::Style::ul/;

sub pre_nav { return qq{\n<nav id="sidenav">} }
sub post_nav { return qq{\n</nav>\n} }

sub pre_level { return qq{\n<ul class="nav nav-pills nav-stacked">\n} }
sub post_level { return '</ul>' }

sub level_style { return "sidenav" }

sub item_style { return "" }
sub item_style_active { return "active" }
sub item_style_type { return "class" }

sub link_style {
  return "";
}
sub link_style_active {
  return "";
}


package Sniglets::Navi::Style::spacewalk_main_nav;
use base qw/Sniglets::Navi::Style::ul/;

sub item_style_type { return 'class' }

sub pre_item {
  my $self = shift;
  my $pxt = shift;
  my $active = shift;
  my $level = shift;

  # what number am i...
  my $sibling_count = shift;
  # ... out of ...
  my $num_siblings = shift;


  #my $item_style = $active ? $self->item_style_active($level) : $self->item_style($level);

  my $item_style_type = $self->item_style_type($level);
  my $item_style;

  if ($active) {
    $item_style = "active";
  }

  if ($item_style) {
    return qq{\n<li $item_style_type="$item_style">}
  }
  else {
    return qq{<li>};
  }
}
sub post_item {
  return "</li>\n";
}


sub pre_level {
  return qq{<ul class="nav navbar-nav navbar-primary">};
}

sub post_level {
  return "</ul>";
}

#sub item_style_active {
#  return "current";
#}

sub recursive_type { return '' }

sub render_link {
  my $self = shift;
  my $pxt = shift;
  my $tree = shift;
  my $node = shift;
  my $active = shift;
  my $depth = shift;

  my $css_style;
#  if ($self->link_style($depth) or $self->link_style_active($depth)) {
#    $css_style = $active ? $self->link_style_active($depth) : $self->link_style($depth);
#  }

  my $url = $node->urls->[0] || '';
  my $tree_formvars = $tree->formvars;
  my $node_formvars = $node->formvars;

  my %form_params;

  # always repeat tree formvars, they span the tree
  foreach my $formvar (@{$tree_formvars}) {
    my $value = $pxt->passthrough_param($formvar);
    $form_params{$formvar} = $value if $value;
  }

  # only repeat node formvars if the node is active
  foreach my $formvar (@{$node_formvars}) {
    my $value = $pxt->passthrough_param($formvar);
    $form_params{$formvar} = $value if $value;
  }

  if ($node->node_id) {
    my $prefix = $tree->label . "_";
    $form_params{"${prefix}navi_node"} = $node->node_id;
  }

  if (keys %form_params) {
    if ($url =~ /[?]/) {
      $url .= "&amp;";
    }
    else {
      $url .= "?";
    }
    $url .= join("&amp;", map { qq{$_=} . PXT::Utils->escapeURI($form_params{$_}) } keys %form_params);
  }

  return PXT::HTML->link($url, PXT::Utils->escapeHTML($node->name), $css_style, $node->target);
}


1;

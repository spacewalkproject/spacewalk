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

package Sniglets::Navi::Tree;

use strict;
use PXT::ACL;

# This is the basic navigation tree.  It is responsible for holding
# child nodes that (the actual nav locations) as well as finding them
# when necessary.  The 'id' thing is to avoid circular references and
# allow fast lookup of a given node.

my %allowed_params = (label => 1, formvars => 1, acl_parser => 1, title_depth => 1);

sub new {
  my $class = shift;
  my %params = @_;

  my $self = bless { label => '',
                     id_pool => 1,
                     route_nodes => [],
                     formvars => [],
                     title_depth => 0,
                     acl_parser => undef,
                     }, $class;

  if ($params{acl_mixins}) {
    $params{acl_mixins} = [ split(/,\s*/, $params{acl_mixins}) ];
  }

  die "Sniglets::Navi::Tree->new(label[, formvar])" if not $params{label};

  $params{acl_parser} = new PXT::ACL (mixins => $params{acl_mixins});

  foreach (keys %params) {
    next unless exists $allowed_params{$_};
    $self->{$_} = $params{$_};
  }

  return $self;
}

sub label { return $_[0]->{label} }
sub title_depth { return $_[0]->{title_depth} }

sub next_id {
  my $self = shift;

  my $id = ++$self->{id_pool};

  # ugly way to make a unique ID, but it helps in debugging.  could
  # just be $id from above, in theory
  return "TREE($self)-$id";
}

sub formvars { return $_[0]->{formvars} }
sub acl_parser { return $_[0]->{acl_parser} }

sub add_formvar {
  my $self = shift;
  my $formvar = shift;

  die "no formvars array?" unless $self->{formvars};
  die 'no additional formvar' unless $formvar;

  push @{$self->{formvars}}, $formvar;
}

sub add_node {
  my $self = shift;
  my $navi_node = shift;
  my $parent_navi_node = shift;

  $self->{nodes}->{$navi_node->id} = $navi_node;
  $self->{nodes_by_id}->{$navi_node->node_id} = $navi_node
    if defined $navi_node->node_id;

  if ($parent_navi_node) {
    $self->{child_to_parent_map}->{$navi_node->id} = $parent_navi_node;
    push @{$self->{parent_to_child_map}->{$parent_navi_node->id}}, $navi_node;
  }
  else {
    push @{$self->{root_nodes}}, $navi_node;
  }

  $navi_node->set_tree($self);
}

sub remove_node {
  my $self = shift;
  my $node = shift;

  return unless $node and exists $self->{nodes}->{$node->id};

  $self->remove_node($_) for $self->children($node);

  my $parent_node = $self->parent($node);
  if ($parent_node) {
    @{$self->{parent_to_child_map}->{$parent_node->id}} =
      grep { $_->id ne $node->id } @{$self->{parent_to_child_map}->{$parent_node->id}};
  }

  delete $self->{nodes}->{$node->id};
  delete $self->{nodes_by_id}->{$node->node_id}
    if defined $node->node_id;

  @{$self->{root_nodes}} = grep { $_->id ne $node->id } @{$self->{root_nodes}};
  delete $self->{child_to_parent_map}->{$node->id};

  $node->set_tree(undef);
}

sub find_node {
  my $self = shift;
  my $node_id = shift;

  return $self->{nodes_by_id}->{$node_id};
}

sub nodes_at_depth {
  my $self = shift;
  my $depth = shift;

  return @{$self->{node_levels}->[$depth] || []};
}

sub children {
  my $self = shift;
  my $node = shift;

  return @{$self->{parent_to_child_map}->{$node->id} || []};
}

sub parent {
  my $self = shift;
  my $node = shift;

  return $self->{child_to_parent_map}->{$node->id};
}

sub siblings {
  my $self = shift;
  my $node = shift;

  if ($self->parent($node)) {
    return $self->children($self->parent($node));
  }
  else {
    return $self->nodes_at_depth(0);
  }
}

sub freeze {
  my $self = shift;

  delete $self->{node_map};
  delete $self->{node_dir_map};
  delete $self->{node_levels};

  my @todo = map { [0, $_ ] } @{$self->{root_nodes}};
  while (1) {
    my $tuple = shift @todo;
    last unless $tuple;

    my ($depth, $node) = @$tuple;
    push @{$self->{node_map}->{$_}}, $node
      for @{$node->urls};
    push @{$self->{node_dir_map}->{$_}}, $node
      for @{$node->directories};
    push @{$self->{node_levels}->[$depth]}, $node;
    $self->{depth_map}->{$node->id} = $depth;

    $self->add_node($_, $node) for $node->dynamic_children($self);

    push @todo, map { [ $depth + 1, $_ ] } $self->children($node);
  }
}

sub clean_dynamic_children {
  my $self = shift;

  my @dynamic_nodes = grep { $_->dynamic } values(%{$self->{nodes}});
  $self->remove_node($_) for @dynamic_nodes;
}

# active node.  passed in a list of candidate locations.  typically
# the first is the actual URL the user is on.  the second is from
# session data from the last page the user hit that WAS mapped
# anywhere in here.

sub active_node {
  my $self = shift;
  my @locations = grep { defined $_ } @_;

  for my $location (@locations) {
    if (exists $self->{node_map}->{$location}) {
      my @nodes = @{$self->{node_map}->{$location}};

      # return the deepest node in the tree
      my $choice = $nodes[0];
      for my $candidate (@nodes) {
        $choice = $candidate if $candidate->node_depth > $choice->node_depth;
      }

      return $choice;
    }

    my @dirs = File::Spec->splitdir($location);
    for my $end (reverse 1 ..$#dirs) {
      my $directory = File::Spec->catfile(@dirs[0 .. $end]);

      if (exists $self->{node_dir_map}->{$directory}) {
        my @nodes = @{$self->{node_dir_map}->{$directory}};

        # return the deepest node in the tree
        my $choice = $nodes[0];
        for my $candidate (@nodes) {
          $choice = $candidate if $candidate->node_depth > $choice->node_depth;
        }

        return $choice;
      }
    }
  }

  return ($self->nodes_at_depth(0))[0];
}

1;

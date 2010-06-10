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

package Sniglets::Navi::Node;

use strict;
use Carp qw/confess/;
use PXT::ACL;
use Sniglets::Lists;


my %allowed_params = map { $_ => 1 }
  qw/name url acl dominant invisible override_sidenav hide_all_children_unless_active
     perm_fail_redirect active-image inactive-image node-id on-click dynamic-children
     target/;

sub new {
  my $class = shift;
  my %params = @_;

  my $self = bless { urls => [], id => undef, tree => undef, directories => [] }, $class;

  my $url = delete $params{url};

  for my $p (keys %params) {

    # backwards compatibility
    if ($p eq 'formvar') {
      $self->add_formvar($params{$p});
      next;
    } elsif ($p eq 'target') {
      $self->set_target($params{$p});
    }

    die "Invalid param to $class->new: '$p'"
      unless exists $allowed_params{$p};

    $self->{$p} = $params{$p};
  }


  $self->add_url($url) if defined $url;

  return $self;
}

sub name { return $_[0]->{name} }
sub node_id { return $_[0]->{'node-id'} }
sub formvars { return $_[0]->{formvars} }
sub urls { return $_[0]->{urls} }
sub directories { return $_[0]->{directories} }
sub acl { return $_[0]->{acl} }
sub perm_fail_redirect { return $_[0]->{perm_fail_redirect} }
sub target { return $_[0]->{target} }

# any children
sub hide_all_children_unless_active { return $_[0]->{hide_all_children_unless_active} }

sub is_active { return 1 }

sub invoke_on_click {
  my $self = shift;
  my $pxt = shift;

  my $call = $self->{'on-click'};
  return unless $call;

  my ($class, $method) = split /->/, $call, 2;
  if (not $class or not $method) {
    die "on_click handler '$call' not parseable";
  }

  $class->$method($self, $pxt);
}

# is the node dynamic, ie, runtime generated?
sub dynamic {
  my $self = shift;

  if (@_) {
    $self->{dynamic} = shift;
  }
  return $self->{dynamic};
}

# does this node have dynamic children?
sub dynamic_children {
  my $self = shift;
  my $tree = shift;

  my $call = $self->{'dynamic-children'};
  return unless $call;

  my ($class, $method) = split /->/, $call, 2;
  if (not $class or not $method) {
    die "on-load handler '$call' not parseable";
  }

  eval "use $class";
  die $@ if $@;

  my @ret = eval { $class->$method($self, $tree) };

  if (not @ret and $@) {
    warn "Exception raised in navi dynamic child, continuing on...";
    return;
  }

  for my $node (@ret) {
    $node->set_id($tree->next_id);
    $node->dynamic(1);
  }
  return @ret;
}

sub id {
  my $self = shift;

  confess "Request for node id before being set" unless defined $self->{id};

  return $self->{id};
}

sub set_target {
  my $self = shift;

  confess "node target already defined for node" if defined $self->{target};

  $self->{target} = shift;
}

sub set_id {
  my $self = shift;

  confess "id already defined for node" if defined $self->{id};

  $self->{id} = shift;
}

sub set_tree {
  my $self = shift;

  confess "node tree already defined for node" if defined $self->{tree} and defined $_[0];

  $self->{tree} = shift;
}

sub add_url {
  my $self = shift;
  my $url = shift;

  push @{$self->{urls}}, $url;
}

sub add_name {
  my $self = shift;
  my $name = shift;

  $self->{name} .= $name;
}

sub add_formvar {
  my $self = shift;
  my $formvar = shift;

  push @{$self->{formvars}}, $formvar;
}

sub add_directory {
  my $self = shift;
  my $url = shift;

  push @{$self->{directories}}, $url;
}

sub visible {
  my $self = shift;
  my $pxt = shift;

  return 0 if $self->{invisible};

  # acl?  let it decide; otherwise, we're visible
  if ($self->{acl}) {
    return $self->{tree}->acl_parser->eval_acl($pxt, $self->{acl});
  }
  else {
    return 1;
  }
}

# some helper routines; parent, etc are all a result of the tree
# itself, but these make it more convenient to access the tree's true
# structure

sub parent {
  my $self = shift;
  return $self->{tree}->parent($self);
}

sub children {
  my $self = shift;
  return $self->{tree}->children($self);
}

sub siblings {
  my $self = shift;
  return $self->{tree}->siblings($self);
}

sub node_stack {
  my $self = shift;

  my @node_stack;
  while ($self) {
    unshift @node_stack, $self;
    $self = $self->parent($self);
  }

  return @node_stack;
}

sub node_depth {
  my $self = shift;

  my @node_stack;
  while ($self) {
    unshift @node_stack, $self;
    $self = $self->parent($self);
  }

  return scalar @node_stack;
}


1;

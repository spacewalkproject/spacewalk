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

package RHN::AppInstall::Replace;

use strict;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

# This module is designed to traverse a data structure, find the
# strings that look like '${foo.bar}', and replace them (in place)
# using a hash passed into perform_substitutions() (%replacements).

sub build_replacement_hash {
  my $class = shift;
  my $bottom_of_tree = shift;

  my %replacements = ();

  my $method = sub {
    my $ref = shift;

    foreach my $match ($$ref =~ /\$\{([\w\.]*):?[^}]*\}/g) {
      $replacements{$match} = undef;
    }

    return;
  };

  step_up_tree($bottom_of_tree, $method);

  return %replacements;
}

sub perform_substitutions {
  my $class = shift;
  my $bottom_of_tree = shift;
  my %replacements = @_;

  my $method = sub {
    my $ref = shift;

    $$ref =~ s/\$\{([\w\.]*):?([^}]*)?\}/$replacements{$1} || "$2"/ge;

    return;
  };

  step_up_tree($bottom_of_tree, $method);

  return;
}

sub step_up_tree {
  my $value = shift;
  my $method = shift;

  if (ref $value eq 'HASH') {
    traverse_leaf_for_hashref($value, $method);
  }
  elsif (ref $value eq 'ARRAY') {
    traverse_leaf_for_arrayref($value, $method);
  }
  elsif (ref $value eq 'SCALAR') {
    &$method($value);
  }
  elsif (eval {$value->can('valid_fields') }) {
    traverse_leaf_for_hashref($value, $method);
  }
  elsif (not ref $value) {
    throw "(not_a_reference) $value";
  }

  return;
}

sub traverse_leaf_for_hashref {
  my $hashref = shift;
  my $method = shift;

  foreach my $key (keys %{$hashref}) {
    if (not defined $hashref->{$key}) {
      next;
    }
    if (ref $hashref->{$key}) {
      step_up_tree($hashref->{$key}, $method);
    }
    else {
      step_up_tree(\$hashref->{$key}, $method);
    }
  }

  return;
}

sub traverse_leaf_for_arrayref {
  my $arrayref = shift;
  my $method = shift;

  foreach my $index (0 .. (scalar @{$arrayref} - 1)) {
    if (not defined $arrayref->[$index]) {
      next;
    }
    if (ref $arrayref->[$index]) {
      step_up_tree($arrayref->[$index], $method);
    }
    else {
      step_up_tree(\$arrayref->[$index], $method);
    }
  }

  return;
}

1;

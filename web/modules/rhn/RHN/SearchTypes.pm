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

use strict;

# NOTE: There are SearchTypes and SearchType objects.  the former is a
# bag of the others.


our %search_types;
package RHN::SearchTypes;
sub find_type {
  my $class = shift;
  my $label = shift;
  my $ret = $search_types{$label};

  die "unknown search type $label" unless defined $ret;

  return $ret;
}

package RHN::SearchType;

use Params::Validate qw/validate/;
use PXT::ACL;
use RHN::Exception qw/throw/;

sub new {
  my $class = shift;

  my $self = bless { search_modes => [], min_search_length => 0 }, $class;

  return $self;
}

sub set_name {
  my $self = shift;

  if (@_) {
    $self->{set_name} = shift;
  }

  return $self->{set_name};
}

sub add_mode {
  my $self = shift;
  my $mode_label = shift;
  my $mode_choice_name = shift;
  my $mode_column_name = shift || $mode_choice_name;

  push @{$self->{search_modes}},
    {
     mode_choice_name => $mode_choice_name,
     mode_label => $mode_label,
     mode_column_name => $mode_column_name
    };
}

sub label_to_column_name {
  my $self = shift;
  my $view_mode = shift;

  my @matches = grep { $_->{mode_label} eq  $view_mode } @{$self->{search_modes}};
  die "Invalid search: $view_mode" unless @matches == 1;

  return $matches[0]->{mode_column_name};
}


package RHN::SearchType::System;

use base qw/RHN::SearchType/;
use RHN::Exception qw/throw/;
use Params::Validate qw/validate/;

sub new {
  my $class = shift;

  my $self = bless { categories => [], min_search_length => 0 }, $class;

  return $self;
}

sub label_to_column_name {
  my $self = shift;
  my $view_mode = shift;

  my @matches = grep { $_->{mode_choice_name} eq $view_mode }
    map { @{$_->{modes}} } @{$self->{categories}};

  throw "Invalid search: $view_mode" unless @matches == 1;

  return $matches[0]->{mode_column_name};
}


1;

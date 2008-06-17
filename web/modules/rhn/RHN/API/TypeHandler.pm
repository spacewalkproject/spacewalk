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
package RHN::API::TypeHandler;

use RHN::API::Types;
use Carp;

sub new {
  my $class = shift;

  my $self = bless { }, $class;
  RHN::API::Types->register_default_types($self);

  return $self;
}

sub register_type {
  my $self = shift;
  my $type = shift;
  my $func = shift;

  $self->{types}->{$type} = $func;
}

sub register_mangler {
  my $self = shift;
  my $type = shift;
  my $mangler = shift;
  my $func = shift;

  $self->{type_manglers}->{$type}->{$mangler} = $func;
}

sub mangle_type {
  my $self = shift;
  my $type = shift;
  my $mangler = shift;
  my $value = shift;

  my $mangle_func = $self->{generic_manglers}->{$mangler} || $self->{type_manglers}->{$type}->{$mangler};
  croak "No mangler '$mangler' for type '$type'" unless $mangle_func;

  return $mangle_func->($value);
}

sub validate_type {
  my $self = shift;
  my $type = shift;
  my $value = shift;

  croak "No registered API type '$type'" unless exists $self->{types}->{$type};

  return $self->{types}->{$type}->($value);
}

1;

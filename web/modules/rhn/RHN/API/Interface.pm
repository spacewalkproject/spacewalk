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
package RHN::API::Interface;

use RHN::API::Method;
use RHN::API::Exception;
use RHN::API::TypeHandler;
use Carp;

# pretty simple class.  mainly a wrapper for methods.  later will
# include more data about type handlers, acls, etc

sub new {
  my $class = shift;
  my $prefix = shift;

  my $self = bless { }, $class;
  $self->{type_handler} = new RHN::API::TypeHandler;
  $self->{prefix} = $prefix || '';

  return $self;
}

sub prefix {
  my $self = shift;

  return $self->{prefix};
}

sub add_method {
  my $self = shift;
  my $method = shift;

  $self->{methods}->{$method->name} = $method;
}

sub method_list {
  my $self = shift;

  return sort { $a->name cmp $b->name } values %{$self->{methods}};
}

sub find_method {
  my $self = shift;
  my $method_name = shift;

  my $ret = $self->{methods}->{$method_name};
  RHN::API::Exception->throw_named("method_not_found") unless $ret;

  return $ret;
}

sub invoke_method {
  my $self = shift;
  my $method_name = shift;

  my $method = $self->find_method($method_name);

  $method->invoke_method($self->{type_handler}, @_);
}

1;

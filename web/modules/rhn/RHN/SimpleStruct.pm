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

package RHN::SimpleStruct;
use Carp;

sub new {
  my $class = shift;

  my $self = bless { }, $class;

  my $aref = find_simplestruct_array($class);
  $self->{_simple_struct_fields_} = { map { $_ => undef } @$aref };

  return $self;
}

# logic: simple_struct_fields in this namespace?  if so, return it.
# else recurse on @ISA.  if @ISA is empty or has more than 1 entry,
# bomb.
sub find_simplestruct_array {
  my $namespace = shift;

  my $aref = extract_namespace_array($namespace, 'simple_struct_fields');
  return $aref if $aref;

  my $isa_ref = extract_namespace_array($namespace, 'ISA');
  croak "unable to find simple_struct_fields in class or ancestors" unless $isa_ref and @$isa_ref;
  croak "multiple inheritence is not allowed in SimpleStruct hierarchy" if @$isa_ref > 1;

  return find_simplestruct_array($isa_ref->[0]);
}

# simple method; given namespace and array, return ref to it
sub extract_namespace_array {
  my $namespace = shift;
  my $array = shift;

  no strict 'refs';
  my $symbol_name = "${namespace}::$array";
  my $aref = *$symbol_name{ARRAY};

  return $aref;
}

sub AUTOLOAD {
  my $self = shift;

  our $AUTOLOAD;

  # handle cases of foo::bar as well as just bar
  my ($class, $method) = $AUTOLOAD =~ /^(.*)::([^:]*)$/;
  $method = $AUTOLOAD if not $method;

  if (not ref $self) {
    croak "Unknown class method $self->$method";
  }

  croak "attempt to access field on un-initialized $self" unless exists $self->{_simple_struct_fields_};
  croak "attempt to access invalid field '$method' of $self" unless exists $self->{_simple_struct_fields_}->{$method};

  if (@_) {
    $self->{_simple_struct_fields_}->{$method} = shift;
  }

  return $self->{_simple_struct_fields_}->{$method};
}

sub unset {
  my $self = shift;
  my $field = shift;

  croak "attempt to delete invalid field '$field' of $self" unless exists $self->{_simple_struct_fields_}->{$field};
  $self->{_simple_struct_fields_}->{$field} = undef;

  return;
}

sub DESTROY {
  # nop, so we don't try to AUTOLOAD this method
}

1;

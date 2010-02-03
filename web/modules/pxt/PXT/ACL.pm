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

package PXT::ACL;

use strict;

use PXT::Utils;
use PXT::Config;
use RHN::Exception qw/throw/;

sub new {
  my $class = shift;
  my %params = @_;

  my $self = bless { acls => {} }, $class;

  $self->mixins($params{mixins});
  $self->register_handler(true => sub { 1 } );
  $self->register_handler(false => sub { 0 } );

  return $self;
}

sub mixins {
  my $self = shift;
  my $mixins = shift || [];

  push(@{$mixins}, split(/,\s*/, PXT::Config->get('base_acls')));

  foreach my $class (@{$mixins}) {
    PXT::Utils->untaint(\$class);

    eval "use $class";
    die $@ if $@;
    $class->register_acl_handlers($self);
  }
}

sub register_handler {
  my $self = shift;
  my ($label, $coderef) = @_;

  $self->{acls}->{$label} = $coderef;
}

sub acl {
  my $self = shift;
  my $expression = shift;

  throw "unknown acl '$expression'" unless exists $self->{acls}->{$expression};
  return $self->{acls}->{$expression};
}

# Grammar:
# ACL         := EXPRESSION [; EXPRESSION; ]+
# EXPRESSION  := STATEMENT [ OR STATEMENT ]+
sub eval_acl {
  my $self = shift;
  my $object = shift;
  my $acl_string = shift;

  throw "Usage: PXT::ACL->eval_acl(\$object, 'acl_string')" if not $object or not defined $acl_string;

  my @acl_expressions = split /;\s*/, ($acl_string || '');
  for my $expression (@acl_expressions) {
    my @statements = split /\s+or\s+/, $expression;
    my $result = 0;

    for my $statement (@statements) {
      my ($negated, $function, $params);
      if ($statement =~ /^(not +)?(.*)\((.*)\)$/) {
	$negated = $1 ? 1 : 0;
	$function = $2;
	$params = $3;
      }
      else {
	die "Could not parse acl statement '$statement';"
      }

      $result = $self->acl($function)->($object, $params);

      $result = !$result if $negated;

      # short circuit out of the ORs if we hit a true
      last if $result;
    }

    # short circuit out of the ANDs if we hit a false
    return 0 unless $result;
  }

  # made it to the end, ACL tests passed
  return 1;
}

1;

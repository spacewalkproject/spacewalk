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
package RHN::API::Method;

use RHN::Cleansers;
use RHN::SimpleStruct;
our @ISA = qw/RHN::SimpleStruct/;
our @simple_struct_fields = (qw/name min_params max_params version params required_params/,
			     qw/description return_type return_kids handler sla/);

use Carp;
use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

sub new {
  my $class = shift;
  my $name = shift;
  my $version = shift;

  my $self = $class->SUPER::new();
  $self->name($name);
  $self->version($version);
  $self->min_params(0);
  $self->max_params(0);
  $self->params([]);

  return $self;
}

# used when building the method; add a new param to the list
sub push_param {
  my $self = shift;
  my %params = validate(@_, { name => 1,
			      type => 1,
			      kids => 0,
			      default => 0,
			      required => 0,
			      slurp => 0,
			      mangle => 0 });

  my $self_params = $self->params;

  # slurp params, if present, must be the last param
  if ($self_params->[-1] and $self_params->[-1]->{slurp}) {
    die "attempt to add additional parameter after slurping parameter";
  }

  # once you declare a default param, you cannot have non-default params
  if ($self_params->[-1] and $self_params->[-1]->{default} and not $params{default}) {
    die "attempt to add parameter with non-default after parameter with default";
  }

  # can't have a required param after an optional one
  if ($self_params->[-1] and not $self_params->[-1]->{required} and $params{required}) {
    die "attempt to add required parameter after optional parameter";
  }

  # adjust counts now
  $self->min_params($self->min_params + 1) if $params{required};
  $self->max_params($self->max_params + 1);
  $self->max_params(undef) if $params{slurp};

  push @{$self_params}, \%params;
}

# set the handler for a method, optionally loading class as necessary
sub set_handler {
  my $self = shift;
  my $handler = shift;

  if (ref $handler and ref $handler eq 'CODE') {
    $self->handler($handler);
  }
  else {
    my $class = $handler;
    my $method = shift;

    my $module = "$class.pm";
    $module =~ s/::/\//g;
    require $module;

    # 'can' returns a coderef to the func in question, if found, handily enough
    $self->handler($class->can($method));
    die "Unable to find method of name '$method' in class '$class'" unless $self->handler;
  }
}

# invoke a method.  performs parameter count and type checking, as
# well as return type checking

sub invoke_method {
  my $self = shift;
  my $type_handler = shift;
  my @values = @_;

  # make sure we have enough params
  if (defined $self->min_params and scalar @values < $self->min_params) {
    RHN::API::Exception->throw_named("method_too_few_params");
  }

  if (defined $self->max_params and scalar @values > $self->max_params) {
    RHN::API::Exception->throw_named("method_too_many_params");
  }

  # okay.  build the actual param list for the method in question...
  my @actual_values;
  my @actual_params;

  my %typemap;
  my $self_params = $self->params;

  for my $i (0 .. $#{$self_params}) {
    my $param = $self_params->[$i];

    # have we hit the slurp param?  if so, consume the rest, end loop now
    if ($param->{slurp}) {
      push @actual_values, @values;
      push @actual_params, ($param) x @values;
      last;
    }

    # not slurp, okay, are there any supplied values left?
    if (@values) {
      push @actual_values, shift @values;
      push @actual_params, $param;
    }
    # okay, no supplied values left, grab the default for this position
    elsif (exists $param->{default}) {
      push @actual_values, $param->{default};
      push @actual_params, $param;
    }
    # this shouldn't hit since we verified the counts at the start of the func
    else {
      croak "Ran out of parameters?";
    }
  }

  my $active_user;
  my $perform_cleansing = 0;
  if ($actual_params[0] and $actual_params[0]->{name} eq 'session') {
    my $session = RHN::Session->load($actual_values[0]);
    RHN::API::Exception->throw_named("invalid_session") unless $session->uid;

    $active_user = RHN::User->lookup(-id => $session->uid);
    $perform_cleansing = 1;
  }

  # whew okay, now the easy part, validate and mangle params
  for my $i (0 .. $#actual_values) {

    my $skip = ((($i + 1) > $self->min_params) and (not defined $actual_values[$i])) ? 1 : 0;

    if ((not $skip) and (not $type_handler->validate_type($actual_params[$i]->{type}, $actual_values[$i]))) {
      RHN::API::Exception->throw_named("method_invalid_param", $i, $actual_params[$i]->{type});
    }

    if ($perform_cleansing) {
      my $pass = RHN::Cleansers->check_param($active_user,
					     $actual_params[$i]->{name},
					     $actual_values[$i]);
      if (not defined $pass) {
	# noop; undef means no cleanser
      }
      elsif ($pass) {
	# yep, we pass
      }
      else {
	RHN::API::Exception->throw_named("permission_check_failure");
      }
    }

    $actual_values[$i] = $type_handler->mangle_type($actual_params[$i]->{type},
						    $actual_params[$i]->{mangle},
						    $actual_values[$i])
      if $actual_params[$i]->{mangle};
  }

  # call it
  my $result = $self->handler->(@actual_values);
  my $return_type = $self->return_type;

  # validate return type
  if (not $type_handler->validate_type($return_type, $result)) {
    croak sprintf("Return type of '%s' mismatch: $result is not '$return_type'", $self->name);;
  }

  # and we're done!
  return $result;
}

1;

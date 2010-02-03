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

package RHN::AppInstall::ActionHandler;

use strict;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my %valid_fields = ( action_registry => { type => HASHREF,
					  optional => 1 },
		   );

sub valid_fields {
  return %valid_fields;
}

sub new {
  my $class = shift;
  my %fields = $class->valid_fields();
  my %attr = validate(@_, \%fields);

  my $self = bless { map { ( $_, undef ) } keys(%fields),
		   }, $class;

  foreach (keys %attr) {
    my $func = "set_${_}";
    throw "Invalid function: $func"
      unless $self->can($func);

    $self->$func($attr{$_});
  }

  $self->_init();
  return $self;
}

sub _init {
  my $self = shift;

  $self->register_actions();

  return;
}

sub register_actions {
  my $self = shift;

  throw "(base_class) Cannot register actions on the base class.  Use a subclass instead.";

  return;
}

sub add_action {
  my $self = shift;
  my $action_name = shift;
  my $subref = shift;

  if (exists $self->{action_registry}->{$action_name}) {
    throw "(action_exists) An action with the name '$action_name' already exists";
  }

  $self->{action_registry}->{$action_name} = $subref;

  return;
}

sub remove_action {
  my $self = shift;
  my $action_name = shift;

  if (not delete $self->{action_registry}->{$action_name}) {
    throw "(action_not_found) There is no '$action_name' action registered";
  }

  return;
}

sub do_action {
  my $self = shift;
  my $action = shift;
  my $session = shift;
  my @extra_params = @_;

  if (not exists $self->{action_registry}->{$action->get_name()}) {
    throw "(unknown_action) Could not find an action named '" . $action->get_name() . "' in $self";
  }

  my @arguments = $self->export_arguments($session, $action);

  # extra params come before arguments so the install document can override the code.

  my $ret;

  eval {
    $ret = &{$self->{action_registry}->{$action->get_name()}}($session, @extra_params, @arguments);
  };
  if ($@) {
    my $E = $@;
    if (ref $E and $E =~ /^[^\n]*\(appinstall:.*\) (.*)/m) {
      $ret = $1;
    }
    else {
      throw $E;
    }
  }

  return $ret;
}

# Export the arguments for the action in question.  This is made more
# complicated by the fact that individual arguments can have ACLs,
# which need to be parsed by the acl parser in the session.
sub export_arguments {
  my $self = shift;
  my $session = shift;
  my $action = shift;

  my @args = $action->get_arguments;
  my %args_out;

  foreach my $arg (@args) {
    if ($arg->get_acl) {
      next unless ($session->eval_acl($arg->get_acl));
    }

    if (not $arg->get_name) {
      $args_out{$arg->get_value} = undef;
      next;
    }

    if (exists $args_out{$arg->get_name}) {
      if (not ref $args_out{$arg->get_name}) {
	$args_out{$arg->get_name} = [ $args_out{$arg->get_name}, $arg->get_value ];
      }
      elsif (ref $args_out{$arg->get_name} eq 'ARRAY') {
	push @{$args_out{$arg->get_name}}, $arg->get_value;
      }
      else {
	throw "(invalid_argument) The argument '" . $arg->get_name. "' seems to be invalid";
      }

      next;
    }

    $args_out{$arg->get_name} = $arg->get_value;
  }

  if (not values %args_out) {
    return (keys %args_out);
  }
  else {
    return %args_out;
  }
}

1;

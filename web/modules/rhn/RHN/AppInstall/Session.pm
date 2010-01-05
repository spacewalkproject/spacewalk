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

package RHN::AppInstall::Session;

use strict;

use RHN::DB::AppInstall::Session;
our @ISA = qw/RHN::DB::AppInstall::Session/;

use RHN::AppInstall::Instance;
use RHN::AppInstall::Session::Access;
use RHN::AppInstall::ActionHandler::ActionRunner;
use RHN::AppInstall::ActionHandler::ActionScheduler;
use RHN::AppInstall::RequirementHandler;
use RHN::AppInstall::Replace;

use PXT::ACL;
use RHN::Server;
use RHN::User;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

# The valid fields (method calls) we can look up for a user to do
# replacements for an AppInstall session.
my @valid_user_data = qw/id org_id login login_uc prefix first_names
			 last_name company title email/;

# The valid fields (method calls) we can look up for a server to do
# replacements for an AppInstall session.
my @valid_server_data = qw/id os release name description auto_update
			   auto_deliver applet_activated is_proxy
			   is_satellite proxy_evr base_channel_id
			   base_channel_label base_channel_name
			   check_lock proxy_hostname guess_hostname
			   guess_rhn_parent/;

my @valid_app_data = qw/name label version ts_and_cs md5/;

sub _init {
  my $self = shift;

  $self->_init_acl_parser();
  $self->_init_action_runner();
  $self->_init_action_scheduler();
  $self->_init_requirement_handler();

  $self->SUPER::_init();
  return;
}

# initialize the ACL parser for this session, using any mixins
# specified by the app install instance.
sub _init_acl_parser {
  my $self = shift;

  my @acl_mixins = $self->get_app_instance->get_acl_mixins();
  push @acl_mixins, 'RHN::AppInstall::Session::Access';
  $self->set_acl_parser(new PXT::ACL (mixins => \@acl_mixins));

  return;
}

sub _init_action_runner {
  my $self = shift;

  $self->set_action_runner(new RHN::AppInstall::ActionHandler::ActionRunner);
}

sub _init_action_scheduler {
  my $self = shift;

  $self->set_action_scheduler(new RHN::AppInstall::ActionHandler::ActionScheduler);
}

sub _init_requirement_handler {
  my $self = shift;

  $self->set_requirement_handler(new RHN::AppInstall::RequirementHandler);
}


# Lookup a step by it's order in the current process
sub _lookup_step {
  my $self = shift;
  my $index = shift;

  my $step = $self->current_process->lookup_step($index);

  if ($step) {
    $self->perform_substitutions($step);
  }

  return $step;
}

# return the current RHN::AppInstall::Process object
sub current_process {
  my $self = shift;

  throw "(no_app_instance) There is no current RHN::AppInstall::Instance associated with this session"
    unless ($self->get_app_instance);

  return $self->get_app_instance->lookup_process($self->get_process_name);
}


# return the next step, or undef if none exists.
# does not advance the step counter.
sub next_step {
  my $self = shift;

  return if (not defined $self->get_step_number());
  $self->_lookup_step($self->get_step_number + 1)
}

# return the next step, or undef if none exists.
# *does* advance the step counter.
sub advance_step {
  my $self = shift;

  my $next_step = $self->next_step;

  if ($next_step) {
    $self->set_step_number($self->get_step_number + 1);
  }
  else {
    $self->set_step_number(undef);
  }

  return $next_step;
}

# return true if we are done processing this session, false otherwise.
sub done {
  my $self = shift;

  my $done = $self->next_step() ? 0 : 1;

  return $done;
}


# We need a couple of subroutines to be compatible with what
# RHN::Access and child modules expect a 'pxt' object to be.
#
# TODO: fix RHN::Access to not assume a 'pxt' object, but instead some
# generic interface.

sub user {
  my $self = shift;

  return $self->get_user;
}

sub param {
  my $self = shift;
  my $param = shift;

  if ($param eq 'sid') {
    return $self->get_server->id;
  }

  if (scalar @_ == 1) {
    $self->{__session_data__}->{$param} = shift;
  }
  elsif (scalar @_ > 1) {
    $self->{__session_data__}->{$param} = \@_;
  }

  return $self->{__session_data__}->{$param};
}

sub passthrough_param {
  my $self = shift;

  return $self->param(@_);
}


# use the cached ACL parser to eval a given ACL
sub eval_acl {
  my $self = shift;
  my $acl = shift;

  return 1 unless $acl;
  return $self->get_acl_parser()->eval_acl($self, $acl);
}


# perform substitutions on a data structure using session information.
sub perform_substitutions {
  my $self = shift;
  my $ref = shift;

  throw "(not_a_reference) '$ref' is supposed to be a reference" unless (ref $ref);

  my %replacements = RHN::AppInstall::Replace->build_replacement_hash($ref);
  $self->_populate_replacement_hash(\%replacements);
  RHN::AppInstall::Replace->perform_substitutions($ref, %replacements);

  return;
}

sub _populate_replacement_hash {
  my $self = shift;
  my $replacements = shift;

  foreach my $key (keys %{$replacements}) {
    my ($pred, @method) = split(/\./, $key);
    my $method = join('.', @method);

    if ($pred eq 'app' and grep { $method eq $_ } @valid_app_data) {
      my $real_method = "get_$method";
      $replacements->{$key} = $self->get_app_instance->$real_method() || '';
    }
    elsif ($pred eq 'system' and grep { $method eq $_ } @valid_server_data) {
      $replacements->{$key} = $self->get_server->$method() || '';
    }
    elsif ($pred eq 'user' and grep { $method eq $_ } @valid_user_data) {
      $replacements->{$key} = $self->get_user->$method() || '';
    }
    elsif ($pred eq 'session') {
      $replacements->{$key} = $self->param($method) || '';
    }
    else {
      throw '(invalid_replacement) Cannot find a replacement for ${' . $pred . '.' . $method . '}';
    }
  }

  return;
}


# export the storable state of the session has a hashref
sub export {
  my $self = shift;

  my $state = {
	       app_label => $self->get_app_instance->get_label,
	       app_version => $self->get_app_instance->get_version,
	       app_md5sum => $self->get_app_instance->get_md5,
	       process_name => $self->get_process_name,
	       step_number => $self->get_step_number,
	       user_id => $self->get_user->id,
	       server_id => $self->get_server->id,
	       session_data => {$self->get_session_data},
	      };

  return $state;
}


# Run an action.
# Returns 0              if the action succeeded
#         undef          if the action is ACLed away
#         error message  if the action failed
sub run_action {
  my $self = shift;
  my $action = shift;
  my @extra_params = @_;

  if ($action->get_acl and not $self->eval_acl($action->get_acl)) {
    return undef;
  }

  return $self->get_action_runner->do_action($action, $self, @extra_params);
}

# Schedule an action.
# Returns action_id      if the action was scheduled successfully
#         undef          if the action is ACLed away
# throws and exception   if the action scheduling failed
sub schedule_action {
  my $self = shift;
  my $action = shift;
  my @extra_params = @_;

  if ($action->get_acl and not $self->eval_acl($action->get_acl)) {
    return undef;
  }

  return $self->get_action_scheduler->do_action($action, $self, @extra_params);
}

# Check a requirement
# Returns 0              if the requirement passed
#         error message  if the requirement failed
sub check_requirement {
  my $self = shift;
  my $requirement = shift;

  return $self->get_requirement_handler->check_requirement($requirement, $self);
}

1;

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

package RHN::AppInstall::Process::Step::Activity;

use strict;

use RHN::AppInstall::Process::Step;
our @ISA = qw/RHN::AppInstall::Process::Step/;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my %valid_fields = (actions => { type => ARRAYREF,
				 default => [],
			       },
		   );

sub valid_fields {
  my $class = shift;
  return ($class->SUPER::valid_fields(), %valid_fields);
}

sub get_actions {
  my $self = shift;

  return @{$self->{actions} || []};
}

sub set_actions {
  my $self = shift;
  my @actions = @_;

  if (ref $actions[0] eq 'ARRAY') {
    @actions = @{$actions[0]};
  }

  $self->push_action(@actions);

  return;
}

sub push_action {
  my $self = shift;
  my @actions = @_;

  foreach my $action (@actions) {
    throw "(set_error) $action is not an RHN::AppInstall::Process::Step::Activity::Action"
      unless (ref $action and $action->isa('RHN::AppInstall::Process::Step::Activity::Action'));
  }

  push @{$self->{actions}}, @actions;

  return;
}

sub pop_action {
  my $self  = shift;

  return if (not @{$self->{actions}});
  return pop @{$self->{actions}};
}

sub unshift_action {
  my $self = shift;
  my @actions = @_;

  foreach my $action (@actions) {
    throw "(set_error) $action is not an RHN::AppInstall::Process::Step::Activity::Action"
      unless (ref $action and $action->isa('RHN::AppInstall::Process::Step::Activity::Action'));
  }

  unshift @{$self->{actions}}, @actions;

  return;
}

sub shift_action {
  my $self  = shift;

  return if (not @{$self->{actions}});
  return shift @{$self->{actions}};
}

1;

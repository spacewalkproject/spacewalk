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

package RHN::AppInstall::Process::Step::ActionStatus;

use strict;

use RHN::AppInstall::Process::Step::ActionStatus::Action;
use RHN::AppInstall::Process::Step;
our @ISA = qw/RHN::AppInstall::Process::Step/;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my %valid_fields = (header => 0,
		    footer => 0,
		    inprogress_msg => 0,
		    complete_msg => 0,
		    failed_msg => 0,
		    action => { class => 'RHN::AppInstall::Process::Step::ActionStatus::Action',
				optional => 1 },
		   );

sub valid_fields {
  my $class = shift;
  return ($class->SUPER::valid_fields(), %valid_fields);
}

sub get_header {
  my $self = shift;

  return $self->{header};
}

sub set_header {
  my $self = shift;
  my $header = shift;

  $self->{header} = $header;

  return;
}

sub get_footer {
  my $self = shift;

  return $self->{footer};
}

sub set_footer {
  my $self = shift;
  my $footer = shift;

  $self->{footer} = $footer;

  return;
}

sub get_inprogress_msg {
  my $self = shift;

  return $self->{inprogress_msg};
}

sub set_inprogress_msg {
  my $self = shift;
  my $inprogress_msg = shift;

  $self->{inprogress_msg} = $inprogress_msg;

  return;
}

sub get_complete_msg {
  my $self = shift;

  return $self->{complete_msg};
}

sub set_complete_msg {
  my $self = shift;
  my $complete_msg = shift;

  $self->{complete_msg} = $complete_msg;

  return;
}

sub get_failed_msg {
  my $self = shift;

  return $self->{failed_msg};
}

sub set_failed_msg {
  my $self = shift;
  my $failed_msg = shift;

  $self->{failed_msg} = $failed_msg;

  return;
}

sub get_action {
  my $self = shift;

  return $self->{action};
}

sub set_action {
  my $self = shift;
  my $action = shift;

  throw "(set_error) '$action' is not an RHN::AppInstall::Process::Step::ActionStatus::Action"
    unless (ref $action and $action->isa('RHN::AppInstall::Process::Step::ActionStatus::Action'));

  $self->{action} = $action;

  return;
}

1;

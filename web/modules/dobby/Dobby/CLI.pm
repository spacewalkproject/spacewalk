#
# Copyright (c) 2008--2015 Red Hat, Inc.
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
package Dobby::CLI;
use Params::Validate;
use Carp;

use Dobby::Log;

Params::Validate::validation_options(strip_leading => "-");

sub new {
  my $class = shift;
  my $exec_name = shift;

  my $self = bless { executable_name => $exec_name }, $class;

  $self->register_mode(-command => "help",
                       -description => "Display command summary",
                       -handler => \&Dobby::CLI::command_help);

  return $self;
}

sub register_mode {
  my $self = shift;
  my %params = validate(@_, { command => 1, description => 1, handler => 1 });

  croak "Attempt to re-register existing command $params{command}" if exists $self->{modes}->{$params{command}};

  $self->{modes}->{$params{command}} = \%params;
}

sub invoke_command {
  my $self = shift;
  my $command = shift;
  my @args = @_;

  $self->fatal("No such command '$command'; use 'help' to list available commands.") unless exists $self->{modes}->{$command};

  $self->{executing_mode} = $command;
  my $handler = $self->{modes}->{$command}->{handler};

  $handler->($self, $command, @args);
}

sub usage {
  my $self = shift;
  my $msg = shift;

  print STDERR sprintf("Usage: %s %s %s\n", $self->{executable_name}, $self->{executing_mode}, $msg);
  exit 1;
}

sub fatal {
  my $self = shift;
  my $msg = shift;

  print STDERR "$msg\n";
  exit 1;
}

sub command_help {
  my $self = shift;
  my $command = shift;
  my @args = @_;

  print "Available commands:\n";
  for my $command (sort keys %{$self->{modes}}) {
    printf "       %-10s - %s\n", $command, $self->{modes}->{$command}->{description};
  }
}

1;

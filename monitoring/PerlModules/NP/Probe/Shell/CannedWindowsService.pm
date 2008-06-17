package NOCpulse::Probe::Shell::CannedWindowsService;

use strict;

use base qw(NOCpulse::Probe::Shell::WindowsService);

use Class::MethodMaker
  get_set =>
  [qw(
      last_command
     )],
  counter =>
  [qw(
      command_count
     )],
  list =>
  [qw(
      results
      errors
     )],
;

sub connect {
    my $self = shift;
    $self->connected(1);
}

sub disconnect {
    my $self = shift;
    $self->connected(0);
}

sub write_command {
    my ($self, $command) = @_;
    $self->last_command($command);
    $self->command_count_incr();
}

sub read_result {
    my $self = shift;
    return $self->stdout;
}

sub stdout {
    my $self = shift;
    return $self->results->[$self->command_count - 1] if $self->results;
}

sub stderr {
    my $self = shift;
    return $self->errors->[$self->command_count - 1] if $self->errors;
}


1;

package NOCpulse::Probe::Shell::AbstractShell;

use strict;

use IPC::Open3;
use IO::Handle;
use IO::Select;
use POSIX ':sys_wait_h';
use Error;

use NOCpulse::Log::Logger;
use NOCpulse::Probe::MessageCatalog;
use NOCpulse::Probe::Error;

use Class::MethodMaker
  abstract =>
  [qw(
      connect
      disconnect
      write_command
      read_result
     )],
  get_set =>
  [qw(
      shell_command
      shell_switches
      timeout_seconds
      write_timeout_seconds
      stdout
      stderr
      last_command
      command_status
      exit_code
      end_marker
      end_marker_command
      end_marker_regex
      timed_out
      connection_broken
      exec_failed
      connected
      _message_catalog
     )],
  new_hash_init => 'hash_init',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


# Public methods


# Initializes message catalog.
sub init {
    my ($self, %args) = @_;
    $args{_message_catalog} = NOCpulse::Probe::MessageCatalog->instance();
    $self->hash_init(%args);
}


# Returns true value if the latest command timed out, had a broken
# connection, or nonzero exit code.
sub failed {
    my ($self) = @_;
    return $self->timed_out
      || $self->connection_broken
      || $self->command_status != 0;
}


# Runs a shell command, setting stdout, stderr, and command_status.
# Raises NotConnectedError if not connected, LostConnectionError
# if the child shell cannot be written to, and TimedOutError if
# reading the response timed out.
sub run {
    my ($self, $command) = @_;

    unless ($self->connected) {
        local $Error::Depth = $Error::Depth + 1;
        throw NOCpulse::Probe::Shell::NotConnectedError(
            $self->_message_catalog->shell('not_connected'));
    }
    
    # Clear any prior state.
    $self->stdout(undef);
    $self->stderr(undef);
    $self->command_status(0);
    
    # Store this command as the last one run.
    $self->last_command($command);
    $Log->log(2, "$command\n");
    
    # Set up the line that tells us we're done reading
    $self->end_marker_init();
    
    # Write the command.
    $self->write_command($command);
    
    # Read the results.
    $self->read_result();
    $self->handle_read_errors();
    
    return 1;
}

sub _throw_lost_connection {
    my $self = shift;

    my $msg;
    if ($self->stderr) {
        $msg = sprintf($self->_message_catalog->shell('lost_connection_err'), $self->stderr);
    } else {
        $msg = $self->_message_catalog->shell('lost_connection');
    }
    local $Error::Depth = $Error::Depth + 1;
    throw NOCpulse::Probe::Shell::LostConnectionError($msg);
}

# Raises TimedOutError or LostConnectionError based on
# timed_out and connection_broken flags. The caller info is
# from one level up in the stack to be more useful.
sub handle_read_errors {
    my ($self) = @_;
    if ($self->timed_out) {
        local $Error::Depth = $Error::Depth + 1;
        my $msg;
        if ($self->stderr) {
            $msg = sprintf($self->_message_catalog->shell('timed_out_err'),
                           $self->timeout_seconds, $self->stderr);
        } else {
            $msg = sprintf($self->_message_catalog->shell('timed_out'),
                           $self->timeout_seconds);
        }        
        throw NOCpulse::Probe::Shell::TimedOutError($msg);
    } elsif ($self->connection_broken) {
        $self->_throw_lost_connection();
    }
}

# Initializes the end-of-data marker for this connection.
sub end_marker_init {
}

# Disconnects the shell when it goes out of scope.
sub DESTROY {
    # Preserve the eval error in case disconnect does its own eval.
    my $prev_err = $@;
    $_[0]->disconnect;
    $@ = $prev_err;
}

# Helper method to transfer shell args, optionally translating argument names.
sub _transfer_args {
    my ($self, $argsref, $transfer_to) = @_;
    my %new_args = ();
    if (ref($transfer_to) eq 'ARRAY') {
        foreach my $name (@{$transfer_to}) {
            $new_args{$name} = $argsref->{$name};
        }
    } elsif (ref($transfer_to) eq 'HASH') {
        while (my ($old_name, $new_name) = each %{$transfer_to}) {
            if ((exists $argsref->{$old_name}) and not (exists $argsref->{$new_name})) {
                $new_args{$new_name} = $argsref->{$old_name};
            } elsif (exists $argsref->{$new_name}) {
                $new_args{$new_name} = $argsref->{$new_name};
            }
        }
    } else {
        throw NOCpulse::Probe::InternalError("Transfer target not an " .
                                             "array or hash ref: $transfer_to");
    }
    return %new_args;
}


1;

__END__

=head1 NAME

  NOCpulse::Probe::Shell::AbstractShell - Shell base class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Overview

=head2 Construction and initialization

=head2 Methods

=cut

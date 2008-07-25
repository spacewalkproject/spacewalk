package NOCpulse::Probe::Shell::Unix;

use strict;

use IPC::Open3;
use IO::Handle;
use IO::Select;
use POSIX ':sys_wait_h';
use Error;

use NOCpulse::Log::Logger;
use NOCpulse::Probe::Error;

use base qw(NOCpulse::Probe::Shell::AbstractShell);

use Class::MethodMaker
  get_set =>
  [qw(
      os_name
      os_version
      shell_pid
      killed_by_signal
      _child_pid
      _child_stdin
      _child_stdout
      _child_stderr
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

# Time to wait for something to appear on stderr that indicates
# the connection failed
use constant TEST_CONNECT_ERROR_TIMEOUT => 0.30;

# Connects to a shell. Returns true value if connection succeeded,
# otherwise raises ConnectError.
sub connect {
    my $self = shift;

    if ($self->connected) {
        $Log->log(2, "Ignoring attempt to connect to connected shell\n");
        return 1;
    }
    
    $Log->log(2, "Execute '", $self->shell_command, " @{$self->shell_switches}'\n");

    $self->_child_stdin(IO::Handle->new);
    $self->_child_stdout(IO::Handle->new);
    $self->_child_stderr(IO::Handle->new);
    
    my $child_died = 0;
    local $SIG{'CHLD'} = sub { $child_died = 1; };
    
    $self->_child_pid(open3($self->_child_stdin,
                            $self->_child_stdout,
                            $self->_child_stderr,
                            $self->shell_command,
                            @{$self->shell_switches}));
    $Log->log(3, "Opened pipe to ", $self->_child_pid, "\n");

    my $errs;

    my $stderr_readable = IO::Select->new($self->_child_stderr);
    if ($stderr_readable->can_read(TEST_CONNECT_ERROR_TIMEOUT)) {
        $errs = $self->_drain_handle($self->_child_stderr, $stderr_readable);
    }

    # Allow subclasses to give a regex to ignore, such as
    # the ssh warnings about adding hosts.
    my $regex = $self->ignore_connect_error_regex;

    unless ($errs and not ($regex && $errs =~ /$regex/)) {
        # Get the pid and uname info from the shell. This also
        # should force connection errors to appear on stderr.
        $self->end_marker_init();
        $self->write_command('echo `uname -s`#`uname -r`#$$');
        $self->read_result();

        # Need to be careful here.  If the child timed out on connect,
        # the ssh process might still be trying.  Need to kill it.
        $self->_kill_child() if ($self->timed_out());

        $self->handle_read_errors();

        my $result = $self->stdout;
        if ($result) {
            chomp $result;
            my @parts = split("#", $result);
            $self->os_name($parts[0]);
            $self->os_version($parts[1]);
            $self->shell_pid($parts[2]);
            $Log->log(3, 'OS ', $self->os_name, ' ', $self->os_version, ', shell pid ',
                      $self->shell_pid, "\n");
        }
        $errs = $self->stderr;
    }

    # If we got a sigchld or there is anything written to stderr,
    # assume the shell connection failed.
    if ($child_died || $errs) {
        $Log->log(2, "Child died = $child_died, OS err $?, stderr $errs\n");
        
        unless ($regex and $errs =~ /$regex/) {

            # Not suppressed, remember the error message and bail out.
            $self->connected(0);
            $self->stderr($errs);

            if ($errs =~ /^open3:/) {
                # Open3 exec failed, which only happens if the shell command
                # itself cannot be exec'ed.
                $self->exec_failed(1);
            }
            $self->_handle_exit_code;
        
            if ($self->exec_failed()) {
                $Log->log(2, "Execution failed\n");
                my $msg = sprintf($self->_message_catalog->shell('exec_failed'),
                                  $self->shell_command);
                throw NOCpulse::Probe::Shell::ExecFailedError($msg);
            }
            $Log->log(2, "Failed\n");
            my $msg;
            my $cmd = $self->shell_command . " @{$self->shell_switches}";
            if ($errs) {
                $errs =~ s/[\r\n]/ /g;
                $errs =~ s/\.?\s*$//g;
                $msg = sprintf($self->_message_catalog->shell('connect_failed_err'), $errs, $cmd);
            } else {
                $msg = sprintf($self->_message_catalog->shell('connect_failed'), $cmd);
            }
            throw NOCpulse::Probe::Shell::ConnectError($msg);
        }
    }
    
    $Log->log(2, "OK\n");
    $self->connected(1);
    return $self->connected;
}


# Disconnects the shell, killing the child if necessary.
sub disconnect {
    my $self = shift;
    
    return unless $self->connected;
    
    $Log->log(2, "Disconnecting\n");
    
    $self->connected(0);

    $self->_kill_child();
}



# Overridable methods



# Writes a command to the shell with appropriate safeguards.
sub write_command {
    my ($self, $command) = @_;

    # Set up the pipe handler to catch writes to a dead child.
    my $child_broken = 0;
    local $SIG{'PIPE'} = sub { $child_broken = 1; };
    
    # Send the command and our exit marker.
    eval {
        my $writeable = IO::Select->new($self->_child_stdin);
        if ($writeable->can_write(1)) {
            # Send the command, followed by the end marker suffixed by the
            # status of the script execution
            $Log->log(4, "Sending >>>$command\n", $self->end_marker_command, "<<<\n");
            $self->_child_stdin->print($command, "\n", $self->end_marker_command);
            $self->_child_stdin->flush();  # Make sure any SIGPIPE happens right away
            $Log->log(4, "Done\n");
        } else {
            # We can't write to the child at all
            $Log->log(1, "Cannot write to child process\n");
            $child_broken = 1;
        }
    };
    if ($child_broken) {
        $self->connection_broken(1);
        $self->disconnect();
        $Log->log(2, "Connection broken trying to write command: ", $self->stderr, "\n");
        $self->_throw_lost_connection();
    }
}

# Reads the stdout and stderr from the last command. Returns nothing.
# Sets the timed_out field if read times out.
sub read_result {
    my $self = shift;
    
    # Assume timeout. At the end of a successful read this flag must be reset.
    $self->timed_out(1);
    
    # Set up the read buffers, each a scalar, indexed by fileno.
    my @buffers = ();
    $buffers[$self->_child_stdout->fileno] = '';
    $buffers[$self->_child_stderr->fileno] = '';
    
    my $marker_regex = $self->end_marker_regex;
    
    my $got = '';
    
    my $readable = IO::Select->new($self->_child_stdout, $self->_child_stderr);
    
    # Read the results.
  READ: while (my @ready = $readable->can_read($self->timeout_seconds)) {
        
        foreach my $fh (@ready) {
            $fh->sysread($got, 4096);
            
            if (length($got)) {
                if ($Log->loggable(4)) {
                    $Log->log(4, "Read ", length($got), 
                        " bytes from ", $fh->fileno, ": >>>$got<<<\n");
                }
                $buffers[$fh->fileno] .= $got;

                if ($buffers[$fh->fileno] =~ /$marker_regex/) {
                    # Matched our end of data marker, which should include the
                    # real command status as an integer at the end. Allow for
                    # up to three alternations for finding the status.
                    my $status = $1;
                    $status = $2 unless defined($status);
                    $status = $3 unless defined($status);
                    $self->command_status($status);
                    
                    # Strip out the marker
                    $buffers[$fh->fileno] =~ s/$marker_regex//;

                    # Get anything left in stderr.
                    $buffers[$self->_child_stderr->fileno] .=
                        join('', $self->_drain_stderr());
                    
                    $self->timed_out(0);
                    last READ;
                    
                } 
                
            } else {
                # Ready to read but nothing there means the child has died.
                # Remove this handle and drain the remaining one, or
                # finish the loop if this is the last one.
                if (scalar($readable->handles) > 1) {
                    $readable->remove($fh);
                } else {
                    $self->connection_broken(1);
                    $self->timed_out(0);
                    last READ;
                }
            }
        }
    }
    
    # Assign the output strings to their respective slots.
    $self->stdout($buffers[$self->_child_stdout->fileno]);
    $self->stderr($buffers[$self->_child_stderr->fileno]);
    
    if ($Log->loggable(3)) {
        $Log->log(3, "stdout: >>>", $self->stdout, "<<<\n");
        $Log->log(3, "stderr: >>>", $self->stderr, "<<<\n");
        $Log->log(3, "status: >>>", $self->command_status, "<<<\n");
    }
    
    if ($self->connection_broken) {
        # Clean up before we leave if the child is gone.
        $self->disconnect();
    }
}

# Returns the regex that describes ignorable errors during connection.
# Defaults to nothing.
sub ignore_connect_error_regex {
}


# Initializes the end-of-data marker for this connection.
sub end_marker_init {
    my $self = shift;
    my $now = time();
    my $marker = "NOCPULSE-$now-STATUS";
    $self->end_marker($marker);
    $self->end_marker_regex(qr/$marker (-?\d+)\n$/);
    $self->end_marker_command('echo '.$marker.' $?'."\n");
}



# Internal methods



# Extracts the exit code and killed-by-signal from $?.
sub _handle_exit_code {
    my $self = shift;
    $self->exit_code($? >> 8);
    $self->killed_by_signal($? & 127);
}

sub _drain_stderr {
   my $self = shift;

   return $self->_drain_handle($self->_child_stderr);
}

# Reads and returns the current contents of the child's stderr.
sub _drain_handle {
   my ($self, $handle, $readable) = @_;

   $readable ||= IO::Select->new($handle);
   my @errs = ();
   my $got = '';

   while (my @ready = $readable->can_read(0.25)) {
      my $fh = $ready[0];
      my $num_read = $fh->sysread($got, 4096);
      last if $num_read == 0;
      push(@errs, $got);
   }
   return join('', @errs);
}


sub _kill_child {
    my $self = shift;

    # Try for a graceful exit.
    $self->_child_stdin->close();
    
    # Give up to two seconds to actually die.
    my $dead_pid;
    my $wait_until = time() + 2;
    do {
        $dead_pid = waitpid($self->_child_pid, &WNOHANG);
        select(undef, undef, undef, 0.25);
    } until ($dead_pid == -1 || $dead_pid == $self->_child_pid || time() == $wait_until);
    
    # It's still alive, so kill it completely.
    if ($dead_pid == 0) {
        $Log->log(2, "Killing ", $self->_child_pid, "\n");
        kill('KILL', $self->_child_pid);
        $self->exit_code(0);
        $self->killed_by_signal(9);
        
    } else {
        $Log->log(2, "Child exit code $?\n");
        $self->_handle_exit_code;
    }
}

1;

__END__

=head1 NAME

  NOCpulse::Probe::Shell::Unix - Unix shell base class

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Overview

=head2 Construction and initialization

=head2 Methods

=cut

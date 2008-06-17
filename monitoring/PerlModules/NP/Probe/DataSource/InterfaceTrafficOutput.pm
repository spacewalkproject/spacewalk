package NOCpulse::Probe::DataSource::InterfaceTrafficOutput;

use strict;

use NOCpulse::Probe::Config::UnixOS qw(:constants);
use NOCpulse::Log::Logger;

use Class::MethodMaker
  get_set =>
  [qw(
      found_interface
      bytes_in
      bytes_out
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub init {
    my ($self, $unix_command, $shell_os_name, $for_interface) = @_;

    $for_interface or throw NOCpulse::Probe::InternalError("No interface provided\n");

    my %os_command =
      (
       LINUX() =>
       {
        binary => '/bin/cat',
        args   => '/proc/net/dev',
        parse  =>
        sub {
            my ($self, $line) = @_;
            # Match "  eth0:"
            $Log->log_method(2, "init", "Check $line for $for_interface\n");
            if ($line =~ /^\s*$for_interface:/i) {
                $line =~ s/^\s+//g;
                my ($in, $out) = (split(/[:\s]+/, $line))[1,9];
                $self->found_interface(1);
                $self->bytes_in($in);
                $self->bytes_out($out);
            }
        }
       },

       SOLARIS() =>
       {
        binary => '/bin/netstat',
        args   => "-k $for_interface",
        parse  =>
        sub {
            my ($self, $line) = @_;
            if ($line =~ /^$for_interface/i) {
                $self->found_interface(1);
            } elsif ($self->found_interface && $line =~ / [r|o]bytes /) {
                # rx_late_collisions 0 rbytes 2361200816 obytes 2793491976 ...
                $line =~ /[^ ]* [^ ]* ([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*).*/;
                $self->bytes_in($2);
                $self->bytes_out($4);
            }
        }
       },

       BSD() =>
       {
        binary => '/usr/bin/netstat',
        args   => '-b -i',
        parse  =>
        sub {
            my ($self, $line) = @_;
            if ($line =~ /^$for_interface /i && $line =~ /<Link>/) {
                $self->found_interface(1);
                my @fields = split(' ', $line);
                my $macaddr = $fields[3];
                if ($macaddr =~ /[:.]/) {
                    $self->bytes_in($fields[6]);
                    $self->bytes_out($fields[9]);
                } else {
                    $self->bytes_in($fields[5]);
                    $self->bytes_out($fields[8]);
                }
            }
        }
       },
      );

    my $os_entry = $os_command{$shell_os_name};
    if ($os_entry) {
        my $binary = $os_entry->{binary};
        my $command = $binary . ' ' . $os_entry->{args};
        $Log->log_method(2, "init", "$shell_os_name: $command\n");

        $unix_command->ensure_program_installed($binary);

	$unix_command->execute($command);

        my @lines = split(/\n/, $unix_command->results);
        foreach my $line (@lines) {
            &{$os_entry->{parse}}($self, $line);
        }
    } else {
        $unix_command->unsupported_os();
    }

    return $self->found_interface;
}

1;

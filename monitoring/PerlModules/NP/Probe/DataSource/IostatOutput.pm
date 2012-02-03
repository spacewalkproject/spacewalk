package NOCpulse::Probe::DataSource::IostatOutput;

use strict;

use NOCpulse::Probe::Config::UnixOS qw(:constants);
use NOCpulse::Log::Logger;

use Class::MethodMaker
  get_set =>
  [qw(
      found_disk
      kbytes_read
      kbytes_written
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub init {
    my ($self, $unix_command, $shell_os_name, $for_disk) = @_;

    defined($for_disk) or throw NOCpulse::Probe::InternalError("No disk provided\n");

    my %os_command =
      (
       LINUX() => 
       {
        binary => '/usr/bin/iostat',
        args   => '-dk',
        parse  =>
        sub {            
            my ($self, $line) = @_;
            # systat 2.0
            # Device:       tps    Kb_read/s    Kb_wrtn/s    Kb_read    Kb_wrtn
            # sda           1.72         0.28         2.28     777171    6336201
            # sda1          0.00         0.00         0.00          0          0

            if (($line =~ /^\w*$for_disk\s+/i) or ($line =~ /^\w*\-$for_disk\s+/i))  {
                my ($in, $out) = (split(' ', $line))[4, 5];
                $self->found_disk(1);
                $self->kbytes_read($in);
                $self->kbytes_written($out);
            }
        }
       },

       SOLARIS() => 
       {
        binary => '/bin/iostat',
        args   => '-xI',
        parse  =>
        sub {            
            my ($self, $line) = @_;
            # device       r/i    w/i   kr/i   kw/i wait actv  svc_t  %w  %b 
            # md10      474405.0 3045303.0 5471763.0 20576798.0  0.0  0.0   30.0   1   2 
            # md11      237203.0 3044285.0 2739555.0 20554596.5  0.0  0.0   17.2   0   1 
            if ($line =~ /^\w*$for_disk\s+/i) {
                $self->found_disk(1);
                my ($in, $out) = (split(' ', $line))[3, 4];
                $self->found_disk(1);
                $self->kbytes_read($in);
                $self->kbytes_written($out);
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

    return $self->found_disk;
}

1;

package NOCpulse::Probe::DataSource::SwapOutput;

use strict;

use NOCpulse::Probe::Config::UnixOS ':constants';
use NOCpulse::Log::Logger;

use Class::MethodMaker
  get_set =>
  [qw(
      found
      used
      free
      total
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub init {
    my ($self, $unix_command, $shell_os_name) = @_;

    $self->found(0);

    my %os_command =
      (
       LINUX() =>
       {
        binary => '/usr/bin/free',
        args   => '-b',
        parse  =>
        sub {
            my ($self, $line) = @_;
            if ($line =~ /^Swap:\s+(\d+)\s+(\d+)\s+(\d+)$/) {
                $self->total($1);
                $self->used($2);
                $self->free($3);
                $self->found(1);
            }
        }
       },
       AIX() =>
       {
        binary => '/usr/sbin/lsps',
        args   => '-s',
        parse  =>
        sub {
            my ($self, $line) = @_;
            #Total Paging Space   Percent Used
            #   2048MB               3%
            if ($line =~ /^.*(\d+)MB\s+(\d+)%$/) {
                $self->total($1);
                #free for the AIX case is 100 minus percent used we got from lsps and will get handled by the swap plugin
                $self->free(100 - $2);
                $self->found(1);
            }
        }
       },

       SOLARIS() =>
       {
        binary => '/usr/sbin/swap',
        args   => '-s',
        parse  =>
        sub {
            my ($self, $line) = @_;
            # total: 496368k bytes allocated + 87592k reserved = 583960k used, 2278544k available
            if ($line =~
                /^total: \d+\D bytes allocated \+ \d+\D reserved = (\d+\D) used, (\d+\D) available/)
              {
                  $self->used(convert_to_bytes($1));
                  $self->free(convert_to_bytes($2));
                  $self->total($self->used + $self->free);
                  $self->found(1);
              }
        }
       },

       BSD() =>
       { 
        binary => '/usr/sbin/swapinfo',
        args   => '-k',
        parse  =>
        sub {            
            my ($self, $line) = @_;
            # Device          1K-blocks     Used    Avail Capacity  Type
            # /dev/ad0s1b       1048448        0  1048448     0%    Interleaved
            if ($line =~ /^\S+\s+(\d+)\s+(\d+)\s+(\d+)/) {
                $self->total($self->total + ($1 * 1024));
                $self->used($self->used + ($2 * 1024));
                $self->free($self->free + ($3 * 1024));
                $self->found(1);
            }
        }
       },

       IRIX() =>
       {
        binary => '/sbin/swap',
        args   => '-s',
        parse  =>
        sub {            
            my ($self, $line) = @_;
            # total: 5.06m allocated + 28.37m add'l reserved = 33.43m bytes used, 153.81m bytes available
            if ($line =~
                /^total: [\d.]+\D allocated \+ [\d.]+\D add\'l reserved = ([\d.]+\D) bytes used, ([\d.]+\D) bytes available/)
              {
                  $self->used(convert_to_bytes($1));
                  $self->free(convert_to_bytes($2));
                  $self->total($self->used + $self->free);
                  $self->found(1);
              }
        }
       },
      );
    $os_command{IRIX64} = $os_command{IRIX};

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
}

sub convert_to_bytes {
    my $value = shift;

    if ($value =~ s/m//) {
        $value *= 1024 * 1024;
    } elsif ($value =~ s/k//) {
        $value *= 1024;
    } else {
        $value =~ s/\D//;
    }
    return $value;
}

1;

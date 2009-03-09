package NOCpulse::Probe::DataSource::UnixCommand;

use strict;

use Error qw(:try);

use NOCpulse::Probe::Config::UnixOS qw(:constants);
use NOCpulse::Probe::Error;
use NOCpulse::Probe::Shell::Local;
use NOCpulse::Probe::Shell::SSH;
use NOCpulse::Probe::DataSource::DfOutput;
use NOCpulse::Probe::DataSource::DigOutput;
use NOCpulse::Probe::DataSource::InterfaceTrafficOutput;
use NOCpulse::Probe::DataSource::IostatOutput;
use NOCpulse::Probe::DataSource::NetstatOutput;
use NOCpulse::Probe::DataSource::PsOutput;
use NOCpulse::Probe::DataSource::SwapOutput;
use NOCpulse::Probe::DataSource::UptimeOutput;
use NOCpulse::Probe::DataSource::VirtualMemoryOutput;
use NOCpulse::Probe::DataSource::LogAgentOutput;

use base qw(NOCpulse::Probe::DataSource::AbstractOSCommand);

use Class::MethodMaker
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

use constant LOCAL_SHELL => 'NOCpulse::Probe::Shell::Local';
use constant SSH_SHELL   => 'NOCpulse::Probe::Shell::SSH';


sub init {
    my ($self, %in_args) = @_;

    my $shell_class = $in_args{shell} || LOCAL_SHELL;

    if ($shell_class eq "SSHRemoteCommandShell") {
        $shell_class = SSH_SHELL;
    }

    if ($shell_class eq SSH_SHELL) {
        # Assign the default nocpulsed port number.
        $in_args{sshport} ||= 4545;
    }

    my %own_args = ();

    $self->default_datasource_args(\%in_args, \%own_args);

    $in_args{timeout_seconds} = delete $in_args{timeout};

    $own_args{shell} = $shell_class->new(%in_args);

    $self->SUPER::init(%own_args);

    return $self;
}

# Raises OSMismatchError if the configured OS and the real one
# returned by uname don't match.
sub ensure_os_matches {
    my $self = shift;

    my $configured_os = $self->probe_record->os_name;

    my $match = NOCpulse::Probe::Config::UnixOS::os_matches($self->shell_os_name,
                                                            $configured_os);
    unless ($match) {
        my $msg = sprintf($self->_message_catalog->status('os_mismatch'),
                          $self->probe_record->host_name,
                          $self->probe_record->os_name,
                          $self->shell_os_name);
        throw NOCpulse::Probe::DataSource::OSMismatchError($msg);
    }
}

# Raises DataSource::UnsupportedOSError to indicate that the check is being run
# on an OS it doesn't know about.
sub unsupported_os {
    my $self = shift;
    my $msg = sprintf($self->_message_catalog->status('unsupported_os'), $self->shell_os_name);
    throw NOCpulse::Probe::DataSource::UnsupportedOSError($msg);
}

# Looks for an executable and raises DataSource::MissingProgramError if it can't be found.
sub ensure_program_installed {
    my ($self, $program_path) = @_;

    my $old_die_flag = $self->die_on_failure;
    $self->die_on_failure(0);

    $self->execute("test -x $program_path");

    $self->die_on_failure($old_die_flag);

    if ($self->command_status == 1) {
        my $msg = sprintf($self->_message_catalog->status('missing_program'), $program_path);
        throw NOCpulse::Probe::DataSource::MissingProgramError($msg);
    }
}


# Specific commands

sub cpu {
    my $self = shift;

    $self->ensure_os_matches();

    my $command = '/usr/bin/vmstat 5 2';
    my $is_aix = os_is_aix($self->shell_os_name);
    my $is_irix = os_is_irix($self->shell_os_name);

    if ($is_irix) {
        $command = '/usr/sbin/pmkstat -s3 -t1';
    }
    $self->execute($command);

    my @lines = split("\n", $self->results);
    my @out;
    if ($is_aix) {
	@out = split(' ', $lines[4]);
    } elsif ($is_irix) {
	@out = split(' ', $lines[5]);
    } else {
        @out = split(' ', $lines[3]);
    }

    my $cpu_pct_used;

    if (($is_irix) || ($is_aix) || ($lines[1] =~ /.*wa$/)) {
        $cpu_pct_used = $out[-3] + $out[-4];
    } elsif ($lines[1] =~ /.*st$/) {
        $cpu_pct_used = $out[-4] + $out[-5];
    } else {
        $cpu_pct_used = $out[-2] + $out[-3];
    }
    return $cpu_pct_used;
}

# Parses df output and returns a DfOutput instance, which
# has a for_filesystem hash indexed by filesystem name.
sub df {
    my $self = shift;
    my $args = '-k';

    if (os_matches($self->shell_os_name, PROBE_HPUX)){
	$args = '-Pk';
    } elsif (os_matches($self->shell_os_name, PROBE_AIX)) {
	$args = '-Ik';
    }

    $self->execute("/bin/df $args");

    return NOCpulse::Probe::DataSource::DfOutput->new($self->results);
}

# Runs the dig command with the dns_server and host or address to find.
# Returns a DigOutput instance.
sub dig {
    my ($self, $dns_server, $find_host) = @_;

    $self->die_on_failure(0);

    $dns_server or throw NOCpulse::Probe::InternalError("No DNS server provided");
    $find_host  or throw NOCpulse::Probe::InternalError("No host to find provided");

    #BZ 165759: IP addresses with leading zeros in any octets need
    #to be fixed so requests work correctly
    my @octets = split(/\./, $dns_server);
    foreach my $octet (@octets) {
        $octet =~ s/^0*//;
        $octet = 0 unless $octet;
    }
    $dns_server = join('.', @octets);

    if ($find_host =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {
        $self->execute("/usr/bin/dig \@$dns_server -x $find_host");
    } else {
        $self->execute("/usr/bin/dig \@$dns_server $find_host");
    }
    return NOCpulse::Probe::DataSource::DigOutput->new($self->results);
}

sub inodes {
    my ($self, $fs) = @_;

    my %os_command =
      (
       LINUX() =>
       {
        binary => '/bin/df',
        args   => "-i $fs",
        parse  =>
        sub {
            my (@fields) = @_;
               if ($fields[0] !~ /^\//){
                   #BZ147633: need to check for leading '/', as linux hosts that have
                   #line wraps in output need to be handled correctly
                   unshift @fields, ' ';
               }
            my $total = $fields[1];
            my $used  = $fields[2];
            my $free  = $fields[3];
            return ($used, $free, $total);
        }
       },
       AIX() =>
       {
        binary => '/bin/df',
        args   => "-v $fs",
        parse  =>
        sub {
            my (@fields) = @_;
            my $used  = $fields[5];
            my $free  = $fields[6];
            return ($used, $free, $used + $free);
        }
       },

       SOLARIS() =>
       {
        binary => '/bin/df',
        args   => "-o i $fs",
        parse  =>
        sub {
            my (@fields) = @_;
            my $used = $fields[1];
            my $free = $fields[2];
            return ($used, $free, $used + $free);
        }
       },

       BSD() =>
       {
        binary => '/bin/df',
        args   => "-i $fs",
        parse  =>
        sub {
            my (@fields) = @_;
            my $used = $fields[5];
            my $free = $fields[6];
            return ($used, $free, $used + $free);
        }
       },

       IRIX() =>
       {
        binary => "/usr/sbin/df",
        args   => "-i $fs",
        parse  =>
        sub {
            my (@fields) = @_;
            my $used = $fields[6];
            my $free = $fields[7];
            return ($used, $free, $used + $free);
        }
       },
      );
    $os_command{IRIX64} = $os_command{IRIX};

    my $os_entry = $os_command{$self->shell_os_name};

    if ($os_entry) {
        my $binary = $os_entry->{binary};
        my $command = $binary . ' ' . $os_entry->{args};
        $Log->log_method(2, 'inodes', $self->shell_os_name, ": $command\n");

        $self->ensure_program_installed($binary);

        try {
            $self->execute($command);

        } catch NOCpulse::Probe::DataSource::CommandFailedError with {
            if ($self->command_status == 1) {
                # Bad filesystem name
                return undef;
            } else {
                my $err = shift;
                throw $err;
            }
        };
        my @lines = split(/\n/, $self->results);

	##BZ147633: handle long device names for linux clients
        if ($lines[2]) {
            return &{$os_entry->{parse}}(split(' ', $lines[2]));
        } else {
            return &{$os_entry->{parse}}(split(' ', $lines[1]));
        }

    } else {
	$self->unsupported_os();
    }

}

sub interface_traffic {
    my ($self, $for_interface) = @_;

    $self->ensure_os_matches();

    return NOCpulse::Probe::DataSource::InterfaceTrafficOutput->new(
        $self, $self->shell_os_name, $for_interface);
}

sub iostat {
    my ($self, $for_disk) = @_;

    $self->ensure_os_matches();

    return NOCpulse::Probe::DataSource::IostatOutput->new(
        $self, $self->shell_os_name, $for_disk);
}

sub netstat_tcp {
    my $self = shift;

    $self->ensure_os_matches();

    return NOCpulse::Probe::DataSource::NetstatOutput->new($self, $self->shell_os_name);
}

sub free_memory {
    my ($self, $params_ref) = @_;

    my %os_command =
      (
       LINUX() => 
       {
        binary => '/usr/bin/free',
        args   => undef,
        parse  =>
        sub {
            my @lines = @_;
            my $free_memory;
            if ((!$params_ref->{reclaim}) || ($params_ref->{reclaim} =~ /^no$/i)) {
                $free_memory = (split(' ', $lines[1]))[3];
            } else {
                $free_memory = (split(' ', $lines[2]))[3];
            }
            return $free_memory;
        }
       },

       AIX() =>
       {
        binary => '/bin/vmstat',
        args   => '1 2',
        parse  =>
        sub {
            my @lines = @_;
            my $free_memory;
	    my $free_pages = (split(' ', $lines[4]))[3];
	    if ($free_pages > 0) {
		#AIX vmstat output is in 4096 byte pages
		$free_pages *= 4096;
		#but, we need the data given back to MemoryFree to be in Kbytes
		$free_memory = $free_pages / 1024;
	    } else {
		$free_memory = $free_pages;
	    }
	    return $free_memory;
        }
       },

       SOLARIS() =>
       {
        binary => '/bin/vmstat',
        args   => '1 2',
        parse  =>
        sub {
            my @lines = @_;
            (split(' ', $lines[3]))[4];
        }
       },

       BSD() =>
       {
        binary => '/usr/bin/top',
        args   => '-d1',
        parse  =>
        sub {
            my @lines = @_;
            my $free_memory = (split(',', $lines[3]))[-1];
            if ($free_memory =~ /M/) {
                $free_memory =~ s/\D//g;
                $free_memory *= 1024;
            } else {
                $free_memory =~ s/\D//g;
            }
            return $free_memory;
        }
       },

       IRIX() =>
       {
        binary => '/usr/sbin/pmkstat',
        args   => '-s1 -t1',
        parse  =>
        sub {
            my @lines = @_;
            (split(' ', $lines[3]))[2];
        }
       },

      );
    $os_command{IRIX64} = $os_command{IRIX};

    my $os_entry = $os_command{$self->shell_os_name};
    if ($os_entry) {
        my $binary = $os_entry->{binary};
        my $command = $binary . ' ' . $os_entry->{args};
        $Log->log_method(2, 'memory', $self->shell_os_name, ": $command\n");

        $self->ensure_program_installed($binary);

        $self->execute($command);

        return &{$os_entry->{parse}}(split(/\n/, $self->results));

    } else {
        $self->unsupported_os();
    }
}

sub logagent {
    my ($self, $log_file, $regex) = @_;

    $self->die_on_failure(0);

    return NOCpulse::Probe::DataSource::LogAgentOutput->new($self, $log_file, $regex);
}

sub ntpq {
    my ($self, $host) = @_;

    try {
	my $peer_data = $self->execute("/usr/sbin/ntpq -c \'host $host\' -c rv");

	my ($peer, $latency);
	if ($peer_data =~ /.*peer=(\d*)/ ) {
	    $peer = $1;
	    if ($peer) {
		my $offset_data = $self->execute("/usr/sbin/ntpq -c \'host $host\' -c \"rv $peer\"");
		if ($offset_data =~ /\boffset=\s*([+-]?\d+(?:\.\d*))\b/) {
		    $latency = $1;
		    return ($latency);	
		} else {
		    $Log->log_method(2, "Offest data not found \n");
		    my $msg = "Offset data not found";
		    throw NOCpulse::Probe::DataSource::CommandFailedError($msg)
		}
	    }
	} else {
	    $Log->log_method(2, "Peer data not found \n");
	    my $msg = "Peer data not found";
	    throw NOCpulse::Probe::DataSource::CommandFailedError($msg)
	}
    } catch NOCpulse::Probe::Shell::TimedOutError with {
	# Treat timeout the same as receiving no data from the query.
	$self->shell->command_status(1);
	$Log->log_method(3, "ntpq query", "timed out\n");
    };
}

sub page_scans {
    my ($self, $params_ref) = @_;

    my %os_command =
      (
       SOLARIS() =>
       {
        binary => '/bin/vmstat',
        args   => '1 4',
        parse  =>
        sub {
            my @lines = @_;
	    my @vmstat_line = (split(' ', $lines[5]));
	    if (scalar(@vmstat_line) != 22)  {
		$Log->log_method(2, "page_scans", "vmstat output format is incorrect");
		throw NOCpulse::Probe::DataSource::CommandFailedError("vmstat output format is incorrect");
	    } else {
		return $vmstat_line[11];
	    }
	}
       },

       HPUX() =>
       {
        binary => '/usr/bin/vmstat',
        args   => '1 4',
        parse  =>
        sub {
            my @lines = @_;
	    my @vmstat_line = (split(' ', $lines[5]));
	    if (scalar(@vmstat_line) != 18) {
		$Log->log_method(2, "page_scans", "vmstat output format is incorrect");
		throw NOCpulse::Probe::DataSource::CommandFailedError("vmstat output format is incorrect");
	    } else {
		return $vmstat_line[11];
	    }
	},
       }
      );

    my $os_entry = $os_command{$self->shell_os_name};
    if ($os_entry) {
        my $binary = $os_entry->{binary};
        my $command = $binary . ' ' . $os_entry->{args};
        $Log->log_method(2, 'page_scans', $self->shell_os_name, ": $command\n");

        $self->ensure_program_installed($binary);

        $self->execute($command);

        return &{$os_entry->{parse}}(split(/\n/, $self->results));

    } else {
        $self->unsupported_os();
    }
}

sub physical_memory_kb {
    my $self = shift;

    $self->ensure_os_matches();

    my %os_command =
      (

       LINUX() =>
       {
        binary => '/usr/bin/free',
        args   => '-t | /bin/grep Total',
        parse  =>
        sub {
            my $line = shift;
            if ($line =~ /^Total:\s+(\d+)\s+(\d+)\s+(\d+)$/) {
                return $1;
            }
        }
       },
       IRIX() =>
       {
        binary => '/bin/hinv',
        args   => '| /bin/grep memory',
        parse  =>
        sub {
            my $line = shift;
            if ($line =~ /^Main memory size: (\d+) Mbytes$/) {
                return $1 * 1024;
            }
        }
       },
       SOLARIS() =>
       {
        binary => '/usr/platform/`uname -i`/sbin/prtdiag',
        args   => '| /bin/grep Memory',
        parse  =>
        sub {
            my $line = shift;
            if ($line =~ /^Memory size: (\d+)/) {
                return $1 * 1024;
            }
        }
       },
      );
    my $os_entry = $os_command{$self->shell_os_name};
    if ($os_entry) {
        my $binary = $os_entry->{binary};
        my $command = $binary . ' ' . $os_entry->{args};
        $Log->log_method(2, 'physical_memory_kb', $self->shell_os_name, ": $command\n");

        $self->ensure_program_installed($binary);

	$self->execute($command);

        return &{$os_entry->{parse}}($self->results);
    } else {
        $self->unsupported_os();
    }
}

sub ping {
    my ($self, $ip, $packets) = @_;

    #adding 1 to packets since we will strip off the first packet due to possible network latency 
    #as the route is determined
    $packets += 1;

    #BZ 165759: IP addresses with leading zeros in any octets need
    #to be fixed so requests work correctly
    my @octets = split(/\./, $ip);
    foreach my $octet (@octets) {
        $octet =~ s/^0*//;
        $octet = 0 unless $octet;
    }
    $ip = join('.', @octets);

    my $old_die = $self->die_on_failure;
    $self->die_on_failure(0);

    my %os_command =
      (
       LINUX() =>
       {
        binary => '/bin/ping',
        args   => "-n -p ff -i .2 -c $packets $ip",
       },
       SOLARIS() =>
       {
        binary => '/usr/sbin/ping',
        args   => "-s -n $ip 56 $packets",
       }
      );

    my $os_entry = $os_command{$self->shell_os_name};
    if ($os_entry) {
	my $binary = $os_entry->{binary};
        my $command = $binary . ' ' . $os_entry->{args};
	$Log->log_method(2, 'Ping', $self->shell_os_name, ": $command\n");

	$self->ensure_program_installed($binary);

	my @pings = ();
	try {
	    my $ping_output = $self->execute($command);

	    $Log->log_method(2, "ping", "$ping_output\n");

	    if ($self->ran) {
		my @lines = split("\n", $ping_output);
		foreach my $line (@lines) {
		    if ($line =~ /^.*icmp_seq=(\d+).*$/) {
			my $icmp_seq = $1;
			$Log->log_method(4, "ping", "icmp $icmp_seq: $line\n");
			if ($icmp_seq != 0) {
                            if ($line =~ /\btime=(\d+(?:\.\d*)?)\s+([mu]?)s/) {
                                my($time, $unit) = ($1, $2);
                                if ($unit eq 'u') {
                                    # Microseconds (/1000 => milliseconds)
                                    $time /= 1000;
                                } elsif ($unit eq 'm') {
                                    # No conversion -- already in milliseconds
                                } else {
                                    # Seconds (*1000 => milliseconds)
                                    $time *= 1000;
                                }
                                push(@pings, $time);
                            }
                            $Log->log_method(3, "ping time", "$pings[-1]\n");
			}
		    }
		}
	    }
	} catch NOCpulse::Probe::Shell::TimedOutError with {
	    # Treat timeout the same as receiving no data from the ping.
	    $self->shell->command_status(1);
	    $Log->log_method(3, "ping", "timed out\n");
	};

	$self->die_on_failure($old_die);

	# Status 2 means other error which we report as UNKNOWN.
	if ($self->command_status == 2) {
	    $Log->log_method(3, "ping", "status 2\n");
	    my $msg = sprintf($self->_message_catalog->status('command_status'),
			      $self->command_status);
	    throw NOCpulse::Probe::DataSource::CommandFailedError($msg);
	}

	#taking the extra packet back so that our counts are correct
        $packets -= 1;

	my $ping_count = scalar(@pings);
	$Log->log_method(2, "ping $ping_count  pings\n");

	#various versions of ping (e.g. ping utility, iputils-ss020124) report the first icmp_seq as 1 and not 0,
	#so if that is the case, remove the icmp_seq=1 entry, as it is usually bad, and adjust the $ping_count accordingly
	if ($ping_count > $packets) {
	    shift @pings;
	    my $offset = $ping_count - $packets;
	    $Log->log(2, "Ping Count ($ping_count) greater than packets ($packets): removing offset of $offset packet(s)\n");
	    $ping_count -= $offset;
	};

	return @pings;

    } else {
	$self->unsupported_os();
    }
}

sub ps {
    my $self = shift;

    $self->ensure_os_matches();

    my %os_command =
      (
       LINUX()   => '/bin/ps -o pid,ppid,vsz,rss,time,state,args -ewwww',
       SOLARIS() => '/bin/ps -o pid,ppid,vsz,rss,time,nlwp,s,args -e',
       BSD()     => '/bin/ps -axwwww -o pid,ppid,vsz,rss,time,command',
       IRIX()    => '/bin/ps -o pid,ppid,vsz,rss,time,state,args -e',
       AIX()     => '/bin/ps -o pid,ppid,vsz,rssize,time,state,command -e',
      );
    $os_command{IRIX64} = $os_command{IRIX};

    my $command = $os_command{$self->shell_os_name};
    if ($command) {
        $Log->log_method(2, 'ps', $self->shell_os_name, ": $command\n");
        $self->ensure_program_installed('/bin/ps');
        $self->execute($command);
    } else {
	$self->unsupported_os();
    }

    return NOCpulse::Probe::DataSource::PsOutput->new($self->results);
}

sub smb{
    my ($self, $host, $share, $workgroup, $user, $password)  = @_;

    my $share_data = $self->execute("/usr/bin/smbclient \/\/$host\/$share $password -W $workgroup -U $user -c du");

    my ($pct_free, $avail);
    if ($share_data =~ /\s*(\d*) blocks of size (\d*)\. (\d*) blocks available/) {
	$pct_free = ($3/$1)*100;
	$avail  = ($3*$2)/1024;

	if (int($avail / 1024) > 0) {
	    $avail = int($avail / 1024);
	    if (int($avail /1024) > 0) {
		$avail = (int(($avail / 1024)*100))/100;
		$avail = $avail." GB";
	    } else {
		$avail = $avail." MB";
	    }
	} else {
	    $avail = $avail." KB";
	}
	return ($pct_free, $avail);
    } else {
	$Log->log_method(2, "SMB share data not found \n");
        my $msg = "SMB Share $host\/$share data could not be found";
        throw NOCpulse::Probe::DataSource::CommandFailedError($msg)
    }

}


sub swap {
    my $self = shift;

    $self->ensure_os_matches();

    return NOCpulse::Probe::DataSource::SwapOutput->new($self, $self->shell_os_name);
}

sub uptime {
    my $self = shift;

    $self->ensure_os_matches();

    return NOCpulse::Probe::DataSource::UptimeOutput->new($self, $self->shell_os_name);
}

sub virtual_memory {
    my $self = shift;

    $self->ensure_os_matches();

    return NOCpulse::Probe::DataSource::VirtualMemoryOutput->new($self, $self->shell_os_name);
}

sub w {
    my $self = shift;

    $self->ensure_os_matches();

    my $binary = '/usr/bin/w';
    if (os_is_irix($self->shell_os_name)) {
        $binary = '/usr/bsd/w';
    }
    $self->ensure_program_installed($binary);
    $self->execute("$binary -h");

    return split("\n", $self->results);
}

1;

__END__

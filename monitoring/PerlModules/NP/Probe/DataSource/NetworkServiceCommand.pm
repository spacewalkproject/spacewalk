package NOCpulse::Probe::DataSource::NetworkServiceCommand;

use strict;

use Error qw(:try);

use NOCpulse::Probe::Config::UnixOS qw(:constants);
use NOCpulse::Probe::Error;
use NOCpulse::Probe::Shell::Local;
use NOCpulse::Probe::Shell::SSH;
use NOCpulse::Probe::DataSource::DigOutput;
use Time::HiRes qw(gettimeofday tv_interval);

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
        $in_args{port} ||= 4545;
    }

    my %own_args = ();

    $self->default_datasource_args(\%in_args, \%own_args);

    $in_args{timeout_seconds} = delete $in_args{timeout};

    $own_args{shell} = $shell_class->new(%in_args);

    $self->SUPER::init(%own_args);

    return $self;
}

# Specific commands

# Runs the dig command with the dns_server and host or address to find.
# Returns a DigOutput instance.
sub dig {
    my ($self, $dns_server, $find_host) = @_;

    $self->die_on_failure(0);

    $dns_server or throw NOCpulse::Probe::InternalError("No DNS server provided");
    $find_host  or throw NOCpulse::Probe::InternalError("No host to find provided");

    if ($find_host =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/) {
        $self->execute("/usr/bin/dig \@$dns_server -x $find_host");
    } else {
        $self->execute("/usr/bin/dig \@$dns_server $find_host");
    }
    return NOCpulse::Probe::DataSource::DigOutput->new($self->results);
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
		if ($offset_data =~ /.*offset=\D*(\d*).*jitter.*/) {
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

sub nmb {
    my ($self, $server, $nmbname ) = @_;

    my $test_nmb = $self->execute("/usr/bin/nmblookup -U $server $nmbname");

    my $status;
    if ($test_nmb =~ /.*failed to find name.*/) {
	$Log->log_method(2, "NMB name $nmbname not found \n");
	$status = "for name $nmbname failed";
    } else {
	$Log->log_method(2, "NMB name $nmbname found \n");
	$status = "query for $nmbname on server $server succeeded";
    }
    return $status;
}

sub rpc {
    my ($self, $host, $proto, $service) = @_;

    $self->die_on_failure(0);

    my $proto_switch = ($proto eq 'tcp') ? 't' : 'u';

    my $start_time = [gettimeofday];
    my $command = $self->execute("/usr/sbin/rpcinfo -$proto_switch $host $service");
    my $end_time = [gettimeofday];
    my $latency = tv_interval($start_time, $end_time);

    if ($command =~ /ready and waiting$/) {
	$Log->log_method(2, "RPC connection was made and data was:\n $command \n");
	return $latency;
    } else {
	$Log->log_method(2, "RCP connection did not return good data:\n $command \n");
    }
}

sub smb{
    my ($self, $host, $share, $workgroup, $user, $password)  = @_;

    $self->die_on_failure(0);

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
    }

}

1;

__END__


=head1 NAME

  NOCpulse::Probe::DataSource::NetworkServiceCommands.pm - Datasource for network service checks that gather data by
  running a local command on the scout

=head1 SYNOPSIS

  The methods available are to be used by NOCpulse::Probe modules found in the NOCpulsePlugins package.
  This datasource is specifically for use by the probes in the /opt/home/nocpulse/libexec/NetworkService directory.

=head1 DESCRIPTION

  Need to add a description

=head1 METHODS

=over 4

=item dig ( $dns_server, $find_host )

This is the method that uses the dig command to query the given C<dns_server> (which should be a nameserver) for C<find_host> (the host to lookup).

=item ntpq ( $host )

Using the '/usr/sbin/ntpq' command, this method will return the offset found by querying the 'peer' as identifed by the C<host> (ntp server).

=item nmb

This method uses the '/usr/bin/nmblookup' command to query the given C<server> for the C<nmbname>. If it is found, an OK is generated. If not, then a CRITICAL state is returned.

=item rpc

The '/usr/sbin/rpcinfo' command is used to test the availability of the monitored hosts rpc service


=item smb ( $host, $share, $workgroup, $user, $password )

Using the '/usr/bin/smbclient' program, this method will return the pct_free metric data and the avail(able) item that is not a metric.


=back

=head1 BUGS

Will add bugs as I find them.

=head1 AUTHOR

 Nick Hansen <nhansen@redhat.com>
 Last updated: $id$

=head1 SEE ALSO

L<NOCpulse::Probe::Overview|PerlModules::NP::Probe::Overview>,
L<NOCpulse::Probe::DataSource::Overview|PerlModules::NP::Probe::DataSource::Overview>,
L<NOCpulse::Probe::ProbeRunner|PerlModules::NP::Probe::ProbeRunner>,
L<NOCpulse::Probe::ItemStatus|PerlModules::NP::Probe::ItemStatus>

=cut

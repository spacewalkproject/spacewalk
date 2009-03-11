package NOCpulse::Probe::DataSource::NetstatEntry;

use strict;

# local_ip and remote_ip are IPAddressRange instances
use Class::MethodMaker
  get_set =>
  [qw(
      local_ip
      local_port
      remote_ip
      remote_port
      state
     )],
  new => 'new',
  ;

sub to_string {
    my $self = shift;

    my $lip = $self->local_ip ? $self->local_ip->ip : 'none';
    my $rip = $self->remote_ip ? $self->remote_ip->ip : 'none';

    return "Local $lip:" . $self->local_port . " remote $rip:" . $self->remote_port . 
      " state " . $self->state;
}


package NOCpulse::Probe::DataSource::NetstatOutput;

use strict;

use NOCpulse::Probe::Config::UnixOS qw(:constants);
use NOCpulse::Log::Logger;
use NOCpulse::Probe::Utils::IPAddressRange;

use Class::MethodMaker
  list =>
  [qw(
      entries
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub init {
    my ($self, $unix_command, $shell_os_name) = @_;

    # Linux/BSD:
    # Active Internet connections (servers and established)
    # Proto Recv-Q Send-Q Local Address           Foreign Address         State      
    # tcp        0      0 192.168.0.72:4545       172.16.101.193:2967     TIME_WAIT   
    # tcp        0      1 127.0.0.1:4637          0.0.0.0:*               CLOSE       

    # Solaris:
    # TCP: IPv4
    #    Local Address        Remote Address    Swind Send-Q Rwind Recv-Q  State
    # -------------------- -------------------- ----- ------ ----- ------ -------
    #       *.*                  *.*                0      0 24576      0 IDLE
    #       *.4545               *.*                0      0 24576      0 LISTEN
    # 192.168.0.60.32784   192.168.0.72.6000    32120      0 24820     32 ESTABLISHED

    my %os_command =
      (
       LINUX() => 
       {
        binary => '/bin/netstat',
        args   => '-ant',
        parse  => \&linux_bsd,
       },

       BSD() => 
       {
        binary => '/usr/bin/netstat',
        args   => '-an',
        parse  => \&linux_bsd,
       },

       SOLARIS() => 
       {
        binary => '/bin/netstat',
        args   => '-an -P tcp',
        parse  => \&solaris,
       },
      );

    my $os_entry = $os_command{$shell_os_name};
    if ($os_entry) {
        my $binary = $os_entry->{binary};
        my $command = $binary . ' ' . $os_entry->{args};
        $Log->log(2, "$shell_os_name: $command\n");

        $unix_command->ensure_program_installed($binary);

	$unix_command->execute($command);

        my @lines = split(/\n/, $unix_command->results);
        foreach my $line (@lines) {
            my $entry = &{$os_entry->{parse}}($self, $line);
            $self->entries_push($entry) if $entry;
            $Log->log(2, "\n\t$line\n\t", $entry->to_string(), "\n") if $entry;
        }
    } else {
        $unix_command->unsupported_os();
    }
    return $self;
}

# Returns list of netstat entries filtered by port and IP pattern lists.
# The IP list contents should be IPAddressRange instances.
sub filtered_entries {
    my ($self, $local_port, $local_ips, $remote_port, $remote_ips) = @_;

    my @filtered = ();
    foreach my $entry (@{$self->entries}) {
        if (   $self->port_matches($local_port, $entry->local_port)
            && $self->port_matches($remote_port, $entry->remote_port)
            && $self->ip_matches($entry->local_ip, $local_ips)
            && $self->ip_matches($entry->remote_ip, $remote_ips)) {
            push(@filtered, $entry);
        }
    }
    return @filtered;
}

sub port_matches {
    my ($self, $match_port, $entry_port) = @_;

    defined($match_port) or return 1;

    return defined($entry_port) && $match_port eq $entry_port;
}

sub ip_matches {
    my ($self, $match_ip, $ip_list_ref) = @_;

    defined $ip_list_ref && scalar(@$ip_list_ref) or return 1;

    my $match = 0;
    foreach my $ip (@$ip_list_ref) {
        $match |= $ip->matches($match_ip);
    }
    return $match;
}

sub linux_bsd {
    my ($self, $line) = @_;
    return $self->parse_line($line, 3, 4, 5, qr/[\.:]/);
}

sub solaris {
    my ($self, $line) = @_;
    return $self->parse_line($line, 0, 1, 6, qr/[\.]/);
}

sub parse_line {
    my ($self, $line, $local_field, $remote_field, $state_field, $split_regex) = @_;

    my @fields = split(' ', $line);

    unless ($fields[$local_field] =~ /\./) {
        return undef;
    }

    my $entry = NOCpulse::Probe::DataSource::NetstatEntry->new();

    my ($octet_ref, $port) = $self->split_ip($fields[$local_field], $split_regex);
    $entry->local_ip(NOCpulse::Probe::Utils::IPAddressRange->new(octets => $octet_ref));
    $entry->local_port($port);

    ($octet_ref, $port) = $self->split_ip($fields[$remote_field], $split_regex);
    $entry->remote_ip(NOCpulse::Probe::Utils::IPAddressRange->new(octets => $octet_ref));
    $entry->remote_port($port);

    $entry->state($fields[$state_field]);

    return $entry;
}

sub split_ip {
    my ($self, $field, $regex) = @_;

    my @octets;
    my $port;

    ($octets[0], $octets[1], $octets[2], $octets[3], $port) = split($regex, $field);

    # Set empty octets to wildcard
    map { $_ = '*' unless defined($_) } @octets;

    return (\@octets, $port);
}

1;

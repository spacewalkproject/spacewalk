package NOCpulse::Probe::Shell::SSH;

use strict;

use NOCpulse::Log::Logger;

use base qw(NOCpulse::Probe::Shell::Unix);

use Class::MethodMaker
  get_set =>
  [qw(
      username
      host
      port
     )],
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

# Covers "permanently added host" and man-in-the-middle warnings.
use constant SSL_WARNING => qr/Warning:|WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED/;


sub init {
    my ($self, %in_args) = @_;

    my %args = $self->_transfer_args(\%in_args, 
                                     {sshuser => 'username',
                                      sshhost => 'host',
                                      sshport => 'port',
                                      timeout => 'timeout_seconds'});
    $args{timeout_seconds} = 60 unless defined $args{timeout_seconds};
    $args{write_timeout_seconds} = 5;

    my $host = $args{host};
    # add this hack to strip trailing whitespaces from the IP address we make the connection to
    # needed only for RHEL 2.1 systems -- see bug 141688 for more info
    $host =~ s/\s*$//;

    # this hack is needed to strip out padded zeroes in the IP address of systems that we 
    # want to ssh into. The zeroes are added during system registration and there's not much 
    # we can do about it after the data is there -- see bugs 158882 and 157657
    my @octets = split(/\./, $host);
    foreach my $octet (@octets) {
	$octet =~ s/^0*//;
        $octet = 0 unless $octet;
    }
    $host = join('.', @octets);

    $args{shell_command} = '/usr/bin/ssh';
    $args{shell_switches} = ['-l' => $args{username},
                             '-p' => $args{port},
                             '-i' => '/opt/home/nocpulse/.ssh/nocpulse-identity',
                             '-o' => 'StrictHostKeyChecking=no',
                             '-o' => 'BatchMode=yes',
                             $host,
                             '/bin/sh -s'
                            ];
    $self->SUPER::init(%args);
}

# Allowable stuff on stderr for ssh
sub ignore_connect_error_regex {
    return SSL_WARNING;
}

1;

__END__
  

=head1 NAME

  NOCpulse::Probe::Shell::SSH - Connects to an SSH daemon and runs /bin/sh

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Overview

Connects to an arbitrary SSH daemon on a Unix host. This could be nocpulsed
but could also be the standard sshd instead. Starts /bin/sh, sends
shellscripts to it, and collects the results or errors.

=head2 Construction and initialization

=head2 Methods

=cut

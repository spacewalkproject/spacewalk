package Oracle::TNSping;

use strict;

use Error qw(:try);
use IO::Socket::INET;
use Time::HiRes ();

# based on 
# http://www.jammed.com/~jwa/hacks/security/tnscmd/tnscmd

sub tnscmd {
    my ($command, $hostname, $port, $timeout) = @_;

    my $cmdlen = length ($command);
    my $clenH = $cmdlen >> 8;
    my $clenL = $cmdlen & 0xff;

    # calculate packet length
    my $packetlen = length($command) + 58; # "preamble" is 58 bytes
    my $plenH = $packetlen >> 8;
    my $plenL = $packetlen & 0xff;

    # decimal offset
    # 0:   packetlen_high packetlen_low
    # 26:  cmdlen_high cmdlen_low
    # 58:  command

    # the packet.
    my (@packet) = (
        $plenH, $plenL, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
        0x01, 0x36, 0x01, 0x2c, 0x00, 0x00, 0x08, 0x00,
        0x7f, 0xff, 0x7f, 0x08, 0x00, 0x00, 0x00, 0x01,
        $clenH, $clenL, 0x00, 0x3a, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x34, 0xe6, 0x00, 0x00,
        0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00
        );

    for (my $i=0;$i<length($command);$i++) {
        push(@packet, ord(substr($command, $i, 1)));
    }

    my ($sendbuf) = pack("C*", @packet);

    my $tns_sock = IO::Socket::INET->new(
        PeerAddr => $hostname,
        PeerPort => $port,
        Proto => 'tcp',
        Type => SOCK_STREAM,
        Timeout => $timeout);
    return (-1, '') unless $tns_sock; #could not connect
    $tns_sock->autoflush(1);

    my $count = length($sendbuf);
    my $offset = 0;
    while ($count > 0) {
        my $written = syswrite($tns_sock, $sendbuf, $count, $offset);
        $count -= $written;
        $offset += $written;
    }

    # get fun data
    # 1st 12 bytes have some meaning which so far eludes me
    my ($buf, $recvbuf);
    # read until socket EOF
    while (sysread($tns_sock, $buf, 128)) {
        $recvbuf .= $buf;
    }
    close ($tns_sock);
    return (1, $recvbuf);
}

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $start= Time::HiRes::time();
    my ($code, $response)=tnscmd("(CONNECT_DATA=(COMMAND=ping))",
        $params{'ip'}, $params{'port'}, $params{'timeout'});
    my $time=Time::HiRes::time()-$start;

    if ($code <= 0) {
        $result->item_critical("Could not connect to host $params{'ip'} on port $params{'port'}");
    } elsif ($response =~ /\(ERR=\d+\)/) {
        $result->context("TNS Listener");
        $result->metric_value('latency', $time, '%.3f');
    } else {
        $result->item_critical("Error from Oracle: ", $1);
    }
}

=head1 NAME

Oracle::TNSping - TNS ping probe

=head1 DESCRIPTION

This module implement NOCpulse probe, which try to ping Oracle database.

=head1 METHODS

=head2 run()

Run the probe. Accept hash and this fields are mandatory:

=over 4

=item result  - NOCpulse::Probe::Result object, where we pass the result of probe.

=item timeout - The timeout must be greater than zero.

=item ip - hostname to connect to

=item port - On which port is Oracle listener.

=back

=head1 SEE ALSO

L<NOCpulse::Probe::Result>

=head1 COPYRIGHT

Copyright (c) 2008 Red Hat, Inc.,
Miroslav Suchy <msuchy@redhat.com>

jwa@jammed.com (tnscmd function)

Permission is granted to copy, distribute and/or modify this 
document under the terms of the GNU Free Documentation 
License, Version 1.2 or any later version published by the 
Free Software Foundation; with no Invariant Sections, with 
no Front-Cover Texts, and with no Back-Cover Texts.

=cut

1;

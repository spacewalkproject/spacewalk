package Oracle::TNSping;

use strict;

use Error qw(:try);
use Net::Ping;

sub run {
    my %args = @_;

    my $result  = $args{result};
    my %params  = %{$args{params}};

    my $p = Net::Ping->new("tcp", $params{'timeout'});
    $p->hires(1);
    if (my ($return_code, $time, $resolved_ip) = $p->ping($params{'ip'})) {
        if ($return_code) {
	    $result->context("TNS Listener");
            $result->metric_value('latency', $time, '%.3f'); 
        } else {
	    $result->item_critical("Host is unreachable ", $resolved_ip);
        }
    } else {
	$result->item_unknown("Hostname cannot be found or there is a problem with the IP number ", $params{'ip'});
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

Permission is granted to copy, distribute and/or modify this 
document under the terms of the GNU Free Documentation 
License, Version 1.2 or any later version published by the 
Free Software Foundation; with no Invariant Sections, with 
no Front-Cover Texts, and with no Back-Cover Texts.

=cut

1;

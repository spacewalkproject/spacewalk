package General::SNMPCheck;

use strict;

use NOCpulse::Probe::SNMP::MibEntryList;

sub run {
    my %args = @_;
    
    my $result    = $args{result};
    my $param_ref = $args{params};

    $param_ref->{ip}   = delete $param_ref->{ip_0};
    $param_ref->{port} = delete $param_ref->{port_0};

    #BZ 165759: IP addresses with leading zeros in any octets need
    #to be fixed so requests work correctly
    my @octets = split(/\./, $param_ref->{ip});
    foreach my $octet (@octets) {
        $octet =~ s/^0*//;
	$octet = 0 unless $octet;
    }
    $param_ref->{ip} = join('.', @octets);


    my $entry = { name      => 'generic',
                  oid       => $param_ref->{oid_0},
                  data_type => 'INTEGER',
                  metric    => 'value',
                };

    NOCpulse::Probe::SNMP::MibEntryList->new($entry)->run(%args);
}

1;

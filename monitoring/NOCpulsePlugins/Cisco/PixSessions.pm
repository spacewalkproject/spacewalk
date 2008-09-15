package Cisco::PixSessions;

use strict;

use Error qw(:try);
use NOCpulse::Probe::SNMP::MibEntryList;

my $workaround_entry =
  # This OID is being walked via get_table due to a bug
  # in Cisco PIX code(Cisco bug #CSCdw77148), no useful data is
  # actually produced from it. The bug simply requires a walk of the table
  # first...weird
   { name      => "cfwConnectionStatValue.40",
     oid       => "1.3.6.1.4.1.9.9.147.1.2.2.2.1.5.40",
     is_index  => 1,
     match_any => 1,
     data_type => "OCTET_STRING",
   };

my @entries = 
  (
   { name      => 'cfwConnectionStatValue.40.6 (nconns)',
     oid       => '1.3.6.1.4.1.9.9.147.1.2.2.2.1.5.40.6',
     data_type => 'INTEGER',
     metric    => 'pix_sess',
   },
   { name      => 'cfwConnectionStatValue.40.7 (highwater_conns)',
     label     => 'Highest sessions since start',
     oid       => '1.3.6.1.4.1.9.9.147.1.2.2.2.1.5.40.7',
     data_type => 'INTEGER',
   },
  );

sub run {
    my %args = @_;
    my $result = $args{result};
    my $memory = $args{memory};

    # Table walk workaround
    delete $memory->{'MIB-CACHED-INDEX-cfwConnectionStatValue.40'};
    my $workaround_list = NOCpulse::Probe::SNMP::MibEntryList->new($workaround_entry);
    try {
       $workaround_list->run(%args);
    } otherwise {
    };
    $args{result}->remove_item('cfwConnectionStatValue.40');
    $args{result}->context(undef);   # Index entries set the context

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $oid_list->run(%args);
}

1;

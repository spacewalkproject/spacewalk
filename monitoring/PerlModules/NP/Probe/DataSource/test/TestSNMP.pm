package NOCpulse::Probe::DataSource::test::TestSNMP;

use strict;
use NOCpulse::Probe::DataSource::SNMP;
use NOCpulse::Probe::DataSource::Factory;

use base qw(Test::Unit::TestCase);

use constant DYNAMO_JDBC_OID => '.1.3.6.1.4.1.2725.1.5.1.1.7.1';
use constant DYNAMO_SNMP_PORT => 8994;
use constant CISCO_INDEX_OID => '1.3.6.1.2.1.2.2.1.2';
use constant CISCO_INTERFACE => 'serial2/1';
use constant CISCO_INTERFACE_1 => 'serial1/3';

sub set_up {
    my $self = shift;
    $self->{'factory'} = NOCpulse::Probe::DataSource::Factory->new;
}

sub test_snmp_oid {
    my $self = shift;
    my $snmp = $self->{'factory'}->snmp(ip => 'spinner.nocpulse.net',
                                        port => DYNAMO_SNMP_PORT,
                                        community => 'public');
    $snmp->connect;
    $self->assert($snmp->connected, 'SNMP not connected');
    
    my $value = $snmp->fetch_oid_value(DYNAMO_JDBC_OID);
    
    $self->assert(defined($value), 'OID request failed: ', $snmp->errors);
    $self->assert(qr/$value/, $snmp->results);
    $self->assert(length($value) > 0, 'OID request produced no results');
    $self->assert(length($snmp->errors) == 0, 'OID request produced errors');
    
    $snmp->disconnect;
}

sub test_snmp_bad_oid {
    my $self = shift;
    my $snmp = $self->{'factory'}->snmp(ip => 'spinner.nocpulse.net',
                                        port => DYNAMO_SNMP_PORT,
                                        community => 'public');
    $snmp->connect;
    $self->assert($snmp->connected, 'SNMP not connected');
    
    my $value = $snmp->fetch_oid_value(DYNAMO_JDBC_OID . '.99');
    $self->assert(! $value, "OID request succeeded: $value");
    $self->assert(qr/$value/, $snmp->results);
    $self->assert(length($value) == 0, 'OID request produced results');
    $self->assert(length($snmp->errors) > 0, 'OID request produced no errors');
    $self->assert(qr/noSuchName/, $snmp->net_snmp->error);
    
    $snmp->disconnect;
}

sub test_snmp_index {
    my $self = shift;
    my $snmp = $self->{'factory'}->snmp(ip => 'gateway.nocpulse.net',
                                        port => 161,
                                        version => 2,
                                        community => 'norad');
    $snmp->connect;
    $self->assert($snmp->connected, 'SNMP not connected');
    
    my $result = $snmp->fetch_index(CISCO_INDEX_OID, CISCO_INTERFACE);
    
    $self->assert(defined($result), 'Index request failed: ', $snmp->errors);
    $self->assert(length($snmp->errors) == 0, 'Index request produced errors');
    
    my $index = $result->{index_suffix};
    my $refetch_value = $snmp->fetch_oid_value(CISCO_INDEX_OID.$index);
    $self->assert(qr/$refetch_value/, $result->{value});
    $self->assert($refetch_value, 'OID request for index failed: ', $snmp->errors);
    $self->assert(length($refetch_value) > 0, 'Index request produced no results');
    $self->assert(length($snmp->errors) == 0, 'Index request produced errors');
    $self->assert(lc($refetch_value) eq CISCO_INTERFACE, 'Wrong interface returned: ',
                  $refetch_value); 
    
    # Try it as a cached index.
    my $hit = $snmp->fetch_cached_index(CISCO_INDEX_OID, $index, CISCO_INTERFACE);
    $self->assert(defined($hit), 'Cached index request failed: ', $snmp->errors);
    $self->assert(qr/($result->{index_suffix})/, $hit->{index_suffix});
    $self->assert(qr/($result->{value})/, $hit->{value});
    
    # Now a cache miss.
    my $missed = $snmp->fetch_cached_index(CISCO_INDEX_OID, $index, CISCO_INTERFACE_1);
    $self->assert(defined($missed), 'Cached index request failed: ', $snmp->errors);
    $self->assert($result->{index_suffix} ne $missed->{index_suffix},
                  'Same index returned after cache miss');
    $self->assert(lc($missed->{value}) eq CISCO_INTERFACE_1,
                  'Wrong value returned on cache miss: ', $missed->{value});
    
    $snmp->disconnect;
}

1;

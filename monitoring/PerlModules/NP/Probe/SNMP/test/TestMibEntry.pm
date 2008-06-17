package NOCpulse::Probe::SNMP::test::TestMibEntry;

use strict;

use Error(':try');
use NOCpulse::Probe::Config::Command;
use NOCpulse::Probe::Config::CommandParameter;
use NOCpulse::Probe::Config::ProbeRecord;
use NOCpulse::Probe::Result;
use NOCpulse::Probe::DataSource::SNMP;
use NOCpulse::Probe::DataSource::Factory;
use NOCpulse::Probe::SNMP::MibEntry;
use NOCpulse::Probe::SNMP::MibEntryList;

use base qw(Test::Unit::TestCase);

use constant DYNAMO_SNMP_PORT => 8994;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub set_up {
    my $self = shift;
    $self->{'factory'} = NOCpulse::Probe::DataSource::Factory->new;
}

sub dummy_up_result_obj {
    my ($self, @metric_ids) = @_;
    my $probe_rec = NOCpulse::Probe::Config::ProbeRecord->new
      ({ recid        => 111,
         command_id  => 1234,
         parameters  => { a_critical_maximum => '345.67', },
       }
      );
    my $command_param = NOCpulse::Probe::Config::CommandParameter->new
      ( command_id  => 1234,
        param_name  => 'a_critical_maximum',
        description => 'i am critical max',
        param_type  => 'threshold',
        threshold_metric_id => $metric_ids[0],
        threshold_type_name => 'crit_max',
      );

    my %metrics = ();

    foreach my $metric_id (@metric_ids) {
        $metrics{$metric_id} = NOCpulse::Probe::Config::CommandMetric->new
          (
           command_class => 'module',
           metric_id     => $metric_id,
           label         => 'Things',
           unit_label    => 'things/sec',
          );
    }
    my $command = NOCpulse::Probe::Config::Command->new
      (command_id => 1234,
       parameters => {a_critical_maximum => $command_param},
       metrics => \%metrics,
      );
    return NOCpulse::Probe::Result->new(probe_record   => $probe_rec,
                                        command_record => $command);
}

sub test_bad_type {
    my $self = shift;
    my @entries = 
      ({ name      => 'drpAvgReqTime',
         oid       => '.1.3.6.1.4.1.2725.1.4.5',
         data_type => 'NOT_RIGHT',
         metric    => 'avgreqtime',
         value_format => '%.3f',
       });
    my $caught;
    try {
        my $list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    } catch NOCpulse::Probe::InternalError with {
        $caught = shift;
    };
    $self->assert($caught, "Bad data type not caught");
}

sub test_one_entry {
    my $self = shift;
    my $snmp = $self->{'factory'}->snmp(ip        => 'spinner.nocpulse.net',
                                        port      => DYNAMO_SNMP_PORT,
                                        community => 'public');
    $snmp->connect();
    $self->assert($snmp->connected, 'SNMP not connected');

    my @entries = 
      ({ name      => 'drpAvgReqTime',
         oid       => '.1.3.6.1.4.1.2725.1.4.5',
         data_type => 'INTEGER',
         metric    => 'avgreqtime',
         value_format => '%.3f',
       });
    my $list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    
    $self->assert($list->entry_named_exists('drpAvgReqTime'),
                  'No drpAvgReqTime entry in mib entry map');

    my $result = $self->dummy_up_result_obj('avgreqtime');

    $list->process($snmp, $result);

    my $value = $list->entry_named('drpAvgReqTime')->fetched_value;

    $self->assert(defined($value), 'OID request failed: ', $snmp->errors);
    $self->assert(qr/$value/, $snmp->results);
    $self->assert(length($value) > 0, 'OID request produced no results');
    $self->assert(length($snmp->errors) == 0, 'OID request produced errors');

    $snmp->disconnect();
}

sub test_index {
    my $self = shift;
    my $snmp = $self->{'factory'}->snmp(ip => 'gateway.nocpulse.net',
                                        port => 161,
                                        version => 2,
                                        community => 'norad');
    $snmp->connect();
    $self->assert($snmp->connected, 'SNMP not connected');

    my @entries = 
      (
       { name     => 'ifDescr',
         oid       => '1.3.6.1.2.1.2.2.1.2',
         label     => 'Name',
         data_type => 'OCTET_STRING',
         is_index  => 1,
       },
       { name      => 'locIfInBitsSec',
         oid       => '1.3.6.1.4.1.9.2.2.1.1.6',
         data_type => 'INTEGER',
         metric    => 'in_bit_rt',
         value_format => '%.3f',
       },
       { name      => 'locIfOutBitsSec',
         oid       => '1.3.6.1.4.1.9.2.2.1.1.8',
         data_type => 'INTEGER',
         metric    => 'out_bit_rt',
         value_format => '%.3f',
       },
       { name      => 'someOtherStuff',
         oid       => '1.3.6.1.4.1.9.2.2.1.1.8',
         data_type => 'INTEGER',
         value_format => '%.3f',
       },
      );
    my $list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $list->entry_named('ifDescr')->match_index_value('serial1/2');

    my $result = $self->dummy_up_result_obj('in_bit_rt', 'out_bit_rt');
    my $memory = {};

    $list->process($snmp, $result, $memory);
    my $seq = 0;

    foreach my $name ('locIfInBitsSec', 'locIfOutBitsSec', 'someOtherStuff') {
        $self->assert(defined($list->entry_named($name)->fetched_value), 'No value for $name');
        $self->assert($list->entry_named($name)->fetched_value > 0, 'Zero value for $name');
        my $metric = $list->entry_named($name)->metric;
        my $item_name = $metric ? $metric : $name;
        my $item_seq = $result->item_named($item_name)->sequence;
        $self->assert($seq == $item_seq, "$name sequence is $item_seq instead of $seq");
        ++$seq;
    }

    # Verify that index caching works
    $self->assert(values %$memory, "No memory entries");
    $self->assert($memory->{$list->MEMORY_PREFIX.'ifDescr'}, "No cached index in memory");
    $self->assert(qr/.\d+/, $memory->{$list->MEMORY_PREFIX.'ifDescr'});

    $snmp->disconnect();
}

sub test_unmatched_index {
    my $self = shift;
    my $snmp = $self->{'factory'}->snmp(ip => 'gateway.nocpulse.net',
                                        port => 161,
                                        version => 2,
                                        community => 'norad');
    $snmp->connect();
    $self->assert($snmp->connected, 'SNMP not connected');

    my @entries = 
      (
       { name      => 'ifDescr',
         oid       => '1.3.6.1.2.1.2.2.1.2',
         data_type => 'OCTET_STRING',
         is_index  => 1,
         match_index_value => 'blatfoop',
       },
      );
    my $list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);

    my $result = $self->dummy_up_result_obj('in_bit_rt');
    my $memory = {};

    $list->process($snmp, $result, $memory);

    $self->assert($result->overall_status eq $result->UNKNOWN, 
                  "Wrong status with bad index match: ", $result->overall_status);
    $snmp->disconnect();
}

sub test_divisor {
    my $self = shift;

    my $snmp = $self->{'factory'}->snmp(ip        => 'spinner.nocpulse.net',
                                        port      => DYNAMO_SNMP_PORT,
                                        community => 'public');
    $snmp->connect();
    $self->assert($snmp->connected, 'SNMP not connected');

    my @entries = 
      ({ name      => 'drpAvgReqTime',
         oid       => '.1.3.6.1.4.1.2725.1.4.5',
         data_type => 'INTEGER',
         metric    => 'avgreqtime',
         value_format => '%.3f',
         divisor   => 100,
       });
    my $list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);

    $self->assert($list->entry_named_exists('drpAvgReqTime'),
                  'No drpAvgReqTime entry in mib entry map');

    my $result = $self->dummy_up_result_obj('avgreqtime');

    $list->process($snmp, $result);

    my $value = $list->entry_named('drpAvgReqTime')->fetched_value;

    $self->assert($value / 100 == $result->item_named('avgreqtime')->value,
                  "Divisor not used: raw $value, item ", 
                  $result->item_named('avgreqtime')->value);

    $snmp->disconnect();
}

sub test_counter {
    my $self = shift;
    my $snmp = $self->{'factory'}->snmp(ip => 'qaap.qa',
                                        port => 161,
                                        version => 1,
                                        community => 'norad');
    $snmp->connect();
    $self->assert($snmp->connected, 'SNMP not connected');
    my @entries = 
      (
       { name      => 'apSvcName',
         oid       => '1.3.6.1.4.1.2467.1.15.2.1.1',
         label     => 'Service name',
         data_type => 'OCTET_STRING',
         is_index  => 1,
         match_index_param => 'ap_host_0'
       },
       { name      => 'apSvcTransitions',
         oid       => '1.3.6.1.4.1.2467.1.15.2.1.21',
         data_type => 'COUNTER32',
         metric    => 'trans_rate',
       },
      );

    my $list = NOCpulse::Probe::SNMP::MibEntryList->new(@entries);
    $list->entry_named('apSvcName')->match_index_value('megasmon-1-smon');

    my $result = $self->dummy_up_result_obj('trans_rate');
    my $memory = {};
    my $item;

    $list->process($snmp, $result, $memory);
    $item = $result->item_named('trans_rate');
    $self->assert(qr/second iteration/, $item->message);

    $result->prior_item_named({$result->item_named});

    $list->process($snmp, $result, $memory);
    $item = $result->item_named('trans_rate');

    $self->assert(defined $item->value, "No value for trans_rate: message is ", $item->message);

    $snmp->disconnect();
}

1;

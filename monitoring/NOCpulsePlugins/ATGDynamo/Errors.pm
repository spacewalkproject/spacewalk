package ATGDynamo::Errors;

use strict;

use POSIX 'ceil';
use NOCpulse::Probe::SNMP::MibEntry;
use NOCpulse::Probe::SNMP::MibEntryList;

my $errors = NOCpulse::Probe::SNMP::MibEntry->new
  ({ name      => 'generic',
     oid       => '1.3.6.1.4.1.2725.1.1.8',
     data_type => 'INTEGER',
     metric    => 'errors',
   }
  );

sub run {
    my %args = @_;
    my $result = $args{result};
    $args{params}->{ip} = delete $args{params}->{ip_0};
    $args{params}->{port} = delete $args{params}->{port_0};
    $args{params}->{version} = 2;

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new();
    $oid_list->add_entries($errors);
    $oid_list->run(%args);

    my $errs = $errors->fetched_value;
    if (defined($errs)) {
	$result->metric_rate('err_rate', $errs, '%.3f');
    }
}

1;

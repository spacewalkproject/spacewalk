package ATGDynamo::RequestTimeAve;

use strict;

use POSIX 'ceil';
use NOCpulse::Log::Logger;
use NOCpulse::Probe::SNMP::MibEntry;
use NOCpulse::Probe::SNMP::MibEntryList;


my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


my $total_reqs = NOCpulse::Probe::SNMP::MibEntry->new
  ({ name      => 'generic',
     oid       => '1.3.6.1.4.1.2725.1.4.3',
     data_type => 'INTEGER',
   });
my $total_req_time = NOCpulse::Probe::SNMP::MibEntry->new
  ({ name      => 'generic',
     oid       => '1.3.6.1.4.1.2725.1.4.4',
     data_type => 'INTEGER',
   });
my $ave_req_time = NOCpulse::Probe::SNMP::MibEntry->new
  ({ name      => 'generic',
     oid       => '1.3.6.1.4.1.2725.1.4.5',
     data_type => 'INTEGER',
   });

sub run {
    my %args = @_;
    my $result = $args{result};
    $args{params}->{ip} = delete $args{params}->{ip_0};
    $args{params}->{port} = delete $args{params}->{port_0};
    $args{params}->{version} = 2;

    my $oid_list = NOCpulse::Probe::SNMP::MibEntryList->new();
    $oid_list->add_entries($total_reqs, $total_req_time, $ave_req_time);
    $oid_list->run(%args);

    my $mem = $args{memory};

    if (exists($mem->{req_time})) {
	my $reqs = $total_reqs->fetched_value - $mem->{reqs};
	my $time = $total_req_time->fetched_value - $mem->{req_time};
	$Log ->log(2, "requests ",           $total_reqs->fetched_value,
		   ": time ",                $total_req_time->fetched_value,
		   ": requests - mem_reqs ", $reqs,
		   ": time - mem_time ",     $time, "\n");
	if ($time == 0) {
	    $result->metric_message('interval_reqtimeave', "not calculated (no requests since last checked)");
	} else {
	    my $avgtime = ($time/$reqs);
	    my $item = $result->metric_value('interval_reqtimeave', $avgtime, '%d');
	    $item->need_second_iteration(0);
	    $item->format_detailed_message;
	}
    } else {
	my $item = $result->metric_value('interval_reqtimeave', undef);
	$item->need_second_iteration(1);
	$item->format_detailed_message;
    }

    $mem->{reqs} = $total_reqs->fetched_value;
    $mem->{req_time} = $total_req_time->fetched_value;

    my $avg_item = $result->metric_value('avgreqtime', $ave_req_time->fetched_value, '%d');
    $result->remove_item("generic");
}

1;

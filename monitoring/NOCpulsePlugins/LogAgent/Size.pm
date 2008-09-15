package LogAgent::Size;

use strict;

use NOCpulse::Log::Logger;
use ProbeMessageCatalog;
use Data::Dumper;

sub run {
    my %args = @_;

    my %params = %{$args{params}};
    my $result  = $args{result};
    my $mem = $args{memory};
    my $msgcat  = ProbeMessageCatalog->instance();
    my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

    my $probe_id = $args{data_source_factory}{'probe_record'}{'recid'};
    my $log = $params{log};

    my $command = $args{data_source_factory}->unix_command(%params);
    my $log_size = $command->logagent($log);

    if (($log_size->error_msg =~ /No such file or directory/) || ($log_size->error_msg =~ /does not exist/))  {
	#could not find log file, so send error message and clear out all memory items
	$result->item_unknown("Log File: $log", "not found");
	$mem->{log_inode} = 0;
	$Log->log_method(2, "clearing Memory:log_inode = ", $mem->{log_inode}, " \n" );
	$mem->{prev_end_line} = 0;
	$mem->{prev_size} = 0;
    } elsif ($log_size->error_msg) {
	#found some other error and need to error out on it
	$result->item_unknown("Found error:", $log_size->error_msg);
	$mem->{log_inode} = 0;
	$Log->log_method(2, "clearing Memory:log_inode = ", $mem->{log_inode}, " \n" );
	$mem->{prev_end_line} = 0;
	$mem->{prev_size} = 0;
    } else {
	my ($linerate, $byterate);
	if ($mem->{log_inode}) {
	    #if log_inode is already set, then let's make sure the log has not been rotated or moved somehow
	    if (($mem->{log_inode} == $log_size->inode)  && ($mem->{prev_end_line} <= $log_size->total_lines))   {
		# this is not a first run and inode matches, so
		# find number of new lines, number of bytes added, and the rate of each
		my $new_lines = $log_size->total_lines - $mem->{prev_end_line};
		$result->metric_value('lines', $new_lines, '%d');
		my $new_bytes = $log_size->total_bytes - $mem->{prev_size};
		$result->metric_value('bytes', $new_bytes, '%d');
		$result->metric_rate('linerate', $log_size->total_lines, '%.3f', '60');
		$result->metric_rate('byterate', $log_size->total_bytes, '%.3f', '60');
		$mem->{prev_end_line} = $log_size->total_lines;
		$Log->log_method(2, "Set Memory:prev_end_line = ", $mem->{prev_end_line}, " \n" );
		$mem->{prev_size} = $log_size->total_bytes;
		$Log->log_method(2, "Set Memory:prev_size = ", $mem->{prev_size}, " \n" );
	    } else {
		#log has been rotated
		#handle error here and make sure to get all new info	
		my $lines = $log_size->total_lines; 
		$result->metric_value('lines', $lines, '%d');
		my $bytes = $log_size->total_bytes; 
		$result->metric_value('bytes', $bytes, '%d');
		$linerate = $lines;
		$byterate = $bytes;
		$result->metric_rate('linerate', $linerate, '%.3f', '60');
		$result->metric_rate('byterate', $byterate, '%.3f', '60');
		$mem->{log_inode} = $log_size->inode;
		$Log->log_method(2, "Set rotated Memory:log_inode = ", $mem->{log_inode}, " \n" );
		$mem->{prev_size} = $bytes;
		$mem->{prev_end_line} = $lines;
		$Log->log_method(2, "Set rotated Memory:prev_end_line = ", $mem->{prev_end_line}, " \n" );
		$mem->{prev_size} = $bytes;
		$Log->log_method(2, "Set rotated Memory:prev_size = ", $mem->{prev_size}, " \n" );
	    }
	} else {
	    # if log_inode in not found in the probe memory, then this is a first time probe run
	    $mem->{log_inode} = $log_size->inode;
	    $Log->log_method(2, "Set first Memory:log_inode = ", $mem->{log_inode}, " \n" );
	    my $lines = $log_size->total_lines;
	    #use item_ok on first probe run, since the lines and bytes metrics could cross thresholds
	    $result->item_ok('Lines', $lines);
	    my $bytes = $log_size->total_bytes;
	    $result->item_ok('Size', $bytes);
	    $result->metric_rate('linerate', $lines, '%.3f', '60');
	    $result->metric_rate('byterate', $bytes, '%.3f', '60');
	    $mem->{prev_end_line} = $lines;
	    $Log->log_method(2, "Set first Memory:prev_end_line = ", $mem->{prev_end_line}, " \n" );
	    $mem->{prev_size} = $bytes;
	    $Log->log_method(2, "Set first Memory:prev_size = ", $mem->{prev_size}, " \n" );
	}
    }
}

1;

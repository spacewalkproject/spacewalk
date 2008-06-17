package LogAgent::PatternMatch;

use strict;

use ProbeMessageCatalog;
use NOCpulse::Log::Logger;
use Data::Dumper;

sub run {
    my %args = @_;

    my %params = %{$args{params}};
    my $result  = $args{result};
    my $mem = $args{memory};
    my $msgcat  = ProbeMessageCatalog->instance();
    my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

    my $log = $params{log};
    my $regex = $params{regex};

    my $command = $args{data_source_factory}->unix_command(%params);
    my $pattern_match = $command->logagent($log, $regex);


    if (($pattern_match->error_msg =~ /No such file or directory/) || ($pattern_match->error_msg =~ /does not exist/)) {
	#could not find log file, so send error message and clear out all memory items
	$result->item_unknown("Log File: $log", "not found");
	$mem->{inode} = 0;
	$mem->{previous_total_matches} = 0;
    } elsif ($pattern_match->error_msg) {
	#found some other error and need to error out on it
	$result->item_unknown("Found error:", $pattern_match->error_msg);
	$mem->{inode} = 0;
        $mem->{previous_total_matches} = 0;
    } else {
	my ($new_matches);
	if ($mem->{inode}) {
	    if (($mem->{inode} == $pattern_match->inode) && ($mem->{previous_total_matches} <= $pattern_match->total_matches_found)) {
		#this is not a first run, as we found more matches this run then we did on the last and inodes match, meaning no rotation
		$new_matches = $pattern_match->total_matches_found - $mem->{previous_total_matches};
		$result->metric_value('regmatches', $new_matches, '%d');
		$result->metric_rate('regrate', $pattern_match->total_matches_found, '%.3f', 60);
		$mem->{previous_total_matches} = $pattern_match->total_matches_found;
		$Log->log_method(3, "Set Memory:matches = ", $mem->{previous_total_matches}, " \n" );
	    } else {
		#not a first run, but inodes don't match or less matches were found then before, so handle as probable rotation
		$mem->{inode} = $pattern_match->inode;	
		$Log->log_method(3, "Set rotated Memory:inode = ", $mem->{inode}, " \n" );
		$mem->{previous_total_matches} = $pattern_match->total_matches_found;
		$Log->log_method(3, "Set rotated Memory:matches = ", $mem->{previous_total_matches}, " \n" );
		$new_matches = $pattern_match->total_matches_found;
		$result->metric_value('regmatches', $new_matches, '%d');
		$result->metric_rate('regrate', $new_matches, '%.3f', 60);
	    }	
	} else {
	    # this is a first run so memory inode and matches needs to be set
	    $mem->{inode} = $pattern_match->inode;
	    $Log->log_method(3, "Set first run Memory:inode = ", $mem->{inode}, " \n" );
	    $mem->{previous_total_matches} = $pattern_match->total_matches_found;
	    $Log->log_method(3, "Set first run Memory:matches = ", $mem->{previous_total_matches}, " \n" );
	    #new matches is simply the total matches found since this is a first run
	    $new_matches = $pattern_match->total_matches_found;
	    #since this is first run, regmatches should not be thresholded, but should simply be displayed using item_ok
	    $result->item_ok('First run: Pattern matches', $new_matches);
	    $result->metric_rate('regrate', $new_matches, '%.3f', 60);
	}
    }	
}

1;

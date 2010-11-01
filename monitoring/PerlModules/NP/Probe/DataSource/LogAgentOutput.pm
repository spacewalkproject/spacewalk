package NOCpulse::Probe::DataSource::LogAgentOutput;

use strict;

use NOCpulse::Log::Logger;

use Class::MethodMaker
  get_set =>
  [qw(
      inode
      total_bytes
      total_lines
      total_matches_found
      error_msg
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub init {
    my ($self, $unix_command, $log_file, $regex) = @_;

    #need to verify that the $log_file actually exists on the monitored host and is readable by nocpulse
    #and get the inode of the file too
    my $ls = 'ls -i';
    $Log->log_method(2, "Checking to make sure log file ", $log_file, " exists \n" );
    $unix_command->execute("$ls $log_file");
    if ($unix_command->errors) {
	$self->error_msg($unix_command->errors);
	$Log->log_method(2, "Could not find file. Error message: ", $self->error_msg, "\n");
    } else {
	if ($unix_command->results =~ /\s*(\d+)\s+$log_file/) {
	    $self->inode($1);
	    if ($self->inode) {
		$Log->log_method(2, "Inode of the log file is: ", $self->inode, "\n");
		# get the total line count and byte count of the log file
		my $wc = 'wc -cl';
		$Log->log_method(2, "Getting total line count and total byte count of log file ", $log_file, " \n" );
		$unix_command->execute("$wc $log_file");
		if ($unix_command->errors) {
		    $self->error_msg($unix_command->errors);
		    $Log->log_method(2, "Found error: ", $self->error_msg, "\n");
		    return;
		} elsif ($unix_command->results =~ /^\s+(\d+)\s+(\d+)\s$log_file/) {
		    $self->total_lines($1);
		    $self->total_bytes($2);
		    $Log->log_method(2, "Found ", $self->total_lines, " total lines and ",
				     $self->total_bytes, " total bytes for $log_file \n" );
		}
	    } else {
		$self->error_msg("inode does not exist");
		return;
	    }
	} else {
	    $self->error_msg("inode cannot be determined");
	    return;
	}
	if ((!$self->error_msg) && ($regex)) {
	    #regex param is set, so find total number of occurences in the log
	    my $grep = 'grep -E -c';
	    $Log->log_method(2, "Grepping log for ", $regex, " \n" );
	    $unix_command->execute("$grep \'$regex\' $log_file");
	    if ($unix_command->errors) {
		$self->error_msg($unix_command->errors);
		$Log->log_method(2, "Found error: ", $self->error_msg, "\n");
		return;
	    } else {
		my $matches = $unix_command->results;
		#remove the newline char (\n) from the results
		$matches =~  s/\n//;
		$self->total_matches_found($matches);
		$Log->log_method(2, "Found $matches matches of regex: ", $regex, " \n" );
	    }		
	}
    }	
}




1;

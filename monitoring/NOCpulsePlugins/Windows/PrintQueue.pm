package Windows::PrintQueue;

use strict;

use NOCpulse::Probe::DataSource::WindowsCommand;

sub run {
    my %args = @_;

    my $result = $args{result};
    my $memory = $args{memory};
    my %params = %{$args{params}};

    my $command = $args{data_source_factory}->windows_command(%params);

    $command->require_version('3.0');

    my $printer = $params{printer_name};

    $result->context("Printer $printer");

    my $jobs = $command->perf_data('Print Queue', 'Jobs', $printer);
    my $job_errs = $command->perf_data('Print Queue', 'Job Errors', $printer);
    my $not_rdy_errs = $command->perf_data('Print Queue', 'Not Ready Errors', $printer);
    my $out_of_paper_errs = $command->perf_data('Print Queue', 'Out of Paper Errors', $printer);

    if ($jobs) {
	$result->metric_value('jobs', $jobs, '%d');
	$result->metric_rate('job_rate', $jobs. '%.2f');
    } else {
	$result->user_data_not_found('Printer', $printer);
	$result->context(undef);
	last;
    }

    my ($new_job_errs);
    if ($job_errs) {
	if ($memory->{job_errs}) {
	    if ($job_errs >= $memory->{job_errs}) {
		$new_job_errs = $job_errs - $memory->{job_errs};
		$memory->{job_errs} = $job_errs;
		$result->metric_value('job_errs', $new_job_errs, '%d');
	    } else {
		#if the memory exists, but the number found is less then what we rememeber, then the count has been reset
		$result->item_ok('Job Errors', $job_errs);
		$memory->{job_errs} = $job_errs;
	    }
	} else {
	    #if we find that memory doesn't exist for job_errs, then set it
	    # i.e. First Run
	    $result->item_ok('Job Errors', $job_errs);
	    $memory->{job_errs} = $job_errs;
	}
    } else {	
	$result->user_data_not_found('Printer', $printer);
	$result->context(undef);
	last;
    }

    my ($new_not_rdy_errs);
    if ($not_rdy_errs) {
	if ($memory->{not_rdy_errs}) {
	    if ($not_rdy_errs >= $memory->{not_rdy_errs}) {
		$new_not_rdy_errs = $not_rdy_errs - $memory->{not_rdy_errs};
		$memory->{not_rdy_errs} = $not_rdy_errs;
		$result->metric_value('not_rdy_errs', $new_not_rdy_errs, '%d');
	    } else {
		#if the memory exists, but the number found is less then what we rememeber, then the count has been reset
		$result->item_ok('Not Ready Errors', $not_rdy_errs);
		$memory->{not_rdy_errs} = $not_rdy_errs;
	    }
	} else {
	    #if we find that memory doesn't exist, then set it
	    # i.e. First Run
	    $result->item_ok('Not Ready Errors', $not_rdy_errs);
	    $memory->{not_rdy_errs} = $not_rdy_errs;
	}
    } else {	
	$result->user_data_not_found('Printer', $printer);
	$result->context(undef);
	last;
    }

    my ($new_out_of_paper_errs);
    if ($out_of_paper_errs) {
	if ($memory->{out_of_paper_errs}) {
	    if ($out_of_paper_errs >= $memory->{out_of_paper_errs}) {
		$new_out_of_paper_errs = $out_of_paper_errs - $memory->{out_of_paper_errs};
		$memory->{out_of_paper_errs} = $out_of_paper_errs;
		$result->metric_value('out_of_paper_errs', $new_out_of_paper_errs, '%d');
	    } else {
		#if the memory exists, but the number found is less then what we rememeber, then the count has been reset
		$result->item_ok('Out Of Paper Errors', $out_of_paper_errs);
		$memory->{out_of_paper_errs} = $out_of_paper_errs;
	    }
	} else {
	    #if we find that memory doesn't exists, then set it
	    # i.e. First Run
	    $result->item_ok('Out of Paperp Errors', $out_of_paper_errs);
	    $memory->{out_of_paper_errs} = $out_of_paper_errs;
	}
    } else {	
	$result->user_data_not_found('Printer', $printer);
	$result->context(undef);
	last;
    }

}
1;

package NOCpulse::Utils::TestRunner;

# Override standard text-based TestRunner to print the
# test names as they are run.

use strict;
use Test::Unit::TestRunner;
use FileHandle;
 
use base qw(Test::Unit::TestRunner);
 
sub start_test {
    my ($self, $test) = @_;
    $self->_print("\t", $test->{_name}, ": ");
    local *FH = *{$self->print_stream()};
    FH->flush;
}

sub end_test {
    my ($self, $test) = @_;
    $self->_print("\n");
}
 
sub print_header {
    my $self = shift;
    my ($result) = @_;
    if ($result->was_successful()) {
	$self->_print("\n", "OK", " (", $result->run_count(), " tests)\n");
    } else {
        my $nfail = $result->failure_count();
        my $nerr = $result->error_count();
	$self->_print("\n", "THERE WERE FAILURES", "\n",
		      "Ran ", $result->run_count(), " tests with ", 
                      $nfail, " assertion ", $nfail == 1 ? " failure" : " failures",
		      " and ", 
                      $nerr, $nerr == 1 ? " error" : " errors",
		      "\n");
    }
}

sub print_errors {
    my $self = shift;
    my ($result) = @_;
    if ( $result->error_count() ) {
        my $i = 0; 
        for my $e (@{$result->errors()}) {
            $i++;
            $self->_print($i, ") ", $e->thrown_exception->get_message());
        }
    }
}

sub print_failures {
    my $self = shift;
    my ($result) = @_;
    if ($result->failure_count() != 0) {
	my $i = 0; 
	for my $e (@{$result->failures()}) {
	    $i++;
	    $self->_print($i, ") ", $e->to_string());
	}
    }
}

sub add_error {
    my $self = shift;
    my ($test, $exception) = @_;
    $self->_print("ERROR: ", $exception->get_message());
}
 
sub add_failure {
    my $self = shift;
    my ($test, $exception) = @_;
    $self->_print("ASSERTION FAILURE: ", $exception->get_message());
}
 
1;

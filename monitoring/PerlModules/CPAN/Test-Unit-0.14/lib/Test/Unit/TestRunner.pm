package Test::Unit::TestRunner;
use strict;
use constant DEBUG => 0;

use base qw(Test::Unit::TestListener); 

use Test::Unit::TestSuite;
use Test::Unit::TestResult;

use Benchmark;

sub new {
    my $class = shift;
    my ($filehandle) = @_;
    $filehandle = \*STDOUT unless $filehandle;
    bless { _Print_stream => $filehandle }, $class;
}

sub print_stream {
    my $self = shift;
    return $self->{_Print_stream};
}

sub _print {
    my $self = shift;
    my (@args) = @_;
    local *FH = *{$self->print_stream()};
    print FH @args;
}

sub add_error {
    my $self = shift;
    my ($test, $exception) = @_;
    $self->_print("E");
}
	
sub add_failure {
    my $self = shift;
    my ($test, $exception) = @_;
    $self->_print("F");
}

sub add_pass {
    # in this runner passes are ignored.
}

sub create_test_result {
    my $self = shift;
    return Test::Unit::TestResult->new();
}
	
sub do_run {
    my $self = shift;
    my ($suite, $wait) = @_;
    my $result = $self->create_test_result();
    $result->add_listener($self);
    my $start_time = new Benchmark();
    $suite->run($result);
    my $end_time = new Benchmark();
    my $run_time = timediff($end_time, $start_time);
    $self->_print("\n", "Time: ", timestr($run_time), "\n");
    
    $self->print_result($result);
    
    if ($wait) {
        print "<RETURN> to continue"; # go to STDIN any case
        <STDIN>;
    }
    if (not $result->was_successful()) {
        die "\nTest was not successful.\n";
    }
    return 0;
}

sub end_test {
    my $self = shift;
    my ($test) = @_;
}

sub main {
    my $self = shift;
    my $a_test_runner = Test::Unit::TestRunner->new();
    $a_test_runner->start(@_);
}

sub print_result {
    my $self = shift;
    my ($result) = @_;
    $self->print_header($result);
    $self->print_errors($result);
    $self->print_failures($result);
}

sub print_errors {
    my $self = shift;
    my ($result) = @_;
    if ( $result->error_count() ) {
        if ($result->error_count == 1) {
            $self->_print("There was ",  $result->error_count(), " error:\n" );
        } else {
            $self->_print("There were ", $result->error_count(), " errors:\n");
        }
        my $i = 0; 
        for my $e (@{$result->errors()}) {
            $i++;
            $self->_print($i, ") ", $e->to_string());
        }
    }
}

sub print_failures {
    my $self = shift;
    my ($result) = @_;
    if ($result->failure_count() != 0) {
	if ($result->failure_count == 1) {
	    $self->_print("There was ", $result->failure_count(), " failure:\n");
	} else {
	    $self->_print("There were ", $result->failure_count(), " failures:\n");
	}
	my $i = 0; 
	for my $e (@{$result->failures()}) {
	    $i++;
	    $self->_print($i, ") ", $e->to_string());
	}
    }
}

sub print_header {
    my $self = shift;
    my ($result) = @_;
    if ($result->was_successful()) {
	$self->_print("\n", "OK", " (", $result->run_count(), " tests)");
    } else {
	$self->_print("\n", "!!!FAILURES!!!", "\n",
		      "Test Results:\n",
		      "Run: ", $result->run_count(), 
		      " Failures: ", $result->failure_count(),
		      " Errors: ", $result->error_count(),
		      "\n");
    }
}

sub run {
    my $self = shift;
    my ($class) = @_;
    my $a_test_runner = Test::Unit::TestRunner->new();
    if ($class->isa("Test::Unit::Test")) {
	$a_test_runner->do_run($class, 0);
    } else {
	$a_test_runner->do_run(Test::Unit::TestSuite->new($class), 0);
    }
}
	
sub run_and_wait {
    my $self = shift;
    my ($test) = @_;
    my $a_test_runner = Test::Unit::TestRunner->new();
    $a_test_runner->do_run($test, 1);
}

sub start {
    my $self = shift;
    my (@args) = @_;

    my $test_case = "";
    my $wait = 0;

    for (my $i = 0; $i < @args; $i++) {
	if ($args[$i] eq "-wait") {
	    $wait = 1;
	} elsif ($args[$i] eq "-v") {
	    print "Test::Unit Version 0.1 experimental, copyright Christian Lemburg, Brian Ewins, J.E. Fritz, Cayte Lindner, Zhon Johansen, 2000\n";
	} else {
	    $test_case = $args[$i];
	}
    }
    if ($test_case eq "") {
	die "Usage TestRunner.pl [-wait] name, where name is the name of the TestCase class", "\n";
    }

    eval "require $test_case" 
	or die "Suite class " . $test_case . " not found: $@";
    no strict 'refs';
    my $suite;
    my $suite_method = $test_case->can("suite") ? 
	    \&{"$test_case" . "::" . "suite"} : undef; 
    if (not $suite_method) {
	$suite = Test::Unit::TestSuite->new($test_case);
    }
    if (not $suite) {
	eval {
	    $suite = $suite_method->();
	};
	die "Could not invoke the suite() method: $@" if $@;
    }
    $self->do_run($suite, $wait);
}

sub start_test {
    my $self = shift;
    my ($test) = @_;
    $self->_print(".");
}

1;
__END__


=head1 NAME

Test::Unit::TestRunner - unit testing framework helper class

=head1 SYNOPSIS

    use Test::Unit::TestRunner;

    my $testrunner = Test::Unit::TestRunner->new();
    $testrunner->start($my_testcase_class);

=head1 DESCRIPTION

This class is the test runner for the command line style use
of the testing framework.

It is used by simple command line tools like the F<TestRunner.pl>
script provided.

The class needs one argument, which is the name of the class
encapsulating the tests to be run.

=head1 OPTIONS

=over 4

=item -wait

wait for user confirmation between tests

=item -v

version info

=back


=head1 AUTHOR

Framework JUnit authored by Kent Beck and Erich Gamma.

Ported from Java to Perl by Christian Lemburg.

Copyright (c) 2000 Christian Lemburg, E<lt>lemburg@acm.orgE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::TestCase>

=item *

L<Test::Unit::TestListener>

=item *

L<Test::Unit::TestSuite>

=item *

L<Test::Unit::TestResult>

=item *

L<Test::Unit::TkTestRunner>

=item *

For further examples, take a look at the framework self test
collection (Test::Unit::tests::AllTests).

=back

=cut

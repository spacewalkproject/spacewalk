package ExceptionChecker;

use strict;
use warnings;

use Test::Unit::Error;
use Test::Unit::Failure;

use Error qw(:try);

sub check_failures {
    my $self = shift;
    $self->check_exceptions('Test::Unit::Failure', @_);
}

sub check_errors {
    my $self = shift;
    $self->check_exceptions('Test::Unit::Error', @_);
}

sub check_exceptions {
    my $self = shift;
    my ($exception_class, @tests) = @_;
    my ($asserter, $file, $line)
      = caller($Error::Depth + 1); # EVIL hack!  Assumes check_exceptions
                                   # always called via check_{failures,errors}.
                                   # My brain hurts too much right now to think
                                   # of a better way.
    while (@tests) {
        my $expected        = shift @tests;
        my $test_components = shift @tests;
        my ($test_code_line, $test) = @$test_components;
	my $exception;
	try {
	    $self->$test();
	}
	catch $exception_class with {
	    $exception = shift;
	}
	catch Error::Simple with {
	    $exception = shift;
	}
	otherwise {
	    $exception = 0;
	};

        try {
            $self->check_exception($exception_class, $expected, $exception);
            $self->check_file_and_line($exception,
                                       $file,
                                       $test_code_line);
        }
        catch Test::Unit::Failure with {
            my $failure = shift;
            $failure->throw_new(
                -package => $asserter,
                -file    => $file,
                -line    => $line,
                -object  => $self
            );
        }
    }
}

sub check_exception {
    my $self = shift;
    my ($exception_class, $expected, $exception) = @_;
    Test::Unit::Failure->throw(
        -text => "Didn't get $exception_class `$expected'",
        -object => $self,
    ) unless $exception;

    my $got = $exception->text();
    Test::Unit::Failure->throw(
        -text => "Expected $exception_class `$expected', got `$got'",
        -object => $self,
    ) unless UNIVERSAL::isa($expected, 'Regexp')
               ? $got =~ /$expected/ : $got eq $expected;
}

sub check_file_and_line {
    my $self = shift;
    my ($exception, $expected_file, $test_code_line) = @_;
    if ($exception->file() ne $expected_file) {
        throw Test::Unit::Failure(
            -text   => "failure's file() should have returned $expected_file"
                       . " (line $test_code_line), not " . $exception->file(),
            -object => $self,
        );
    }
    if ($exception->line() != $test_code_line) {
        throw Test::Unit::Failure(
            -text   => "failure's line() should have returned "
                       . "$test_code_line, not " . $exception->line(),
            -object => $self,
        );
    }
}

1;

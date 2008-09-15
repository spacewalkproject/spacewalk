package Test::Unit::Result;
use strict;

use Test::Unit::Debug qw(debug);
use Test::Unit::Error;
use Test::Unit::Failure;

use Error qw/:try/;

sub new {
    my $class = shift;
    bless {
           _Failures  => [],
           _Errors    => [],
           _Listeners => [],
           _Run_tests => 0,
           _Stop      => 0,
    }, $class;
}

sub tell_listeners {
    my $self = shift;
    my $method = shift;
    foreach (@{$self->listeners}) {
        $_->$method(@_);
    }
}

sub add_error { 
    my $self = shift;
    debug($self . "::add_error() called\n");
    my ($test, $exception) = @_;
    $exception->{-object} = $test;
    push @{$self->errors()}, $exception;
    $self->tell_listeners(add_error => @_);
}

sub add_failure {
    my $self = shift;
    debug($self . "::add_failure() called\n");
    my ($test, $exception) = @_;
    $exception->{-object} = $test;
    push @{$self->failures()}, $exception;
    $self->tell_listeners(add_failure => @_);
}

sub add_pass {
    my $self = shift;
    debug($self . "::add_pass() called\n");
    my ($test) = @_;
    $self->tell_listeners(add_pass => @_);
}

sub add_listener {
    my $self = shift;
    debug($self . "::add_listener() called\n");
    my ($listener) = @_;
    push @{$self->listeners()}, $listener;
}

sub listeners {
    my $self = shift;
    return $self->{_Listeners};
}

sub end_test {
    my $self = shift;
    my ($test) = @_;
    $self->tell_listeners(end_test => $test);
}

sub error_count {
    my $self = shift;
    return scalar @{$self->{_Errors}};
}

sub errors {
    my $self = shift;
    return $self->{_Errors};
}
 
sub failure_count {
    my $self = shift;
    return scalar @{$self->{_Failures}};
}

sub failures {
    my $self = shift;
    return $self->{_Failures};
}

sub run {
    my $self = shift;
    my ($test) = @_;
    debug(sprintf "%s::run(%s) called\n", $self, $test->name());
    $self->start_test($test);

    # This closure may look convoluted, but it allows Test::Unit::Setup
    # to work cleanly.
    $self->run_protected(
        $test,
        sub {
            $test->run_bare() ?
              $self->add_pass($test)
            : $self->add_failure($test);
        }
    );

    $self->end_test($test);
} 

sub run_protected {
    my $self = shift;
    my $test = shift;
    my $protectable = shift;
    debug("$self\::run_protected($test, $protectable) called\n");

    try {
        &$protectable();
    }
    catch Test::Unit::Failure with {
        $self->add_failure($test, shift);
    }
    catch Error with {
        # *Any* exception which isn't a failure or
        # Test::Unit::Exception should get rebuilt and added to the
        # result as a Test::Unit::Error, so that the stringify()
        # method can be called on it for nice reporting.
        my $error = shift;
        $error = Test::Unit::Error->make_new_from_error($error)
          unless $error->isa('Test::Unit::Exception');
        $self->add_error($test, $error);
    };
}

sub run_count {
    my $self = shift;
    return $self->{_Run_tests};
}

sub run_count_inc {
    my $self = shift;
    ++$self->{_Run_tests};
    return $self->{_Run_tests};
}
    
sub should_stop {
    my $self = shift;
    return $self->{_Stop};
}
    
sub start_test {
    my $self = shift;
    my ($test) = @_;
    $self->run_count_inc();
    $self->tell_listeners(start_test => $test);
}

sub stop {
    my $self = shift;
    $self->{_Stop} = 1;
}

sub was_successful {
    my $self = shift;
    return ($self->failure_count() == 0) && ($self->error_count() == 0);
}

sub to_string {
    my $self = shift;
    my $class = ref($self);
    debug($class . "::to_string() called\n");
}

1;
__END__


=head1 NAME

Test::Unit::Result - unit testing framework helper class

=head1 SYNOPSIS

This class is not intended to be used directly 

=head1 DESCRIPTION

This class is used by the framework to record the results of tests,
which will throw an instance of a subclass of Test::Unit::Exception in
case of errors or failures.

To achieve this, this class gets called with a test case as argument.
It will call this test case's run method back and catch any exceptions
thrown.

It could be argued that Test::Unit::Result is the heart of the
PerlUnit framework, since TestCase classes vary, and you can use one
of several Test::Unit::TestRunners, but we always gather the results
in a Test::Unit::Result object.

This is the quintessential call tree of the communication needed to
record the results of a given test:

    $aTestCase->run() {
	# creates result
	$aTestResult->run($aTestCase) { 
	    # catches exception and records it
	    $aTestCase->run_bare() {
		# runs test method inside eval
		$aTestCase->run_test() {
		    # calls method $aTestCase->name() 
		    # and propagates exception
		    # method will call Assert::assert() 
		    # to cause failure if test fails on 
		    # test assertion
		    # it finds this because $aTestCase is-a Assert
		}
	    }
	}
    }

Note too that, in the presence of Test::Unit::TestSuites, this call
tree can get a little more convoluted, but if you bear the above in
mind it should be apparent what's going on.

=head1 AUTHOR

Copyright (c) 2000 Christian Lemburg, E<lt>lemburg@acm.orgE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::Assert>

=item *

L<Test::Unit::TestCase>

=item *

L<Test::Unit::Exception>

=back

=cut

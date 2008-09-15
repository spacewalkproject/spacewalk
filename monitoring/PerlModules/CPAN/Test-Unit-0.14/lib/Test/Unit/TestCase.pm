package Test::Unit::TestCase;
use strict;
use constant DEBUG => 0;

use base qw(Test::Unit::Test);

use Test::Unit::ExceptionFailure; 
use Test::Unit::ExceptionError; 
use Test::Unit::TestResult;

use vars '@ISA';

sub new {
    my $class = shift;
    my ($name) = @_;
    bless { _name => $name }, $class;
}

sub count_test_cases {
    my $self = shift;
    return 1;
}

sub create_result {
    my $self = shift;
    return Test::Unit::TestResult->new();
}

sub name {
    my $self = shift;
    return $self->{_name};
}

sub run {
    my $self = shift;
    print ref($self) . "::run() called\n" if DEBUG;
    my ($result) = @_;
    $result = create_result() unless defined($result);
    $result->run($self);
    return $result;
}

sub run_bare {
    my $self = shift;
    print ref($self) . "::run_bare() called\n" if DEBUG;
    $self->set_up();
    eval {
	$self->run_test();
    };
    my $exception = $@;
    $self->tear_down();
    if ($exception) {
	print ref($self) . "::run_bare() propagating exception\n" if DEBUG;
	if (!ref($exception) ||
	    ! eval {$exception->isa("Test::Unit::ExceptionFailure")} ) {
	    $exception = Test::Unit::ExceptionError->new($exception);
	}
	die $exception; # propagate exception
    }
}

sub run_test {
    my $self = shift; 
    print ref($self) . "::run_test() called\n" if DEBUG;
    my $method = $self->name();
    if ($self->can($method)) {
        $self->$method();
    } else {
        $self->fail("Method $method not found");
    }
}

sub set_up {
}

sub tear_down {
}

sub to_string {
    my $self = shift;
    my $class = ref($self);
    return $self->name() . "(" . $class . ")";
}

# Returns a list of the tests run by this class and its superclasses.
# DO NOT OVERRIDE THIS UNLESS YOU KNOW WHAT YOU ARE DOING!
sub list_tests {
    my $class = ref($_[0]) || $_[0];
    my @tests;
    no strict 'refs';
    if (defined(@{"$class\::TESTS"})) {
        push @tests, @{"$class\::TESTS"};
    }
    else {
        push @tests, grep { /^test/ && $class->can($_) }
            keys %{"$class\::"};
    }
    push @tests, map {$_->can('list_tests') ? $_->list_tests : ()}
        @{"$class\::ISA"};
    my %tests = map {$_ => ''} @tests if @tests;
    return keys %tests;
}

1;
__END__



=head1 NAME

Test::Unit::TestCase - unit testing framework base class

=head1 SYNOPSIS

    package FooBar;
    use base qw(Test::Unit::TestCase);

    sub new {
        my $self = shift()->SUPER::new(@_);
        # your state for fixture here
        return $self;
    }

    sub set_up {
        # provide fixture
    }
    sub tear_down {
        # clean up after test
    }
    sub test_foo {
        # test the foo feature
    }
    sub test_bar {
        # test the bar feature
    }

=head1 DESCRIPTION

(Taken from the JUnit TestCase class documentation)

A test case defines the "fixture" (resources need for testing) to run
multiple tests. To define a test case:

=over 4

=item 1

implement a subclass of TestCase

=item 2

define instance variables that store the state of the fixture

=item 3

initialize the fixture state by overriding C<set_up()>

=item 4

clean-up after a test by overriding C<tear_down()>.

=back

Each test runs in its own fixture so there can be no side
effects among test runs. Here is an example:

      package MathTest;
      use base qw(Test::Unit::TestCase);

      sub new {
	  my $self = shift()->SUPER::new(@_);
	  $self->{value_1} = 0;
	  $self->{value_2} = 0;
	  return $self;
      }

      sub set_up {
	  my $self = shift;
	  $self->{value_1} = 2;
	  $self->{value_2} = 3;
      }

For each test implement a method which interacts with the fixture.
Verify the expected results with assertions specified by calling
C<$self-E<gt>assert()> with a boolean value.

      sub test_add {
	  my $self = shift;
	  my $result = $self->{value_1} + $self->{value_2};
	  $self->assert($result == 5);
      }

Once the methods are defined you can run them. The normal way to do
this uses reflection to implement C<run_test>. It dynamically finds
and invokes a method. For this the name of the test case has to
correspond to the test method to be run. The tests to be run can be
collected into a TestSuite. The framework provides different test
runners, which can run a test suite and collect the results. A test
runner either expects a method C<suite()> as the entry point to get a
test to run or it will extract the suite automatically.

If you do not like the rather verbose backtrace that appears when a
test fails, you can use the C<quell_backtrace()> method. You will get
any message provided, but not the backtrace.

=head1 AUTHOR

Framework JUnit authored by Kent Beck and Erich Gamma.

Ported from Java to Perl by Christian Lemburg.

Copyright (c) 2000 Christian Lemburg, E<lt>lemburg@acm.orgE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

Thanks for patches go to:
Matthew Astley.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::TestSuite>

=item *

L<Test::Unit::TestRunner>

=item *

L<Test::Unit::TkTestRunner>

=item *

For further examples, take a look at the framework self test
collection (Test::Unit::tests::AllTests).

=back

=cut

package Test::Unit::TestSuite;
use strict;

=head1 NAME

Test::Unit::TestSuite - unit testing framework base class

=cut

use base 'Test::Unit::Test';

use Carp;

use Test::Unit::Debug qw(debug);
use Test::Unit::TestCase;
use Test::Unit::Loader;
use Test::Unit::Warning;

=head1 SYNOPSIS

    package MySuite;

    use base qw(Test::Unit::TestSuite);

    sub name { 'My very own test suite' } 
    sub include_tests { qw(MySuite1 MySuite2 MyTestCase1 ...) }

This is the easiest way of building suites; there are many more.  Read on ...

=head1 DESCRIPTION

This class provides the functionality for building test suites in
several different ways.

Any module can be a test suite runnable by the framework if it
provides a C<suite()> method which returns a C<Test::Unit::TestSuite>
object, e.g.

    use Test::Unit::TestSuite;

    # more code here ...

    sub suite {
	my $class = shift;

	# Create an empty suite.
	my $suite = Test::Unit::TestSuite->empty_new("A Test Suite");
	# Add some tests to it via $suite->add_test() here

	return $suite;
    }

This is useful if you want your test suite to be contained in the module
it tests, for example.

Alternatively, you can have "standalone" test suites, which inherit directly
from C<Test::Unit::TestSuite>, e.g.:

    package MySuite;

    use base qw(Test::Unit::TestSuite);

    sub new {
        my $class = shift;
        my $self = $class->SUPER::empty_new();
        # Build your suite here
        return $self;
    }

    sub name { 'My very own test suite' }

or if your C<new()> is going to do nothing more interesting than add
tests from other suites and testcases via C<add_test()>, you can use the
C<include_tests()> method as shorthand:

    package MySuite;

    use base qw(Test::Unit::TestSuite);

    sub name { 'My very own test suite' } 
    sub include_tests { qw(MySuite1 MySuite2 MyTestCase1 ...) }

This is the easiest way of building suites.

=head1 CONSTRUCTORS

=head2 empty_new ([NAME])

    my $suite = Test::Unit::TestSuite->empty_new('my suite name');

Creates a fresh suite with no tests.

=cut

sub empty_new {
    my $this = shift;
    my $classname = ref $this || $this;
    my $name = shift || '';
    
    my $self = {
        _Tests => [],
        _Name => $name,
    };
    bless $self, $classname;
    
    debug(ref($self), "::empty_new($name) called\n");
    return $self;
}

=head2 new ([ CLASSNAME | TEST ])

If a test suite is provided as the argument, it merely returns that
suite.  If a test case is provided, it extracts all test case methods
from the test case (see L<Test::Unit::TestCase/list_tests>) into a new
test suite.

If the class this method is being run in has an C<include_tests> method
which returns an array of class names, it will also automatically add
the tests from those classes into the newly constructed suite object.

=cut

sub new {
    my $class = shift;
    my $classname = shift || ''; # Avoid a warning
    debug("$class\::new($classname) called\n");

    my $self = $class->empty_new();

    if ($classname) {
        Test::Unit::Loader::compile_class($classname);
        if (eval { $classname->isa('Test::Unit::TestCase') }) {
            $self->{_Name} = "suite extracted from $classname";
            my @testcases = Test::Unit::Loader::extract_testcases($classname);
            foreach my $testcase (@testcases) {
                $self->add_test($testcase);
            }
        }
        elsif (eval { $classname->can('suite') }) {
            return $classname->suite();
        }
        else {
            my $error = "Class $classname was not a test case or test suite.\n";
            #$self->add_warning($error);
            die $error;
        }
    }

    if ($self->can('include_tests')) {
        foreach my $test ($self->include_tests()) {
            $self->add_test($test);
        }
    }

    return $self;
}

=head1 METHODS

=cut

sub suite {
    my $class = shift;
    croak "suite() is not an instance method" if ref $class;
    $class->new(@_);
}

=head2 name()

Returns the suite's human-readable name.

=cut

sub name {
    my $self = shift;
    croak "Override name() in subclass to set name\n" if @_;
    return $self->{_Name};
}

=head2 names()

Returns an arrayref of the names of all tests in the suite.

=cut

sub names {
    my $self = shift;
    my @test_list = @{$self->tests};
    return [ map {$_->name} @test_list ] if @test_list;
}

=head2 list (SHOW_TESTCASES)

Produces a human-readable indented lists of the suite and the subsuites
it contains.  If the first parameter is true, also lists any testcases
contained in the suite and its subsuites.

=cut

sub list {
    my $self = shift;
    my $show_testcases = shift;
    my $first = ($self->name() || 'anonymous Test::Unit::TestSuite');
    $first .= " - " . ref($self) unless ref($self) eq __PACKAGE__;
    $first .= "\n";
    my @lines = ( $first );
    foreach my $test (@{ $self->tests() }) {
        push @lines, map "   $_", @{ $test->list($show_testcases) };
    }
    return \@lines;
}

=head2 add_test (TEST_CLASSNAME | TEST_OBJECT)

You can add a test object to a suite with this method, by passing
either its classname, or the object itself as the argument.

Of course, there are many ways of getting the object too ...

    # Get and add an existing suite.
    $suite->add_test('MySuite1');

    # This is exactly equivalent:
    $suite->add_test(Test::Unit::TestSuite->new('MySuite1'));

    # So is this, provided MySuite1 inherits from Test::Unit::TestSuite.
    use MySuite1;
    $suite->add_test(MySuite1->new());

    # Extract yet another suite by way of suite() method and add it to
    # $suite.
    use MySuite2;
    $suite->add_test(MySuite2->suite());
    
    # Extract test case methods from MyModule::TestCase into a
    # new suite and add it to $suite.
    $suite->add_test(Test::Unit::TestSuite->new('MyModule::TestCase'));

=cut

sub add_test {
    my $self = shift;
    my ($test) = @_;
    debug('+ ', ref($self), "::add_test($test) called\n");
    $test = Test::Unit::Loader::load_test($test) unless ref $test;
    croak "`$test' could not be interpreted as a Test::Unit::Test object"
        unless eval { $test->isa('Test::Unit::Test') };
    push @{$self->tests}, $test;
}

sub count_test_cases {
    my $self = shift;
    my $count;
    $count += $_->count_test_cases for @{$self->tests};
    return $count;
}

sub run {
    my $self = shift;
    my ($result, $runner) = @_;

    $result ||= create_result();
    $result->tell_listeners(start_suite => $self);

    $self->add_warning("No tests found in " . $self->name())
        unless @{ $self->tests() };

    for my $t (@{$self->tests()}) {
        if ($runner && $self->filter_test($runner, $t)) {
            debug(sprintf "skipping %s\n", $t->name());
            next;
        }
 
        last if $result->should_stop();
        $t->run($result);
    }

    $result->tell_listeners(end_suite => $self);

    return $result;
}
    
sub filter_test {
    my $self = shift;
    my ($runner, $test) = @_;
    my @filter_tokens = $runner->filter();

    foreach my $token (@filter_tokens) {
        return 1 if $test->filter_method($token, $test->name())
                 || $test->filter_method($token, 'ALL');
    }

    return 0;
}

sub test_at {
    my $self = shift;
    my ($index) = @_;
    return $self->tests()->[$index];
}

sub test_count {
    my $self = shift;
    return scalar @{$self->tests()};
}

sub tests {
    my $self = shift;
    return $self->{_Tests};
}

sub to_string {
    my $self = shift;
    return $self->name();
}

sub add_warning {
    my $self = shift;
    $self->add_test(Test::Unit::Warning->new(join '', @_));
}

1;
__END__


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

L<Test::Unit::TestRunner>

=item *

L<Test::Unit::TkTestRunner>

=item *

For further examples, take a look at the framework self test
collection (t::tlib::AllTests).

=back

=cut

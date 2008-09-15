package Test::Unit::TestCase;
use strict;

use base qw(Test::Unit::Test);

use Test::Unit::Debug qw(debug);
use Test::Unit::Failure; 
use Test::Unit::Error; 
use Test::Unit::Result;

use Devel::Symdump;
use Class::Inner;
use Error qw/:try/;

sub new {
    my $class = shift;
    my ($name) = @_;
    bless {
        __PACKAGE__ . '_name'        => $name,
        __PACKAGE__ . '_annotations' => '',
    }, $class;
}

sub annotate {
    my $self = shift;
    $self->{__PACKAGE__ . '_annotations'} .= join '', @_;
}
  
sub annotations { $_[0]->{__PACKAGE__ . '_annotations'} }

sub count_test_cases {
    my $self = shift;
    return 1;
}

sub create_result {
    my $self = shift;
    return Test::Unit::Result->new();
}

sub name {
    my $self = shift;
    return $self->{__PACKAGE__ . '_name'};
}

sub run {
    my $self = shift;
    debug(ref($self), "::run() called on ", $self->name, "\n");
    my ($result, $runner) = @_;
    $result ||= create_result();
    $result->run($self);
    return $result;
}

sub run_bare {
    my $self = shift;
    debug("  ", ref($self), "::run_bare() called on ", $self->name, "\n");
    $self->set_up();
    # Make sure tear_down happens if and only if set_up() succeeds.
    try {
        $self->run_test();
        1;
    }
    finally {
        $self->tear_down;
    };
}

sub run_test {
    my $self = shift; 
    debug("    ", ref($self) . "::run_test() called on ", $self->name, "\n");
    my $method = $self->name();
    if ($self->can($method)) {
        debug("      running `$method'\n");
        $self->$method();
    } else {
        $self->fail("      Method `$method' not found");
    }
}

sub set_up    { 1 }

sub tear_down { 1 }

sub to_string {
    my $self = shift;
    my $class = ref($self);
    return ($self->name() || "ANON") . "(" . $class . ")";
}

sub make_test_from_coderef {
    my ($self, $coderef, @args) = @_;
    die "Need a coderef argument" unless $coderef;
    return Class::Inner->new(parent  => ($self || ref $self),
                             methods => {run_test => $coderef},
                             args    => [ @args ]);
}


# Returns a list of the tests run by this class and its superclasses.
# DO NOT OVERRIDE THIS UNLESS YOU KNOW WHAT YOU ARE DOING!
sub list_tests {
    my $class = ref($_[0]) || $_[0];
    my @tests = ();
    no strict 'refs';
    if (defined(@{"$class\::TESTS"})) {
        push @tests, @{"$class\::TESTS"};
    }
    else {
        push @tests, $class->get_matching_methods(qr/::(test[^:]*)$/);
    }
    push @tests, map {$_->can('list_tests') ? $_->list_tests : () } @{"$class\::ISA"};
    my %tests = map {$_ => ''} @tests;
    return keys %tests;
}

sub get_matching_methods {
    my $class = ref($_[0]) || $_[0];
    my $re = $_[1];
    my $st = Devel::Symdump->new($class);
    return map { /$re/ ? $1 : () } $st->functions();
}

sub list {
    my $self = shift;
    my $show_testcases = shift;
    return $show_testcases ?
             [ ($self->name() || 'anonymous testcase') . "\n" ]
           : [];
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
        my $self = shift;
        my $obj = ClassUnderTest->new(...);
        $self->assert_not_null($obj);
        $self->assert_equals('expected result', $obj->foo);
        $self->assert(qr/pattern/, $obj->foobar);
    }
    sub test_bar {
        # test the bar feature
    }

=head1 DESCRIPTION

Test::Unit::TestCase is the 'workhorse' of the PerlUnit framework.
When writing tests, you generally subclass Test::Unit::TestCase, write
C<set_up> and C<tear_down> functions if you need them, a bunch of
C<test_*> test methods, then do

    $ TestRunner.pl My::TestCase::Class

and watch as your tests fail/succeed one after another. Or, if you
want your tests to work under Test::Harness and the standard perlish
'make test', you'd write a t/foo.t that looked like:

    use Test::Unit::HarnessUnit;
    my $r = Test::Unit::HarnessUnit->new();
    $r->start('My::TestCase::Class');

=head2 How To Use Test::Unit::TestCase

(Taken from the JUnit TestCase class documentation)

A test case defines the "fixture" (resources need for testing) to run
multiple tests. To define a test case:

=over 4

=item 1

implement a subclass of TestCase

=item 2

define instance variables that store the state of the fixture (I
suppose if you are using Class::MethodMaker this is possible...)

=item 3

initialize the fixture state by overriding C<set_up()>

=item 4

clean-up after a test by overriding C<tear_down()>.

=back


Implement your tests as methods.  By default, all methods that match
the regex C</^test/> are taken to be test methods (see
L</list_tests()> and L</get_matching_methods()>).  Note that, by
default all the tests defined in the current class and all of its
parent classes will be run.  To change this behaviour, see L</NOTES>.

By default, each test runs in its own fixture so there can be no side
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

=head2 Writing Test Methods

The return value of your test method is completely irrelevant. The
various test runners assume that a test is executed successfully if no
exceptions are thrown. Generally, you will not have to deal directly
with exceptions, but will write tests that look something like:

    sub test_something {
        my $self = shift;
        # Execute some code which gives some results.
        ...
        # Make assertions about those results
        $self->assert_equals('expected value', $resultA);
        $self->assert_not_null($result_object);
        $self->assert(qr/some_pattern/, $resultB);
    }

The assert methods throw appropriate exceptions when the assertions fail, 
which will generally stringify nicely to give you sensible error reports.

L<Test::Unit::Assert> has more details on the various different
C<assert> methods.

L<Test::Unit::Exception> describes the Exceptions used within the
C<Test::Unit::*> framework.

=head2 Helper methods

=over 4

=item make_test_from_coderef (CODEREF, [NAME])

Takes a coderef and an optional name and returns a Test case that
inherits from the object on which it was called, which has the coderef
installed as its C<run_test> method. L<Class::Inner> has more details
on how this is generated.

=item list_tests

Returns the list of test methods in this class and its parents. You
can override this in your own classes, but remember to call
C<SUPER::list_tests> in there too.  Uses C<get_matching_methods>.

=item get_matching_methods (REGEXP)

Returns the list of methods in this class matching REGEXP.

=item set_up

=item tear_down

If you don't have any setup or tear down code that needs to be run, we
provide a couple of null methods. Override them if you need to.

=item annotate (MESSAGE)

You can accumulate helpful debugging for each testcase method via this
method, and it will only be outputted if the test fails or encounters
an error.

=back

=head2 How it All Works

The PerlUnit framework is achingly complex. The basic idea is that you
get to write your tests independently of the manner in which they will
be run, either via a C<make test> type script, or through one of the
provided TestRunners, the framework will handle all that for you. And
it does. So for the purposes of someone writing tests, in the majority
of cases the answer is 'It just does.'.

Of course, if you're trying to extend the framework, life gets a
little more tricky. The core class that you should try and grok is
probably Test::Unit::Result, which, in tandem with whichever
TestRunner is being used mediates the process of running tests,
stashes the results and generally sits at the centre of everything.

Better docs will be forthcoming.

=head1 NOTES

Here's a few things to remember when you're writing your test suite:

Tests are run in 'random' order; the list of tests in your TestCase
are generated automagically from its symbol table, which is a hash, so
methods aren't sorted there. 

If you need to specify the test order, you can do one of the
following:

=over 4

=item * Set @TESTS

  our @TESTS = qw(my_test my_test_2);

This is the simplest, and recommended way.

=item * Override the C<list_tests()> method

to return an ordered list of methodnames

=item * Provide a C<suite()> method

which returns a Test::Unit::TestSuite.

=back

However, even if you do manage to specify the test order, be careful,
object data will not be retained from one test to another, if you want
to use persistent data you'll have to use package lexicals or globals.
(Yes, this is probably a bug).

If you only need to restrict which tests are run, there is a filtering
mechanism available.  Override the C<filter()> method in your testcase
class to return a hashref whose keys are filter tokens and whose
values are arrayrefs of test method names, e.g.

  sub filter {{
      slow => [ qw(my_slow_test my_really_slow_test) ],
  }}

Then, set the filter state in your runner before the test run starts:

  # @filter_tokens = ( 'slow', ... );
  $runner->filter(@filter_tokens);
  $runner->start(@args);

This interface is public, but currently undocumented (see
F<doc/TODO>).

=head1 BUGS

See note 1 for at least one bug that's got me scratching my head.
There's bound to be others.

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

More changes made by Piers Cawley <pdcawley@iterative-software.com>

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::Assert>

=item *

L<Test::Unit::Exception>

=item *

L<Test::Unit::TestSuite>

=item *

L<Test::Unit::TestRunner>

=item *

L<Test::Unit::TkTestRunner>

=item *

For further examples, take a look at the framework self test
collection (t::tlib::AllTests).

=back

=cut

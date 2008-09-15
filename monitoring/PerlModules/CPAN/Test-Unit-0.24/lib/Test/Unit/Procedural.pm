package Test::Unit::Procedural;

use strict;

use Test::Unit::TestSuite;
use Test::Unit::TestRunner;

use base 'Exporter';

use vars qw(@EXPORT);
@EXPORT = qw(assert create_suite run_suite add_suite);

# Helper classes
use Devel::Symdump;
use Class::Inner;

# Exception handling
use Error qw/:try/;
use Test::Unit::Exception;
use Test::Unit::Failure;

# private

my $test_suite = Test::Unit::TestSuite->empty_new("Test::Unit");
my %suites = ();
%suites = ('Test::Unit' => $test_suite);
    
sub add_to_suites {
    my $suite_holder = shift;
    if (not exists $suites{$suite_holder}) {
	my $test_suite = Test::Unit::TestSuite->empty_new($suite_holder);
	$suites{$suite_holder} = $test_suite;
    }
}

# public

sub assert ($;$) {
    my($condition, $message) = @_;
    my($asserter,$file,$line) = caller(1);
    
    add_to_suites($asserter);
    try {
        $suites{$asserter}->assert($condition, $message);
    }
    catch Test::Unit::Exception with {
        my $e = shift;
        $e->throw_new(
                      -package => $asserter,
                      -file    => $file,
                      -line    => $line);
    }
}

sub create_suite {
    my ($test_package_name) = @_;
    $test_package_name = caller() unless defined($test_package_name);
    add_to_suites($test_package_name);
    
    no strict 'refs';

    my $set_up_func    = sub {};
    my $tear_down_func = sub {};

    my $st = Devel::Symdump->new($test_package_name);
    my @set_up_candidates = grep /::set_up$/, $st->functions;
    $set_up_func = \&{$set_up_candidates[0]} if @set_up_candidates;

    my @tear_down_candidates = grep /::tear_down$/, $st->functions;
    $tear_down_func = \&{$set_up_candidates[0]} if @set_up_candidates;

    for my $test_method (grep /::test[^:]*$/, $st->functions) {
        my($method_name) = $test_method =~ /::(test[^:]*)/;
        my $subref = \&{$test_method};
        my $test_case = Class::Inner->new
            (parent  => 'Test::Unit::TestCase',
             methods => {set_up       => $set_up_func,
                         tear_down    => $tear_down_func,
                         $method_name => $subref,
                        },
             args    => [$method_name],);
	    $suites{$test_package_name}->add_test($test_case);
	}
}

sub run_suite {
    my ($test_package_name, $filehandle) = @_;
    $test_package_name = caller() unless defined($test_package_name);
    my $test_runner = Test::Unit::TestRunner->new($filehandle);
    $test_runner->do_run($suites{$test_package_name});
}

sub add_suite {
    my ($to_be_added, $to_add_to) = @_;
    $to_add_to = caller() unless defined($to_add_to);
    die "Error: no suite '$to_be_added'" unless exists $suites{$to_be_added};
    die "Error: no suite '$to_add_to'" unless exists $suites{$to_add_to};
    $suites{$to_add_to}->add_test($suites{$to_be_added});
}

1;
__END__

=head1 NAME

Test::Unit::Procedural - Procedural style unit testing interface

=head1 SYNOPSIS

    use Test::Unit::Procedural;

    # your code to be tested goes here

    sub foo { return 23 };
    sub bar { return 42 };

    # define tests

    sub test_foo { assert(foo() == 23, "Your message here"); }	
    sub test_bar { assert(bar() == 42, "I will be printed if this fails"); }

    # set_up and tear_down are used to
    # prepare and release resources need for testing

    sub set_up    { print "hello world\n"; }
    sub tear_down { print "leaving world again\n"; }

    # run your test

    create_suite();
    run_suite();

=head1 DESCRIPTION

Test::Unit::Procedural is the procedural style interface to a
sophisticated unit testing framework for Perl that is derived from the
JUnit testing framework for Java by Kent Beck and Erich Gamma.  While
this framework is originally intended to support unit testing in an
object-oriented development paradigm (with support for inheritance of
tests etc.), Test::Unit::Procedural is intended to provide a simpler
interface to the framework that is more suitable for use in a
scripting style environment.  Therefore, Test::Unit::Procedural does
not provide much support for an object-oriented approach to unit
testing - if you want that, please have a look at
L<Test::Unit::TestCase>.

You test a given unit (a script, a module, whatever) by using
Test::Unit::Procedural, which exports the following routines into your
namespace:

=over 4

=item assert()

used to assert that a boolean condition is true

=item create_suite()

used to create a test suite consisting of all methods with a name
prefix of C<test>

=item run_suite()

runs the test suite (text output)

=item add_suite()

used to add test suites to each other

=back

For convenience, C<create_suite()> will automatically build a test
suite for a given package. This will build a test case for each
subroutine in the package given that has a name starting with C<test>
and pack them all together into one TestSuite object for easy testing.
If you dont give a package name to C<create_suite()>, the current
package is taken as default.

Test output is one status line (a "." for every successful test run,
or an "F" for any failed test run, to indicate progress), one result
line ("OK" or "!!!FAILURES!!!"), and possibly many lines reporting
detailed error messages for any failed tests.

Please remember, Test::Unit::Procedural is intended to be a simple and
convenient interface. If you need more functionality, take the
object-oriented approach outlined in L<Test::Unit::TestCase>.


=head1 AUTHOR

Copyright (c) 2000, 2001 Christian Lemburg, E<lt>lemburg@acm.orgE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen, Matthew Astley,
Adam Spiers, Piers Cawley.

Thanks for patches and other contributions go to:
David Esposito, Kevin Connor.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::TestCase>

=item *

the procedural style examples in the examples directory

=back

=cut

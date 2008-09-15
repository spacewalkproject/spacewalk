package AllTests;

use Test::Unit::TestSuite;
use SuiteTest;
use InheritedSuite::Simple;
use InheritedSuite::TestNames;

sub new {
    my $class = shift;
    return bless {}, $class;
}

sub suite {
    my $class = shift;
    my $suite = Test::Unit::TestSuite->empty_new("Framework Tests");

    # We now add the various test cases and suites to this suite
    # in deliberately different ways, so as to implicitly test
    # the different interfaces by which one can add/construct tests.

    # Add test cases in 3 different ways.  The first 3 extract all
    # test_* methods, and the last extracts only 1 method.
    $suite->add_test(Test::Unit::TestSuite->new('TestTest'));      
    $suite->add_test('ListenerTest');                             
    $suite->add_test('BadSuitesTest');
    $suite->add_test('WillDie');
    $suite->add_test(InheritedSuite::TestNames->new('test_names'));

    # Add test suites in 4 different ways.
    $suite->add_test(SuiteTest->suite());                          
    $suite->add_test(InheritedSuite::Simple->new());           
    $suite->add_test('InheritedSuite::OverrideNew');           
#    $suite->add_test(Test::Unit::TestSuite->new('InheritedSuite::OverrideNewName'));

    return $suite;
}

1;
__END__


=head1 NAME

AllTests - unit testing framework self tests

=head1 SYNOPSIS

    # command line style use

    perl TestRunner.pl AllTests

    # GUI style use

    perl TkTestRunner.pl AllTests


=head1 DESCRIPTION

This class is used by the unit testing framework to encapsulate all
the self tests of the framework.

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

L<Test::Unit::TestSuite>

=back

=cut

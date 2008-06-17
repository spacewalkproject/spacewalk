package Test::Unit::Runner::Terminal;
use strict;

use base qw(Test::Unit::TestRunner); 

sub start_suite {
    my $self = shift;
    $self->SUPER::start_suite(@_);
    $self->_update_status;
}

sub end_suite {
    my $self = shift;
    $self->SUPER::end_suite(@_);
    $self->_update_status;
}

sub start_test {
    my $self = shift;
    my ($test) = @_;
    $self->{_last_test} = $test->name;
    $self->_update_status;
}

sub end_test {
    my $self = shift;
    my ($test) = @_;
    $self->{_last_test} = '';
    $self->_update_status;
}

sub add_error {
    my $self = shift;
    my ($test, $exception) = @_;
    $self->_update_status;
}
	
sub add_failure {
    my $self = shift;
    my ($test, $exception) = @_;
    $self->_update_status;
}

sub add_pass {
    my $self = shift;
    my ($test) = @_;
    $self->_update_status;
}

sub _update_status {
    my $self = shift;
    my $result = $self->result;

    # \e[2A goes two lines up
    # \e[K clears to end of line
    # \e[J clears below
    # \e7 saves cursor position
    # \e8 restores cursor position
    my $template = <<STATUS; 




\e[4A\e7Run: %d, Failures: %d, Errors: %d\e[K
Current suite: %s\e[K
Current test:  %s\e[J\e8
STATUS
    chomp $template;

    $self->_print(
        sprintf $template,
                $result->run_count,
                $result->failure_count,
                $result->error_count,
                join(' -> ', map { $_->name || '?' }  $self->suites_running),
                $self->{_last_test} || '',
    );
}

sub print_result {
    my $self = shift;
    $self->_print("\e[J"); # clear status lines below
    $self->SUPER::print_result(@_);
}

1;
__END__


=head1 NAME

Test::Unit::Runner::Terminal - unit testing framework helper class

=head1 SYNOPSIS

    use Test::Unit::Runner::Terminal;

    my $testrunner = Test::Unit::Runner::Terminal->new();
    $testrunner->start($my_test_class);

=head1 DESCRIPTION

This class is a test runner for the command line style use
of the testing framework.

It is similar to its parent class, Test::Unit::TestRunner, but it uses
terminal escape sequences to continually update a more informative
status report as the runner progresses through the tests than just a
string of dots, E's and F's.  The status report indicates the number
of tests run, the number of failures and errors encountered, which
test is currently being run, and where it lives in the suite
hierarchy.

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

L<Test::Unit::Listener>

=item *

L<Test::Unit::TestSuite>

=item *

L<Test::Unit::Result>

=item *

L<Test::Unit::TkTestRunner>

=item *

For further examples, take a look at the framework self test
collection (t::tlib::AllTests).

=back

=cut

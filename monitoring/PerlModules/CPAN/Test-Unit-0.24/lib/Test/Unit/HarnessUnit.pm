package Test::Unit::HarnessUnit;
# this is a test runner which outputs in the same
# format that Test::Harness expects. 
use strict;

use base qw(Test::Unit::Runner); 

use Test::Unit::TestSuite;
use Test::Unit::Loader;

sub new {
    my $class = shift;
    my ($filehandle) = @_;
    # should really use the IO::Handle package here.
    # this is very ugly.
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
    $self->{_Print_stream}->print( @args);
}

sub start_test {
    my $self=shift;
    my $test=shift;
}

sub not_ok {
    my $self = shift;
    my ($test, $exception) = @_;
    $self->_print("\nnot ok ERROR ",
                  $test->name(),
                  "\n$exception\n");
}

sub ok {
    my $self = shift;
    my ($test) = @_;
    $self->_print("ok PASS " . $test->name() . "\n");
}

sub add_error {
    my $self = shift;
    $self->not_ok(@_);
}
	
sub add_failure {
    my $self = shift;
    $self->not_ok(@_);
}

sub add_pass {
    my $self = shift;
    $self->ok(@_);
}

sub end_test {
    my $self = shift;
    my ($test) = @_;
}

sub do_run {
    my $self    = shift;
    my ($suite) = @_;
    my $result  = $self->create_test_result();
    $result->add_listener($self);
    $suite->run($result, $self);
}

sub main {
    my $self = shift;
    my $a_test_runner = __PACKAGE__->new;
    $a_test_runner->start(@_);
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

sub start {
    my $self      = shift;
    my (@args)    = @_;

    my $test_case = "";
    my $wait      = 0;
    my $suite     = Test::Unit::Loader::load(@args);
    if ($suite) {
        my $count=$suite->count_test_cases();
        $self->_print("STARTING TEST RUN\n1..$count\n");
        $self->do_run($suite);
        exit(0);
    } else {
        $self->_print("Invalid argument to test runner: $args[0]\n");
        exit(1);
    }
}

1;
__END__


=head1 NAME

Test::Unit::HarnessUnit - unit testing framework helper class

=head1 SYNOPSIS

This class is not intended to be used directly 

=head1 DESCRIPTION

This is a test runner which outputs in the same format that
Test::Harness expects.

=head1 AUTHOR

Copyright (c) 2000 Brian Ewins.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Christian Lemburg, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::UnitHarness>

=item *

L<Test::Unit::TestRunner>

=item *

L<Test::Unit::TkTestRunner>

=back

=cut

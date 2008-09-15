package Test::Unit::TestFailure;
use strict;
use constant DEBUG => 0;

sub new {
    my $class = shift;
    my ($test, $exception) = @_;
    bless { 
	_Failed_test => $test,
	_Thrown_exception => $exception,
    }, $class;
}

sub failed_test {
    my $self = shift;
    return $self->{_Failed_test};
}

sub thrown_exception {
    my $self = shift;
    return $self->{_Thrown_exception};
}

sub to_string {
    my $self = shift;
    return $self->failed_test()->to_string() . "\n" .
	$self->thrown_exception()->to_string();
}

1;
__END__


=head1 NAME

Test::Unit::TestFailure - unit testing framework helper class

=head1 SYNOPSIS

This class is not intended to be used directly 

=head1 DESCRIPTION

This class is used by the framework to record the results of failed
tests, which will throw an instance of a subclass of
Test::Unit::Exception in case of errors or failures.

=head1 AUTHOR

Copyright (c) 2000 Christian Lemburg, E<lt>lemburg@acm.orgE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::TestResult>

=item *

L<Test::Unit::Exception>

=back

=cut

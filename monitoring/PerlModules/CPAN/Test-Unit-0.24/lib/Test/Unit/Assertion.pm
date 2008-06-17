package Test::Unit::Assertion;

use strict;

use Carp;
use Test::Unit::Failure;

use overload '""' => 'to_string';

sub fail {
    my $self = shift;
    my($asserter, $file, $line) = caller(2); # We're always called from
                                             # within an Assertion...
    Test::Unit::Failure->throw(-object => $self,
                               -file   => $file,
                               -line   => $line,
                               -text   => join '', @_);
}

sub do_assertion {
    Carp::croak("$_[0] forgot to override do_assertion");
}

sub new {
    Carp::croak("$_[0] forgot to override new");
}

1;

__END__

=head1 NAME

Test::Unit::Assertion - The abstract base class for assertions

=head1 NAME

Any assertion class that expects to plug into Test::Unit::Assert needs
to implement this interface. 

=head2 Required methods

=over 4

=item new

Creates a new assertion object. Takes whatever arguments you desire.
Isn't strictly necessary for the framework to work with this class but
is generally considered a good idea.

=item do_assertion

This is the important one. If Test::Unit::Assert::assert is called
with an object as its first argument then it does:

    $_[0]->do_assertion(@_[1 .. $#_]) ||
        $self->fail("Assertion failed");

This means that C<do_assertion> should return true if the assertion
succeeds and false if it doesn't. Or, you can fail by throwing a
Test::Unit::Failure object, which will get caught further up
the stack and used to produce a sensible error report. Generally it's
good practice for do_assertion to die with a meaningful error on
assertion failure rather than just returning false.

=back


=head1 AUTHOR

Copyright (c) 2001 Piers Cawley E<lt>pdcawley@iterative-software.comE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::Assert>

=item *

L<Test::Unit::CodeRef>

=item *

L<Test::Unit::Regexp>

=back

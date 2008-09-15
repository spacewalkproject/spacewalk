package Test::Unit::Assert;
use strict;
use constant DEBUG => 0;

require Test::Unit::ExceptionFailure;

sub assert {
    my $self = shift;
    my $assertion = $self->normalize_assertion(shift);
    print "Calling $assertion\n" if DEBUG;
    $assertion->do_assertion(@_) ||
        $self->fail("$assertion failed\n");
}

sub normalize_assertion {
    my $self      = shift;
    my $assertion = shift;
    if (!ref($assertion)) {
        require Test::Unit::Assertion::Boolean;
        return Test::Unit::Assertion::Boolean->new($assertion);
    }
    elsif (eval {$assertion->isa('Regexp')}) {
        require Test::Unit::Assertion::Regexp;
        return Test::Unit::Assertion::Regexp->new($assertion);
    }
    elsif (eval {$assertion->isa('UNIVERSAL')}) {
        # It's an object already.

        return $assertion->can('do_assertion') ? $assertion :
            Test::Unit::Assertion::Boolean->new($assertion);
        
    }
    elsif (ref($assertion) eq 'CODE') {
        require Test::Unit::Assertion::CodeRef;
        return Test::Unit::Assertion::CodeRef->new($assertion);
    }
#     elsif (ref($assertion) eq 'SCALAR') {
#         require Test::Unit::Assertion::Scalar;
#         return Test::Unit::Assertion::Scalar->new($assertion);
#     }
    else {
        die "Don't know how to normalize $assertion\n";
    }
}

sub fail {
    my $self = shift;
    print ref($self) . "::fail() called\n" if DEBUG;
    my $message = join '', @_;
    my $ex = Test::Unit::ExceptionFailure->new($message);
    $ex->hide_backtrace() unless $self->get_backtrace_on_fail();
    die $ex;
}

sub quell_backtrace {
    my $self = shift;
    $self->{_no_backtrace_on_fail} = 1;
}

sub get_backtrace_on_fail {
    my $self = shift;
    return $self->{_no_backtrace_on_fail} ? 0 : 1;
}



1;
__END__

=head1 NAME

Test::Unit::Assert - unit testing framework assertion class

=head1 SYNOPSIS

    # this class is not intended to be used directly, 
    # normally you get the functionality by subclassing from 
    # Test::Unit::TestCase

    use Test::Unit::TestCase;

    # more code here ...

    $self->assert($your_condition_here, $your_optional_message_here);

    # or, for regular expression comparisons:

    $self->assert(qr/some_pattern/, $result);

    # or, for functional style coderef tests:

    $self->assert(sub {$_[0] == $_[1] || die "Expected $_[0], got $_[1]"},
                  1, 2); 

    # or, for old style regular expression comparisons:

    $self->assert(scalar("foo" =~ /bar/), $your_optional_message_here);


=head1 DESCRIPTION

This class is used by the framework to assert boolean conditions that
determine the result of a given test. The optional message will be
displayed if the condition fails. Normally, it is not used directly,
but you get the functionality by subclassing from Test::Unit::TestCase.

You can also pass in a regular expression object or a coderef as first
argument to get additional functionality. Note that this is the
recommended approach to testing regular expression matching.

If you want to use the "old" style for testing regular expression
matching, please be aware of this: the arguments to assert() are
evaluated in list context, e.g. making a failing regex "pull" the
message into the place of the first argument. Since this is ususally
just plain wrong, please use scalar() to force the regex comparison
to yield a useful boolean value.

Copyright (c) 2000 Christian Lemburg, E<lt>lemburg@acm.orgE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

Thanks for patches go to:
Matthew Astley, David Esposito, Piers Cawley.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::Assertion>

=item *

L<Test::Unit::Assertion::Regexp>

=item *

L<Test::Unit::Assertion::CodeRef>

=item *

L<Test::Unit::Assertion::Boolean>

=item *

L<Test::Unit::TestCase>

=item *

L<Test::Unit::Exception>

=item *

The framework self-testing suite
(L<Test::Unit::tests::AllTests|Test::Unit::tests::AllTests>)

=back

=cut

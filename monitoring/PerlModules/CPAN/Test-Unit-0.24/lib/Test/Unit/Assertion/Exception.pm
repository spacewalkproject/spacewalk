package Test::Unit::Assertion::Exception;

use strict;
use base qw/Test::Unit::Assertion/;

use Carp;
use Error qw/:try/;
use Test::Unit::Debug qw(debug);

my $deparser;

sub new {
    my $class = shift;
    my $exception_class = shift;
    croak "$class\::new needs an exception class" unless $exception_class;
    bless \$exception_class => $class;
}

sub do_assertion {
    my $self = shift;
    my $coderef = shift;
    my $exception_class = $$self;

    my $exception;
    try {
        &$coderef();
    }
    catch $exception_class with {
        $exception = shift;
    };

    if (! $exception || ! $exception->isa($$self)) {
        $self->fail(@_ ? $_[0] : "No $exception_class was raised");
    }
    return $exception; # so that it can be stored in the test for the
                       # user to get at.
}

sub to_string {
    my $self = shift;
    return "$$self exception assertion";
}

1;
__END__

=head1 NAME

Test::Unit::Assertion::Exception - A assertion for raised exceptions

=head1 SYNOPSIS

    require Test::Unit::Assertion::Exception;

    my $assert_raised =
      Test::Unit::Assertion::Exception->new('MyException');

    # This should succeed
    $assert_eq->do_assertion(sub { MyException->throw() });

    # This should fail
    $assert_eq->do_assertion(sub { });

=head1 DESCRIPTION

Although the SYNOPSIS shows how you'd use
Test::Unit::Assertion::Exception directly, it is more sensibly used
indirectly via C<Test::Unit::Test::assert_raises()>, which
instantiates a C<Test::Unit::Assertion::Exception>.

=head1 AUTHOR

Copyright (c) 2001 Piers Cawley E<lt>pdcawley@iterative-software.comE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::TestCase>

=item *

L<Test::Unit::Assertion>

=back

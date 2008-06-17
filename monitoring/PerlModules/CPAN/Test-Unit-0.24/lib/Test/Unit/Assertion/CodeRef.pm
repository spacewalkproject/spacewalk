package Test::Unit::Assertion::CodeRef;

use strict;
use base qw/Test::Unit::Assertion/;

use Carp;
use Test::Unit::Debug qw(debug);

my $deparser;

sub new {
    my $class = shift;
    my $code = shift;
    croak "$class\::new needs a CODEREF" unless ref($code) eq 'CODE';
    bless \$code => $class;
}

sub do_assertion {
    my $self = shift;
    my $possible_object = $_[0];
    debug("Called do_assertion(" . ($possible_object || 'undef') . ")\n");
    if (ref($possible_object) and
        ref($possible_object) ne 'Regexp' and
        eval { $possible_object->isa('UNIVERSAL') })
    {
        debug("  [$possible_object] isa [" . ref($possible_object) . "]\n");
        $possible_object->$$self(@_[1..$#_]);
    }
    else {
        debug("  asserting [$self]"
              . (@_ ? " on args " . join(', ', map { $_ || '<undef>' } @_) : '')
              . "\n");
        $$self->(@_);
    }
}

sub to_string {
    my $self = shift;
    if (eval "require B::Deparse") {
        $deparser ||= B::Deparse->new("-p");
        return join '', "sub ", $deparser->coderef2text($$self);
    }
    else {
        return "sub {
    # If you had a working B::Deparse, you'd know what was in
    # this subroutine.
}";
    }
}

1;
__END__

=head1 NAME

Test::Unit::Assertion::CodeRef - A delayed evaluation assertion using a Coderef

=head1 SYNOPSIS

    require Test::Unit::Assertion::CodeRef;

    my $assert_eq =
      Test::Unit::Assertion::CodeRef->new(sub {
        $_[0] eq $_[1]
          or Test::Unit::Failure->throw(-text =>
                                          "Expected '$_[0]', got '$_[1]'\n");
      });

    $assert_eq->do_assertion('foo', 'bar');

Although this is how you'd use Test::Unit::Assertion::CodeRef
directly, it is more usually used indirectly via
Test::Unit::Test::assert, which instantiates a
Test::Unit::Assertion::CodeRef when passed a Coderef as its first
argument.

=head1 IMPLEMENTS

Test::Unit::Assertion::CodeRef implements the Test::Unit::Assertion
interface, which means it can be plugged into the Test::Unit::TestCase
and friends' C<assert> method with no ill effects.

=head1 DESCRIPTION

This class is used by the framework to allow us to do assertions in a
'functional' manner. It is typically used generated automagically in
code like:

    $self->assert(sub {
                    $_[0] == $_[1]
                      or $self->fail("Expected $_[0], got $_[1]");
                  }, 1, 2); 

(Note that if Damian Conway's Perl6 RFC for currying ever comes to
pass then we'll be able to do this as:

    $self->assert(^1 == ^2 || $self->fail("Expected ^1, got ^2"), 1, 2)

which will be nice...)

If you have a working B::Deparse installed with your perl installation
then, if an assertion fails, you'll see a listing of the decompiled
coderef (which will be sadly devoid of comments, but should still be
useful) 

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

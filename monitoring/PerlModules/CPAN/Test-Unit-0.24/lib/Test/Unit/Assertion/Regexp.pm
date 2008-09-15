package Test::Unit::Assertion::Regexp;

use strict;
use Test::Unit::Assertion;
use base qw/Test::Unit::Assertion/;

sub new {
    my $class = shift;
    my $regex = shift;

    bless \$regex, $class;
}

sub do_assertion {
    my $self = shift;
    my $target = shift;
    $target =~ $$self or
        $self->fail(@_ ? $_[0] : "'$target' did not match /$$self/");
}

sub to_string {
    my $self = shift;
    "/$$self/ regexp assertion";
}

1;

__END__

=head1 NAME

Test::Unit::Assertion::Regexp - Assertion with regex matching

=head1 SYNOPSIS

    require Test::Unit::Assertion::Regexp;

    my $assert_re =
      Test::Unit::Assertion::Regexp->new(qr/a_pattern/);

    $assert_re->do_assertion('a_string');

This is rather more detail than the average user will need.
Test::Unit::Assertion::Regexp objects are generated automagically by
Test::Unit::Assert::assert when it is passed a regular expression as
its first parameter. 

    sub test_foo {
      ...
      $self->assert(qr/some_pattern/, $result);
    }

If the assertion fails then the object throws an exception with
details of the pattern and the string it failed to match against.

Note that if you need to do a 'string does I<not> match this pattern'
type of assertion then you can do:

   $self->assert(qr/(?!some_pattern)/, $some_string)

ie. Make use of the negative lookahead assertion.

=head1 IMPLEMENTS

Test::Unit::Assertion::Regexp implements the Test::Unit::Assertion
interface, which means it can be plugged into the Test::Unit::TestCase
and friends' C<assert> method with no ill effects.

=head1 DESCRIPTION

The class is used by the framework to provide sensible 'automatic'
reports when a match fails. The old:

    $self->assert(scalar($foo =~ /pattern/), "$foo didn't match /.../");

seems rather clumsy compared to this. If the regexp assertion fails,
then the user is given a sensible error message, with the pattern and
the string that failed to match it...

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

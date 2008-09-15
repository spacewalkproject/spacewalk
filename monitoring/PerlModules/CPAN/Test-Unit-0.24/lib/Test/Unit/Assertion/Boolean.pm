package Test::Unit::Assertion::Boolean;

use strict;

# adding this fixes the 'Can't locate object method "fail" via package
# "Test::Unit::Assertion::Boolean"' problem under perl 5.005 - Christian
use Test::Unit::Assertion;
use Test::Unit::Failure;


use base 'Test::Unit::Assertion';

use overload 'bool' => sub {$ {$_[0]}};

sub new {
    my $class = shift;
    my $bool  = shift;

    my $self = \$bool;
    bless $self, $class;
}

sub do_assertion {
    my $self = shift;
    $$self or $self->fail( @_ ? join('', @_) : "Boolean assertion failed");
}

sub to_string {
    my $self = shift;
    ($$self ? 'TRUE' : 'FALSE') . ' boolean assertion';
}

1;

__END__

=head1 NAME

Test::Unit::Assertion::Boolean - A boolean assertion

=head1 SYNOPSIS

Pay no attention to the man behind the curtain. This is simply a
boolean assertion that exists solely to rationalize the way
Test::Unit::Assert::assert does its thing. You should never have to
instantiate one of these directly. Ever. Go away. There's nothing to
see here.


=head1 AUTHOR

Copyright (c) 2001 Piers Cawley E<lt>pdcawley@iterative-software.comE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

Look, I've told you, there's nothing going on here. If you go looking
at the listing of this module you'll see that it does almost nothing.
Why on earth you're still reading at this point is something of a
mystery to me. After all, if you're hacking on the Test::Unit source
code you'll be able to use the Source.

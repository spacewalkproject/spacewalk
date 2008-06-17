=head1 NAME

Test::Unit - the PerlUnit testing framework

=head1 SYNOPSIS

This package provides no functionality; it just serves as an
overview of the available modules in the framework.

=head1 DESCRIPTION

This framework is intended to support unit testing in an
object-oriented development paradigm (with support for
inheritance of tests etc.) and is derived from the JUnit
testing framework for Java by Kent Beck and Erich Gamma.  To
start learning how to use this framework, see
L<Test::Unit::TestCase> and L<Test::Unit::TestSuite>.  (There
will also eventually be a tutorial in
L<Test::Unit::Tutorial>.

However C<Test::Unit::Procedural> is the procedural style
interface to a sophisticated unit testing framework for Perl
that .  Test::Unit is intended to provide a simpler
interface to the framework that is more suitable for use in a
scripting style environment.  Therefore, Test::Unit does not
provide much support for an object-oriented approach to unit
testing.

=head1 AUTHOR

Copyright (c) 2000, 2001 the PerlUnit Development Team
(see the F<AUTHORS> file included in this distribution).

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::TestCase>

=item *

L<Test::Unit::TestSuite>

=item *

L<Test::Unit::Procedural>

=back

=head1 FEEDBACK

The Perl Unit development team are humans. In part we develop stuff
because it scratches our collective itch but we'd also really like to
know if it scratches yours. Please subscribe to the perlunit-users
mailing list at
L<http://lists.sourceforge.net/lists/listinfo/perlunit-users> and let
us know what you love and hate about PerlUnit and what else you want
to do with it.

=cut

package Test::Unit;

use strict;
use vars qw($VERSION);

# NOTE: this version number has to be kept in sync with the
# number in the distribution file name (the distribution file
# is the tarball for CPAN release) because the CPAN module
# decides to fetch the tarball by looking at the version of
# this module if you say "install Test::Unit" in the CPAN
# shell.  "make tardist" should do this automatically.

$VERSION = '0.24';

1;
__END__

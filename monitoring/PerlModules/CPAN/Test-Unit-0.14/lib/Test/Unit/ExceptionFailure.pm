package Test::Unit::ExceptionFailure;
use strict;
use base qw(Test::Unit::Exception);

1;
__END__


=head1 NAME

Test::Unit::ExceptionFailure - unit testing framework exception class

=head1 SYNOPSIS

This class is not intended to be used directly 

=head1 DESCRIPTION

This class is used by the framework to communicate the result of
assertions, which will throw an instance of this class in case of
failures (that is, failed tests, not syntax errors and the like, these
are classified as errors).

=head1 AUTHOR

Copyright (c) 2000 Christian Lemburg, E<gt>lemburg@acm.orgE<gt>.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Brian Ewins, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::Exception>

=item *

L<Test::Unit::Assert>

=back

=cut

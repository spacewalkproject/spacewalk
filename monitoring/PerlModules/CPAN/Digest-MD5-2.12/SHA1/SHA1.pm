package Digest::SHA1;

use strict;
use vars qw($VERSION @ISA @EXPORT_OK);

$VERSION = '1.03';  # $Date: 2000-10-13 20:19:24 $

require Exporter;
*import = \&Exporter::import;
@EXPORT_OK = qw(sha1 sha1_hex sha1_base64);

require DynaLoader;
@ISA=qw(DynaLoader);
Digest::SHA1->bootstrap($VERSION);

*reset = \&new;

1;
__END__

=head1 NAME

Digest::SHA1 - Perl interface to the SHA-1 Algorithm

=head1 SYNOPSIS

 # Functional style
 use Digest::SHA1  qw(sha1 sha1_hex sha1_base64);

 $digest = sha1($data);
 $digest = sha1_hex($data);
 $digest = sha1_base64($data);


 # OO style
 use Digest::SHA1;

 $ctx = Digest::SHA1->new;

 $ctx->add($data);
 $ctx->addfile(*FILE);

 $digest = $ctx->digest;
 $digest = $ctx->hexdigest;
 $digest = $ctx->b64digest;

=head1 DESCRIPTION

The C<Digest::SHA1> module allows you to use the NIST SHA-1 message
digest algorithm from within Perl programs.  The algorithm takes as
input a message of arbitrary length and produces as output a 160-bit
"fingerprint" or "message digest" of the input.

The C<Digest::SHA1> module provide a procedural interface for simple
use, as well as an object oriented interface that can handle messages
of arbitrary length and which can read files directly.

A binary digest will be 20 bytes long.  A hex digest will be 40
characters long.  A base64 digest will be 27 characters long.


=head1 FUNCTIONS

The following functions can be exported from the C<Digest::SHA1>
module.  No functions are exported by default.

=over 4

=item sha1($data,...)

This function will concatenate all arguments, calculate the SHA-1
digest of this "message", and return it in binary form.

=item sha1_hex($data,...)

Same as sha1(), but will return the digest in hexadecimal form.

=item sha1_base64($data,...)

Same as sha1(), but will return the digest as a base64 encoded string.

=back

=head1 METHODS

The C<Digest::SHA1> module provide the standard C<Digest> OO-interface.
The constructor looks like this:

=over 4

=item $sha1 = Digest->new('SHA-1')

=item $sha1 = Digest::SHA1->new

The constructor returns a new C<Digest::SHA1> object which encapsulate
the state of the SHA-1 message-digest algorithm.  You can add data to
the object and finally ask for the digest using the methods described
in L<Digest>.

=back

=head1 SEE ALSO

L<Digest>, L<Digest::HMAC_SHA1>, L<Digest::MD5>

http://www.itl.nist.gov/fipspubs/fip180-1.htm

=head1 COPYRIGHT

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

 Copyright 1999-2000 Gisle Aas.
 Copyright 1997 Uwe Hollerbach.

=head1 AUTHORS

Peter C. Gutmann,
Uwe Hollerbach <uh@alumni.caltech.edu>,
Gisle Aas <gisle@aas.no>

=cut

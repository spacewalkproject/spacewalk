package Digest::MD2;

use strict;
use vars qw($VERSION @ISA @EXPORT_OK);

$VERSION = '1.01';  # $Date: 2000-10-13 20:19:23 $

require Exporter;
*import = \&Exporter::import;
@EXPORT_OK = qw(md2 md2_hex md2_base64);

require DynaLoader;
@ISA=qw(DynaLoader);
Digest::MD2->bootstrap($VERSION);

*reset = \&new;

1;
__END__

=head1 NAME

Digest::MD2 - Perl interface to the MD2 Algorithm

=head1 SYNOPSIS

 # Functional style
 use Digest::MD2  qw(md2 md2_hex md2_base64);

 $digest = md2($data);
 $digest = md2_hex($data);
 $digest = md2_base64($data);

 # OO style
 use Digest::MD2;

 $ctx = Digest::MD2->new;

 $ctx->add($data);
 $ctx->addfile(*FILE);

 $digest = $ctx->digest;
 $digest = $ctx->hexdigest;
 $digest = $ctx->b64digest;

=head1 DESCRIPTION

The C<Digest::MD2> module allows you to use the RSA Data Security
Inc. MD2 Message Digest algorithm from within Perl programs.  The
algorithm takes as input a message of arbitrary length and produces as
output a 128-bit "fingerprint" or "message digest" of the input.

The C<Digest::MD2> programming interface is identical to the interface
of C<Digest::MD5>.

=head1 SEE ALSO

L<Digest::MD5>

=head1 COPYRIGHT

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

 Copyright 1998-2000 Gisle Aas.
 Copyright 1990-1992 RSA Data Security, Inc.

=head1 AUTHOR

Gisle Aas <gisle@aas.no>

=cut

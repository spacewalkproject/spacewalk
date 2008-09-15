package SHA;

use strict;
use vars qw($VERSION @ISA @EXPORT_OK);

$VERSION = '2.00'; # $Date: 2000-10-13 20:19:24 $

require Digest::SHA1;
@ISA=qw(Digest::SHA1);

require Exporter;
*import = *Exporter::imprt;
@EXPORT_OK=qw(sha_version);

sub hexdigest
{
    my $self = shift;
    join(" ", unpack("A8 A8 A8 A8 A8", $self->SUPER::hexdigest(@_)));
}

sub hash        { shift->new->add(@_)->digest;    }
sub hexhash     { shift->new->add(@_)->hexdigest; }
sub sha_version { "SHA-1"; }

1;

__END__

=head1 NAME

SHA - Perl interface to the NIST Secure Hash Algorithm

=head1 SYNOPSIS

    use SHA;

    $version = &SHA::sha_version;

    $context = new SHA;
    $context->reset();

    $context->add(LIST);
    $context->addfile(HANDLE);

    $digest = $context->digest();
    $string = $context->hexdigest();

    $digest = $context->hash($string);
    $string = $context->hexhash($string);

=head1 DESCRIPTION

The C<SHA> module is B<depreciated>.  Use C<Digest::SHA1> instead.

The current C<SHA> module is just a wrapper around the C<Digest::SHA1>
module.  It is provided so that legacy code that rely on the old
interface still work.  This wrapper does not support the old (and
buggy) SHA-0 algorithm.

In addition to the methods provided by C<Digest::SHA1> this module
provide the class methods SHA->hash() and SHA->hexhash() that
basically do the same as the sha1() and sha1_hex() functions provided
C<Digest::SHA1>.

The SHA->hex* methods will insert spaces between groups of 8 hex
characters, while the Digest::SHA1 version of the same methods will not
do this.

=head1 SEE ALSO

L<Digest::SHA1>

=cut

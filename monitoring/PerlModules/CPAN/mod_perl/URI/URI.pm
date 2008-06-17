package Apache::URI;

use mod_perl ();

$VERSION = '1.00';
__PACKAGE__->mod_perl::boot($VERSION);

1;
__END__

=head1 NAME

Apache::URI - URI component parsing and unparsing

=head1 SYNOPSIS

  use Apache::URI ();
  my $uri = $r->parsed_uri;

  my $uri = Apache::URI->parse($r, "http://perl.apache.org/");

=head1 DESCRIPTION

This module provides an interface to the Apache I<util_uri> module and 
the I<uri_components> structure.

=head1 METHODS

=over 4

=item Apache::parsed_uri

Apache will have already parsed the requested uri components, which can
be obtained via the I<parsed_uri> method defined in the I<Apache> class.
This method returns an object blessed into the I<Apache::URI> class.

 my $uri = $r->parsed_uri;

=item parse

This method will parse a URI string into uri components which are stashed 
in the I<Apache::URI> object it returns.

    my $uri = Apache::URI->parse($r, "http://www.foo.com/path/file.html?query+string");

This method is considerably faster than using I<URI::URL>:

    timethese(5000, {
	C => sub { Apache::URI->parse($r, $test_uri) },
	Perl => sub { URI::URL->new($test_uri) },
    });

 Benchmark: timing 5000 iterations of C, Perl...
   C:  1 secs ( 0.62 usr  0.04 sys =  0.66 cpu)
   Perl:  6 secs ( 6.21 usr  0.08 sys =  6.29 cpu) 

=item unparse

This method will join the uri components back into a string version.

 my $string = $uri->unparse;


=item scheme

 my $scheme = $uri->scheme;


=item hostinfo

 my $hostinfo = $uri->hostinfo;


=item user

 my $user = $uri->user;


=item password

 my $password = $uri->password;


=item hostname

 my $hostname = $uri->hostname;

=item port

 my $port = $uri->port;

=item path

 my $path = $uri->path;

=item rpath

Returns the I<path> minus I<path_info>.

 my $path = $uri->rpath;


=item query

 my $query = $uri->query;


=item fragment

 my $fragment = $uri->fragment;


=back

=head1 AUTHOR

Doug MacEachern

=head1 SEE ALSO

perl(1).

=cut

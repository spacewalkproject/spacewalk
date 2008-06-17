#!/usr/bin/perl
# 8.6.1998, Sampo Kellomaki <sampo@iki.fi>
# Get a page via HTTP and print some info about it.
# Demonstrates how to generate password header

use Net::SSLeay  qw(get_https make_headers);
use MIME::Base64;

($user, $pass, $site, $port, $path) = @ARGV;
die "Usage: ./get_authenticated_page.pl user pass www.bacus.com 443 /\n"
    unless $path;

($page, $result, %headers) =
    get_https($site, $port, $path,
	      make_headers('Authorization' =>
			   'Basic ' . MIME::Base64::encode("$user:$pass"))
	      );

print "Result was `$result'\n";
foreach $h (sort keys %headers) {
    print "Header `$h'\tvalue `$headers{$h}'\n";
}

print "=================== Page follows =================\n";
print $page;

__END__

#!/usr/bin/perl
# 8.6.1998, Sampo Kellomaki <sampo@iki.fi>
# 25.3.2002, added certificate display --Sampo
# $Id: get_page_cert.pl,v 1.1.1.1 2003-08-22 19:31:39 cvs Exp $
# Get a page via HTTP and print some info about it.

use Net::SSLeay;

($site, $port, $path) = @ARGV;
die "Usage: ./get_page.pl www.cryptsoft.com 443 /\n" unless $path;

($page, $result, $headers, $server_cert)
    = &Net::SSLeay::get_https3($site, $port, $path);

if (!defined($server_cert) || ($server_cert == 0)) {
    print "Subject Name: undefined, Issuer  Name: undefined\n";
} else {
    print 'Subject Name: '
	. Net::SSLeay::X509_NAME_oneline(
	       Net::SSLeay::X509_get_subject_name($server_cert))
	    . 'Issuer  Name: '
		. Net::SSLeay::X509_NAME_oneline(
		       Net::SSLeay::X509_get_issuer_name($server_cert))
		    . "\n";
}

print "Headers were `$headers'\n";
print "Result was `$result'\n";

print "=================== Page follows =================\n";
print $page;

__END__

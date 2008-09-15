#!/usr/bin/perl
# 8.6.1998, Sampo Kellomaki <sampo@iki.fi>
# Get a page via HTTP and print some info about it.

use Net::SSLeay;

($site, $port, $path) = @ARGV;
die "Usage: ./get_page.pl www.cryptsoft.com 443 /\n" unless $path;

($page, $result, %headers) = &Net::SSLeay::get_https($site, $port, $path);

print "Result was `$result'\n";
foreach $h (sort keys %headers) {
    print "Header `$h'\tvalue `$headers{$h}'\n";
}

print "=================== Page follows =================\n";
print $page;

__END__

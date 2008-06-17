#!/usr/bin/perl
# ssl-inetd-serv.pl - SSL echo server run from inetd
#
# Copyright (c) 1996,1998 Sampo Kellomaki <sampo@iki.fi>. All Rights Reserved.
# Date:   27.6.1996, 19.6.1998
#
# /etc/inetd.conf:
#   ssltst  stream  tcp nowait root /usr/sampo/ssl-inetd-serv.pl ssl-inetd
#
# /etc/services:
#   ssltst		1234/tcp
#

use Net::SSLeay qw(die_now die_if_ssl_error);
Net::SSLeay::load_error_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();

chdir '/usr/sampo' or die "chdir: $!";

$| = 1;  # STDOUT Piping hot!

open LOG, ">>log" or die "Can't open log file $!";
select LOG; $| = 1;
print "ssl-inetd-serv.pl started\n";

print "Creating SSL context...\n";
$ctx = Net::SSLeay::CTX_new or die_now("CTX_new ($ctx) ($!)");
print "Setting private key and certificate...\n";
Net::SSLeay::set_server_cert_and_key($ctx, 'cert.pem', 'key.pem') or die "key";

print "Creating SSL connection (context was '$ctx')...\n";
$ssl = Net::SSLeay::new($ctx) or die_now("new ($ssl) ($!)");

print "Setting fds (ctx $ctx, con $ssl)...\n";
Net::SSLeay::set_rfd($ssl, fileno(STDIN));
Net::SSLeay::set_wfd($ssl, fileno(STDOUT));

print "Entering SSL negotiation phase...\n";
    
Net::SSLeay::accept($ssl);
die_if_ssl_error("accept: $!");

print "Cipher '" . Net::SSLeay::get_cipher($ssl) . "'\n";

#
# Connected. Exchange some data.
#

$got = Net::SSLeay::ssl_read_all($ssl) or die "$$: ssl read failed";
print "Got `$got' (" . length ($got) . " chars)\n";
$got = uc $got;
Net::SSLeay::ssl_write_all($ssl, $got) or die "$$: ssl write failed";

print "Tearing down the connection.\n";

Net::SSLeay::free ($ssl);
Net::SSLeay::CTX_free ($ctx);

close LOG;

__END__

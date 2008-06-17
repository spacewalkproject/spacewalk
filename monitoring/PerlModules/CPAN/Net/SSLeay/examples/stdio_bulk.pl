#!/usr/local/bin/perl
# stdio_bulk.pl - 8.6.1998, Sampo Kellomaki <sampo@iki.fi>
# Send tons of stuff over SSL connected by STDIO pipe.
# This also demonstrates how you can communicate via arbitrary strean, not
# just a TCP one.

use Socket;
use Net::SSLeay qw(die_now die_if_ssl_error);
Net::SSLeay::load_error_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();
#$Net::SSLeay::trace = 2;

($cert_pem, $key_pem, $how_much) = @ARGV;      # Read command line

$ctx = Net::SSLeay::CTX_new() or die_now("Failed to create SSL_CTX $!");
Net::SSLeay::set_server_cert_and_key($ctx, $cert_pem, $key_pem) or die "key";

pipe RS, WC or die "pipe 1 ($!)";
pipe RC, WS or die "pipe 2 ($!)";
select WC; $| = 1;
select WS; $| = 1;
select STDOUT;
$| = 1;

if ($child_pid = fork) {
    print "$$: I'm the server for child $child_pid\n";
    $ssl = Net::SSLeay::new($ctx)     or die_now "$$: new ($ssl) ($!)";
    
    Net::SSLeay::set_rfd($ssl, fileno(RS));
    Net::SSLeay::set_wfd($ssl, fileno(WS));
    
    Net::SSLeay::accept($ssl) and die_if_ssl_error("$$: ssl accept: $!");
    print "$$: Cipher `" . Net::SSLeay::get_cipher($ssl) . "'\n";
    #print "$$: " . Net::SSLeay::dump_peer_certificate($ssl);
    
    $got = Net::SSLeay::ssl_read_all($ssl,$how_much)
	or die "$$: ssl read failed";
    print "$$: got " . length($got) . " bytes\n";
    Net::SSLeay::ssl_write_all($ssl, \$got) or die "$$: ssl write failed";
    $got = '';
    
    Net::SSLeay::free ($ssl);               # Tear down connection
    Net::SSLeay::CTX_free ($ctx);

    wait;  # wait for child to read the stuff

    close WS;
    close RS;
    print "$$: server done ($?).\n"
	. (($? >> 8) ? "ERROR\n" : "OK\n"); 
    exit;
}

print "$$: I'm the child.\n";
sleep 1;  # Give server time to get its act together

$ssl = Net::SSLeay::new($ctx) or die_now("Failed to create SSL $!");
Net::SSLeay::set_rfd($ssl, fileno(RC));
Net::SSLeay::set_wfd($ssl, fileno(WC));
Net::SSLeay::connect($ssl);
die_if_ssl_error("ssl connect");

print "$$: Cipher `" . Net::SSLeay::get_cipher($ssl) . "'\n";
print "$$: " . Net::SSLeay::dump_peer_certificate($ssl);

# Exchange data

$data = 'B' x $how_much;
Net::SSLeay::ssl_write_all($ssl, \$data) or die "$$: ssl write failed";
$got = Net::SSLeay::ssl_read_all($ssl, $how_much)
    or die "$$: ssl read failed";

Net::SSLeay::free ($ssl);               # Tear down connection
Net::SSLeay::CTX_free ($ctx);
close WC;
close RC;
exit ($data ne $got);

__END__

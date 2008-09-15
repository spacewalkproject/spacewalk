#!/usr/local/bin/perl
# cli-cert.pl
# 8.6.1998, originally written as stdio_bulk.pl Sampo Kellomaki <sampo@iki.fi>
# 8.12.2001, adapted to test client certificates
#
# Contact server using client side certificate. Demonstrates how to
# set up the client and how to make the server request the certificate.
# This also demonstrates how you can communicate via arbitrary stream, not
# just a TCP one.
# $Id: cli-cert.pl,v 1.1.1.1 2003-08-22 19:31:39 cvs Exp $

use Socket;
use Net::SSLeay qw(die_now die_if_ssl_error);
$ENV{RND_SEED} = '1234567890123456789012345678901234567890';
Net::SSLeay::randomize();
Net::SSLeay::load_error_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();
#$Net::SSLeay::trace = 2;

($cert_pem, $key_pem, $cert_dir) = @ARGV;      # Read command line
$how_much = 10000;

### Note: the following initialization is common for both client
### and the server. In particular, it is important that VERIFY_PEER
### is sent on the server as well, because otherwise the client
### certificate will never be requested.

$ctx = Net::SSLeay::CTX_new() or die_now("Failed to create SSL_CTX $!");
Net::SSLeay::set_cert_and_key($ctx, $cert_pem, $key_pem) or die "key";
Net::SSLeay::CTX_load_verify_locations($ctx, '', $cert_dir)
    or die_now("CTX load verify loc=`$cert_dir' $!");
Net::SSLeay::CTX_set_verify($ctx, &Net::SSLeay::VERIFY_PEER, \&verify);
die_if_ssl_error('callback: ctx set verify');

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
    print "$$: client cert: " . Net::SSLeay::dump_peer_certificate($ssl);
    
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
print "$$: server cert: " . Net::SSLeay::dump_peer_certificate($ssl);

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

sub verify {
    return 1;
    my ($ok, $x509_store_ctx) = @_;
    print "$$: **** Verify 2 called ($ok)\n";
    my $x = Net::SSLeay::X509_STORE_CTX_get_current_cert($x509_store_ctx);
    if ($x) {
	print "$$: Certificate:\n";
	    print "  Subject Name: "
		. Net::SSLeay::X509_NAME_oneline(
	            Net::SSLeay::X509_get_subject_name($x))
		    . "\n";
	    print "  Issuer Name:  "
		. Net::SSLeay::X509_NAME_oneline(
	            Net::SSLeay::X509_get_issuer_name($x))
		    . "\n";
    }
    $callback_called++;
    return 1;
}

__END__

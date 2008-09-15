#!/usr/local/bin/perl -w
# ephemeral.pl mikem@open.com.au
#
# Test and demonstrate setting ephemeral RSA key

use Net::SSLeay qw(die_now);

Net::SSLeay::randomize();
Net::SSLeay::load_error_strings();
Net::SSLeay::ERR_load_crypto_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();

$ctx = Net::SSLeay::CTX_new() 
    or die_now("Failed to create SSL_CTX $!");

$rsa = &Net::SSLeay::RSA_generate_key(512, 0x10001); # 0x10001 = RSA_F4

die_now("Failed to set ephemeral RSA key $!")
    if (&Net::SSLeay::CTX_set_tmp_rsa($ctx, $rsa) < 0);

print "OK\n";
exit;

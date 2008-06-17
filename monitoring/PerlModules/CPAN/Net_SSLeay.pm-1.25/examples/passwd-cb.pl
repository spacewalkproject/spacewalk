#!/usr/local/bin/perl
# passwd-cb.pl
#
# Check using password callbacks to decrypt private keys
# $Id: passwd-cb.pl,v 1.1.1.1 2003-08-22 19:31:39 cvs Exp $

use Socket;
use Net::SSLeay qw(die_now die_if_ssl_error);
Net::SSLeay::randomize();
Net::SSLeay::load_error_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();

my ($key_pem, $password) = @ARGV;

print "Keyfile: `$key_pem', pw: `$password'\n";
$calls = 0;

sub callback {
    $calls++;
    print "Callback `$password'\n";
    return $password;
}

my $ctx = Net::SSLeay::CTX_new() or die_now("Failed to create SSL_CTX $!");
if (1) {
Net::SSLeay::CTX_set_default_passwd_cb($ctx, \&callback);
}
Net::SSLeay::CTX_use_PrivateKey_file($ctx, $key_pem,
    &Net::SSLeay::FILETYPE_PEM())
    or print "CTX_use_PrivateKey_file failed\n";

print "calls=$calls\n";

#EOF

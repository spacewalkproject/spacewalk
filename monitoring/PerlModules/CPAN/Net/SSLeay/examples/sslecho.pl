#!/usr/bin/perl -w
# sslecho.pl - Echo server using SSL
#
# Copyright (c) 1996,1998 Sampo Kellomaki <sampo@iki.fi>, All Rights Reserved.
# Date:   27.6.1996, 8.6.1998
#
# Usage: ./sslecho.pl *port* *cert.pem* *key.pem*
#
# This server always binds to localhost as this is all that is needed
# for tests.

die "Usage: ./sslecho.pl *port* *cert.pem* *key.pem*\n" unless $#ARGV == 2;
($port, $cert_pem, $key_pem) = @ARGV;
$our_ip = "\x7F\0\0\x01";

$trace = 2;
use Socket;
use Net::SSLeay qw(sslcat die_now die_if_ssl_error);
$Net::SSLeay::trace = 3; # Super verbose debugging

#
# Create the socket and open a connection
#

$our_serv_params = pack ('S n a4 x8', &AF_INET, $port, $our_ip);
socket (S, &AF_INET, &SOCK_STREAM, 0)  or die "socket: $!";
bind (S, $our_serv_params)             or die "bind:   $! (port=$port)";
listen (S, 5)                          or die "listen: $!";

#
# Prepare SSLeay
#

Net::SSLeay::load_error_strings();
Net::SSLeay::ERR_load_crypto_strings();
Net::SSLeay::SSLeay_add_ssl_algorithms();
Net::SSLeay::randomize();

print "sslecho: Creating SSL context...\n" if $trace>1;
$ctx = Net::SSLeay::CTX_new () or die_now("CTX_new ($ctx): $!\n");
print "sslecho: Setting cert and RSA key...\n" if $trace>1;
Net::SSLeay::CTX_set_cipher_list($ctx,'ALL');
Net::SSLeay::set_server_cert_and_key($ctx, $cert_pem, $key_pem) or die "key";

while (1) {
    
    print "sslecho $$: Accepting connections...\n" if $trace>1;
    ($addr = accept (NS, S)) or die "accept: $!";
    $old_out = select (NS); $| = 1; select ($old_out);  # Piping hot!
    
    if ($trace) {
	($af,$client_port,$client_ip) = unpack('S n a4 x8',$addr);
	@inetaddr = unpack('C4',$client_ip);
	print "$af connection from " . join ('.', @inetaddr)
	    . ":$client_port\n" if $trace;;
    }
    
    #
    # Do SSL negotiation stuff
    #

    print "sslecho: Creating SSL session (cxt=`$ctx')...\n" if $trace>1;
    $ssl = Net::SSLeay::new($ctx) or die_now("ssl new ($ssl): $!");

    print "sslecho: Setting fd (ctx $ctx, con $ssl)...\n" if $trace>1;
    Net::SSLeay::set_fd($ssl, fileno(NS));

    print "sslecho: Entering SSL negotiation phase...\n" if $trace>1;
    
    Net::SSLeay::accept($ssl);
    die_if_ssl_error("ssl_echo: ssl accept: ($!)");
    
    print "sslecho: Cipher `" . Net::SSLeay::get_cipher($ssl)
	. "'\n" if $trace;
    
    #
    # Connected. Exchange some data.
    #
    
    $got = Net::SSLeay::ssl_read_all($ssl) or die "$$: ssl read failed";
    print "sslecho $$: got " . length($got) . " bytes\n" if $trace==2;
    print "sslecho: Got `$got' (" . length ($got) . " chars)\n" if $trace>2;
    $got = uc $got;
    Net::SSLeay::ssl_write_all($ssl, $got) or die "$$: ssl write failed";
    $got = '';  # in case it was huge
    
    print "sslecho: Tearing down the connection.\n\n" if $trace>1;
    
    Net::SSLeay::free ($ssl);
    close NS;
}
Net::SSLeay::CTX_free ($ctx);
close S;

__END__

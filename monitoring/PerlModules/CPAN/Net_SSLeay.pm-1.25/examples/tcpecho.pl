#!/usr/bin/perl -w
# tcpecho.pl - Echo server using TCP
#
# Copyright (c) 2003 Sampo Kellomaki <sampo@iki.fi>, All Rights Reserved.
# $Id: tcpecho.pl,v 1.1.1.1 2003-08-22 19:31:39 cvs Exp $
# 17.8.2003, created --Sampo
#
# Usage: ./tcpecho.pl *port*
#
# This server always binds to localhost as this is all that is needed
# for tests.

die "Usage: ./tcpecho.pl *port*\n" unless $#ARGV == 0;
($port) = @ARGV;
$our_ip = "\x7F\0\0\x01";

$trace = 2;
use Socket;
use Net::SSLeay;

#
# Create the socket and open a connection
#

$our_serv_params = pack ('S n a4 x8', &AF_INET, $port, $our_ip);
socket (S, &AF_INET, &SOCK_STREAM, 0)  or die "socket: $!";
bind (S, $our_serv_params)             or die "bind:   $! (port=$port)";
listen (S, 5)                          or die "listen: $!";

#while (1) {     # uncomment to turn off "one shot" behaviour
    print "tcpecho $$: Accepting connections on port $port...\n" if $trace>1;
    ($addr = accept(Net::SSLeay::SSLCAT_S, S)) or die "accept: $!";
    $old_out = select(Net::SSLeay::SSLCAT_S); $| = 1; select ($old_out);  # Piping hot!
    
    if ($trace) {
	($af,$client_port,$client_ip) = unpack('S n a4 x8',$addr);
	@inetaddr = unpack('C4',$client_ip);
	print "$af connection from " . join ('.', @inetaddr)
	    . ":$client_port\n" if $trace;;
    }
    
    #
    # Connected. Exchange some data.
    #
    
    $got = Net::SSLeay::tcp_read_all() or die "$$: read failed";
    print "tcpecho $$: got " . length($got) . " bytes\n" if $trace==2;
    print "tcpecho: Got `$got' (" . length ($got) . " chars)\n" if $trace>2;
    $got = uc $got;
    Net::SSLeay::tcp_write_all($got) or die "$$: write failed";
    $got = '';  # in case it was huge
    
    print "tcpecho: Tearing down the connection.\n\n" if $trace>1;
    close Net::SSLeay::SSLCAT_S;
#}
close S;

__END__

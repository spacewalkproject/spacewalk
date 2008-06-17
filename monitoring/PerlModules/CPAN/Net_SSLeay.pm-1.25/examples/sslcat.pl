#!/usr/bin/perl
# sslcat.pl - Send a message and receive a reply from SSL server.
#
# Copyright (c) 1996-2001 Sampo Kellomaki <sampo@iki.fi>, All Rights Reserved.
# $Id: sslcat.pl,v 1.1.1.1 2003-08-22 19:31:39 cvs Exp $
# Date:   7.6.1996
 
$host = 'localhost' unless $host = shift;
$port = 443         unless $port = shift;
$msg = "get \n\r\n" unless $msg = shift;

$ENV{RND_SEED} = '1234567890123456789012345678901234567890';
print "$host $port $msg\n";
use Net::SSLeay qw(sslcat);
print sslcat($host, $port, $msg);
 
__END__

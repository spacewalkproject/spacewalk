#!/usr/bin/perl
# sslcat.pl - Send a message and receive a reply from server.
#
# Copyright (c) 1996 Neuronio, Lda. All Rights Reserved.
# Author: Sampo Kellomaki <sampo@iki.fi>
# Date:   7.6.1996
 
$host = 'localhost' unless $host = shift;
$port = 443         unless $port = shift;
$msg = "get \n\r\n" unless $msg = shift;

print "$host $port $msg\n";
use Net::SSLeay qw(sslcat);
print sslcat($host, $port, $msg);
 
__END__

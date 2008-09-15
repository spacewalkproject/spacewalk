#!/usr/bin/perl
##
##  loadcacert.cgi -- Load a CA certificate into Communicator
##  Copyright (c) 1998-2000 Ralf S. Engelschall, All Rights Reserved. 
##

$|++;
open(FP, "<ca.crt");
$cert = '';
$cert .= $_ while (<FP>);
close(FP);
$len = length($cert);
print "Content-type: application/x-x509-ca-cert\n";
print "Content-length: $len\n";
print "\n";
print $cert;


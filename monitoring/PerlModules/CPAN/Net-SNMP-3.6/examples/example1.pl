#! /usr/local/bin/perl

# ============================================================================

# $Id: example1.pl,v 1.1.1.1 2001-01-05 23:26:26 dparker Exp $

# Copyright (c) 2000 David M. Town <david.town@marconi.com>.
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use strict;
use vars qw($session $error $response);

use Net::SNMP;

($session, $error) = Net::SNMP->session(
   -hostname  => shift || 'localhost',
   -community => shift || 'public',
   -port      => shift || 161 
);

if (!defined($session)) {
   printf("ERROR: %s.\n", $error);
   exit 1;
}

my $sysUpTime = '1.3.6.1.2.1.1.3.0';

if (!defined($response = $session->get_request($sysUpTime))) {
   printf("ERROR: %s.\n", $session->error());
   $session->close();
   exit 1;
}

printf("sysUpTime for host '%s' is %s\n", 
   $session->hostname(), 
   $response->{$sysUpTime}
);

$session->close();

exit 0;


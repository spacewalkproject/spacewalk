#! /usr/local/bin/perl

eval '(exit $?0)' && eval 'exec /usr/local/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/local/bin/perl $0 $argv:q'
if 0;

# ============================================================================

# $Id: trap.pl,v 1.1.1.1 2001-01-05 23:26:26 dparker Exp $

# Copyright (c) 2000 David M. Town <david.town@marconi.com>.
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use Net::SNMP qw(:ALL);

use strict;
use vars qw($session $error $result @varbind);

($session, $error) = Net::SNMP->session(
   -hostname  => shift || 'localhost',
   -community => shift || 'public',
   -port      => SNMP_TRAP_PORT,      # Need to use port 162 
);

if (!defined($session)) {
   printf("ERROR: %s\n", $error);
   exit 1;
}

## Trap example specifying all values

$result = $session->trap(
   -enterprise   => '1.3.6.1.4.1',
   -agentaddr    => '10.10.1.1',
   -generictrap  => WARM_START,
   -specifictrap => 0,
   -timestamp    => 12363000,
   -varbindlist  => [
      '1.3.6.1.2.1.1.1.0', OCTET_STRING, 'Hub',
      '1.3.6.1.2.1.1.5.0', OCTET_STRING, 'Closet Hub' 
   ]
);

if (!defined($result)) {
   printf("ERROR: %s\n", $session->error());
}


## A second trap example using mainly default values

push(@varbind, '1.3.6.1.2.1.2.2.1.7.0', INTEGER, 1);

$result = $session->trap(-varbindlist  => \@varbind); 

if (!defined($result)) {
   printf("ERROR: %s\n", $session->error());
}

## Change the SNMP version to SNMPv2c to send a snmpV2-trap

$session->version('2c');

$result = $session->snmpv2_trap(
   '1.3.6.1.2.1.1.3.0', TIMETICKS, 600,
   '1.3.6.1.6.3.1.1.4.1.0', OBJECT_IDENTIFIER, '1.3.6.1.4.1.326' 
);

if (!defined($result)) {
   printf("ERROR: %s\n", $session->error());
}

$session->close();

exit 0;

# ============================================================================

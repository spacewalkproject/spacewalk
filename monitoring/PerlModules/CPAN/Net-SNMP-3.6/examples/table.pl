#! /usr/local/bin/perl 

eval '(exit $?0)' && eval 'exec /usr/local/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/local/bin/perl $0 $argv:q'
if 0;

# ============================================================================

# $Id: table.pl,v 1.1.1.1 2001-01-05 23:26:26 dparker Exp $

# Copyright (c) 2000 David M. Town <david.town@marconi.com>.
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use Net::SNMP(qw(snmp_event_loop oid_lex_sort));

use strict;
use vars qw($session $error $response);

# Create the SNMP session 
($session, $error) = Net::SNMP->session(
   -hostname  => $ARGV[0] || 'localhost',
   -community => $ARGV[1] || 'public',
   -port      => $ARGV[2] || 161,
#   -debug     => 1
);

# Was the session created?
if (!defined($session)) {
   printf("ERROR: %s\n", $error);
   exit 1;
}

# iso.org.dod.internet.mgmt.interfaces.ifTable.ifEntry.ifInOctets
my $interfaces = '1.3.6.1.2.1.2.2.1.10';

printf("\n== SNMPv1 blocking get_table(): %s ==\n\n", $interfaces);

if (defined($response = $session->get_table($interfaces))) {
   foreach (oid_lex_sort(keys(%{$response}))) {
      printf("%s => %s\n", $_, $response->{$_});
   }
   print "\n";
} else {
   printf("ERROR: %s\n\n", $session->error());
}

# Switch to SNMPv2c and get_table() will use get-bulk-requests instead
# of get-next-requests.

printf("\n== SNMPv2c blocking get_table(): %s ==\n\n", $interfaces);

$session->version('v2c');

if (defined($response = $session->get_table($interfaces))) {
   foreach (oid_lex_sort(keys(%{$response}))) {
      printf("%s => %s\n", $_, $response->{$_});
   }
   print "\n";
} else {
   printf("ERROR: %s\n\n", $session->error());
}

$session->close;

###
## Now a non-blocking example
###

printf("\n== SNMPv1 non-blocking get_table(): %s ==\n\n", $interfaces); 

# Create the non-blocking SNMP session
($session, $error) = Net::SNMP->session(
   -hostname    => $ARGV[0] || 'localhost',
   -community   => $ARGV[1] || 'public',
   -port        => $ARGV[2] || 161,
   -nonblocking => 0x1,
#   -debug       => 1
);

# Was the session created?
if (!defined($session)) {
   printf("ERROR: %s\n", $error);
   exit 1;
}

if (!defined($session->get_table(-baseoid  => $interfaces,
                                 -callback => [\&_print_results_cb])))
{
   printf("ERROR: %s\n", $session->error());
}

# Start the event loop
snmp_event_loop();

print "\n";

exit 0;


# [private] ------------------------------------------------------------------

sub _print_results_cb
{
   my ($this) = @_;

   if (!defined($this->var_bind_list())) {
      printf("ERROR = %s\n", $this->error());
   } else {
      foreach (oid_lex_sort(keys(%{$this->var_bind_list()}))) {
         printf("%s => %s\n", $_, $this->var_bind_list()->{$_});
      } 
   }
}

# ============================================================================


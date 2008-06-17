#! /usr/local/bin/perl 

eval '(exit $?0)' && eval 'exec /usr/local/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/local/bin/perl $0 $argv:q'
if 0;

# ============================================================================

# $Id: snmpset.pl,v 1.1.1.1 2001-01-05 23:26:26 dparker Exp $

# Copyright (c) 2000 David M. Town <david.town@marconi.com>.
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use Net::SNMP(qw(:asn1 oid_lex_sort));
use Getopt::Std;

use strict;
use vars qw($SCRIPT $VERSION %OPTS);

$SCRIPT  = 'snmpset';
$VERSION = '1.00';

# Validate the command line options
if (!getopts('dm:p:r:t:v:', \%OPTS)) {
   _usage();
}

# Do we have enough information?
if (@ARGV < 5) {
   _usage();
}

# Create the SNMP session
my ($s, $e) = Net::SNMP->session(
   -hostname  => shift,
   -community => shift,
   exists($OPTS{'d'}) ? (-debug   => $OPTS{'d'}) : (),
   exists($OPTS{'m'}) ? (-mtu     => $OPTS{'m'}) : (),
   exists($OPTS{'p'}) ? (-port    => $OPTS{'p'}) : (),
   exists($OPTS{'r'}) ? (-retries => $OPTS{'r'}) : (),
   exists($OPTS{'t'}) ? (-timeout => $OPTS{'t'}) : (),
   exists($OPTS{'v'}) ? (-version => $OPTS{'v'}) : ()
);

# Was the session created?
if (!defined($s)) {
   _exit($e);
}

# Convert the ASN.1 types to the respresentation expected by Net::SNMP
if (_convert_asn1_types(\@ARGV)) {
   _usage();
}

# Send the SNMP message
if (!defined($s->set_request(@ARGV))) {
   _exit($s->error());
}

# Print the results
foreach (oid_lex_sort(keys(%{$s->var_bind_list()}))) {
   printf("%s => %s\n", $_, $s->var_bind_list()->{$_});
}

# Close the session
$s->close();
 
exit 0;


# [private] ------------------------------------------------------------------


sub _convert_asn1_types
{
   my ($argv) = @_;

   my %asn1_types = (
      'a' => IPADDRESS,
      'c' => COUNTER32,
      'C' => COUNTER64,
      'g' => GAUGE32,
      'i' => INTEGER32,
      'o' => OBJECT_IDENTIFIER,
      'p' => OPAQUE,
      's' => OCTET_STRING,
      't' => TIMETICKS,
   );

   if ((ref($argv) ne 'ARRAY') || (scalar(@{$argv}) % 3)) {
      return 1;
   }

   for (my $i = 0; $i < scalar(@{$argv}); $i++) {
      if (!($i % 3)) {
         if (exists($asn1_types{$argv->[$i+1]})) {
            $argv->[$i+1] = $asn1_types{$argv->[$i+1]}; 
         } else {
            _exit("Unknown ASN.1 type [%s]", $argv->[$i+1]);
         }
      }
   }

   0; 
}

sub _exit
{
   printf join('', sprintf("%s: ", $SCRIPT), shift(@_), ".\n"), @_;
   exit 1;
}

sub _usage
{
   printf("%s v%s\n", $SCRIPT, $VERSION);

   printf(
      "Usage: %s [options] <hostname> <community> <oid> <type> <value> [...]\n",
      $SCRIPT
   );
   printf("Options: -d             enable debugging\n");
   printf("         -m <octets>    maximum transport unit\n"); 
   printf("         -p <port>      UDP port\n");
   printf("         -r <attempts>  number of retries\n");
   printf("         -t <secs>      timeout period\n");
   printf("         -v 1|2c        SNMP version\n");

   printf("Valid type values:\n");
   printf("          a - IpAddress         o - OBJECT IDENTIFIER\n");
   printf("          c - Counter           p - Opaque\n");
   printf("          C - Counter64         s - OCTET STRING\n");
   printf("          g - Gauge             t - TimeTicks\n");
   printf("          i - INTEGER\n");

   exit 1;
}

# ============================================================================


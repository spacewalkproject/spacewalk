#! /usr/local/bin/perl 

eval '(exit $?0)' && eval 'exec /usr/local/bin/perl $0 ${1+"$@"}'
&& eval 'exec /usr/local/bin/perl $0 $argv:q'
if 0;

# ============================================================================

# $Id: snmpgetnext.pl,v 1.1.1.1 2001-01-05 23:26:26 dparker Exp $

# Copyright (c) 2000 David M. Town <david.town@marconi.com>.
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use Net::SNMP('oid_lex_sort');
use Getopt::Std;

use strict;
use vars qw($SCRIPT $VERSION %OPTS);

$SCRIPT  = 'snmpgetnext';
$VERSION = '1.00';

# Validate the command line options
if (!getopts('dm:p:r:t:v:', \%OPTS)) {
   _usage();
}

# Do we have enough information?
if (@ARGV < 3) {
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

# Send the SNMP message
if (!defined($s->get_next_request(@ARGV))) {
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

sub _exit
{
   printf join('', sprintf("%s: ", $SCRIPT), shift(@_), ".\n"), @_;
   exit 1;
}

sub _usage
{
   printf("%s v%s\n", $SCRIPT, $VERSION);

   printf("Usage: %s [options] <hostname> <community> <oid> [...]\n", 
      $SCRIPT
   );
   printf("Options: -d             enable debugging\n");
   printf("         -m <octets>    maximum transport unit\n"); 
   printf("         -p <port>      UDP port\n");
   printf("         -r <attempts>  number of retries\n");
   printf("         -t <secs>      timeout period\n");
   printf("         -v 1|2c        SNMP version\n");

   exit 1;
}

# ============================================================================


#! /usr/local/bin/perl

# ============================================================================

# $Id: example3.pl,v 1.1.1.1 2001-01-05 23:26:26 dparker Exp $

# Copyright (c) 2000 David M. Town <david.town@marconi.com>.
# All rights reserved.

# This program is free software; you may redistribute it and/or modify it
# under the same terms as Perl itself.

# ============================================================================

use strict;
use vars qw(@hosts @sessions $polls $last_poll_time $sleep);

use Net::SNMP qw(snmp_event_loop ticks_to_time);

# List of hosts to poll
@hosts = qw(1.1.1.1 1.1.1.2 localhost lamprey);

# Poll interval (in seconds).  This value should be greater than
# the number of retries times the timeout value.
my $interval = 60;

# Maximum number of polls
my $max_polls = 10;

# Create a session for each host
foreach (@hosts) {
   my ($session, $error) = Net::SNMP->session(
      -hostname    => $_,
      -nonblocking => 0x1,   # Create non-blocking objects
      -translate   => [
         -timeticks => 0x0   # Turn off so sysUpTime is numeric
      ]   
   );
   if (!defined($session)) {
      printf("ERROR: %s.\n", $error);
      foreach (@sessions) { $_->[0]->close(); }
      exit 1;
   }

   # Create an array of arrays which contain the new 
   # object and the last sysUpTime.

   push(@sessions, [$session, 0]);
}

my $sysUpTime = '1.3.6.1.2.1.1.3.0';

while (++$polls <= $max_polls) {

   $last_poll_time = time();

   # Queue each of the queries for sysUpTime
   foreach (@sessions) {
      $_->[0]->get_request(
          -varbindlist => [$sysUpTime],
          -callback    => [\&validate_sysUpTime_cb, \$_->[1]]
      );
   }

   # Enter the event loop
   snmp_event_loop();

   # Sleep until the next poll time
   $sleep = $interval - (time() - $last_poll_time);
   if (($sleep < 1) || ($polls >= $max_polls)) { next; }
   sleep($sleep);

   print "\n";
}

# Not necessary, but it is nice to clean up after yourself
foreach (@sessions) { $_->[0]->close(); }

exit 0;

sub validate_sysUpTime_cb
{
   my ($this, $last_uptime) = @_;

   if (!defined($this->var_bind_list())) {
      printf("%-15s  ERROR: %s\n", $this->hostname(), $this->error());
   } else {
      my $uptime = $this->var_bind_list()->{$sysUpTime};
      if ($uptime < ${$last_uptime}) {
         printf("%-15s  WARNING: %s is less than %s\n",
            $this->hostname(), 
            ticks_to_time($uptime), 
            ticks_to_time(${$last_uptime})
         );
      } else {
         printf("%-15s  Ok (%s)\n", 
            $this->hostname(), 
            ticks_to_time($uptime)
         );
      }
      # Store the new sysUpTime
      ${$last_uptime} = $uptime;
   }

   $this->error_status();
}

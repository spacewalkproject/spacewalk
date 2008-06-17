package ProbeMessageCatalog;

use strict;

use base qw(NOCpulse::Probe::MessageCatalog);
use Carp;

use Class::MethodMaker
  static_hash =>
  [qw(
      apache
      config
      http
      logagent
      oracle
      tcp
     )],
  ;

ProbeMessageCatalog->config
  (
   pidfile_or_pattern => 'You must enter either a PID file or a command pattern',
   no_loopback        => 'Please select a non-loopback IP address instead of "%s"',
   ext_no_thresh      => 'You must enter a threshold for number or percent extents used',
   wrong_state        => 'State must be one of OK, WARNING, CRITICAL, or UNKNOWN ' .
                         'instead of "%s"',
  );

ProbeMessageCatalog->http
  (
   timed_out => 'HTTP %s request for "%s" did not complete within %d seconds: %s',
  );

ProbeMessageCatalog->tcp
  (
   expect_string => 'Response does not include',
  );

ProbeMessageCatalog->oracle
  (
   # Table or index extents messages
   ext_count => '%s using %s kbytes, extent count', 
   ext_pct   => '%s using %s kbytes, %s of %s extents,', 

   # Table extents probe
   tab_ext_count_ok  => 'All tables below', 
   tab_ext_pct_ok    => 'All tables below', 

   # Index extents probe
   ind_ext_count_ok  => 'All indexes below', 
   ind_ext_pct_ok    => 'All indexes below', 

   # Tablespace usage probe
   tablespace_pct => '%s using %s of %s KB,', 
   tablespace_ok  => 'All usage below', 
  );

ProbeMessageCatalog->apache
  (
   http_error             => 'HTTP error found at %s: %s',
   no_uptime              => 'Cannot find Apache Server uptime at URL %s',
   no_processes_metrics   => 'Cannot find Max Child and Slot MB metrics at URL %s',
   parse_error            => 'The page found at URL %s is not an Apache Status page',
   no_status_page         => 'No status page found to parse at URL %s',
   authorization_required => 'A valid username and password are required to access the status page at URL %s',
   extended_status_off    => 'Please set the ExtendedStatus directive to On for this check to function correctly',

  );

ProbeMessageCatalog->logagent
  (
   log_not_found => 'Could not find the log file %s',
  );





1;

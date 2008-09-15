package NOCpulse::Probe::MessageCatalog;

use strict;

use Carp;

use Class::MethodMaker
  static_hash =>
  [qw(
      _class_instances
      database
      event
      internal
      oracle
      perfdata
      wql_query
      result
      shell
      snmp
      snmp_translated
      socket
      sqlserver
      status
      threshold
      windows_update
      winsvc
     )],
  new => '_create_singleton',
  ;

sub instance {
    my $class = shift;

    $class or confess "Called without a class reference\n";
    $class->_class_instances($class, $class->_create_singleton())
      unless ($class->_class_instances($class));
    return $class->_class_instances($class);
}

sub message {
    my ($self, $section, $key) = @_;
    $self->can($section) or return undef;
    return $self->$section($key);
}

NOCpulse::Probe::MessageCatalog->status
  (
   user_data_not_found     => '%s: Cannot find match for "%s"',
   internal_data_not_found => '%s: Internal problem: cannot find value. Please contact Red Hat',
   internal_problem        => 'Internal problem executing check. Please contact Red Hat',
   missing_program         => 'Cannot find %s. You must install it for this check to run', 
   command_status          => 'Command failed with status %d',
   command_status_err      => 'Command failed with status %d: %s',
   os_mismatch             => 'Please correct the operating system for %s; ' .
                              'it is configured as "%s", ' .
                              'but the uname -s command returns "%s"',
   unsupported_os          => 'This check cannot be run on %s hosts; please delete this check',
   win_version_mismatch    => 'This check requires at least version %s of the ' .
                              'Command Center Service for Windows. The installed version is %s. ' .
                              'You must upgrade to the latest version to use this check',
  );

NOCpulse::Probe::MessageCatalog->shell
  (
   connect_failed      => 'The RHN Monitoring Daemon (RHNMD) is not responding. ' .
       'Please make sure the daemon is running and the host is accessible from the monitoring scout. ' .
       'Command was: %s',
   connect_failed_err  => 'The RHN Monitoring Daemon (RHNMD) is not responding: %s. ' .
       'Please make sure the daemon is running and the host is accessible from the monitoring scout. ' .
       'Command was: %s',
   lost_connection     => 'Lost connection to the monitored host',
   lost_connection_err => 'Lost connection to the monitored host: %s',
   timed_out           => 'Monitoring command did not complete within %d seconds',
   timed_out_err       => 'Monitoring command did not complete within %d seconds: %s',
   exec_failed         => 'Internal error: Cannot execute %s command',
   not_connected       => 'Internal error: Attempting to work with an unconnected shell',
  );

NOCpulse::Probe::MessageCatalog->winsvc
  (
   connect_failed    => 'The RHN Service is not responding on host %s, port %d. '.
   'Version 2.2.x or above is required. Please install or restart the service.',
   ssl_ctx           => 'Cannot create SSL context',
   ssl_ctx_opt       => 'Cannot set SSL context options',
   ssl_private_key   => 'Problem loading private key',
   ssl_cert          => 'Problem loading certificate',
   ssl_new           => 'Cannot create SSL connection',
   ssl_error_string  => '%s (code %d)',
   ssl_connect       => 'Cannot complete SSL connection: %s',
  );

NOCpulse::Probe::MessageCatalog->perfdata
  (
   no_object => 'Cannot find a performance monitor object named "%s". Please verify that this object is enabled.',
   no_counter => 'Cannot find a performance monitor counter named "%s" for object "%s".',
  );

NOCpulse::Probe::MessageCatalog->wql_query
  (
   not_supported    => 'Cannot find a performance monitor object named "%s". Please verify that this object is enabled.',
   not_present      => 'Cannot find a performance monitor counter named "%s" for object "%s".',
   too_many_results => 'The query returned too many results.  Please uniquely identify the object in the query',
  );
  
NOCpulse::Probe::MessageCatalog->snmp
  (
   no_ip          => "No host name or address provided in 'ip' parameter",
   connect_failed => 'Cannot connect to SNMP agent on host %s, port %d, version %s; '.
                     'verify the port is correct and the agent is running',
   not_connected  => 'Attempting to send without having connected',
   bad_data_type  => 'Unrecognized MIB data type "%s": possible types are %s',
  );

NOCpulse::Probe::MessageCatalog->snmp_translated
  (
   'noSuchObject' =>
   'Cannot find the requested SNMP object (agent may not support it)',
   'noSuchName' =>
   'Cannot find the requested SNMP OID (agent may not support it)',
   'noSuchInstance' =>
   'Cannot find the requested SNMP instance (agent may not support it)',
   'endOfMibView' =>
   'Cannot find the requested SNMP table row (agent may not support it)',
   'No response' =>
   'No response from the SNMP agent; check your community string and SNMP version',
   'Connection refused' =>
   'Cannot communicate with the SNMP agent; check your port number and that the agent is running',
  );

NOCpulse::Probe::MessageCatalog->threshold
  (
   crit_min => '(below critical threshold of %s%s)',
   warn_min => '(below warning threshold of %s%s)',
   warn_max => '(above warning threshold of %s%s)',
   crit_max => '(above critical threshold of %s%s)',
  );

NOCpulse::Probe::MessageCatalog->result
  (
   # Context of the current message (such as disk, interface, etc.) 
   context => '%s:',
   # Label, formatted value, units
   # 'Input rate 2.345 bits/sec'
   detailed                => '%s %s%s',
   need_second_iteration   => '%s requires a second iteration to calculate',
   zero_percentage_divisor => '%s cannot be calculated because the total is zero',
   renotification          => 'Notification #%d for %s',
  );

NOCpulse::Probe::MessageCatalog->event
  (
   timed_out => 'Exceeded global timeout - ending run',
   failed    => 'Internal problem executing check; please contact Red Hat',
  );

NOCpulse::Probe::MessageCatalog->windows_update
  (
   prepare_failed_stderr => 'Cannot prepare automatic update: %s',
   prepare_failed        => 'Cannot prepare automatic update',
   fetch_failed          => 'Cannot fetch upgrade package: %s',
   upgrade_denied        => 'Upgrade cannot be performed: %s',
   upgrade_write_failed  => 'Upgrade package was not properly transferred',
  );

NOCpulse::Probe::MessageCatalog->database
  (
   not_connected     => 'Internal error: Not connected to the database',
   connect_timed_out => 'Failed to log in to database %s on host %s, port %d '.
                        'within %d seconds',
   select_timed_out  => 'Monitoring query did not complete within %d seconds',
   select_failed     => 'Database error %d executing query %s: %s',
   may_need_grant    => 'Cannot complete query; ensure that user "%s" can select from %s',
);

NOCpulse::Probe::MessageCatalog->socket
  (
   bad_proto => 'Protocol must be either TCP or UDP instead of "%s"',
   timed_out => 'Could not read response from %s port %d within %d seconds',
);

NOCpulse::Probe::MessageCatalog->oracle
  (
   not_connected  => 'Internal error: Not connected to Oracle',
   login_failed   => 'Cannot log in to Oracle instance %s as user %s: %s',
   bad_sid        => 'Cannot log in to Oracle instance %s: %s',
   connect_failed => 'Cannot log in to Oracle instance %s on host %s, port %d: %s',
   bad_ora_home   => 'Cannot find SQLPlus in %s/bin. ' .
                     'Please verify that you entered the correct ORACLE_HOME directory.',
  );

NOCpulse::Probe::MessageCatalog->sqlserver
  (
   not_connected     => 'Internal error: Not connected to SQL Server',
   login_failed      => 'Cannot log in to SQL Server database %s as user %s',
   connect_failed    => 'Cannot log in to SQL Server on host %s, port %d as user %s',
   connect_timed_out => 'Failed to log in to SQL Server on host %s, port %d within %d seconds',
   bad_db_name       => 'Cannot find SQL Server database "%s"',
   may_need_grant    => 'Cannot complete query; ensure that user "%s" can select from %s',
   select_failed     => 'SQL Server error %d executing query %s: %s',
   select_timed_out  => 'Monitoring query did not complete within %d seconds',
  );

1;

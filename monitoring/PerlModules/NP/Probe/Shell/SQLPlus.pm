package NOCpulse::Probe::Shell::SQLPlus;

# Shell for running remote SQLPlus sessions

use strict;

use base qw(NOCpulse::Probe::Shell::SSH);

use Class::MethodMaker
  grouped_fields =>
  [
   oracle_fields =>
   [qw(
       ORACLE_HOME
       ora_host
       ora_password
       ora_port
       ora_sid
       ora_user
      )],
  ],
  get_set =>
  [qw(
      _connect_string
      _use_sqlplus_end_marker
     )],
  new_with_init => 'new',
  ;

use constant SETUP_STATEMENTS => 
  [ 
   "set sqlprompt ''",
   "whenever oserror exit failure",
   "whenever sqlerror exit failure",
   "set pagesize 0",
   "set embedded on",
   "set feedback off",
   "set linesize 5000",
   "set heading off",
   "set sqlnumber off",
  ];

sub init {
    my ($self, %args) = @_;

    $self->SUPER::init(%args);

    my %ora_args = $self->_transfer_args(\%args, [$self->oracle_fields]);
    $self->hash_init(%ora_args);

    my $tns = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=" .
      $self->ora_host . ")(PORT=" .
      $self->ora_port . "))(CONNECT_DATA=(SID=" .
      $self->ora_sid . ")))";

    $self->_connect_string($self->ora_user . "/" . $self->ora_password . '@' . $tns);
}

sub connect {
    my $self = shift;
    
    $self->SUPER::connect();
    if ($self->connected) {
        my $ora_home = $self->ORACLE_HOME;

        $self->run("test -d $ora_home -a -x $ora_home/bin/sqlplus");

        if ($self->command_status != 0) {
            my $msg = sprintf($self->_message_catalog->oracle('bad_ora_home'), $ora_home);
            throw NOCpulse::Probe::DbLoginError($msg);
        }

        # From here on, use a SQLPlus prompt as the end marker instead of shell echo.
        $self->_use_sqlplus_end_marker(1);
        $self->run("ORACLE_HOME=$ora_home $ora_home/bin/sqlplus " .
                   '"' . $self->_connect_string . '"');

        if ($self->stderr || $self->command_status != 0) {
            $self->stdout =~ /ERROR:\n: (.*)/;
            my $ora_err = $1 || 'Oracle error ' . $self->command_status;
            $self->disconnect();
            my $msg = sprintf($self->_message_catalog->oracle('login_failed'), 
                              $self->ora_sid, $self->ora_user, $ora_err);
            throw NOCpulse::Probe::DbLoginError($msg);
        } else {
            # Set up SQLPlus to nuke formatting and headers.
            $self->run(join("\n", @{&SETUP_STATEMENTS()})."\n");
        }
    }
    return $self->connected;
}

sub run {
    my ($self, $command) = @_;

    # Make sure SQLPlus command actually runs.
    $command .= ';' unless $command =~ /;$/ || $command !~ /select/i;
    $self->SUPER::run($command);
}

sub end_marker_init {
    my $self = shift;
    $self->SUPER::end_marker_init();
    if ($self->_use_sqlplus_end_marker) {
        # Swap out the marker command to one appropriate for SQLPLUS.
        $self->end_marker_command('prompt ' . $self->end_marker . " 0\n");
        # Change the marker regex to also match ORA errors on stdout.
        my $marker = $self->end_marker;
        $self->end_marker_regex(qr/$marker (-?\d+)\n|ORA-(-?\d+)|SQL>/);
    }
}

1;

__END__

=head1 NAME

  NOCpulse::Probe::Shell::SQLPLus - Runs a remote SQLPlus session

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Overview

Forks an instance of /bin/sh locally and sends it shellscripts to run.

=head2 Construction and initialization

=head2 Methods

=cut

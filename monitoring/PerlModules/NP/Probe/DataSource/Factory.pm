package NOCpulse::Probe::DataSource::Factory;

use strict;
use NOCpulse::Probe::DataSource::InetSocket;
use NOCpulse::Probe::DataSource::SNMP;
use NOCpulse::Probe::DataSource::SQLPlusQuery;
use NOCpulse::Probe::DataSource::SQLServer;
use NOCpulse::Probe::DataSource::UnixCommand;
use NOCpulse::Probe::DataSource::NetworkServiceCommand;
use NOCpulse::Probe::DataSource::CannedUnixCommand;
use NOCpulse::Probe::DataSource::WindowsCommand;
use NOCpulse::Probe::DataSource::CannedWindowsCommand;
use NOCpulse::Probe::DataSource::HTTP;
use NOCpulse::Probe::DataSource::MySQL;

use Class::MethodMaker
  get_set =>
  [qw(
      probe_record
      shell_os_name
     )],
  boolean =>
  [qw(
      canned
     )],
  list =>
  [qw(
      canned_results
      canned_errors
      canned_statuses
     )],
  new_hash_init => 'new',
  ;

sub unix_command {
    my ($self, %args) = @_;

    $args{'probe_record'} ||= $self->probe_record;

    my $source;
    if ($self->canned) {
        $args{canned_results}  = [$self->canned_results];
        $args{canned_errors}   = [$self->canned_errors];
        $args{canned_statuses} = [$self->canned_statuses];
        $args{shell_os_name}   = $self->shell_os_name;
        $source = NOCpulse::Probe::DataSource::CannedUnixCommand->new(%args);
    } else {
        $source = NOCpulse::Probe::DataSource::UnixCommand->new(%args);
    }

    return $source;
}

sub windows_command {
    my ($self, %args) = @_;

    $args{auto_update}  ||= $self->probe_record->auto_update if $self->probe_record;
    $args{probe_record} ||= $self->probe_record;

    my $source;

    if ($self->canned) {
        $args{canned_results} = [$self->canned_results];
        $args{canned_errors} = [$self->canned_errors];
        $source = NOCpulse::Probe::DataSource::CannedWindowsCommand->new(%args);
    } else {
        $source = NOCpulse::Probe::DataSource::WindowsCommand->new(%args);
    }

    return $source;
}

sub snmp {
    my $self = shift;
    my $source = NOCpulse::Probe::DataSource::SNMP->new(@_);
    return $source;
}

sub oracle {
    my ($self, %args) = @_;

    require NOCpulse::Probe::DataSource::Oracle;
    require NOCpulse::Probe::DataSource::CannedOracle;

    my $source;

    if ($self->canned) {
        $args{canned_results} = [$self->canned_results];
        $args{canned_errors} = [$self->canned_errors];
        $source = NOCpulse::Probe::DataSource::CannedOracle->new(%args);
    } else {
        $source = NOCpulse::Probe::DataSource::Oracle->new(%args);
    }

    return $source;
}

sub sqlserver {
    my $self = shift;
    my $source = NOCpulse::Probe::DataSource::SQLServer->new(@_);
    return $source;
}

sub sqlplus_query {
    my $self = shift;
    my $source = NOCpulse::Probe::DataSource::SQLPlusQuery->new(@_);
    return $source;
}

sub inet_socket {
    my $self = shift;
    my $source = NOCpulse::Probe::DataSource::InetSocket->new(@_);
    return $source;
}

sub http {
    my $self = shift;
    my $source = NOCpulse::Probe::DataSource::HTTP->new(@_);
    return $source;
}

sub soap {
    my $self = shift;
    my $source = NOCpulse::Probe::DataSource::SoapLite->new(@_);
    return $source;
}

sub network_service_command {
    my $self = shift;
    my $source = NOCpulse::Probe::DataSource::NetworkServiceCommand->new(@_);
    return $source;
}

sub mysql {
    my $self = shift;
    my $source = NOCpulse::Probe::DataSource::MySQL->new(@_);
    return $source;
}

1;

__END__

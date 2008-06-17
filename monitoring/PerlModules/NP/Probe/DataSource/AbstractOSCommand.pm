package NOCpulse::Probe::DataSource::AbstractOSCommand;

use strict;

use NOCpulse::Probe::Error;

use base qw(NOCpulse::Probe::DataSource::AbstractDataSource);

use Class::MethodMaker
  get_set =>
  [qw(
      shell
     )],
  new_with_init => 'new',
  ;


# Separates datasource-specific arguments from shell arguments.
# Defaults die_on_failure to true.
sub default_datasource_args {
    my ($self, $in_args_ref, $own_args_ref) = @_;

    $self->datasource_arg('die_on_failure',   1, $in_args_ref, $own_args_ref);
    $self->datasource_arg('shell',        undef, $in_args_ref, $own_args_ref);
    $self->datasource_arg('probe_record', undef, $in_args_ref, $own_args_ref);
    $self->datasource_arg('auto_connect',     1, $in_args_ref, $own_args_ref);
}

sub connect {
    my $self = shift;
    unless ($self->connected || ($self->shell && $self->shell->connected)) {
        $self->shell or throw NOCpulse::Probe::InternalError("No shell object defined");
        $self->shell->connect();
    }
}

sub disconnect {
    my $self = shift;
    $self->shell->disconnect() if $self->shell;
}

sub execute {
    my ($self, $script) = @_;

    $self->shell or throw NOCpulse::Probe::InternalError("No shell object defined");

    $self->shell->run($script);

   if ($self->die_on_failure and $self->failed) {
       if ($self->command_status != 0) {
           my $msg;
           if ($self->errors) {
               $msg = sprintf($self->_message_catalog->status('command_status_err'),
                              $self->command_status,
                              $self->errors);
           } else {
               $msg = sprintf($self->_message_catalog->status('command_status'),
                              $self->command_status);
           }
           throw NOCpulse::Probe::DataSource::CommandFailedError($msg);
       } else {
           throw NOCpulse::Probe::DataSource::CommandFailedError($self->errors);
       }
   }

    return $self->results;
}

sub results {
    my $self = shift;
    $self->shell or throw NOCpulse::Probe::InternalError("No shell object defined");
    return $self->shell->stdout;
}

sub errors {
    my $self = shift;
    $self->shell or throw NOCpulse::Probe::InternalError("No shell object defined");
    return $self->shell->stderr;
}

sub timed_out {
    my $self = shift;
    $self->shell or throw NOCpulse::Probe::InternalError("No shell object defined");
    return $self->shell->timed_out;
}

sub failed {
    my $self = shift;
    $self->shell or throw NOCpulse::Probe::InternalError("No shell object defined");
    return $self->shell->failed;
}

sub ran {
    my $self = shift;
    return not $self->failed;
}

sub connected {
    my $self = shift;
    $self->shell or throw NOCpulse::Probe::InternalError("No shell object defined");
    return $self->shell->connected and not $self->shell->connection_broken;
}

sub command_status {
    my $self = shift;
    $self->shell or throw NOCpulse::Probe::InternalError("No shell object defined");
    return $self->shell->command_status;
}

sub exit_code {
    my $self = shift;
    $self->shell or throw NOCpulse::Probe::InternalError("No shell object defined");
    return $self->shell->exit_code;
}

sub shell_os_name {
    my $self = shift;
    $self->shell or throw NOCpulse::Probe::InternalError("No shell object defined");
    return $self->shell->os_name;
}

sub shell_os_version {
    my $self = shift;
    $self->shell or throw NOCpulse::Probe::InternalError("No shell object defined");
    return $self->shell->os_version;
}


1;

__END__

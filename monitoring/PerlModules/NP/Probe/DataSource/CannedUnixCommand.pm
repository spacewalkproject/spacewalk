package NOCpulse::Probe::DataSource::CannedUnixCommand;

use strict;

use Carp;

use base qw(NOCpulse::Probe::DataSource::UnixCommand);

use Class::MethodMaker
  counter =>
  [qw(
      executions
      )],
  get_set =>
  [qw(
      shell_os_name
     )],
  list =>
  [qw(
      canned_results
      canned_errors
      canned_statuses
     )],
  new_hash_init => 'hash_init',
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


sub init {
    my ($self, %args) = @_;

    $args{_message_catalog} = NOCpulse::Probe::MessageCatalog->instance();
    $self->SUPER::init(%args);

    my %own_args = ();
    $own_args{shell_os_name}   = $args{shell_os_name};
    $own_args{canned_results}  = $args{canned_results};
    $own_args{canned_errors}   = $args{canned_errors};
    $own_args{canned_statuses} = $args{canned_statuses};
    $self->hash_init(%own_args);
}

sub connect {
}

sub disconnect {
}

sub execute {
    my $self = shift;

    $self->executions_incr();

    if ($self->command_status && $self->die_on_failure) {
        throw NOCpulse::Probe::DataSource::CommandFailedError('No go');
    }
    return $self->results;
}

sub results {
    my $self = shift;
    return $self->canned_results->[$self->executions - 1] if $self->canned_results;
}

sub errors {
    my $self = shift;
    return $self->canned_errors->[$self->executions - 1] if $self->canned_errors;
}

sub failed {
    my $self = shift;
    return $self->canned_errors ? scalar($self->canned_errors->[$self->executions - 1]) : 0;
}

sub command_status {
    my $self = shift;
    return $self->canned_statuses->[$self->executions - 1] if $self->canned_statuses;
}

sub connected {
    return 1;
}

# Make this a no-op so that canned data doesn't have to include it.
sub ensure_program_installed {
    my ($self, $program_path) = @_;
}

1;

__END__

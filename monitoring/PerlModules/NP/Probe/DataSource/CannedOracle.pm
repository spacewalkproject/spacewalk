package NOCpulse::Probe::DataSource::CannedOracle;

use strict;

use Carp;

use base qw(NOCpulse::Probe::DataSource::Oracle);

use Class::MethodMaker
  counter =>
  [qw(
      executions
      )],
  list =>
  [qw(
      canned_results
      canned_errors
     )],
  new_hash_init => 'hash_init',
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


sub init {
    my ($self, %args) = @_;

    $args{_message_catalog} = NOCpulse::Probe::MessageCatalog->instance();

    $self->hash_init(%args);
}

sub connect {
}

sub disconnect {
}

sub execute {
    my ($self, $sql, $tables_used_arr, $fetch_one, @bind_vars) = @_;

    $self->executions_incr();

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

sub connected {
    return 1;
}

1;

__END__

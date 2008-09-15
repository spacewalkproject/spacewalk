package NOCpulse::Probe::DataSource::CannedWindowsCommand;

use strict;

use Carp;

use base qw(NOCpulse::Probe::DataSource::WindowsCommand);

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

    $self->hash_init(%args);
}

sub connect {
}

sub disconnect {
}

sub execute {
    my $self = shift;

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

1;

__END__

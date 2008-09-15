package NOCpulse::Probe::Utils::test::MockLWPAgent;

use strict;

use Class::MethodMaker
  list =>
  [qw(
      responses
      data
     )],
  counter =>
  [qw(
      request_count
     )],
  ;

use base qw(LWP::UserAgent);


# Interpose on request to return fixed data.
sub request {
    my ($self, $req, $callback) = @_;

    if ($self->data && ref($callback) eq 'CODE') {
        &$callback($self->data->[$self->request_count], undef);
    }
    my $resp = $self->responses->[$self->request_count] if $self->responses;
    $self->request_count_incr();
    return $resp;
}

1;


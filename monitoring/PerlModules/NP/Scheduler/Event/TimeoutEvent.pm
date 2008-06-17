package NOCpulse::Scheduler::Event::TimeoutEvent;

use NOCpulse::Scheduler::Event;
use NOCpulse::Scheduler::Message;
use Data::Dumper;

@ISA=qw(NOCpulse::Scheduler::Event);


##########################################################
# Accessor methods
#
sub event      { shift->_elem('event',      @_); }

#########
sub run {
#########
  my $self  = shift();
  my $event = $self->event();

  return $event->handle_timeout();
}


# Accessor implementation (stolen from LWP::MemberMixin,
# by Martijn Koster and Gisle Aas)
###########
sub _elem {
###########
  my($self, $elem, $val) = @_;
  my $old = $self->{$elem};
  $self->{$elem} = $val if defined $val;
  return $old;
}

1;


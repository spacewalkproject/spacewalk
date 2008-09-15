package NOCpulse::Notif::BroadcastStrategy;             

use NOCpulse::Notif::Strategy;
@ISA= qw(NOCpulse::Notif::Strategy);
use strict;       

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


#########
sub ack {
#########
  my ($self,$send,$alert,$escalator)=@_;

  # Don't need to do anything if the alert is completed
  if ($self->is_completed) {
    $Log->log(9,"Don't need to do anything if the strategy is completed\n");
    return
  }

  #nak, expired, and failed trigger can trigger completed event (important for AllAck) as long as all are sent
  unless ($send->acknowledgement eq 'ack') {
    my $completed=1;
    foreach my $send (@{$self->sends}) {
       $completed = $completed && $send->send_time && $send->is_completed
    }
    if ($completed) {
      $self->set_is_completed
    }
    return
  }

  my $method=$self->ack_method;
  if ($method =~ /OneAck/) {
    #since this is a positive ack, we are done with the alert
    $Log->log(9,"since this is a positive ack, we are done with the alert\n");
    $Log->log(9,"setting is_completed\n");
    foreach my $send (@{$self->sends}) {
       $send->set_is_completed 
    }
    $self->set_is_completed;

  } elsif ($method =~ /AllAck/) {
    foreach my $send (@{$self->sends}) {
      unless ($send->acknowledgement eq 'ack' || $send->is_completed) {
        $Log->log(9,"Found an unacked alert\n");
        return
      }
    }
    $Log->log(9,"All acks are positive, setting is_completed\n");
    $self->set_is_completed;
  }  
}

#################
sub start_sends {
#################
  my $self=shift;

  #Determine whether this send will require an ack and
  #if so, configure to publish ack instructions
  my $val=$self->ack_method =~ /NoAck/ ? 0 : 1;

  foreach my $send (@{$self->sends}) {
    $send->requires_ack($val);
    $send->ack_wait($self->ack_wait);
  }

## TBD -- Is this call necessary????
# # If no acknowledgement is required, we are done
# $self->set_is_completed if $self->ack_method eq 'NoAck';

 return $self->sends;
}

#################
sub printString {
#################
  my $self=shift;
  return 'Broadcast Strategy ' . $self->SUPER::printString;
}

1;

__END__

=head1 NAME

NOCpulse::Notif::BroadcastStrategy - A Strategy that delivers to all its destinations nearly simultaneously.

=head1 SYNOPSIS

# Create an empty broadcast strategy, not very useful
$strategy = NOCpulse::Notif::BroadcastStrategy->new(
  'ack_wait' => $minutes );

# Create a new broadcast strategy for a contact group
$strategy = NOCpulse::Notif::BroadcastStrategy->new_for_group($contact_group);

# Create a new broadcast strategy for a contact method
$strategy = NOCpulse::Notif::BroadcastStrategy->new_for_method($contact_method);

=head1 DESCRIPTION

The C<BroadcastStrategy> object is a type of Strategy that sends notifications to all its member destinations at the same time.

=head1 METHODS

=over 4

=item ack ( $send )

Apply the acknowledgement that is part of the send to this strategy.

=item start_sends ( $escalator )

Return a list of sends to launch initially for this strategy.

=item printString ( )

Return a descriptive string representing this strategy.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::Strategy>
B<NOCpulse::Notif::EscalateStrategy>
B<NOCpulse::Notif::Send>
B<NOCpulse::Notif::Escalator>
B<notif-launcher>
B<notif-escalator>

=cut

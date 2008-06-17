package NOCpulse::Notif::EscalateStrategy;             

@ISA= qw(NOCpulse::Notif::Strategy);
use strict;       
use NOCpulse::Notif::Escalator;
use NOCpulse::Notif::Strategy;

use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [ qw(_position _current_send) ];

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


#########
sub ack {
#########
  my ($self,$send,$alert,$escalator)=@_;

  $Log->log(9,"Acknowledgement is ", $send->acknowledgement, " \n");

  # Don't need to do anything if the alert is completed
  if ($self->is_completed) {
    $Log->log(9,"Alert is completed, returning\n");
    return
  } 

  #nak, expired, and failed trigger the next send
  unless ($send->acknowledgement eq 'ack') {
    $Log->log(9,"Ack is nak or expire\n");
    if ($send == $self->_current_send) {
      $Log->log(9,"Starting next send\n");
      my $next_send = $self->_next_send;
      if ($next_send) {
        $escalator->start_sends($alert,$next_send);
      }
    } 
    my $completed;
    return
 } 

  my $method=$self->ack_method;
  if ($method =~ /OneAck/) {
    #since this is a positive ack, if so we are done with the alert
    $Log->log(9,"ack and one ack required: completed\n");
    $self->set_is_completed;
    return
  }

  if (($method =~ /AllAck/) || ($method =~ /NoAck/)) {
    my $completed=1;
    foreach my $send (@{$self->sends}) {
      $completed=0 unless $send->is_completed
    }
    $Log->log(9,"ack and all ack required, completed is $completed\n");
    unless ($completed) {
      $Log->log(9,"Starting next send\n");
      my $next_send = $self->_next_send;
      if ($next_send) {
        $escalator->start_sends($alert,$next_send);
      }
    }
    $self->is_completed($completed);
  }  
}

################
sub _next_send {
################
  my ($self,$escalator)=@_;

  $Log->log(9,'position is ', $self->_position, "\n");
  $self->_current_send(${$self->sends}[$self->_position]);
  $self->_position($self->_position + 1);
  if (defined($self->_current_send)) {
    $Log->log(9,"issuing next send\n");

    my $send=$self->_current_send;

    #Determine whether this send will require an ack and 
    #if so, configure to publish ack instructions
    $send->set_requires_ack;
    $send->ack_wait($self->ack_wait);

    return $send;
  } 

  $Log->log(9,"nothing left to send\n");
  # Nothing left to send
  $self->set_is_completed;
  return undef;
}

#################
sub start_sends {
#################
  my $self=shift;
  my $escalator=shift;
  my @sends;

  $self->_position(0);
  my $send=$self->_next_send($escalator);
  push (@sends,$send) if $send;
  return @sends;  
}

#################
sub printString {
#################
  my $self=shift;
  return 'Escalate Strategy ' . $self->SUPER::printString;
}

1;

__END__

=head1 NAME

NOCpulse::Notif::EscalateStrategy - A Strategy that treats its list of destinations as an escalation path.

=head1 SYNOPSIS

# Create an empty escalate strategy, not very useful
$strategy = NOCpulse::Notif::EscalateStrategy->new(
  'ack_wait' => $minutes );

# Create a new escalate strategy for a contact group
$strategy = NOCpulse::Notif::EscalateStrategy->new_for_group($contact_group);

# Create a new escalate strategy for a contact method
$strategy = NOCpulse::Notif::EscalateStrategy->new_for_method($contact_method);

=head1 DESCRIPTION

The C<EscalateStrategy> object is a type of Strategy that sends to each member destination in turn, until a positive acknowldegement is received or the end of the member list is reached.  It will wait the specified number of ack_wait mninute for an acknowledgement.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item ack ( $send )

Apply the acknowledgement that is part of the send to this strategy.

=item start_sends ( $escalator )

Return the first sends to launch for this strategy.

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
B<NOCpulse::Notif::RotateFirstEscalateStrategy>
B<NOCpulse::Notif::BroadcastStrategy>
B<NOCpulse::Notif::Send>
B<NOCpulse::Notif::Escalator>
B<notif-launcher>
B<notif-escalator>

=cut

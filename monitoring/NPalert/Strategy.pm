package NOCpulse::Notif::Strategy;             

use strict;
use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [ qw ( ack_wait ack_method alert) ],
  boolean       => 'is_completed',
  abstract      => [ qw ( start_sends ack ) ],
  list          => [ qw ( sends )];

use NOCpulse::Notif::Send;
use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


### CLASS METHODS 

###################
sub new_for_group {
###################
  my ($class,$group,$alert) = @_;

  my $instance = $class->new('ack_wait' => $group->ack_wait);
  $instance->sends_push( map { NOCpulse::Notif::Send->new(
    'destination' => $_,
    'ack_wait'    => $group->ack_wait,
    'alert_id'    => $alert->alert_id) } @{$group->destinations});

  return $instance
}

####################
sub new_for_method {
####################
  my ($class,$method,$alert) = @_;

  my $instance = $class->new();
  $instance->sends_push( NOCpulse::Notif::Send->new(
    'destination' => $method,
    'alert_id'    => $alert->alert_id));

  return $instance
}


### INSTANCE METHODS

###########
sub clear {
###########
  my $self = shift;
  $self->set_is_completed;
  foreach my $send (@{$self->sends}) {
    $send->set_is_completed;
  }
}

################
sub send_named {
################
  my ($self,$send_id) = @_;
  my ($send) = grep { $_->send_id eq $send_id } $self->sends;
  return $send;
}

##########
sub show {
##########
  my $self = shift;
  my @array;
  push(@array,$self->printString);
   foreach my $send (@{$self->sends}) {
     push(@array,$send->show) if $send->send_time;
   }
  return join("\n\t",@array);
}

#################
sub printString {
#################
  my $self = shift;
  return $self->ack_method . ':';
}

1;


__END__

=head1 NAME

NOCpulse::Notif::Strategy - An abstract base class defining a methodology for delivering alerts to a group of destinations.

=head1 DESCRIPTION

The C<Strategy> object defines a methodology for delivering alerts to a list of Destinations.  It also defines when an Alert is completed and no more Sends need to be issued.

=head1 CLASS METHODS

=over 4

=item new ( )

Create a new empty strategy.

=item new_for_group ( $contact_group )

Create a strategy for the specified contact group.

=item new_for_method ( $contact_method )

Create a strategy for the specified contact method.

=back

=head1 METHODS

=over 4

=item ack ( $send, $escalator )

Abstract method to be defined by subclass.  Process the acknowledgement given by the send, using the given escalator.

=item ack_method ( ['AllAck','NoAck','OneAck'] )

Get or set the acknowledgement methodology associated with this strategy.

=item ack_wait ( [$minutes] )

Get or set the time, in minutes, to wait for an acknowledgement between issuing sends in the case of an escalation.

=item alert ( [$alert] )

Get or set the alert associated to be sent by this strategy.

=item clear ( )

Clear all sends associated with this strategy.

=item is_completed ( [0|1] )

Get or set the flag associated with this strategy, denoting whether or not the alert is considered completed.

=item printString ( )

Return a string reprsenting this strategy.

=item send_named  ( $send_id )

Return the send associated with this strategy with the given send id.

=item sends ( )

Return the list of sends associated with this strategy.  (Treat as a Class::MethodMaker type list.)

=item show ( )

Return a string describing this Strategy for use in command line notification tools.

=item start_sends ( )

Abstract method to be defined by subclass.  Return a list containing the first send(s) to launch for this strategy.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::Alert>
B<NOCpulse::Notif::BroadcastStrategy>
B<NOCpulse::Notif::EscalateStrategy>
B<NOCpulse::Notif::Escalator>

=cut

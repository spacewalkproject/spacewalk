package NOCpulse::Notif::ContactGroup;             

@ISA = qw( NOCpulse::Notif::Destination );       
use strict;
use NOCpulse::Notif::Destination;
use Class::MethodMaker
  new_hash_init => 'new',
  key_attrib    => 'recid',
  get_set       => [qw ( strategy ack_wait ack_method _first_destination customer_id)], 
  list          => [qw( destinations )];

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

############################
sub new_strategy_for_alert {
############################
  my ($self,$alert)=@_;
  my $strategy= $self->strategy->new_for_group($self,$alert);
  $strategy->alert($alert);
  my $method=defined($self->ack_method) ? $self->ack_method : 'NoAck';
  $strategy->ack_method($method);
  return $strategy;
}

#####################
sub add_destination {
#####################
  my ($self,$destination)=@_;
  $self->push_destinations($destination);
}

##############################
sub rotate_first_destination {
##############################
# Rotate the first destination and return the newly ordered list
  my $self=shift();

  my $size=@{$self->destinations};
  my $max=$size-1;
  my $index=$self->_first_destination;

  $Log->log(9,"size: $size, max: $max, index: $index\n");

  my @return_list;
  if ($index == 0) {
    $Log->log(9,"index is zero\n");
    @return_list=@{$self->destinations};          
  } elsif ($index == $max) {
    $Log->log(9,"index is max\n");
    @return_list=@{$self->destinations};          
    my $item=pop(@return_list);
    unshift(@return_list,$item);
  } else {
    $Log->log(9,"index is inbetween\n");
    my @last =@{$self->destinations}[0..$index-1];
    my @first=@{$self->destinations}[$index..$max];
    push(@return_list,@first,@last);
  } 
  $self->_first_destination($self->_first_destination+1);
  $self->_first_destination(0) if $self->_first_destination > $max;

  $Log->log(9,"first destination is ", $self->_first_destination,"\n");
  $Log->dump(9,"return list:\n",@return_list,"\n");
  return @return_list
}

#################
sub designation {
#################
  return 'g'
}

1;

__END__

=head1 NAME

NOCpulse::Notif::ContactGroup - A list of Destinations that can receive notifications.

=head1 SYNOPSIS

# Create a new empty contact group
$group=NOCpulse::Notif::ContactGroup->new(
  'ack_wait'    => $number,
  'ack_method'  => $method,
  'customer_id' => $customer_id);

# Add a destination to the group
$group->add_destination($dest);

# Create a strategy for this group
$strategy=$group->new_strategy_for_alert($alert);

# Rotate the first destination of the group and return the list with the new first member
@destinations=$group->rotate_first_destination;

=head1 DESCRIPTION

The C<ContactGroup> object is a list of Destinations, ContactMethods or ContactGroups.  It contains a Strategy which determines the timing and order of notification delivery.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item ack_method ( ['AllAck','NoAck','OneAck'] )

Get or set the amount of acknowledgements from the group needed to consider an alert completed.

=item ack_wait ( [$minutes] )

Get or set the number of minutes to wait for a group member's acknowledgement.

=item add_destination ( $destination )

Add a new destination, contact method or group,  to the end of the group.

=item customer_id ( [$number] )

Get or set the unique identifier of the customer to which this group belongs.

=item designation ( )

Return the character designation for this type of destination, for use in printString.

=item destinations ( )

Return the list of contact groups and contact methods that belong to this contact group.  (Treat as Class::MethodMaker type list.)

=item new_strategy_for_alert ( $alert )

Create and return a new Strategy object of the appropriate type for the given alert.

=item recid ( [$number] )

Get or set the unique identifier for this object in the database.

=item rotate_first_destination ( )

Rotate the destination list to the next new first destination and return the group list.

=item strategy ( [$class] )

Get or set the name of the Strategy subclass for this group.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-01-22 23:36:03 $

=head1 SEE ALSO

B<NOCpulse::Notif::Destination>
B<NOCpulse::Notif::ContactMethod>
B<NOCpulse::Notif::Strategy>
B<NOCpulse::Notif::Alert>
B<NOCpulse::Notif::Escalator>
B<notifserver.pl>

=cut

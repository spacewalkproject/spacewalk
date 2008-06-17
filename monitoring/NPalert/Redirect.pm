package NOCpulse::Notif::Redirect;             

use strict;
use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [ qw( expiration start_date last_update_date redirect_type
                         description last_update_user contact_id reason
                         customer_id recurring recurring_frequency)],
  key_attrib    => 'recid',
  list          => [ qw ( criteria targets )];

use NOCpulse::Log::Logger;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);
$Log->show_method(0);


##############
sub redirect {
##############
  my ($self,$alert)=@_;

  #Ugly hack for missing data 
  unless ($alert->probeType) {
    $alert->probeType('HostProbe') if $alert->type eq 'host';
    $alert->probeType('ServiceProbe') if $alert->type eq 'service';
    $alert->probeType('LongLegs') if $alert->type eq 'longlegs';
  }

  return 0 unless $self->matches($alert);
  @{$alert->originalDestinations()} = ();
  $alert->newDestinations_push($self->targets());
  return 1
}

#############
sub matches {
#############
  my ($self,$alert)=@_;
  $Log->log(3,"applying redirect " , $self->recid);

  # Check the start_time and expiration

  if (  ($alert->current_time < $self->start_date) 
     || ($alert->current_time >= $self->expiration)) {
    return 0
  }

  my ($match_param, $last_param, $match);
  my $last_match=0;

  my $criteria=$self->criteria();
  foreach(@$criteria) {

    $match_param=$_->match_param();

    # if it's not the same parameter as last time,
    # check the results for the last parameter.
    # if that match was not successful, we're done.

    if (defined ($last_param) && ($last_param ne $match_param)) {            
      if (!$last_match) {
        last;
      }
    }

    # if there are multiple entries for the same match parameter
    # and we already have a positive match, don't bother checking
    # for an additional match for this same parameter.

    if ($last_param eq $match_param) {
      if ($last_match) {
        next;
      }
    }    

    $match=$_->matches($alert);

    $last_match = $match + 0;
    $last_param = $match_param;   
  }

  $Log->log(3,": $last_match\n");
  $Log->log(1, $alert->printString, " Redirected via #", $self->recid, " ", $alert->ticket_id,"\n") if $last_match;
  return $last_match;
}

###################
sub add_criterion {
########$##########
  my $self=shift();
  my $criterion=shift();
  $self->criteria_push($criterion);
}

################
sub add_target {
################
  my $self=shift();
  my $target=shift();
  $self->targets_push($target);
}
1;

__END__

=head1 NAME

NOCpulse::Notif::Redirect - An type of advanced notification that replaces its recipient destinations.

=head1 SYNOPSIS

# Create a new, empty redirect
$redirect=NOCpulse::Notif::Redirect->new(
  'start_date' => $timestamp1
  'expiration' => $timestamp2,
  'description' => 'blah',
  'reason'      => 'some long-winded explanation',
  'customer_id' => $customer_id,
  'contact_id'  => $contact_id );

# Add a redirect criterion
$redirect->add_criterion($redirect_criterion);

# Add a new recipient
$redirect->add_target($destination);

=head1 DESCRIPTION

The C<Redirect> is a type of advanced notification which removes the original recipient destinations of an alert and adds additional recipients to the list.  This class also defines base class required behavior for all advanced notifications.  

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item add_criterion ( $redirect_criterion )

Add a new redirect criterion to the list.

=item add_target ( $destination )
Add a new supplemental destination to the list.

=item contact_id ( [$number] )

Get or set the unique identifier, from the database, representing the contact who is responsible for this redirect.

=item criteria ( )

Return the list, composed of RedirectCrtierion, which define this redirect.  (Treat as Class::MethodMaker type list.)

=item customer_id ( [$number] )

Get or set the unique identifier, from the database, representing the customer to whom this redirect belongs and should be applied.

=item description ( [$string] )

Get or set the string describing this redirect.

=item expiration ( [$timestamp] )

Get or set the timestamp denoting the time that this redirect no longer applies.

=item last_update_date ( [$timestamp] )

Get or set the timestamp representing the time this object was last inserted or updated in the database.

=item last_update_user ( [$string] )

Get or set the userid of that who last inserted or updated this object in the database.

=item matches ( $alert )

Return a true value if this redirect applies, according to its redirect criteria, to the given alert.

=item reason ( [$string] )

Get or set the string explaning why this redirect was created.

=item recid ( [$number] )

Get or set the unique id assigned to this object in the database.

=item recurring ( [0|1] )

Get or set whether this redirect is a regularly recurring event.

=item recurring_frequency ( ['daily','weekly','monthly'] )

Get or set how often this redirect is to recur, informational purposes only.

=item redirect ( $alert )

Apply this redirect to the given alert.

=item redirect_type ( [$string] ) 

Get or set what type of redirect this is (BLACKHOLE, METOO, AUTOACK, REDIR).

=item start_date ( [$timestamp] )

Get or set the timestamp denoting the time that redirect begins to apply.

=item targets ( )

Return the list, composed of Destinations, to whom supplemental notification should be delivered if this redirect applies to an alert.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2005-06-03 20:05:54 $

=head1 SEE ALSO

B<NOCpulse::Notif::AutoAckRedirect>
B<NOCpulse::Notif::BlackholeRedirect>
B<NOCpulse::Notif::MeTooRedirect>
B<NOCpulse::Notif::Alert>
B<NOCpulse::Notif::Escalator>
B<$NOTIFICATION_HOME/scripts/notifserver.pl>

=cut

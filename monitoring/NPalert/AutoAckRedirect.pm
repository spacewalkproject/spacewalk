package NOCpulse::Notif::AutoAckRedirect;             

@ISA = qw(NOCpulse::Notif::Redirect);  
use strict;
use NOCpulse::Notif::Redirect;

my $Log = NOCpulse::Log::Logger->new('redirects');


##############
sub redirect {
##############
  my ($self,$alert)=@_;

  return unless $self->matches($alert);
  $alert->set_auto_ack;
}

1;

__END__

=head1 NAME

NOCpulse::Notif::AutoAckRedirect - A type of advanced notification that automatically acknowledges all sends as they are issued.

=head1 SYNOPSIS

# Create a new, empty redirect
$redirect=NOCpulse::Notif::AutoAckRedirect->new(
  'start_date' => $timestamp1
  'expiration' => $timestamp2,
  'description' => 'blah',
  'reason'      => 'some long-winded explanation',
  'customer_id' => $customer_id,
  'contact_id'  => $contact_id );

# Add a redirect criterion
$redirect->add_criterion($redirect_criterion);

# Add a new recipient destination
$redirect->add_target($destination);

=head1 DESCRIPTION

The C<AutoAckRedirect> object is a type of redirect that automatically acknowledges all sends as they are issued.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item redirect ( $alert )

Checks to see if the redirect applies to the given alert and if so, sets the alert up for auto acknowledgement.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::Redirect>
B<NOCpulse::Notif::Alert>
B<NOCpulse::Notif::Escalator>
B<notifserver.pl>

=cut

package NOCpulse::Notif::PagerContactMethod;             

@ISA = qw(NOCpulse::Notif::EmailContactMethod);       

use strict;
use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [qw(pager_max_message_length)],
  boolean       => [qw(split_long_messages)];

use NOCpulse::Notif::EmailContactMethod;
use NOCpulse::Notif::NotifMailer;
use NOCpulse::Log::LogManager;

use Data::Dumper;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


#############
sub deliver {
#############
  my ($self,$alert,$db,$smtp)=@_;

  my $subject=$alert->fmt_subject();
  my $body=$alert->fmt_message();

  my @mailers;

  if ($self->pager_max_message_length) {
    $Log->log(9,"Max message length is ", $self->pager_max_message_length, "\n");

    if ($self->split_long_messages) {
    # Break this up
      $Log->log(9,"Splitting up long messages\n");
      my $first_message     = substr($body,0,$self->pager_max_message_length);
      my $remaining_message = substr($body,length($first_message));
      my $mailer = NOCpulse::Notif::NotifMailer->new(
        subject => $subject,
        body    => $first_message);
      $mailer->addressees_push($self->email);
      push(@mailers,$mailer);
      my $piece_count=1;
      while ($remaining_message) {
        $Log->log(9,"A piece of the message remains\n");
        $piece_count++;
        $subject='[' . $alert->send_id . "/$piece_count]\n";
        my $next_message=substr($remaining_message,0,$self->pager_max_message_length);
        my $mailer2 = NOCpulse::Notif::NotifMailer->new(
          subject => $subject,
          body    => $next_message);
        $mailer2->addressees_push($self->email);
        push(@mailers,$mailer2);
        $remaining_message=substr($remaining_message,length($next_message));
        $Log->log(9,"*** next_message; $next_message\n");
        $Log->log(9,"*** remaining_message; $remaining_message\n");
      }
    } else {
    # Send as one message
      $Log->log(9,"Sending as one shortened message\n");
      $body=substr($body,0,$self->pager_max_message_length);
      my $mailer3 = NOCpulse::Notif::NotifMailer->new(
        subject => $subject,
        body    => $body);
      $mailer3->addressees_push($self->email);
      push(@mailers,$mailer3);
    }
  } else {
  # No restrictions on length
    $Log->log(9,"Sending without restrictions\n");
    my $mailer4 = NOCpulse::Notif::NotifMailer->new(
      subject => $subject,
      body    => $body);
    $mailer4->addressees_push($self->email);
    push(@mailers,$mailer4);
  }

  $Log->log(1,"Mailers: ",&Dumper(@mailers),"\n");

  # Do the sending
  $Log->log(9,"Executing the sends\n");
  foreach (@mailers) {
    my $rv;
    $rv = $_->send_via($smtp);
    if ($rv) {
      $Log->log(1,"BIG TIME SEND ERROR: $rv\n");
    }
  }
  $Log->log(9,"All Done\n");
}

1;

__END__


=head1 NAME

NOCpulse::Notif::PagerContactMethod - A ContactMethod that delivers its alert notification via pager.

=head1 SYNOPSIS

  # Create a new pager contact method
  $method=NOCpulse::Notif::PagerContactMethod->new(
    'email'                    => 'nobody@nocpulse.com',
    'schedule'                 => $schedule,
    'message_format'           => $message_format,
    'pager_max_message_length' => 200,
    'split_long_messages'      => 1 );

  # Create a new strategy for this alert
  $strategy=$method->new_strategy_for_alert->($alert);

  # Create the command that will send a specified alert to this destination
  $cmd=$method->send($alert);

=head1 DESCRIPTION

The C<PagerContactMethod> object is a type of L<ContactMethod> that sends notifications to a pager via email using SMTP.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item deliver ( $alert, $db, $smtp )

Launch a send to this contact method.


=item pager_max_message_length ( $number )

Get or set the maximum number of character to send to the destination, including subject and message body.  Messages will be truncated to this length.

=item split_long_messages ( [0|1] )

Get or set a flag to denote whether to break messages with a longer than pager_max_message_length into multiple messages with separate delivery.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::ContactMethod>
B<NOCpulse::Notif::EmailContactMethod>
B<NOCpulse::Notif::Alert>
B<NOCpulse::Notif::Schedule>
B<NOCpulse::Notif::MessageFormat>
B<notifier>

=cut

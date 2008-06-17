package NOCpulse::Notif::EmailContactMethod;

@ISA = qw(NOCpulse::Notif::ContactMethod);

use strict;
use Config::IniFiles;
use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [qw(email)];

use NOCpulse::Notif::ContactMethod;
use NOCpulse::Notif::NotifMailer;
use NOCpulse::Log::LogManager;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

#############
sub deliver {
#############
  my ($self, $alert, $db, $smtp) = @_;

  my $subject = $alert->fmt_subject();
  my $body    = $alert->fmt_message();

  # Remove any line feeds in the subject line
  $subject =~ s/\n//s;

  # Compose and send a mail message based on the supplied arguments.
  my $mailer =
    NOCpulse::Notif::NotifMailer->new(subject => $subject,
                                      body    => $body);
  $mailer->addressees_push($self->email);

  return $mailer->send_via($smtp);
} ## end sub deliver

#################
sub printString {
#################
  my $self = shift;
  return $self->SUPER::printString . ' (' . $self->email() . ')';
}

1;

__END__


=head1 NAME

NOCpulse::Notif::EmailContactMethod - A ContactMethod that delivers its alert notification via email.

=head1 SYNOPSIS

  # Create a new email contact method
  $method=NOCpulse::Notif::EmailContactMethod->new(
    'email'          => 'nobody@nocpulse.com',
    'schedule'       => $schedule,
    'message_format' => $message_format );

  # Create a new strategy for this alert
  $strategy=$method->new_strategy_for_alert->($alert);

  # Do a send of an alert
  my $db=NOCpulse::Notif::AlertDB->new;
  $db->connect;
  my $smtp=Net::SMTP->new();

  my $alert=NOCpulse::Notif::Alert->from_file($filename);
  my @sends=$strategy->sends;

  foreach my $send (@sends) {
    $method->send($send,$alert,$db,$smtp);
  }

=head1 DESCRIPTION

The C<EmailContactMethod> object is a type of ContactMethod that sends notifications via email using SMTP.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item deliver ( $alert, $db, $smtp )

Launch a send to this contact method.

=item email ( $email )

Get or set the email address to which to deliver a notification for this contact method.

=item printString ( )

Return a text string representing this object.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2005-02-15 23:59:53 $

=head1 SEE ALSO

B<NOCpulse::Notif::ContactMethod>
B<NOCpulse::Notif::Alert>
B<NOCpulse::Notif::Schedule>
B<NOCpulse::Notif::MessageFormat>
B<notifier>

=cut

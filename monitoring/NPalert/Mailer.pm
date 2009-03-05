package NOCpulse::Notif::Mailer;             

use strict;
use Mail::Address;
use NOCpulse::Log::Logger;


use Class::MethodMaker
  new_hash_init => 'new',
  get_set       => [qw(subject body replyaddr from precedence priority
                      _capture)],
  list          => 'addressees';

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub send_via {
  my ($self,$smtp) = @_;
  my $code = 0;   # smtp return code

  # Validate the recipients locally
  $self->check_addressees($smtp);
  unless ($self->addressees_count) {
    $Log->log(9, "No recipients found\n"); 
    return $code;
  }

  # Redirect stderr for the purpose of logging smtp transactions
  $self->_start_send($smtp);

  # Check the validity of the sender
  $Log->log(9,"CALLING mail()\n");        
  my($address) = Mail::Address->parse($self->replyaddr);
  my $efrom = $address->format() if (defined($address));
  my $eaddr = $address->address() if (defined($address));

  if (!$smtp->mail($eaddr)) {
    $code=$smtp->code();
    $@="Rejected $eaddr as valid sender\n";
    $Log->log(1, "Rejected $eaddr as valid sender\n"); 
    $self->_end_send($smtp);
    return $code || 1;
  }

  # Prepare the message for sending
  my @addressees = map { Mail::Address->parse($_) } @{$self->addressees};
  my $eto      = join (', ',map { $_->format() } @addressees);
  $eto =~ s/\s//g;
  my $message  = "To: $eto\n";
  $message    .= "From: ". $efrom . "\n";
  $message    .= "Precedence: " . $self->precedence . "\n" if $self->precedence;
  $message    .= "Priority: " . $self->priority . "\n" if $self->priority;
  $message    .= "Subject: "  . $self->subject . "\n" if ($self->subject =~ /\S/);
  $message    .= "\n";
  $message    .= $self->body . "\n";
  
  $Log->log(10,"\$---message is---\n$message\n---end of message---\n");

  # Set the recipients
  if (!$smtp->recipient(map { $_->address() } @addressees)) {
    $code=$smtp->code();
    $Log->log(1, "Rejected addressees as valid recipients.  Server return code $code\n"); 
    $@="Rejected addressees as valid recipients, code=$code";
    $self->_end_send($smtp);
    return $code || 1;
  }

  # Start the transmission
  $Log->log(9, "CALLING data()\n");
  if (!$smtp->data()) {
    $code=$smtp->code();
    $Log->log(1, "Cannot start transmission.  Server return code $code\n"); 
    $@="Cannot start transmission, code=$code";
    $self->_end_send($smtp);
    return $code || 1;
  }

  # Send the message
  $Log->log(9, "CALLING datasend()\n");
  if (!$smtp->datasend($message)) {
    $code=$smtp->code();
    $Log->log(1, "Cannot datasend the message.  Server return code $code\n");
    $@="Cannot datasend the message, code=$code";
    $self->_end_send($smtp);
    return $code || 1;
  }
  
  # End this transmission
  $Log->log(9,"CALLING dataend()\n");
  if (!$smtp->dataend()) 
  {
    $code=$smtp->code();
    $Log->log(1, "dataend failed.  Server returned $code\n"); 
    $@="dataend failed, code=$code";
    $self->_end_send($smtp);
    return $code || 1;
  }

  # Success
  $self->_end_send($smtp);
  return $code
}

sub check_addressees {
  my ($self,$smtp)=@_;
  #No-op
}

# hook called on beggining of smtp transaction
sub _start_send {
  my ($self,$smtp)=@_;
  # no-op
}

# hook called on end of smtp transaction - success or failed
sub _end_send {
  my ($self,$smtp,$code)=@_;

  $smtp->reset;
}

1;

__END__

=head1 NAME

NOCpulse::Notif::Mailer - An object that allows you to send an email via SMTP.

=head1 SYNOPSIS

  # Create a new email
  $email = NOCpulse::Notif::Mailer->new(
    'subject'   => 'This is the subject',
    'body'      => 'This is the main message of the email.',
    'replyaddr' => 'kja@redhat.com');

  # Add a recipient
  $email->addresses_push('nobody@nocpulse.com');

  # Send the email
  my $smtp=Net::SMTP->new();
  $email->send_via($smtp);
  $smtp->quit();

=head1 DESCRIPTION

The C<Mailer> object creates an interface with an SMTP server to send an email.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item addressees ( )

Return the list of recipients for the email.  (Treat as a Class::MethodMaker type list.)

=item body ( [$string] )

Get or set the main body of the email.

=item check_addressees ( )

Prune the addressees of unwanted addresses, in this case, a no-op.

=item from ( [$from] )

Get or set who this email is from.

=item precedence ( [$string] )

Get or set the precedence of this email.  See RFC 2076.

=item priority ( [$string] )

Get or set the priority of this email.  See RFC 2076.

=item replyaddr ( [$address] )

Get or set the "from" field for this email.

=item subject ( [$string] )

Get or set the main subject of the email.

=item send_via ( $smtp )

Deliver the mail, returning true on failure and false on success.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<RFC-821>
B<RFC-2076>
B<NOCpulse::Notif::Acknowledgement>
B<NOCpulse::Notif::NotifMailer>
B<notifier>

=cut

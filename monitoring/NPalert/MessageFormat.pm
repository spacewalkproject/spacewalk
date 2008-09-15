package NOCpulse::Notif::MessageFormat;

use strict;

use Class::MethodMaker
  new_with_init => 'new',
  new_hash_init => 'hash_init',
  key_attrib    => 'recid',
  get_set       => [
  qw( customer_id description max_subject_length max_body_length
    subject_format body_format reply_format )
  ];

use POSIX qw(strftime);
use NOCpulse::Log::LogManager;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

# Defaults
use constant INSTANCE_DEFAULTS => (
                                   max_subject_length => 80,
                                   max_body_length    => 1920
                                  );

# CLASS METHODS

#############
sub default {
#############
  my $class = shift();

  my $instance = $class->new(
    customer_id    => 1,
    description    => 'global default',
    subject_format =>
'^[probe state]: ^[hostname]: ^[probe description] at ^[timestamp:"%H:%M %Z"]',
    body_format =>
'This is Red Hat Command Center notification ^[alert id].\n\nTime:      ^[timestamp:"%a %b %d, %H:%M:%S %Z"]\nState:     ^[probe state]\nHost:      ^[hostname] (^[host IP])\nCheck:     ^[probe description]\nMessage:     ^[probe output]\nRun from:  ^[satellite description]',
    reply_format =>
'\n\nTo acknowledge, reply to this message within ^[ack wait] minutes with this subject line:\n     ACK ^[alert id]\n\nTo immediately escalate, reply to this message with this subject line:\n     NACK ^[alert id]'
  );

  return $instance;
} ## end sub default

# INSTANCE METHODS

##########
sub init {
##########
  my $self = shift;

  # Set defaults for values that weren't supplied to the constructor
  my %values = (INSTANCE_DEFAULTS, @_);
  $self->hash_init(%values);
  return;
}

####################
sub format_message {
####################

  my ($self, $alert, $olson_tz_id) = @_;
  $olson_tz_id = 'GMT' unless $olson_tz_id;

  #Convert to standard for differences between host/service probes

  my $id = $alert->probeType eq 'HostProbe' ? 'hostProbeId' : 'probeId';

  my $premunge_map = {

    # macro name             => name in alert hash
    'ack wait'               => 'ack_wait',
    'ack address'            => 'replyaddr',
    'customer ID'            => 'customerId',
    'contact group ID'       => 'groupId',
    'contact group name'     => 'groupName',
    'from address'           => 'replyaddr',
    'notification server ID' => 'server_id',
    'satellite ID'           => 'clusterId',
    'scout ID'               => 'clusterId',
    'satellite description'  => 'clusterDesc',
    'scout description'      => 'clusterDesc',
    'probe ID'               => $id,
    'probe state'            => 'state',
    'probe type'             => 'probeType',
    'probe description'      => 'probeDescription',
    'probe output'           => 'message',

##  'parent probe ID'
##  'parent probe state'
##  'parent probe description'
    'hostname' => 'hostName',
    'host IP'  => 'hostAddress',
    'message'  => 'message',
    'subject'  => 'subject',
    'email'    => 'email',
    'alert id' => 'send_id'
  };

  my $premunge_times = {
                         'timestamp'    => 'time',
                         'current time' => 'current_time'
                       };

  my $postmunge_map = {

    ## macro name  => name in alert hash
    ## alert id    => '${MaskedTicket}${SendId}'
  };

  # Hardcoding for urls
  if ($alert->hostName() =~ /HOSTNAME_here/) {
    $alert->hostName('URL');
  }

  my $message_format = $self->body_format();
  $message_format =~ s/\\n/\n/g;
  my $subject_format = $self->subject_format();
  $subject_format =~ s/\\n/\n/g;
  my $reply_format = $self->reply_format() || '';
  $reply_format =~ s/\\n/\n/g;
  if ($alert->requires_ack) {
    $message_format .= $reply_format;
  }

  foreach (keys(%$premunge_map)) {
    my $ref   = $premunge_map->{$_};
    my $field = $alert->{$ref};
    $message_format =~ s/\^\[$_\]/$field/g;
    $subject_format =~ s/\^\[$_\]/$field/g;
  }
  $Log->log(4, "premunge_map $_: message_format now: $message_format \n");
  $Log->log(4,
            "premunge_map $_: subject_message_format now: $subject_format \n");

  # Do any special date formatting
  $message_format =
    $self->_format_times($alert, $message_format, $premunge_times,
                         $olson_tz_id);
  $subject_format =
    $self->_format_times($alert, $subject_format, $premunge_times,
                         $olson_tz_id);

  map { $message_format =~ s/\^\[$_\]/$postmunge_map->{$_}/g }
    keys(%$postmunge_map);
  $Log->log(4, "postmunge_map $_: message_format now: $message_format \n");
  map { $subject_format =~ s/\^\[$_\]/$postmunge_map->{$_}/g }
    keys(%$postmunge_map);
  $Log->log(4, "postmunge_map $_: subject_format now: $subject_format \n");

  $Log->log(3, "subject: $subject_format \n");
  $Log->log(3, "message: $message_format \n");

  $alert->fmt_message(substr($message_format, 0, $self->max_body_length()));
  $alert->fmt_subject(substr($subject_format, 0, $self->max_subject_length()));

  $Log->log(3, "Formatted alert with message format ", $self->recid, "\n");
  $Log->log(3, "Subject: ", $alert->fmt_subject, "\n");
  $Log->log(3, "Message: ", $alert->fmt_message, "\n");
} ## end sub format_message

###################
sub _format_times {
###################

  my ($self, $alert, $message, $premunge_times, $olson_tz_id) = @_;

  my $save_tz = $ENV{TZ};
  $ENV{TZ} = $olson_tz_id;
  $Log->log(4,
     "changed ENV{TZ} from timezone [$save_tz] to timezone [$olson_tz_id]\n\n");

  foreach (keys(%$premunge_times)) {

    my $ref = $premunge_times->{$_};
    my $t   = $alert->{$ref};
    next unless $t;
    my $t_str;

    if ($message =~ /\^\[$_(:[^\]]*)?\]/) {
      my $time_format = $1;
      $time_format =~ s/^:"//;
      $time_format =~ s/"$//;

      if ($time_format) {
        eval { $t_str = strftime($time_format, localtime($t)) };
      }

      if (!$t_str) {

        # Use default time formatting
        $t_str = strftime("%H:%M %Z", localtime($t));
      }
    } ## end if ($message =~ /\^\[$_(:[^\]]*)?\]/)

    $message =~ s/\^\[$_(:[^\]]*)?\]/$t_str/g;
  } ## end foreach (keys(%$premunge_times...

  $ENV{TZ} = $save_tz;
  $Log->log(4, "changed ENV{TZ} to [$save_tz]\n\n");
  $Log->log(4, "premunge_times $_: format now: $message \n");
  return $message;
} ## end sub _format_times

1;

__END__

=head1 NAME

NOCpulse::Notif::MessageFormat - An object that formats an alert for delivery.

=head1 SYNOPSIS

# Create a new message format
$format = NOCpulse::Notif::MessageFormat->new(
   'customer_id'        => 1,
   'description'        => 'sample',
   'max_subject_length' => 80,
   'max_body_length'    => 300,
   'subject_format'     => '^[probe state]: ^[hostname]: ^[probe description] at ^[timestamp:"%H:%M %Z"]',
   'body_format'        => 'This is Red Hat Command Center event notification ^[alert id].\n\nTime:      ^[timestamp:"%a %b %d, %H:%M:%S %
Z"]\nState:     ^[probe state]\nHost:      ^[hostname] (^[host IP])\nCheck:     ^[probe description]\nMessage:     ^[probe output]\nRun from:  ^[satellite description]',
   'reply_format'       => '\n\nTo acknowledge, reply to this message with this subject line:\n  
   ACK ^[alert id]\n\nTo immediately escalate, reply to this message with this subject line:\n     NACK ^[alert id]' );

#Apply the format to an alert
$format->format_message($alert,$olson_tz_id);

=head1 DESCRIPTION

The C<MessageFormat> creates a subject and message body line suitable for delivery, based on a set of formatting tags.

=head1 CLASS METHODS

=over 4

=item default ( )

Create a new MessageFormat representing the system default message format.

=item new ( [%args] )

Create a new MessageFormat with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item customer_id ( [$number] )

Get or set the unique identifier of the customer to which this format belongs.

=item description ( [$string] )

Get or set the field which names or describes this format.

=item max_body_length ( [$string] )

Get or set the maximum number of characters in a formatted notification message body.  This object will truncate the body to this length.

=item max_subject_length ( [$string] )

Get or set the maximum number of characters in a formatted notification subject.  This object will truncate the subject to this length.

=item body_format ( [$string] )

Get or set the string describing how a message body formatted by this object should look.  It is a string containing format tags.

=item format_message ( $alert [,$olson_tz_id] )

Apply the format to the given alert, setting the alert's fmt_message and fmt_subject, converting the times in the alert to the given timezone specified by olson_tz_id.

=item recid ( [$number] ) 

Get or set the unique identifier from the database representing this object.

=item reply_format ( [$string] )

Get or set the string describing how a message should be acknowledged.  It is a string containing format tags.

=item subject_format ( [$string] )

Get or set the string describing how a message subject formatted by this object should look.  It is a string containing format tags.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2005-02-15 23:59:53 $

=head1 SEE ALSO

B<NOCpulse::Notif::Alert>
B<$NOTIFICATION_HOME/scripts/notifserver.pl>

=cut

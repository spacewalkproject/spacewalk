package NOCpulse::Notif::RedirectCriterion;             

use strict;
use Class::MethodMaker
  new_hash_init => 'new',
  key_attrib    => 'recid',
  get_set       => [qw(match_param match_value redirect_id)],
  boolean       => 'inverted';

use NOCpulse::Log::Logger;
my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


my $field_map = {
  # name in table            => name in alert hash
  "CASE_SEN_MSG_PATTERN"   => 'message',
  "CASE_INSEN_MSG_PATTERN" => 'message',
  "DESTINATION_NAME"       => 'groupName',
  "NETSAINT_ID"            => 'clusterId',
  "PROBE_TYPE"             => 'probeType',
  "SERVICE_STATE"          => 'state',
  "HOST_STATE"             => 'state',
  "CONTACT_GROUP_ID"       => 'groupId',
  "CONTACT_METHOD_ID"      => 'null',
  "CUSTOMER_ID"            => 'customerId'
  ## "PROBE_ID" is determined later, based upon redirect match_param and match_value
};

#############
sub matches {
#############
  my ($self,$alert)=@_;

  # test for a match for this parameter.
  # eval so an invalid pattern doesn't crash the script

  $@=undef;
  my $match;
  my $match_param=$self->match_param();
  my $match_value=$self->match_value();
  
  $Log->log(3, "\tparam: $match_param value: $match_value\n");
  
  # Find the redirect value to match against

  my $alert_field = $field_map->{$match_param};  # alert name for field
 
  if ($match_param eq 'PROBE_ID') {
    $alert_field = $alert->probeType eq 'HostProbe' ? 'hostProbeId' : 'probeId'
;
  }

  # Find the alert value used for comparison

  $Log->log(9, "alert field: $alert_field\n");
  my $alert_value = $alert->$alert_field();
  $Log->log(3, "alert value: $alert_value\n");

  # Do the matching

  if ($match_param =~ /CASE_SEN/) {
    eval { $match = $alert_value =~ /$match_value/ }

  } elsif ($match_param =~ /CASE_INSEN/) {
    eval { $match = $alert_value =~ /$match_value/i }

  } elsif ($match_param =~ /PROBE_ID/) {
    $match = $match_value == $alert->hostProbeId;
    $match = $match_value == $alert->probeId unless $match;

  } else {
    $match = ($alert_value =~ /^[0-9]*$/) && ($match_value =~ /^[0-9]*$/)
        ? $alert_value == $match_value : $alert_value eq $match_value;
  }

  if ($@) {
    #Invalid $match_param pattern
    $Log->log(3, "Invalid match pattern!\n\n");
    return 0
  }

  $match += 0;

  # negate the match result if specified

  if ($self->inverted()) {
    $match = !$match + 0;
  }

  return $match;
}

1;

__END__

=head1 NAME

NOCpulse::Notif::RedirectCriterion - A key-value type pairing used to describe an advanced notification.

=head1 SYNOPSIS

# Create a new, empty redirect criterion
$crtierion=NOCpulse::Notif::RedirectCriterion->new(
  'redirect_id' => $number,
  'match_param' => $key,
  'match_value' => $value,
  'inverted'    => 0);

# Compare this criterion to an alert
$boolean=$criterion->matches($alert);

=head1 DESCRIPTION

The C<RedirectCriterion> object is a specification for an individual match criterion based on an alert object's fields.  If all the redirect criterion for a redirect match, that redirect is then processed.

=head1 CLASS METHODS

=over 4

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item inverted ( [0|1] )

Get or set the inverted field.  If inverted is true, it negates the sense of the match.

=item match_param ( [$string] )

Get or set the field to be matched.  This roughly corresponds to one of Alert's method.  Valid values are "CASE_SEN_MSG_PATTERN", "CASE_INSEN_MSG_PATTERN", "DESTINATION_NAME", "NETSAINT_ID", "PROBE_TYPE", "SERVICE_STATE", "HOST_STATE", "CONTACT_GROUP_ID", "CONTACT_METHOD_ID", and "CUSTOMER_ID".

=item match_value ( [$string] )

Get or set the expected value of the field being matched.

=item matches ( $alert )

Return true if this criterion holds true when applied to the specified alert.

=item recid ( [$number] )

Get or set the unique identifier of this object, as reflected in the database.

=item redirect_id ( [$number] )

Get or set the unique identifier of the redirect, as reflected in the database, this criterion belongs to.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-01-22 23:36:03 $

=head1 SEE ALSO

B<NOCpulse::Notif::Redirect>
B<NOCpulse::Notif::Alert>
B<notifserver.pl>
B</var/www/cgi-bin/redirmgr.cgi>

=cut

#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#

use strict;

use RHN::Set;

package RHN::DB::ServerActions;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

sub channel_license_consent_for_set {
  my $class = shift;
  my $set = shift;
  my $channel_id = shift;
  my $user_id = shift;
  my $transaction = shift;

  my $query = <<EOQ;
INSERT INTO rhnChannelFamilyLicenseConsent (channel_family_id, user_id, server_id)
SELECT CFM.channel_family_id, ?, SC.server_id
  FROM rhnChannelFamilyLicense CFL,
       rhnChannelFamilyMembers CFM,
       rhnServerChannel SC,
       rhnChannel C,
       rhnSet ST
 WHERE ST.user_id = ?
   AND ST.label = ?
   AND C.id = ?
   AND ST.element = SC.server_id
   AND SC.channel_id = C.parent_channel
   AND C.id = CFM.channel_id
   AND CFM.channel_family_id = CFL.channel_family_id
   AND CFL.license_path IS NOT NULL
   AND NOT EXISTS (SELECT user_id FROM rhnChannelFamilyLicenseConsent WHERE channel_family_id = CFM.channel_family_id AND server_id = SC.server_id)
EOQ

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare($query);

  $sth->execute($user_id, $user_id, $set->label, $channel_id);

  $dbh->commit unless $transaction;

  return $dbh;
}

sub assign_set_to_group {
  my $class = shift;
  my $set = shift;
  my $sgid = shift;
  die "Invalid format for sgid $sgid" if $sgid =~ /\D/;	# contain nondigit? die

  my $query = <<EOQ;
BEGIN
  rhn_server.insert_set_into_servergroup(:server_group_id,:user_id,:label);
END;
EOQ
  my $label = $set->label;
  my $uid = $set->uid;

  my $dbh = RHN::DB->connect();
  my $sth = $dbh->prepare($query);

  $sth->execute_h(server_group_id => $sgid, label => $set->label, user_id => $set->uid);

  $dbh->commit;
}

sub remove_set_from_group {
  my $class = shift;
  my $set = shift;
  my $sgid = shift;

  my $dbh = RHN::DB->connect();
  $dbh->call_procedure('rhn_server.delete_set_from_servergroup', $sgid, $set->uid, 'system_list');

  $dbh->commit;
}


sub system_set_change_base_channels {
  my $class = shift;
  my $user_id = shift;
  my $to_defaults_ref = shift;  # array of base id's to go to default RH base channel
  my $from_to_ref = shift;  # array of [ from_id, to_id ]'s...
  my $transaction;


  my $dbh = $transaction || RHN::DB->connect();

  my $query = <<EOQ;
BEGIN
    rhn_channel.bulk_guess_server_base_from(?, ?, ?);
END;
EOQ

  my $sth = $dbh->prepare($query);

  foreach my $from (@{$to_defaults_ref}) {
    $sth->execute('system_list', $user_id, $from);
  }

  $query = <<EOQ;
BEGIN
    rhn_channel.bulk_server_basechange_from(?, ?, ?, ?);
END;
EOQ

  $sth = $dbh->prepare($query);

  foreach my $from_to (@{$from_to_ref}) {
    $sth->execute('system_list', $user_id, $from_to->[0], $from_to->[1]);
  }

  $dbh->commit unless $transaction;

  return $dbh;
}


sub subscribe_set_to_channel {
  my $class = shift;
  my $set = shift;
  my $channel_id = shift;
  my $transaction = shift;

  my $query = <<EOQ;
BEGIN
  rhn_channel.bulk_subscribe_server(?, ?, ?);
END;
EOQ

  my $dbh = $transaction || RHN::DB->connect();
  my $sth = $dbh->prepare($query);
  $sth->execute($channel_id, $set->label, $set->uid);

  $dbh->commit unless $transaction;

  return $dbh;
}

sub unsubscribe_set_from_channel {
  my $class = shift;
  my $set = shift;
  my $channel_id = shift;
  my $transaction = shift;

  my $query = <<EOQ;
BEGIN
  rhn_channel.bulk_unsubscribe_server(?, ?, ?);
END;
EOQ

  my $dbh = $transaction || RHN::DB->connect();
  my $sth = $dbh->prepare($query);
  $sth->execute($channel_id, $set->label, $set->uid);

  $dbh->commit unless $transaction;

  return $dbh;
}

1;

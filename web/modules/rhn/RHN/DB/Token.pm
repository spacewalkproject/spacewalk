#
# Copyright (c) 2008--2010 Red Hat, Inc.
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

package RHN::DB::Token;

use PXT::Utils;
use RHN::DB;
use RHN::DB::TableClass;
use RHN::DataSource::Simple;
use RHN::Exception qw/throw/;

use Digest::MD5 qw(md5_hex);

use RHN::DataSource::General ();
use RHN::Entitlements ();

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

use Carp;

my @token_fields = qw/ID ORG_ID USER_ID NOTE USAGE_LIMIT DISABLED SERVER_ID DEPLOY_CONFIGS/;

my $t = new RHN::DB::TableClass("rhnRegToken", "RT", "", @token_fields);

my @ak_fields = qw/ACTIVATION_KEY_TOKEN ACTIVATION_KEY_KS_SESSION_ID/;

#class methods

sub entitlements {
  my $self = shift;

  my $ds = new RHN::DataSource::Simple (-querybase => 'General_queries',
					-mode => 'token_entitlements');

  return @{$ds->execute_query(-tid => $self->id)};
}

sub has_entitlement {
  my $self = shift;
  my $target_entitlement = shift;

  throw "(invalid_entitlement) Invalid entitlement: $target_entitlement"
    unless RHN::Entitlements->is_valid_entitlement($target_entitlement);

  my @entitlements = $self->entitlements();

  return (grep { $_->{LABEL} eq $target_entitlement } @entitlements) ? 1 : 0;
}

sub set_entitlements {
  my $self = shift;
  my @entitlements = @_;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
DELETE
  FROM rhnRegTokenEntitlement RTE
 WHERE RTE.reg_token_id = :tid
EOQ

  $sth->execute_h(tid => $self->id);

  $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnRegTokenEntitlement
       (reg_token_id, server_group_type_id)
VALUES (:tid, (SELECT SGT.id FROM rhnServerGroupType SGT WHERE SGT.label = :ent))
EOQ

  foreach my $ent (@entitlements) {
    $sth->execute_h(tid => $self->id, ent => $ent);
  }

  $dbh->commit;

  return;
}

# channels is a wrapper so that fancy_channels can exist without
# breaking old function call semantics
sub channels {
  my $self = shift;

  return map { $_->{ID} } $self->fancy_channels;
}

# packages is a wrapper so that fancy_packages can exist without
# breaking old function call semantics
sub packages {
  my $self = shift;

  return map { $_->{ID} } $self->fancy_packages;
}

# config_channels is a wrapper so that fancy_config_channels can exist without
# breaking old function call semantics
sub config_channels {
  my $self = shift;

  return map { $_->{ID} } $self->fancy_config_channels;
}

# more details about channels associated with a token
sub fancy_channels {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT RTC.channel_id ID, C.parent_channel, C.label, C.name
  FROM rhnChannel C, rhnRegTokenChannels RTC
 WHERE RTC.token_id = ?
   AND C.id = RTC.channel_id
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  return $sth->fullfetch_hashref;
}

sub fancy_config_channels {
  my $self = shift;
  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT RTCC.config_channel_id,
       RTCC.config_channel_id AS ID,
       RTCC.position,
       CC.name,
       CCT.label AS TYPE
  FROM rhnConfigChannelType CCT,
       rhnConfigChannel CC,
       rhnRegTokenConfigChannels RTCC
 WHERE RTCC.token_id = ?
   AND CC.id = RTCC.config_channel_id
   AND CC.confchan_type_id = CCT.id
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($self->id);
  return $sth->fullfetch_hashref;
}

sub fancy_packages {
  my $self = shift;

  my $ds = new RHN::DataSource::General(-mode => 'packages_in_token');
  my $data = $ds->execute_query(-tid => $self->id);

  return @$data;
}

sub groups {
  my $self = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = <<EOQ;
SELECT RTG.server_group_id
  FROM rhnRegTokenGroups RTG
 WHERE RTG.token_id = ?
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  my @groups;

  while (my ($group) = $sth->fetchrow) {
    push @groups, $group;
  }

  return @groups;
}

sub set_channels {
  my $self = shift;
  my %params = validate(@_, { channels => 1, transaction => 0 });

  my @channels = grep { defined $_ and $_ > 0 } @{$params{channels}};

  my $dbh = $params{transaction} || RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOQ;
DELETE FROM rhnRegTokenChannels RTC
      WHERE RTC.token_id = :tid
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(tid => $self->id);

  # make sure we don't add rhn-satellite or rhn-proxy channels to any keys...
  $query = <<EOQ;
INSERT INTO rhnRegTokenChannels
            (token_id, channel_id)
SELECT DISTINCT :tid, :cid
  FROM rhnChannelFamily CF,
       rhnChannelFamilyMembers CFM
 WHERE CFM.channel_id = :cid
   AND CFM.channel_family_id = CF.id
   AND CF.label NOT IN ('rhn-proxy', 'rhn-satellite')
EOQ

  $sth = $dbh->prepare($query);

  foreach my $cid (@channels) {
    $sth->execute_h(tid => $self->id, cid => $cid);
  }

  $sth->finish;
  $dbh->commit unless $params{transaction};

  return;
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, { id => 0, sid => 0, token => 0 });

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  if (exists $params{id}) {
    $query = $t->select_query("RT.ID = :tid");
    $sth = $dbh->prepare($query);
    $sth->execute_h(tid => $params{id});
  }
  elsif (exists $params{sid}) {
    $query = $t->select_query("RT.SERVER_ID = :sid");
    $sth = $dbh->prepare($query);
    $sth->execute_h(sid => $params{sid});
  }
  elsif (exists $params{token}) {
    $query = $t->select_query("EXISTS (SELECT 1 FROM rhnActivationKey AK WHERE AK.token = :token AND AK.reg_token_id = RT.id)");
    $sth = $dbh->prepare($query);
    $sth->execute_h(token => $params{token});
  }
  else {
    die "Need id, sid, or token when looking up token";
  }

  my @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  if ($columns[0]) {
    $ret = $class->blank_token;

    $ret->{__id__} = $columns[0];
    $ret->$_(shift @columns) foreach $t->method_names;
  }
  else {
    return undef;
  }

  my ($token, $session_id);
  if (exists $params{token}) {
    $token = $params{token};

    $sth = $dbh->prepare(<<EOQ);
SELECT AK.ks_session_id
  FROM rhnActivationKey AK
 WHERE AK.reg_token_id = :id
   AND AK.token = :token
EOQ

    $sth->execute_h(id => $ret->id, token => $token);

    ($session_id) = $sth->fetchrow();
    $sth->finish;
  }
  elsif (exists $params{sid}) {
    $sth = $dbh->prepare(<<EOQ);
SELECT AK.token, AK.ks_session_id
  FROM rhnActivationKey AK
 WHERE AK.reg_token_id = :id
EOQ

    $sth->execute_h(id => $ret->id);

    ($token, $session_id) = $sth->fetchrow;
    $sth->finish;
  }
  else {
    $sth = $dbh->prepare(<<EOQ);
SELECT AK.token, AK.ks_session_id
  FROM rhnActivationKey AK
 WHERE AK.reg_token_id = :id
ORDER BY AK.ks_session_id DESC
EOQ

    $sth->execute_h(id => $ret->id);

    ($token) = $sth->fetchrow();
    $sth->finish;
  }

  $ret->activation_key_token($token);
  $ret->activation_key_ks_session_id($session_id);
  delete $ret->{":modified:"};

  return $ret;
}

sub blank_token {
  my $class = shift;

  my $self = bless { }, $class;

  return $self;
}

sub create_token {
  my $class = shift;

  my $tok = $class->blank_token;
  $tok->{__id__} = -1;

  return $tok;
}

# build some accessors
foreach my $field ($t->method_names, map { lc } @ak_fields) {
  my $sub = q {
    sub [[field]] {
      my $self = shift;
      if (@_ and "[[field]]" ne "id") {
        $self->{":modified:"}->{[[field]]} = 1;
        $self->{__[[field]]__} = shift;
      }
      return $self->{__[[field]]__};
    }
  };

  $sub =~ s/\[\[field\]\]/$field/g;
  eval $sub;

  if ($@) {
    die $@;
  }
}

#delete a token
sub purge {
  my $self = shift;
  my $trans = shift;

#delete the groups
  my $dbh = $trans || RHN::DB->connect;
  my $query;
  my $sth;

  $query = <<EOQ;
DELETE FROM rhnRegTokenGroups RTG
      WHERE RTG.token_id = ?
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

#delete the channels
  $query = <<EOQ;
DELETE FROM rhnRegTokenChannels RTC
      WHERE RTC.token_id = ?
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

#delete the servers
  $query = <<EOQ;
DELETE
  FROM rhnServerTokenRegs STR
 WHERE STR.token_id = ?
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

#delete the token
  $query = <<EOQ;
DELETE
  FROM rhnRegToken RT
 WHERE RT.id = ?
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($self->id);

  $dbh->commit unless $trans;

  return;
}

sub commit {
  my $self = shift;
  my $trans = shift;
  my $mode = 'update';

  my $dbh = $trans || RHN::DB->connect;

  if ($self->id == -1) {
    my $sth = $dbh->prepare("SELECT rhn_reg_token_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    die "No new token id from seq rhn_reg_token_seq (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;

    $self->{":modified:"}->{id} = 1;

    $self->{__id__} = $id;
    $mode = 'insert';
  }

  die "$self->commit called on token without valid id" unless $self->id and $self->id > 0;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;
  my %tc_method_names = map { $_ => 1 } $t->method_names;

  my $query;

  my @updated_columns = grep { $tc_method_names{$_} } @modified;

  if ($mode eq 'update') {
    my $sth;

    if (@updated_columns) {
      $query = $t->update_query($t->methods_to_columns(@updated_columns));
      $query .= "RT.ID = ?";

      $sth = $dbh->prepare($query);
      $sth->execute((map { $self->$_() } grep { $modified{$_} } $t->method_names), $self->id);
    }

    if ( exists $modified{activation_key_token} ) {
      if ( exists $modified{activation_key_ks_session_id} ) {
	$sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnActivationKey
       (token, reg_token_id, ks_session_id)
VALUES (:token, :id, :session_id)
EOQ
	$sth->execute_h(token => $self->activation_key_token, id => $self->id,
			session_id => $self->activation_key_ks_session_id);
      }
      elsif ($self->activation_key_ks_session_id) {
	die "attempted update of token for kickstart key";
      }
      else {
	$sth = $dbh->prepare(<<EOQ);
UPDATE rhnActivationKey
   SET token = :token
 WHERE reg_token_id = :id
   AND ks_session_id IS null
EOQ
	$sth->execute_h(token => $self->activation_key_token, id => $self->id);
      }
    }
    elsif ( exists $modified{activation_key_ks_session_id} ) {
      $sth = $dbh->prepare(<<EOQ);
UPDATE rhnActivationKey
   SET ks_session_id = :session_id
 WHERE reg_token_id = :id
   AND token = :token
EOQ

      $sth->execute_h(id => $self->id,
		      token => $self->activation_key_token,
		      session_id => $self->activation_key_ks_session_id);
    }
  }
  else {
    return unless @updated_columns;

    $query = $t->insert_query($t->methods_to_columns(@updated_columns));

    my $sth = $dbh->prepare($query);
    $sth->execute(map { $self->$_() } grep { $modified{$_} } $t->method_names);

    $sth = $dbh->prepare(<<EOQ);
INSERT
  INTO rhnActivationKey
       (token, reg_token_id, ks_session_id)
VALUES (:token, :id, :session_id)
EOQ

    $sth->execute_h(token => $self->activation_key_token, id => $self->id,
		    session_id => $self->activation_key_ks_session_id);
  }

  $dbh->commit unless $trans;

  delete $self->{":modified:"};
}

sub generate_random_key {
  my $class = shift;

  return md5_hex(PXT::Utils->random_bits(1024));
}

sub org_default {
  my $self = shift;
  my $new_value = shift;

  my $dbh = RHN::DB->connect;
  if (defined $new_value) {
    if ($new_value) { # Clear all others and set this one
      $dbh->do_h("DELETE FROM rhnRegTokenOrgDefault WHERE org_id = :org_id", org_id => $self->org_id);
      $dbh->do_h("INSERT INTO rhnRegTokenOrgDefault (org_id,  reg_token_id) VALUES (:org_id, :rtid)",
		 org_id => $self->org_id, rtid => $self->id);
    }
    else { # Just clear this one
      $dbh->do_h("DELETE FROM rhnRegTokenOrgDefault WHERE org_id = :org_id and reg_token_id = :rtid",
		 org_id => $self->org_id, rtid => $self->id);
    }

    $dbh->commit;
  }

  my $sth = $dbh->prepare("SELECT 1 FROM rhnRegTokenOrgDefault WHERE reg_token_id = :rtid");
  $sth->execute_h(rtid => $self->id);
  my ($hit) = $sth->fetchrow;
  $sth->finish;

  return $hit ? 1 : 0;
}

1;

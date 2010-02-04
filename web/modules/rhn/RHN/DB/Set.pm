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

package RHN::DB::Set;

use RHN::DB;
use RHN::User ();

use Carp;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

sub new {
  my $class = shift;
  my $label = shift;
  my $uid = shift;

  croak "Both a label and a user id must be passed to $class->new($label, $uid)"
    unless $label and $uid;

  my $self = bless { label => $label,
		     uid => $uid,
		     contents => { },
		   }, $class;

  $self->_reload;

  return $self;
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {label => 1, uid => 1});

  return $class->new($params{label}, $params{uid});
}

sub uid {
  return $_[0]->{uid};
}

sub label {
  return $_[0]->{label};
}

sub contents {
  return map { /[|]/ ? [ (split /[|]/, $_) ] : $_ } keys %{$_[0]->{contents}};
}

sub contains {
  my $self = shift;
  my $val = shift;

  $val = join("|", @$val) if ref $val eq 'ARRAY';

  return exists $self->{contents}->{$val};
}

sub empty {
  $_[0]->{contents} = { };
}

sub _reload {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT element, element_two FROM rhnSet WHERE user_id = ? AND label = ?");

  $sth->execute($self->uid, $self->label);

  my @contents;
  while (my @elem = $sth->fetchrow) {
    push @contents, defined $elem[1] ? join("|", @elem) : $elem[0];
  }

  @{$self->{contents}}{@contents} = (1) x @contents;
}

sub add {
  my $self = shift;
  my @vals = @_;

  @vals = map { ref $_ ? join("|", @$_) : $_ } @vals;

  @{$self->{contents}}{@vals} = (1) x @vals;
}

sub remove {
  my $self = shift;
  my @vals = @_;

  @vals = map { ref $_ ? join("|", @$_) : $_ } @vals;

  delete @{$self->{contents}}{@vals};
}

sub output_hash {
  my $self = shift;

  my %ret;

  foreach my $elem (keys %{$self->{contents}}) {
    my ($key, $val) = split(/\|/, $elem);
    $ret{$key} = $val;
  }

  return %ret;
}

sub commit {
  my $self = shift;
  my $transaction = shift;

  my $dbh = $transaction || RHN::DB->connect;
  my $lock_sth = RHN::User->lock_web_contact(-transaction => $dbh, -uid => $self->uid);

  my $sth = $dbh->prepare("DELETE FROM rhnSet WHERE user_id = ? AND label = ?");
  $sth->execute($self->uid, $self->label);

  $sth = $dbh->prepare("INSERT INTO rhnSet (user_id, label, element, element_two) VALUES (?, ?, ?, ?)");
  foreach my $val (keys %{$self->{contents}}) {
    my ($e1, $e2) = split /[|]/, $val;
    $sth->execute($self->uid, $self->label, $e1, $e2);
  }

  $lock_sth->finish;

  $dbh->commit unless $transaction;
  return $dbh if $transaction;
}

# remove all the servers who have picked up the specified action from the set
sub remove_picked_up_for_action {
  my $self = shift;
  my $action_id = shift;

  die "no action_id" unless $action_id;

  my $dbh = RHN::DB->connect;
  my $query;

  $query = <<EOQ;
DELETE FROM
       rhnSet ST
 WHERE ST.user_id = ?
   AND ST.label = ?
   AND EXISTS (
SELECT SA.server_id
  FROM rhnActionStatus AStat,
       rhnServerAction SA
 WHERE SA.action_id = ?
   AND SA.status = AStat.id
   AND AStat.name = 'Picked Up'
   AND SA.server_id = ST.element
)
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($self->uid, $self->label, $action_id);
  $dbh->commit;
}

# removes any servers from your set that a)  you don't have access to, or b) aren't of "enterprise" entitlement
sub remove_illegal_servers {
  my $self = shift;
  my $user = shift;

  die "no user!" unless $user;

  # return if $user->is('org_admin');

  my $dbh = RHN::DB->connect;
  my $query;

  $query = <<EOQ;
DELETE FROM
       rhnSet S
 WHERE user_id = ?
   AND label = ?
   AND (NOT EXISTS (SELECT 1 FROM rhnUserServerPerms WHERE user_id = S.user_id AND server_id = S.element)
        OR NOT EXISTS (SELECT 1 FROM rhnServerFeaturesView SFV WHERE SFV.server_id = S.element AND SFV.label = 'ftr_system_grouping'))
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($self->uid, $self->label);
  $dbh->commit;
}

# removes any servers from your set that a)  you don't have access to, or b) There is no 'b'
sub remove_unowned_servers {
  my $self = shift;
  my $user = shift;

  die "no user!" unless $user;

  my $dbh = RHN::DB->connect;
  my $query;

  $query = <<EOQ;
DELETE FROM
       rhnSet S
 WHERE user_id = ?
   AND label = ?
   AND (NOT EXISTS (SELECT 1 FROM rhnUserServerPerms WHERE user_id = S.user_id AND server_id = S.element))
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($self->uid, $self->label);
  $dbh->commit;
}

sub copy_from_group {
  my $class = shift;
  my $uid = shift;
  my $name = shift;
  my $sgid = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('DELETE FROM rhnSet WHERE user_id = ? AND label = ?');
  $sth->execute($uid, $name);

  my $query;

  $query = <<EOQ;
INSERT INTO rhnSet
  (user_id, label, element)
SELECT ?, ?, SGM.server_id
  FROM rhnServerGroupMembers SGM
 WHERE SGM.server_group_id = ?
   AND EXISTS (SELECT 1 FROM rhnUserServerPerms WHERE server_id = SGM.server_id AND user_id = ?)
   AND EXISTS (SELECT 1 FROM rhnServerFeaturesView SFV
                WHERE SFV.server_id = SGM.server_id
                  AND SFV.label = 'ftr_system_grouping')
EOQ
  $sth = $dbh->prepare($query);
  $sth->execute($uid, $name, $sgid, $uid);

  $dbh->commit;
}


sub remove_scheduled_errata_for_system {
  my $self = shift;
  my $sid = shift;

  die "no sid!" unless $sid;

  my $dbh = RHN::DB->connect;
  my $query;

  $query = <<EOQ;
DELETE FROM
       rhnSet S
 WHERE user_id = :user_id
   AND label = :set_label
   AND EXISTS (SELECT 1
                 FROM rhnActionErrataUpdate AEU,
                      rhnServerAction SA,
                      rhnActionStatus AST
                WHERE SA.server_id = :sid
                  AND SA.action_id = AEU.action_id
                  AND AEU.errata_id = S.element
                  AND AST.id = SA.status
                  AND NOT AST.name = 'Completed' -- filter out rolled back status
                  AND NOT AST.name = 'Failed'
              )
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(user_id => $self->uid, set_label => $self->label, sid => $sid);
  $dbh->commit;
}

sub remove_users_with_role {
  my $self = shift;
  my $role = shift;

  croak "No role param" unless $role;

  my $dbh = RHN::DB->connect;
  my $query =<<EOQ;
DELETE FROM
       rhnSet S
 WHERE user_id = :user_id
   AND label = :set_label
   AND EXISTS (SELECT 1
	         FROM web_contact WC, rhnUserGroupmembers UGM, rhnUserGroup UG, rhnUserGroupType UGT
                WHERE WC.id = S.element
                  AND UG.org_id = WC.org_id
	          AND UGM.user_group_id = UG.id
                  AND UGM.user_id = WC.id
                  AND UG.group_type = UGT.id
                  AND UGT.label = :role_label)
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(user_id => $self->uid, set_label => $self->label, role_label => $role);

  $dbh->commit;
}

sub remove_unowned_actions {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my $query =<<EOQ;
DELETE
  FROM rhnSet S
 WHERE S.user_id = :user_id
   AND S.label = :set_label
   AND EXISTS (SELECT 1
                 FROM rhnAction A
                WHERE A.id = S.element
                  AND NOT A.scheduler = S.user_id)
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(user_id => $self->uid, set_label => $self->label);

  $dbh->commit;
}

sub remove_prereq_actions {
  my $self = shift;
  my $server_id = shift;
  die "no server_id" unless $server_id;

  my $dbh = RHN::DB->connect;
  my $query =<<EOQ;
DELETE
  FROM rhnSet S
 WHERE S.user_id = :user_id
   AND S.label = :set_label
   AND EXISTS (
  SELECT 1
    FROM rhnActionStatus AStat,
         rhnAction A,
         rhnServerAction SA
   WHERE SA.server_id = :server_id
     AND A.id = S.element
     AND A.prerequisite  = SA.action_id
     AND SA.status = AStat.id
     AND AStat.name != 'Completed'
)
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(user_id => $self->uid, set_label => $self->label, server_id => $server_id);

  $dbh->commit;
}


1;

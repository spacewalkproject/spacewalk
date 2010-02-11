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

# Server Group DB module

use strict;

package RHN::DB::ServerGroup;

use RHN::DB;
use RHN::DB::TableClass;
use RHN::Set;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my @server_group = qw(id name description org_id current_members max_members);

my $t = new RHN::DB::TableClass("RHNServerGroup", "SG", "", @server_group);

foreach my $field ($t->method_names) {
  my $sub = q {
    sub [[field]] {
      my $self = shift;
      if (@_ and "[[field]]" ne "id") {
        $self->{":modified:"}->{[[field]]} = 1;
        $self->{[[field]]} = shift;
      }
      return $self->{[[field]]};
    }
  };

  $sub =~ s/\[\[field\]\]/$field/g;
  eval $sub;

  if ($@) {
    warn $@;
  }
}

=head1 create

arguments -	$name
		$org
		$desc
returns -

=cut

sub blank_server_group {
  my $class = shift;
  my $self = bless { }, $class;
  return $self;
}

sub create {
  my $class = shift;

  my $sg = $class->blank_server_group;
  $sg->{id} = -1;

  return $sg;
}

sub commit {
  my $self = shift;
  my $mode = 'update';

  if ($self->id == -1) {
    my $dbh = RHN::DB->connect;

    my $sth = $dbh->prepare("SELECT rhn_server_group_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    die "No new sgroup id from seq rhn_server_group_id_seq (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;

    $self->{":modified:"}->{id} = 1;
    $self->{id} = $id;
    $mode = 'insert';
  }

  die "$self->commit called on servergroup without valid id" unless $self->id;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my $dbh = RHN::DB->connect;

  my $query;
  if ($mode eq 'update') {
    $query = $t->update_query($t->methods_to_columns(@modified));
    $query .= "SG.ID = ?";
  }
  else {
    $query = $t->insert_query($t->methods_to_columns(@modified));
  }

  my $sth = $dbh->prepare($query);
  $sth->execute((map { $self->$_() } grep { $modified{$_} } $t->method_names), ($mode eq 'update') ? ($self->id) : ());

  $dbh->commit;

  delete $self->{":modified:"};
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {id => 1});
  my $id = $params{id};

  my $dbh;
  my $sqlstmt;
  my $sth;
  my $servergrp;
  my @columns;

  $dbh = RHN::DB->connect;
  $sqlstmt = $t->select_query("SG.ID = ?");

  $sth = $dbh->prepare($sqlstmt);
  $sth->execute($id);
  @columns = $sth->fetchrow;
  $sth->finish;

  if ($columns[0]) {
    $servergrp = $class->blank_server_group;
    $servergrp->{id} = $columns[0];
    foreach ($t->method_names) {
      $servergrp->$_(shift @columns) 
    }
    delete $servergrp->{":modified:"};
  }
  else {
    local $" = ", ";
    die "Error loading servergroup $id (@columns)";
  }

  return $servergrp;
}

sub member_count {
  my $self_or_pkg = shift;
  my $id;

  if (ref $self_or_pkg) {
    $id = $self_or_pkg->id;
  }
  else {
    $id = shift;
  }

  my $dbh = RHN::DB->connect;

  my $sqlstmt = sprintf <<EOT; 
SELECT COUNT(server_id)
  FROM rhnServerGroupMembers SGM
 WHERE SGM.server_group_id = ?
   AND EXISTS (SELECT 1 FROM rhnServerFeaturesView SFV
                WHERE SFV.server_id = SGM.server_id
                  AND SFV.label = 'ftr_system_grouping')
EOT

  my $sth = $dbh->prepare($sqlstmt);
  $sth->execute($id);

  my ($count) = $sth->fetchrow;
  $sth->finish;

  return $count;
}


=head1 remove

arguments - $group_id
returns -  

=cut

sub remove {
  my $class = shift;
  my $group_id = shift;
#  my $org_id = shift;

  my $dbh = RHN::DB->connect;

#  1.  Remove the user permissions to the group.
#      First, so that user perms won't be regenerated twice.
  my $query = <<EOQ;
DECLARE
  cursor uids is
    select user_id id
    from rhnUserServerGroupPerms
    where server_group_id = :server_group_id;
BEGIN
  for u in uids loop
    rhn_user.remove_servergroup_perm(u.id, :server_group_id);
  end loop;
END;
EOQ
  my $sth = $dbh->prepare($query);
  $sth->execute_h(server_group_id => $group_id);

#  2.  Remove systems from system group
  $query = <<EOQ;
BEGIN
  rhn_server.clear_servergroup(:server_group_id);
END;
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute_h(server_group_id => $group_id);

#  3.  Remove the group itself
  $query = <<EOQ;
DELETE FROM rhnServerGroup SG WHERE SG.id = ?
EOQ

  $sth = $dbh->prepare($query);
  $sth->execute($group_id);

  $dbh->commit();
}

sub server_group_list {
  my $self = shift;
  my $org_id = shift;

  my $dbh = RHN::DB->connect;
  my $query = <<EOQ;
  SELECT SG.name, SG.id
    FROM rhnServerGroup SG
   WHERE SG.org_id = ?
     AND SG.group_type is NULL
ORDER BY UPPER(SG.name), SG.id
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute($org_id);

  my @groups;

  while (my @group = $sth->fetchrow) {
    push @groups, [ @group ];
  }

  return @groups;
}

sub intersect_groups {
  my $self = shift;
  my $user_id = shift;
  my $use_ssm = shift;
  my @groups = @_;

  my $dbh = RHN::DB->connect;
  my $sth;

  unless ($use_ssm) {
    my $sgid = shift(@groups);
    RHN::Set->copy_from_group($user_id, "system_list", $sgid);
  }

  $sth = $dbh->prepare(<<EOQ);
DELETE FROM rhnSet S
 WHERE S.user_id = $user_id
   AND S.label = 'system_list'
   AND NOT EXISTS (SELECT 1 FROM rhnServerGroupMembers SGM WHERE SGM.server_group_id = ? and SGM.server_id = S.element)
EOQ

  foreach my $sgid (@groups) {
    $sth->execute($sgid);
  }

  $dbh->commit;

  return;
}

sub union_groups {
  my $self = shift;
  my $user_id = shift;
  my $use_ssm = shift;
  my @groups = @_;

  my $dbh = RHN::DB->connect;
  my $sth;

  unless ($use_ssm) {
    my $sgid = shift(@groups);
    RHN::Set->copy_from_group($user_id, "system_list", $sgid);
  }

  $sth = $dbh->prepare(<<EOQ);
INSERT INTO rhnSet (user_id, label, element)
     (SELECT :user_id, :set_label, SGM.server_id
               FROM rhnServerGroupMembers SGM
              WHERE SGM.server_group_id = :sgid
                AND NOT EXISTS (SELECT 1 FROM rhnSet WHERE user_id = :user_id AND label = :set_label AND element = SGM.server_id))
EOQ

  foreach my $sgid (@groups) {
    $sth->execute_h(sgid => $sgid, user_id => $user_id, set_label => 'system_list');
  }

  return;
}

sub members {
  my $self = shift;
  my $gid = shift;

  unless (defined $gid) {
    $gid = $self->id;
  }

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT server_id
  FROM rhnServerGroupMembers SGM
 WHERE SGM.server_group_id = ?
   AND EXISTS (SELECT 1 FROM rhnServerFeaturesView SFV
                WHERE SFV.server_id = SGM.server_id
                  AND SFV.label = 'ftr_system_grouping')
EOQ

  my @ret;

  $sth->execute($gid);

  while (my ($sid) = $sth->fetchrow) {
    push @ret, $sid;
  }

  return @ret;
}

sub errata_counts {
  my $class = shift;
  my $org_id = shift;
  my $id = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT  SECURITY_ERRATA, BUG_ERRATA, ENHANCEMENT_ERRATA
  FROM  rhnServerGroupOverview
 WHERE  org_id = :org_id
   AND  group_id = :sgid
EOQ

  $sth->execute_h(sgid => $id, org_id => $org_id);
  my $row = $sth->fetchrow_hashref;
  $sth->finish;

  return $row;
}

sub num_admins {
  my $self = shift;


  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOQ);
SELECT COUNT(DISTINCT user_id) NUM_ADMINS
  FROM rhnUserServerGroupPerms
 WHERE server_group_id = :sgid
EOQ

  $sth->execute_h(sgid => $self->id);
  my ($count) = $sth->fetchrow;
  $sth->finish;

  return $count;
}

1;

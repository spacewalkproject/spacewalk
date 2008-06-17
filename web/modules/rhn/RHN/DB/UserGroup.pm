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

# See POD at bottom for additional comments
use strict;
use DBI;

package RHN::DB::UserGroup;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

use RHN::DB;
use Carp;
use RHN::DB::TableClass;
use Data::Dumper;

my @ug_fields = qw { id name description max_members group_type org_id };
my $ug_table = new RHN::DB::TableClass("rhnUserGroup", "UG", "", @ug_fields);

sub list_group_types {
  my $class = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare("SELECT id, name, label FROM rhnUserGroupType ORDER BY UPPER(label)");
  $sth->execute;

  my @ret;
  while (my @row = $sth->fetchrow) {
    push @ret, [ @row ];
  }

  return @ret;
}

#
# Create a usergroup object to propagate back to the caller
#
sub blank_usergrp {
  my $class = shift;
  my $self = bless { }, $class;
  return $self;
}

#
# Retrieve a group given a group id
#
sub lookup {
  my $class = shift;
  my %params = validate(@_, {id => 1});
  my $id = $params{id};

  my $dbh;
  my $sqlstmt;
  my $sth;
  my $usergrp;
  my @columns;

  $dbh = RHN::DB->connect;
  $sqlstmt = $ug_table->select_query("UG.ID = ?");
  $sth = $dbh->prepare($sqlstmt);
  $sth->execute($id);
  @columns = $sth->fetchrow;
  $sth->finish;

  if ($columns[0]) {
    $usergrp = $class->blank_usergrp;
    $usergrp->{id} = $columns[0];
    foreach ($ug_table->method_names) {
      $usergrp->$_(shift @columns)
    }
    delete $usergrp->{":modified:"};
  }
  else {
    local $" = ", ";
    die "Error loading usergroup $id (@columns)";
  }

  return $usergrp;
}

sub create {
  my $class = shift;

  my $ug = $class->blank_usergrp;
  $ug->{id} = -1;

  return $ug;
}

#
# Delete a group given a group id
#
sub remove {
  my $class = shift;
  my $id = shift;
  my $dbh;
  my $sqlstmt;
  my $sth;

  $dbh = RHN::DB->connect;

  $sqlstmt = "DELETE FROM " . $ug_table->table_name . " WHERE id=?";
  $sth = $dbh->prepare($sqlstmt);
  $sth->execute($id);

  $dbh->commit;
  $sth->finish;
}

#
# build some accessors
#
foreach my $field ($ug_table->method_names) {
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

#
# Commit fields iff they have been updated
#
sub commit {
  my $self = shift;
  my $mode = 'update';

  if ($self->id == -1) {
    my $dbh = RHN::DB->connect;

    my $sth = $dbh->prepare("SELECT rhn_user_group_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    #warn "id: $id";
    die "No new ugroup id from seq rhn_user_group_id_seq (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;

    $self->{":modified:"}->{id} = 1;
    $self->{id} = $id;
    $mode = 'insert';
  }

  die "$self->commit called on usergroup without valid id" unless $self->id;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my $dbh = RHN::DB->connect;

  my $query;
  if ($mode eq 'update') {
    $query = $ug_table->update_query($ug_table->methods_to_columns(@modified));
    $query .= "UG.ID = ?";
  }
  else {
    $query = $ug_table->insert_query($ug_table->methods_to_columns(@modified));
  }

  #warn "ins/upd query: $query";

  my $sth = $dbh->prepare($query);
  $sth->execute((map { $self->$_() } grep { $modified{$_} } $ug_table->method_names), ($mode eq 'update') ? ($self->id) : ());

  $dbh->commit;

  delete $self->{":modified:"};
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
SELECT COUNT(user_id)
  FROM rhnUserGroupMembers UGM
 WHERE UGM.user_group_id = ?
EOT

  my $sth = $dbh->prepare($sqlstmt);
  $sth->execute($id);

  my ($count) = $sth->fetchrow;
  $sth->finish;

  return $count;
}

#
# Return all users in the given group id
#
sub users_in_group {
  my $class = shift;
  my $id = shift;

  die "Attempt to lookup users in group without a group id" if(!$id);
  my $dbh = RHN::DB->connect;

  my $sqlstmt = sprintf <<EOT; 
SELECT U.id, U.login
FROM rhnUser U, rhnUserGroupMembers M
WHERE U.id = M.user_id AND M.user_group_id = ?
ORDER BY U.login_uc
EOT

  my $sth = $dbh->prepare($sqlstmt);
  $sth->execute($id);  

  my @users;

  while (my ($id, $login) = $sth->fetchrow) {
    push @users, [ $id, $login ];
  }

  return @users;
}

1;

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

package RHN::DB::CustomInfoKey;

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

use RHN::DB;
use RHN::DB::TableClass;

use Carp;

my @channel_fields = qw/ID ORG_ID LABEL DESCRIPTION CREATED_BY LAST_MODIFIED_BY CREATED:longdate MODIFIED:longdate/;
my @creator_fields = qw/ID LOGIN/;
my @modifier_fields = qw/ID LOGIN/;

my $cdk = new RHN::DB::TableClass("rhnCustomDataKey", "CDK", "", @channel_fields);

# build some accessors
foreach my $field ($cdk->method_names) {
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

sub delete_key {
  my $class = shift;
  my %params = validate(@_, {key_id => 1, user_id => 1, transaction => 0});
  my $key_id = $params{key_id};
  my $dbh = $params{transaction} || RHN::DB->connect();

  my $sth = $dbh->prepare(<<EOQ);
DECLARE
BEGIN

DELETE FROM rhnServerCustomDataValue
      WHERE server_id IN (SELECT server_id FROM rhnUserServerPerms WHERE user_id = :user_id)
        AND key_id = :key_id;

DELETE FROM rhnCustomDataKey WHERE ID = :key_id;
END;
EOQ

  $sth->execute_h(key_id => $key_id, user_id => $params{user_id});

  if (defined $params{transaction}) {
    return $dbh;
  }
  else {
    $dbh->commit;
  }
}

sub blank_key {
  my $class = shift;

  my $self = bless { }, $class;
  $self->{__id__} = -1;
  return $self;
}

sub commit {
  my $self = shift;
  my $transaction = shift;
  my $mode = 'update';

  if ($self->id == -1) {
    my $dbh = $transaction || RHN::DB->connect;

    my $sth = $dbh->prepare("SELECT rhn_cdatakey_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    die "No new channel id from seq rhn_cdatakey_id_seq.nextval (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;

    $self->{":modified:"}->{id} = 1;
    $self->{__id__} = $id;
    $mode = 'insert';
  }

  die "$self->commit called on channel without valid id" unless $self->id and $self->id > 0;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my $dbh = $transaction || RHN::DB->connect;

  my $query;
  if ($mode eq 'update') {
    my @cols = $cdk->methods_to_columns(@modified);
    $query = $cdk->update_query(@cols);
    $query .= "CDK.ID = ?";
  }
  else {
    $query = $cdk->insert_query($cdk->methods_to_columns(@modified));
  }


  my $sth = $dbh->prepare($query);
  $sth->execute((map { $self->$_() } grep { $modified{$_} } $cdk->method_names), ($mode eq 'update') ? ($self->id) : ());

  $dbh->commit unless $transaction;
  delete $self->{":modified:"};
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {id => 1});
  my $id = $params{id};

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = $cdk->select_query("CDK.ID = ?");
  $sth = $dbh->prepare($query);
  $sth->execute($id);

  my @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  if ($columns[0]) {
    $ret = $class->blank_key;

    $ret->{__id__} = $columns[0];
    $ret->$_(shift @columns) foreach $cdk->method_names;
    delete $ret->{":modified:"};
  }
  else {
    local $" = ", ";
    die "Error loading custom data key $id; no ID? (@columns)";
  }

  return $ret;
}


1;

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
package RHN::DB::CryptoKey;

use RHN::DB;
use RHN::DB::TableClass;
use RHN::DataSource::Simple;

use RHN::Exception;
use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my @ck_fields = qw/ID ORG_ID DESCRIPTION CRYPTO_KEY_TYPE_ID/;
my @all_fields = (@ck_fields, 'KEY');
my $c = new RHN::DB::TableClass("rhnCryptoKey", "CK", "", @ck_fields);

sub new {
  my $class = shift;

  return bless { }, $class;
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, { id => 1 });
  my $id = $params{id};

  my $sqlstmt = $c->select_query("CK.id = ?");

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare($sqlstmt);
  $sth->execute($id);

  my @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  if ($columns[0]) {
    $ret = $class->new;

    foreach ($c->method_names) {
      $ret->{"__".$_."__"} = shift @columns;
    }

    delete $ret->{":modified:"};
  }
  else {
    local $" = ", ";
    throw '(crypto_key_does_not_exist)';
  }

  $sth = $dbh->prepare("SELECT key FROM rhnCryptoKey WHERE id = ?");
  $sth->execute($id);
  ($ret->{__internal_key__}) = $sth->fetchrow;
  $sth->finish;

  return $ret;
}

# build some accessors
foreach my $field (map { lc } @ck_fields) {
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

sub key {
  my $self = shift;
  if (@_) {
    $self->{__internal_key__} = shift;
  }
  return $self->{__internal_key__};
}

sub commit {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;
  my %tc_method_names = map { $_ => 1 } $c->method_names;

  my ($mode, $query, @params);
  if ($self->id) {
    $query = $c->update_query($c->methods_to_columns(@modified));
    @params = ((map { $self->$_() } grep { $modified{$_} } $c->method_names), $self->id);
    $mode = 'update';
    $query .= "CK.id = ?";
  }
  else {
    $mode = 'insert';
    $self->{":modified:"}->{id} = 1;
    $self->{__id__} = $dbh->sequence_nextval("rhn_cryptokey_id_seq");

    push @modified, 'id';
    $query = $c->insert_query($c->methods_to_columns(@modified));
    @params = (map { $self->$_() } grep { $modified{$_} } $c->method_names);
    unshift @params, $self->{__id__};
  }

  my $sth;

  $sth = $dbh->prepare($query);
  $sth->execute(@params);

  # tableclass horks on blobs, so update here by hand
  $sth = $dbh->prepare("UPDATE rhnCryptoKey SET key = :key WHERE id = :id");
  $sth->execute_h(id => $self->id, key => $dbh->encode_blob($self->{__internal_key__}, 'key'));

  $dbh->commit;

  delete $self->{":modified:"};
}

sub set_type {
  my $self = shift;
  my $type = shift;

  my $dbh = RHN::DB->connect;

  my $query = <<EOQ;
SELECT CKT.id
  FROM rhnCryptoKeyType CKT
 WHERE CKT.label = :label
EOQ

  my $sth = $dbh->prepare($query);
  $sth->execute_h(label => $type);

  my $row = $sth->fetchrow_hashref;
  $sth->finish;

  $self->crypto_key_type_id($row->{ID});
}

sub key_type_list {
  my $class = shift;

  my $ds = new RHN::DataSource::Simple(-querybase => "General_queries");
  $ds->mode("crypto_key_types");
  return @{$ds->execute_query};
}

sub delete {
  my $self = shift;

  my $dbh = RHN::DB->connect;
  $dbh->do_h("DELETE FROM rhnCryptoKey WHERE id = :id", id => $self->id);
  $dbh->commit;
}

1;

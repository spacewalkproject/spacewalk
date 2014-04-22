#
# Copyright (c) 2008--2012 Red Hat, Inc.
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

package RHN::DB::Profile;

use RHN::DB;
use RHN::DB::TableClass;

use RHN::DataSource::Simple;
use RHN::DataSource::Package;

use RHN::Profile ();
use RHN::Server ();

use Params::Validate qw/:all/;
Params::Validate::validation_options(strip_leading => "-");

my @p_fields = qw/id org_id base_channel name description info created modified profile_type_id/;

my $p = new RHN::DB::TableClass("rhnServerProfile", "P", "", @p_fields);

sub blank_profile {
  my $class = shift;

  my $self = bless { }, $class;

  return $self;
}

sub create {
  my $class = shift;

  my $p = $class->blank_profile;
  $p->{__id__} = -1;

  $p->set_profile_type('normal');
  return $p;
}

# build some accessors
foreach my $field ($p->method_names) {
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

sub set_profile_type {
  my $self = shift;
  my $label = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare('SELECT id FROM rhnServerProfileType WHERE label = :l');
  $sth->execute_h(l => $label);

  my ($ret) = $sth->fetchrow;
  die "invalid profile type $label" unless defined $ret;

  $self->profile_type_id($ret);
}

sub lookup {
  my $class = shift;
  my %params = validate(@_, {id => 1});
  my $id = $params{id};

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = $p->select_query("P.ID = ?");

  $sth = $dbh->prepare($query);
  $sth->execute($id);

  my @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  if ($columns[0]) {
    $ret = $class->blank_profile;

    $ret->{__id__} = $columns[0];
    $ret->$_(shift @columns) foreach $p->method_names;
    delete $ret->{":modified:"};
  }
  else {
    local $" = ", ";
    die "Error loading profile $id; no ID? (@columns)";
  }

  return $ret;
}

sub commit {
  my $self = shift;
  my $transaction = shift;
  my $mode = 'update';

  my $dbh = $transaction || RHN::DB->connect;

  if ($self->id == -1) {
    my $sth = $dbh->prepare("SELECT sequence_nextval('rhn_server_profile_id_seq') FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    $sth->finish;

    $self->{":modified:"}->{id} = 1;
    $self->{__id__} = $id;
    $mode = 'insert';
  }

  die "$self->commit called on server profile without valid id" unless $self->id and $self->id > 0;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my $query;
  if ($mode eq 'update') {
    $query = $p->update_query($p->methods_to_columns(@modified));
    $query .= "P.ID = ?";
  }
  else {
    $query = $p->insert_query($p->methods_to_columns(@modified));
  }

  my $sth = $dbh->prepare($query);
  $sth->execute((map { $self->$_() } grep { $modified{$_} } $p->method_names), ($mode eq 'update') ? ($self->id) : ());

  $dbh->commit unless $transaction;
  delete $self->{":modified:"};
}

sub compatible_with_channel {
  my $class = shift;
  my %params = validate(@_, { cid => 1, org_id => 1 });

  my $ds = new RHN::DataSource::Simple(-querybase => "profile_queries", -mode => "compatible_with_channel");
  return @{$ds->execute_query( map { ("-$_", $params{$_} ) } keys %params )};
}

# goofy, but useful
sub base_channel_id {
  my $self = shift;

  return $self->base_channel;
}

1;

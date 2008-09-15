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

package RHN::DB::Message::ServerMessage;

use RHN::DB;
use RHN::DB::TableClass;
use RHN::DB::Message;

use Data::Dumper;

use Carp;

our @ISA = qw/RHN::DB::Message/;

my @server_message_fields = qw/MESSAGE_ID SERVER_ID SERVER_EVENT/;
my @user_message_fields = qw/MESSAGE_ID USER_ID STATUS/;

my $s = new RHN::DB::TableClass("rhnServerMessage", "SM", "", @server_message_fields);
my $u = new RHN::DB::TableClass("rhnUserMessage", "UM", "user", @user_message_fields);

my $sm = RHN::DB::Message->tc->create_join([ $s, $u ], { "rhnMessage" => { "rhnServerMessage" => [ "ID", "MESSAGE_ID" ],
  								           "rhnUserMessage" => [ "ID", "MESSAGE_ID" ] } });

#class methods

sub lookup_message {
  my $class = shift;
  my $id = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = $sm->select_query("M.id = ?");
  $sth = $dbh->prepare($query);
  $sth->execute($id);

  my @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  if ($columns[0]) {
    $ret = $class->_blank_message();
    foreach ($sm->method_names) {
      $ret->{"__${_}__"} = shift @columns;
    }

    delete $ret->{":modified:"};
  }
  return $ret;
}

sub _blank_message {
  my $class = shift;

  my $self = bless { }, $class;

  return $self;
}

sub create_message {
  my $class = shift;

  my $mes = $class->_blank_message;
  $mes->{__id__} = -1;

  return $mes;
}

# build some accessors
foreach my $field ($sm->method_names) {
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

sub commit {
  my $self = shift;
  my $mode = 'update';

  if ($self->id == -1) {
    my $dbh = RHN::DB->connect;

    my $sth = $dbh->prepare("SELECT rhn_m_id_seq.nextval FROM DUAL");
    $sth->execute;
    my ($id) = $sth->fetchrow;
    die "No new message id from seq rhn_m_id_seq (possible error: " . $sth->errstr . ")" unless $id;
    $sth->finish;

    $self->{":modified:"}->{id} = 1;
    $self->{__id__} = $id;
    $self->{":modified:"}->{message_id} = 1;
    $self->{__message_id__} = $id;
    $mode = 'insert';
  }

  die "$self->commit called on message without valid id" unless $self->id and $self->id > 0;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my $dbh = RHN::DB->connect;

  my @queries;
  if ($mode eq 'update') {
    @queries = $sm->update_queries($sm->methods_to_columns(@modified));
  }
  else {
    @queries = $sm->insert_queries($sm->methods_to_columns(@modified));
  }

  foreach my $query (@queries) {
    my $sth = $dbh->prepare($query->[0]);
    my @vars = ((map { $self->$_() } grep { exists $modified{$_} } @{$query->[1]}), $modified{id} ? () : $self->id);
    $sth->execute(@vars);
  }

  $dbh->commit;
  delete $self->{":modified:"};
}

1;

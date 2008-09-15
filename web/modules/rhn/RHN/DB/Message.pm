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

package RHN::DB::Message;

use RHN::DB;
use RHN::DB::TableClass;

use Carp;

my @message_fields = qw/ID MESSAGE_TYPE PRIORITY CREATED:longdate MODIFIED:longdate/;

my $m = new RHN::DB::TableClass("rhnMessage", "M", "", @message_fields);

#class methods

sub lookup_message {
  my $class = shift;
  my $id = shift;

  my $dbh = RHN::DB->connect;

  my $query;
  my $sth;

  $query = $m->select_query("M.id = ?");
  $sth = $dbh->prepare($query);
  $sth->execute($id);

  my @columns = $sth->fetchrow;
  $sth->finish;

  my $ret;
  if ($columns[0]) {
    $ret = $class->_blank_message();
    foreach ($m->method_names) {
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
foreach my $field ($m->method_names) {
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
    $mode = 'insert';
  }

  die "$self->commit called on message without valid id" unless $self->id and $self->id > 0;

  my @modified = keys %{$self->{":modified:"}};
  my %modified = map { $_ => 1 } @modified;

  return unless @modified;

  my $dbh = RHN::DB->connect;

  my $query;
  if ($mode eq 'update') {
    $query = $m->update_query($m->methods_to_columns(@modified));
    $query .= "M.ID = ?";
  }
  else {
    $query = $m->insert_query($m->methods_to_columns(@modified));
  }

  my $sth = $dbh->prepare($query);
  $sth->execute((map { $self->$_() } grep { $modified{$_} } $m->method_names), ($mode eq 'update') ? ($self->id) : ());

  $dbh->commit;
  delete $self->{":modified:"};
}

sub tc {
  return $m;
}

sub user_messages {
  my $class = shift;
  my %attr = @_;

  my ($uid, $lower, $upper, $total_ref, $mode, $mode_params, $all_ids) = map { $attr{"-" . $_} } qw/uid lower upper total_rows mode mode_params all_ids/;

  $lower ||= 1;
  $upper ||= 100000;

  die "user_messages called without uid" unless defined $uid;

  my $query;

  if ($mode eq 'all') {

  $query =<<EOQ;
SELECT DISTINCT M.id, M.modified
  FROM rhnMessage M, rhnUserMessage UM, rhnUserMessageStatus UMS
 WHERE UM.user_id = ?
   AND M.id = UM.message_id
ORDER BY M.modified DESC
EOQ
}
  elsif ($mode eq 'status') {

  $query =<<EOQ;
SELECT DISTINCT M.id, M.modified
  FROM rhnMessage M, rhnUserMessage UM, rhnUserMessageStatus UMS
 WHERE UM.user_id = ?
   AND M.id = UM.message_id
   AND UM.status = UMS.id
   AND UMS.label = ?
ORDER BY M.modified DESC
EOQ
}

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare($query);
  $sth->execute(@{$mode_params});

  my @ids;
  my $i = 0;

  while (my ($id) = $sth->fetchrow) {
    push @{$all_ids}, $id if $all_ids;

    $i++;
    if ($i >= $lower and $i <= $upper) {
      push @ids, $id;
    }
  }

  $$total_ref = $i;

  if (@ids) {
    $sth = $dbh->prepare(sprintf(<<EOQ, join(", ", ('?') x (scalar @ids))));
  SELECT distinct M.id, M.message_type, M.priority, UMS.label,
         (SELECT SM.server_id FROM rhnServerMessage SM WHERE SM.message_id = M.id),
         (SELECT S.name FROM rhnServer S, rhnServerMessage SM WHERE SM.message_id = M.id AND S.id = SM.server_id),
         (SELECT SE.details FROM rhnServerEvent SE, rhnServerMessage SM WHERE SM.message_id = M.id AND SE.id = SM.server_event),
         (SELECT TM.message_body FROM rhnTextMessage TM WHERE TM.message_id = M.id),
         TO_CHAR(M.created, 'YYYY-MM-DD HH24:MI:SS'), TO_CHAR(M.modified, 'YYYY-MM-DD HH24:MI:SS')
    FROM rhnMessage M, rhnUserMessage UM, rhnUserMessageStatus UMS
   WHERE M.id IN (%s)
     AND UM.message_id = M.id
     AND UMS.id = UM.status
ORDER BY TO_CHAR(M.modified, 'YYYY-MM-DD HH24:MI:SS') DESC
EOQ

    $sth->execute(@ids);

    my @ret;

   while (my @row = $sth->fetchrow) {
	push @ret, [ @row ];
    }
    return @ret;
  }
  return ();
}

sub update_status_from_set {
  my $class = shift;
  my $status = shift;
  my $set = shift;


  my $dbh = RHN::DB->connect;
  my $query = <<EOQ;
UPDATE rhnUserMessage UM
   SET UM.status = (SELECT UMS.id FROM rhnUserMessageStatus UMS WHERE UMS.label = ?)
 WHERE UM.message_id IN(SELECT element FROM rhnSet S WHERE S.user_id = ? AND S.label = ?)
EOQ

  my $sth = $dbh->prepare($query);

  $sth->execute($status, $set->uid, $set->label);

  $dbh->commit;

  return 1;
}

1;

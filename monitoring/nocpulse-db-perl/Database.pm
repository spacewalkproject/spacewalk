package NOCpulse::Database;
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

use strict;

use RHN::DB;

# Basic constructor.  accepts one mandantory param, type.
sub new {
  my $class = shift;
  my %params = @_;

  my $type = $params{type} || '';
  die "Invalid NOCpulse::Database type: $type"
    unless $type eq 'time_series' or $type eq 'state_change';

  my $self = bless { table_name => $type }, $class;

  return $self;
}

# insert values into the db
sub insert {
  my $self = shift;
  my $oid = shift;
  my $key = shift;
  my $value = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
INSERT INTO $self->{table_name}
  (o_id, entry_time, data)
VALUES
  (:o_id, :entry_time, :data)
EOS

  $sth->execute_h(o_id => $oid, entry_time => $key, data => $value);
  $dbh->commit;

  return 1;
}

# insert a list of values into the db (unused?)
sub insert_list {
  my $self = shift;
  my $oid = shift;
  my $list = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
INSERT INTO $self->{table_name}
  (o_id, entry_time, data)
VALUES
  (:o_id, :entry_time, :data)
EOS

  while (@$list) {
    my ($k, $v) = splice @$list, 0, 2, ();
    $sth->execute_h(o_id => $oid, entry_time => $k, data => $v);
  }

  $dbh->commit;

  return 1;
}

# fetch values from the db in a given range.  if get_initial is true,
# then it gets the first value BEFORE start, too.
sub fetch {
  my $self = shift;
  my $oid = shift;
  my $start = shift;
  my $end = shift;
  my $get_initial = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT entry_time, data
  FROM $self->{table_name}
 WHERE entry_time BETWEEN :entry_start AND :entry_end
   AND o_id = :o_id
EOS

  $sth->execute_h(o_id => $oid, entry_start => $start, entry_end => $end);

  my @ret;
  while (my ($when, $data) = $sth->fetchrow) {
    push @ret, $when, $data;
  }

  if ($get_initial) {
    # nothing in this time period, so we must return just the last
    # datapoint in the dataset
    if (not @ret) {
      return [ $self->last($oid) ];
    }

    if ($ret[0] > $start) {
      unshift @ret, $self->last($oid, $start);
    }
  }

  return \@ret;
}

# get the last value in the db, or the last value before a $before if
# specified
sub last {
  my $self = shift;
  my $oid = shift;
  my $before = shift;

  my $before_clause = '';
  my @params = (o_id => $oid);

  if (defined $before) {
    $before_clause = "   AND entry_time < :before";
    push @params, (before => $before);
  }

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT entry_time, data
  FROM $self->{table_name}
 WHERE o_id = :o_id
$before_clause
ORDER BY entry_time DESC
EOS

  $sth->execute_h(@params);
  my ($k, $v) = $sth->fetchrow;
  $sth->finish;

  return defined $k ? ($k, $v) : ();
}

# delete a value from the db; unused?
sub delete {
  my $self = shift;
  my $oid = shift;
  my $key = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
DELETE FROM $self->{table_name}
      WHERE o_id = :o_id
        AND entry_time = :key
EOS

  $sth->execute_h(o_id => $oid, key => $key);
  $dbh->commit;

  return 1;
}

# originally returned the size of the berkeley file... so I made up a
# value.  unused?
sub size {
  my $self = shift;
  my $oid = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
SELECT COUNT(*)
  FROM $self->{table_name}
 WHERE o_id = :oid
EOS

  $sth->execute_h(o_id => $oid);
  my ($count) = $sth->fetchrow;
  $sth->finish;

  return ($count * 1024);
}

1;

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
    unless $type eq 'time_series_data' or $type eq 'state_change';

  my $self = bless { table_name => $type }, $class;

  return $self;
}

sub get_insert_sth {
  my $self = shift;
  my $dbh = shift;

  my $sth;

  if ($self->{table_name} eq 'state_change') {
     $sth = $dbh->prepare(<<EOS);
insert into $self->{table_name}
    (o_id, entry_time, data) values
    (:o_id, :entry_time, :data)
EOS
  }

  if ($self->{table_name} eq 'time_series_data') {
     $sth = $dbh->prepare(<<EOS);
insert into $self->{table_name}
    (org_id, probe_id, probe_desc, entry_time, data) values
    (:org_id, :probe_id, :probe_desc, :entry_time, :data)
EOS
  }

  return $sth;
}

sub do_insert {
  my $self = shift;
  my $sth = shift;
  my $oid = shift;
  my $key = shift;
  my $value = shift;

  if ($self->{table_name} eq 'state_change') {
     $sth->execute_h(o_id => $oid, entry_time => $key, data => $value);
  }

  if ($self->{table_name} eq 'time_series_data') {
    my ($org_id, $probe_id, $probe_desc) = split /-/, $oid;
    $sth->execute_h(org_id => $org_id,
                    probe_id => $probe_id,
                    probe_desc => $probe_desc,
                    entry_time => $key,
                    data => $value);
  }
}

# insert values into the db
sub insert {
  my $self = shift;
  my $oid = shift;
  my $key = shift;
  my $value = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $self->get_insert_sth($dbh);
  $self->do_insert($sth, $oid, $key, $value);
  $dbh->commit;

  return 1;
}

# insert a list of values into the db (unused?)
sub insert_list {
  my $self = shift;
  my $oid = shift;
  my $list = shift;

  my $dbh = RHN::DB->connect;
  my $sth = $self->get_insert_sth($dbh);

  while (@$list) {
    my ($k, $v) = splice @$list, 0, 2, ();
    $self->do_insert($sth, $oid, $k, $v);
  }

  $dbh->commit;

  return 1;
}

sub get_oid_condition {
  my $self = shift;

  my $condition;

  if ($self->{table_name} eq 'state_change') {
    $condition = "oid = :oid";
  }

  if ($self->{table_name} eq 'time_series_data') {
    $condition = "org_id = :org_id and probe_id = :probe_id and probe_desc = :probe_desc";
  }

  return $condition;
}

sub execute_sth {
  my $self = shift;
  my $sth = shift;
  my $oid = shift;
  my $time1 = shift;
  my $time2 = shift;

  my @params = ();

  if ($self->{table_name} eq 'state_change') {
    push @params, (oid => $oid);
  }

  if ($self->{table_name} eq 'time_series_data') {
    my ($org_id, $probe_id, $probe_desc) = split /-/, $oid;
    push @params, (org_id => $org_id);
    push @params, (probe_id => $probe_id);
    push @params, (probe_desc => $probe_desc);
  }

  if (defined $time1) {
    push @params, (time1 => $time1);
  }

  if (defined $time2) {
    push @params, (time2 => $time2);
  }

  $sth->execute_h(@params);
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
select entry_time, data
  from $self->{table_name}
 where entry_time between :time1 and :time2
   and $self->get_oid_condition()
EOS

  $self->execute_sth($sth, $oid, $start, $end);

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

  if (defined $before) {
    $before_clause = " and entry_time < :time2";
  }

  my $dbh = RHN::DB->connect;
  my $sth = $dbh->prepare(<<EOS);
select entry_time, data
  from $self->{table_name}
 where $self->get_oid_condition()
$before_clause
order by entry_time desc
EOS

  $self->execute_sth($sth, $oid, undef, $before);
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
delete from $self->{table_name}
      where $self->get_oid_condition()
        and entry_time = :time1
EOS

  $self->execute_sth($sth, $oid, $key, undef);
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
select count(*)
  from $self->{table_name}
 where $self->get_oid_condition()
EOS

  $sth->execute_h(o_id => $oid);
  my ($count) = $sth->fetchrow;
  $sth->finish;

  return ($count * 1024);
}

1;

#
# Copyright (c) 2008--2015 Red Hat, Inc.
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

package RHN::DB;

use strict;
use RHN::DBI ();
use Carp;
use RHN::Exception;

our @ISA = qw/DBI/;

# this forces connection immediately after form, before first request
# is served.  can cause a bit of a rush to the db as a bunch of
# httpd's connect, but should be manageable.  typically called in
# startup.pl.

sub apache_child_init_handler {
  my $class = shift;
  $class->connect();
}

my $dbh;

sub connect {
  my $class = shift;
  if (@_) {
    Carp::confess "The RHN::DB::connect does not accept any parameters.\n";
  }

  if (defined $dbh and $dbh->ping()) {
    return $dbh;
  }

  my ($dsn, $login, $password, $attr) = RHN::DBI::_get_dbi_connect_parameters();
  $attr->{HandleError} = \&RHN::DB::handle_error;
  $attr->{private_rhndb_transaction_level} = 0;

  $dbh = $class->direct_connect($dsn, $login, $password, $attr);

  # this dbh is from a cache, which means disconnects fail
  $dbh->{private_from_cache} = 1;
  Carp::croak "$class->connect() failed: $DBI::errstr" unless $dbh;

  $dbh->init_db_handle();
  $dbh->init_db_session();

  if (not $dbh->ping()) {
    $dbh->force_disconnect;

    Carp::croak("Cannot ping database handle: $DBI::errstr");
  }
  return $dbh;
}

sub direct_connect {
  my $class = shift;
  my $connection = shift;
  my $username = shift;
  my $password = shift;
  my $options = shift;

  my $dbh = $class->SUPER::connect($connection, $username, $password, $options);

  return $dbh;
}

sub handle_error {
  my ($error, $handle, $failed_ret) = @_;

  my $query = ($handle->isa("DBI::st") or $handle->isa("DBI::db")) ? $handle->{Statement} : "";
  if ($error =~ /^.*?ORA-(\d+).*?\((.*?)\)/) {
    RHN::Exception::DB->throw(-text => $error, -oracle_error => [ "ORA-$1", $error, $2], $query ? (-query => $query) : (), -severity => "schema");
  }
  else {
    RHN::Exception::DB->throw(-text => $error, -severity => "schema");
  }
}

package RHN::DB::db;
our @ISA = qw/DBI::db/;

sub in_nested_transaction {
  my $self = shift;

  return ($self->{private_rhndb_transaction_level} || 0) > 0 ? 1 : 0;
}

sub assert_nested_transaction {
  my $self = shift;
  RHN::Exception::DB->throw(-text => "assert_transactional failed", -severity => "schema") unless $self->in_nested_transaction;
}

sub current_savepoint_name {
  my $self = shift;
  $self->assert_nested_transaction;

  return sprintf("RHNDB_TX_AUTOSAVE_%02d", $self->{private_rhndb_transaction_level});
}

sub commit {
  my $self = shift;

  if ($self->in_nested_transaction) {
    $self->do("SAVEPOINT " . $self->current_savepoint_name);
  }
  else {
    $self->SUPER::commit(@_);
  }
}

sub rollback {
  my $self = shift;

  if ($self->in_nested_transaction) {
    $self->do("ROLLBACK TO " . $self->current_savepoint_name);
  }
  else {
    $self->SUPER::rollback(@_);
  }
}

sub init_db_handle {
  my $self = shift;

  $self->{LongReadLen} = 1024 * 1024;
  $self->{RowCacheSize} = 500;
}

sub init_db_session {
  my $self = shift;

  # No need for OPTIMIZER_MODE in the new Oracle 10g, 11g
  # Let's use default CBO
  if ($self->{Driver}->{Name} eq 'Oracle') {
    $self->do("begin DBMS_APPLICATION_INFO.SET_MODULE(?, NULL); end;", undef, $0);
  } elsif ($self->{Driver}->{Name} eq 'SQLite') {
    $self->do("pragma synchronous = off");
  }
}

sub disconnect {
  my $dbh = shift;

  if ($dbh->{private_from_cache}) {
    $dbh->set_err(99999, "Can't disconnect cache-loaded RHN::DB handle");
  }
  else {
    $dbh->SUPER::disconnect(@_);
  }
}

sub force_disconnect {
  my $self = shift;

  $self->SUPER::disconnect(@_);
}

sub ping {
  my $class = shift;
  my $dbh;

  if (ref $class) {
    $dbh = $class;
  }
  else {
    $dbh = shift;
  }

  my $ret = eval {
    if ($dbh->{Driver}->{Name} eq 'Pg') {
      return $dbh->SUPER::ping();
    }

    my $ping_query = "SELECT 1 + 2 FROM DUAL";

    my $sth = $dbh->prepare_cached($ping_query);
    return 0 unless $sth;
    return 0 unless $sth->execute;

    my ($sum) = $sth->fetchrow;

    return 0 unless $sum == 3 and not $sth->fetchrow;

    return 1;
  };

  if ($@) {
    return 0;
  }
  else {
    return $ret;
  }
}

# another package
package RHN::DB::st;
our @ISA = qw/DBI::st/;

# We do this because we're not guaranteed the next fetch won't simply
# change values in the href in place instead of creating a new one.
# in fact, it is explicitly guaranteed to change later, so...
sub fetchrow_hashref_copy {
  my $self = shift;
  my $ret = $self->SUPER::fetchrow_hashref(@_);
  return defined $ret ? { %$ret } : undef;
}

sub execute_h {
  my $self = shift;
  my @params = @_;

  $self->set_err(99998, "Odd number of params to execute_h") if @params % 2;

  while (my ($k, $v) = (splice @params, 0, 2, ())) {

    my $attr = {};
    use Scalar::Util qw/blessed/;

    if (ref $v and blessed($v) and $v->isa("RHN::DB::Type::BLOB")) {
      if ($self->{Database}->{Driver}->{Name} eq 'Oracle') {
        eval 'use DBD::Oracle ()';
        if ($@) { die $@; }
        $attr->{ora_type} = DBD::Oracle::ORA_BLOB();
        if (defined $v->{ora_field}) {
          $attr->{ora_field} = $v->{ora_field};
        }
      } elsif ($self->{Database}->{Driver}->{Name} eq 'Pg') {
        eval 'use DBD::Pg ()';
        $attr->{pg_type} = DBD::Pg::PG_BYTEA();
      }
      $v = $v->{value};
    }

    # this allows for inout binds; for instance, DELETE and INSERT with RETURNING clauses
    if (ref $v eq 'SCALAR') {
      $self->bind_param_inout(":$k" => $v, 4096, $attr);
    }
    else {
      $self->bind_param(":$k" => $v, $attr);
    }
  }

  return $self->execute();
}

sub fullfetch {
  my $self = shift;

  my @ret;

  while (my @row = $self->fetchrow) {
    push @ret, [ @row ];
  }

  return @ret;
}

sub fullfetch_hashref {
  my $self = shift;

  my @ret;

  while (my $row = $self->fetchrow_hashref_copy) {
    push @ret, $row;
  }

  return @ret;
}

1;

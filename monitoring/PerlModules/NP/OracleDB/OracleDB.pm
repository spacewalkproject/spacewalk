######################################
package NOCpulse::OracleDB;
######################################

use vars qw($VERSION);
$VERSION = (split(/\s+/, q$Id: OracleDB.pm,v 1.3 2005-07-06 20:51:40 nhansen Exp $, 4))[2];

use strict;
use DBI;
use NOCpulse::Debug;
use NOCpulse::Config;
use RHN::DBI;

# Global defaults
my $DEFAULTDATEFORMAT  = 'YYYY-MM-DD HH24:MI:SS';
my %DEBUG_PARAMS;

# Description cache for sub desc()
my %DESC;


###############################################
# Generic Class Methods
###############################################

##############
sub setDebug {
##############
  $DEBUG_PARAMS{'LEVEL'} = shift;
}

####################
sub setDebugParams {
####################
  my %params = @_;
  my $param;
  foreach $param (keys %params) {
    $DEBUG_PARAMS{$param} = $params{$param};
  }
}



###############################################
# Generic Object Methods
###############################################

# Accessor methods
sub cfg         { shift->_elem('cfg',         @_); }
sub connected   { shift->_elem('connected',   @_); }
sub dateformat  { shift->_elem('dateformat',  @_); }
sub dbd         { shift->_elem('dbd',         @_); }
sub dbh         { shift->_elem('dbh',         @_); }
sub dbname      { shift->_elem('dbname',      @_); }
sub dbpasswd    { shift->_elem('dbpasswd',    @_); }
sub dbuname     { shift->_elem('dbuname',     @_); }
sub debug       { shift->_elem('debug',       @_); }
sub desc_cache  { shift->_elem('desc_cache',  @_); }
sub oracle_home { shift->_elem('oracle_home', @_); }


# Constructor
#########
sub new {
#########

  my ($class) = shift;
  my $conf    = shift;
  my $self    = {};
  bless $self, $class;

  $self->debug(new NOCpulse::Debug());
  my $stream = $self->debug->addstream(%DEBUG_PARAMS);
  $stream->prefix('+++ ');

  $self->dprint(3, defined($conf) ?  "Using conf file '$conf'\n" :
                                     "Using default conf file\n");
  $self->cfg(new NOCpulse::Config($conf));

  $self->oracle_home($self->cfg->get('oracle', 'ora_home'));
  $self->dprint(3, "ORACLE_HOME is '", $self->oracle_home, "'\n");

  $self->dateformat($DEFAULTDATEFORMAT);
  $self->dprint(3, "Default date format is '", $self->dateformat, "'\n");

  $self->desc_cache(1);
  $self->dprint(3, "Description cache enabled\n");

  return $self;
}


# Print debugging statements
############
sub dprint {
############
  my($self) = shift;
  $self->debug->dprint(@_);
  $self->debug->flush();
}


# Accessor implementation (stolen from LWP::MemberMixin
# by Martijn Koster and Gisle Aas)
#########
sub _elem
#########
{
        my($self, $elem, $val) = @_;
        my $old = $self->{$elem};
        $self->{$elem} = $val if defined $val;
        return $old;
}


#############
sub connect {
#############

  # Usage:
  # my $oracle = new NOCpulse::OracleDB;
  # $oracle->connect( 'PrintError'=>0, 'RaiseError'=>1, 'AutoCommit'=>0 );

  my ($self, %paramHash) = @_;

  my $PrintError = $paramHash{PrintError} || 0;
  my $RaiseError = $paramHash{RaiseError} || 1;
  my $AutoCommit = $paramHash{AutoCommit} || 0;

  $self->dprint(2, "Connecting to DB\n");
  my $dbh      = RHN::DBI->connect;

  if ($DBI::err) { $@ = $DBI::errstr ;  return undef }

  # Rember dbh
  $self->dbh($dbh);
  $self->connected(1);


  return $self;

}

################
sub disconnect {
################

  my ($self) = @_;

  # Close the connection to the DB
  $self->dbh->disconnect if ($self->connected());
  $self->connected(0);

}

############
sub commit {
############

  my ($self) = @_;

  # Commit changes to the database
  $self->dbh->commit if ($self->connected());

}


##############
sub rollback {
##############

  my ($self) = @_;

  # Roll back changes to the database
  $self->dbh->rollback if($self->connected());

}



############
sub dbexec {
############

  my ($self, $sql_statement, @bindvars) = @_;

  # Make sure we have an open DB handle
  $self->connect() unless ($self->connected());

  $self->dprint(4, "\t\tEXECUTING:\n$sql_statement\n");
  if (scalar(@bindvars)) {
    $self->dprint(4, "\t\tBIND VARS: '", join("', '", @bindvars), "')\n");
  }

  # Prepare the statement handle
  my $statement_handle = $self->dbh->prepare($sql_statement);
  if ($DBI::err) { $@ = $DBI::errstr ;  return [] }

  # Execute the query, bail out if it fails
  my $rc;
  eval { 
    $rc = $statement_handle->execute(@bindvars); 
  };
  return [] if ($@);

  # Fetch the data, if any
  my $dataref = [];
  if ($statement_handle->{NUM_OF_FIELDS}) {
    $dataref = $statement_handle->fetchall_arrayref;
    $self->dprint(4, "\t\tGot ", scalar(@$dataref), " rows\n");
    if ($DBI::err) { $@ = $DBI::errstr ;  return [] }
  } else {
    $self->dprint(4, "Got 0 rows\n");
  }

  # Close the statement handle
  $statement_handle->finish;
  if ($DBI::err) { $@ = $DBI::errstr ;  return [] }

  return $dataref;
}


#############
sub DESTROY {
#############
  my $self = shift;
  $self->disconnect();
}



###############################################
# SQL Methods
###############################################

##########
sub desc {
##########
  my($self, $tablename) = @_;

  # Fetch the description from cache if it exists
  if ($self->desc_cache()) {
    return $DESC{uc($tablename)} if (exists($DESC{uc($tablename)}));
  }

  my $sql = "SELECT   LOWER(t.column_name),t.data_type,
                      t.data_precision,t.nullable
             FROM     all_tab_columns t, all_synonyms s
             WHERE    UPPER(t.table_name) = UPPER(?)
             AND      t.table_name = s.table_name
             AND      t.owner = s.table_owner
             AND      s.owner = 'PUBLIC'
             ORDER BY t.column_id";

  my $output = $self->dbexec($sql, $tablename);

  $DESC{uc($tablename)} = $output if ($self->desc_cache());

  return $output;
}



#############
sub TableOp {
#############

  my $self          = shift;
  my $table         = shift;
  my $colref        = shift;
  my $keycols       = shift;
  my $action        = shift;
  my $whereclauses  = shift || [];
  my $bindvars      = shift || [];
  my $orderby       = shift || [];
  my $sql_statement;
  my(@cols, @colexp, $col);

  $self->dprint(2, "In TableOp, performing '$action' op on '$table'\n");


  if ($action eq 'insert') {

    $self->dprint(3, "\tInserting into table\n");
    my $cols   = join(',', @$colref);
    $sql_statement = sprintf<<EOSQL, join(', ', @$whereclauses);
    INSERT INTO $table ($cols)
    VALUES (%s)
EOSQL

  } elsif ($action eq 'update') {

    # For updates:
    #  $orderby contains things to set

    $self->dprint(3, "\tUpdating table\n");
    $sql_statement = sprintf<<EOSQL, join(', ', @$orderby);
    UPDATE $table
    SET %s
EOSQL

    if (scalar(@$whereclauses)) {
      $sql_statement .= "WHERE " . join(' AND ', @$whereclauses);
    }


  } elsif ($action eq 'select') {

    $self->dprint(3, "\tSelecting from table\n");

    # Support "SELECT <expression> as <colname>"
    foreach $col (@$colref) {
      if ($col =~ /\s+as\s+/) {
	my($expr, $colname) = split(/\s+as\s+/, $col);
	push(@cols, $colname);
	push(@colexp, $expr);
      } else {
	push(@cols,   $col);
	push(@colexp, $col);
      }
    }
    my $cols   = join(',', @colexp);

    $sql_statement = sprintf<<EOSQL;
    SELECT $cols
    FROM   $table
EOSQL

    if (scalar(@$whereclauses)) {
      $sql_statement .= "\nWHERE " . join(' AND ', @$whereclauses);
    }

    if (scalar(@$orderby)) {
      $sql_statement .= "\nORDER BY " . join(', ', @$orderby);
    }

  } else {

    $@ = "ERROR: Unsupported action '$action'";
    $self->dprint(1, "\t$@\n");
    return undef;
    
  }


  # Fetch/insert the data
  my $rows_ref	 = $self->dbexec($sql_statement, @$bindvars);
  $self->dprint(3, "\t\tROWS_REF is '$rows_ref' (@$rows_ref)\n");
  $self->dprint(3, "\t\t\$\@ is '$@'\n");

  if ($@) {

    $self->dprint(3, "\t\t$action FAILED: $@\n");
    return undef;

  } elsif ($action eq 'insert') {

    $self->dprint(3, "\t\tInsert successful\n");
    $self->commit();

  } elsif ($action eq 'update') {

    $self->dprint(3, "\t\tUpdate successful\n");
    $self->commit();

  } else {

    # Put the table data in a strucured hash
    $self->dprint(3, "\t\tSelect successful\n");
    my($row, $col, %data, @ord);
    foreach $row (@$rows_ref) {
      my %record;
      foreach $col (@cols) {
	$record{lc($col)} = shift @$row;
      }
      my $keyval = $self->keyval($keycols, \%record);
      $data{$keyval} = \%record;
      push(@ord, $keyval)
    }

    # Return the table data and ordered hash
    return (\%data, \@ord);

  }

} # End of TableOp





###############################################
# Utility Methods
###############################################

############
sub keyval {
############
  # Given a row and comma-separated list of columns, return
  # a '|'-separated list of values.
  my($self, $keycols, $record) = @_;
  my(@key, $col);
  foreach $col (split(',', $keycols)) {
    push(@key, $record->{lc($col)});
  }
  return join('|', @key);
}

1;

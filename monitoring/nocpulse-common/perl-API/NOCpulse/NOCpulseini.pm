package NOCpulse::NOCpulseini;

use strict;
use DBI;
use NOCpulse::Config;
use IO::AtomicFile;
use LWP::UserAgent;

use Class::MethodMaker
  get_set =>
  [qw(
        cfg
        dbh
        filename
        macrodb
        paramdb
     )],
  new_with_init => 'new',
  ;

my $nocpulseini_file = '/etc/NOCpulse.ini';

##########
sub init {
##########
  my $self = shift;
  my $args = shift;

  $self->filename($nocpulseini_file);

  $self->cfg(NOCpulse::Config->new($self->filename));

}

# Remove the NOCPulse.ini file - used when restarting the service to
# force download of a new file.
sub remove_config_file {
  my $class = shift;

  unlink($nocpulseini_file);

  return;
}

#############
sub connect {
#############
  my $self = shift;

  my $dbd      = shift;
  my $dbname   = shift;
  my $username = shift;
  my $password = shift;
  my $orahome  = shift;

  $ENV{'ORACLE_HOME'} = $orahome;  # base dir for Oracle

  # Make DB connection
  my $dbh = DBI->connect("DBI:$dbd:$dbname", $username, $password);

  # Set up for graceful exit
  $SIG{'INT'} = $self->can('bailout');

  unless (defined($dbh)) {
    $self->bailout("ERROR:  connect failed: $DBI::errstr\n") 
  }

  $self->dbh($dbh);

  return $dbh;

}



##########
sub save {
##########
  my $self     = shift;
  my $filename = shift || $self->filename;
  my $data     = shift || $self->dump();

  my $fh;
  unless ($fh = IO::AtomicFile->open($filename, 'w')) {
    $@ = "Couldn't open $filename: $!";
    return undef;
  }

  print $fh $data;

  $fh->close();

  # Be sure to make the file world-readable!
  chmod(0644, $filename) or die "Couldn't chmod $filename: $!";

}




##########
sub dump {
##########
  my $self = shift;

  my $pdb = $self->paramdb();

  my $str;

  foreach my $grp (sort keys %$pdb) {
    $str .= "[$grp]\n";
    $str .= "# $pdb->{$grp}->{'desc'}\n";

    foreach my $param (sort keys %{$pdb->{$grp}->{'params'}}) {
      $str .= join('=', $param, $pdb->{$grp}->{'params'}->{$param}) . "\n";
    }
    $str .= "\n\n";
  }

  return $str;

}



##################
sub fetch_macros {
##################
  my $self = shift;
  my $mdb = {};
  $self->macrodb($mdb);

  # Fetch macros
  my $sql = q{
    SELECT   macro.name, macro.definition, macro.description
    FROM     db_environment dbenv, config_macro macro
    WHERE    UPPER(sys_context('userenv', 'db_name')) = UPPER(dbenv.db_name)
    AND      DECODE(macro.environment, 'ALL', dbenv.environment,
                    macro.environment) = dbenv.environment
  };

  my $list = $self->do_fetch_hash($sql);

  # First, create a database of unexpanded macros
  foreach my $macro (@$list) {
    $mdb->{$macro->{'NAME'}} = $macro->{'DEFINITION'};
  }

  # Next, expand the macros
  foreach my $macroname (keys %{$mdb}) {
    $mdb->{$macroname} = $self->expand($mdb->{$macroname});
  }

}



##################
sub fetch_params {
##################
  my $self     = shift;
  my $sec_type = shift;
  my $pdb      = {};

  $self->paramdb($pdb);

  # Fetch parameters from the database
  my $sql = q{
    SELECT   cgrp.description, cparam.group_name, cparam.name, cparam.value
    FROM     config_group cgrp, config_parameter cparam
    WHERE    cparam.group_name = cgrp.name
    AND      ? = DECODE(cparam.security_type, 'ALL', ?,
                                              cparam.security_type)
    ORDER BY cparam.group_name, cparam.name};

  my $rv = $self->do_fetch($sql, $sec_type, $sec_type);

  # Create a parameter database, expanding macros as we go
  foreach my $rec (@$rv) {
    my($gdesc, $gname, $pname, $value) = @$rec;
    $value = $self->expand($value);
    $pdb->{$gname}->{'desc'} = $gdesc;
    $pdb->{$gname}->{'params'}->{$pname} = $value;
  }


}




############
sub expand {
############
  my $self  = shift;
  my $value = shift;

  # Store literal percents using OOB data
  $value =~ s/%%/\0/g;

  # Expand macros only on the value
  my(%seen, $last);
  while ($value =~ /%{(\w+)}/mg) {
    my $submacro = $1;

    # Avoid recursive loops
    if ($seen{$submacro}++) {
      die "Macro expansion loop:  macro '$last' refers to '$submacro'";
    }

    if (exists($self->macrodb->{$submacro})) {
      my $expn = $self->macrodb->{$submacro};
      $value =~ s/%{$submacro}/$expn/;
    } else {
      die "Reference to nonexistent macro '$submacro'\n";
    }

    $last = $submacro;
  }

  # Retore literal percents as percent signs
  $value =~ s/\0/%/g;

  return $value;
}


##############
sub do_fetch {
##############
  my $self = shift;
  my($sql, @args) = @_;
  my $sth = $self->dbh->prepare($sql);
  $sth->execute(@args);
  my $output = $sth->fetchall_arrayref;
  return $output;
}


###################
sub do_fetch_hash {
###################
  my $self = shift;
  my($sql, @args) = @_;
  my $sth = $self->dbh->prepare($sql);
  $sth->execute(@args);
  my $output = $sth->fetchall_arrayref({});
  return $output;
}




#############
sub bailout {
#############
  my $self = shift;

  # Use instead of 'exit' if $dbh is open
  $self->dbh->disconnect() if (defined($self->dbh));

  die @_;
}


#######################
sub fetch_nocpulseini {
#######################
  my $self     = shift;
  my $sec_type = shift;

  # Fetch macro definitions
  $self->fetch_macros();

  # Fetch parameters
  $self->fetch_params($sec_type);

}


##########################
sub download_nocpulseini {
##########################
  my $self = shift;
  my $url  = shift;

  my $ua  = LWP::UserAgent->new();
  my $res = $ua->get($url);
  if ($res->is_success) {

    $self->save($self->filename, $res->content);
    
  } else {

    die "Couldn't download NOCpulse.ini:  " . $res->status_line . "\n";

  }

}



1;

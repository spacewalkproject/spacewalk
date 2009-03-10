package NOCpulse::ReleaseDB;

use strict;
use Data::Dumper;
use Error qw(:try);
use NOCpulse::Config;
use NOCpulse::Probe::DataSource::AbstractDatabase qw(:constants);
use NOCpulse::Probe::DataSource::Oracle;
use NOCpulse::Probe::Error;

use base qw(NOCpulse::Probe::DataSource::Oracle);

use vars qw($VERSION);
$VERSION = (split(/\s+/,
     q$Id: ReleaseDB.pm,v 1.32 2003-02-21 21:32:33 cvs Exp $,
     4))[2];

my $cfg = new NOCpulse::Config;

my %INIT_ARGS = (
   ORACLE_HOME  => $cfg->get('oracle',     'ora_home'),
   ora_port     => $cfg->get('oracle',     'ora_port'),
   ora_host     => $cfg->get('release_db', 'host'),
   ora_sid      => $cfg->get('release_db', 'name'),
   ora_user     => $cfg->get('release_db', 'username'),
   ora_password => $cfg->get('release_db', 'password'),
  );


# Constants
use constant MCLASS  => 'MacroComponent';
use constant DBRANCH => 'main';


# Global variable initialization
use vars qw(%DETAIL);
&init_details();


##########
sub init {
##########
  my $self = shift;
  my %args = (%INIT_ARGS, @_);

  $self->SUPER::init(%args);

  return $self;
}





###################
# RECORD CREATION #
###################

sub create_component         { shift->_create('COMPONENT',         @_) }
sub create_component_class   { shift->_create('COMPONENT_CLASS',   @_) }
sub create_release           { shift->_create('RELEASE',           @_) }

sub create_release_component_version 
    { shift->_create('RELEASE_COMPONENT_VERSION',      @_) }

sub create_component_version_dependency 
    { shift->_create('COMPONENT_VERSION_DEPENDENCY',   @_) }


# Special handling
sub create_component_version { 
  my $self = shift;
  my %bindvars = @_;

  $bindvars{'SORT_STRING'} = $self->ver2str($bindvars{'COMPONENT_VERSION'});

  $self->_create('COMPONENT_VERSION', %bindvars);
}


# Special handling
sub create_box {
  my $self = shift;
  my %bindvars = @_;

  # Override -- MACRO_CLASS *must* be MCLASS
  $bindvars{'MACRO_CLASS'} = MCLASS;

  $self->_create('BOX', %bindvars);

}

sub create_macro_component {
  my $self = shift;
  my %bindvars = @_;

  # Override -- MACRO_CLASS *must* be MCLASS
  $bindvars{'MACRO_CLASS'} = MCLASS;

  $self->_create('MACRO_COMPONENT', %bindvars);

}






#################################
# SINGLE-TABLE RECORD SELECTION #
#################################

# Single record selection
sub select_box               { shift->_select_record('BOX',               @_) }
sub select_component         { shift->_select_record('COMPONENT',         @_) }
sub select_component_class   { shift->_select_record('COMPONENT_CLASS',   @_) }
sub select_component_version { shift->_select_record('COMPONENT_VERSION', @_) }
sub select_macro_component   { shift->_select_record('MACRO_COMPONENT',   @_) }
sub select_release           { shift->_select_record('RELEASE',           @_) }
sub select_screen            { shift->_select_record('SCREEN',           @_) }
sub select_component_version_dependency 
    { shift->_select_record('COMPONENT_VERSION_DEPENDENCY', @_) }
sub select_release_component_version    
    { shift->_select_record('RELEASE_COMPONENT_VERSION',    @_) }



# Multiple record selection
sub select_boxes             { shift->_select_records('BOX',               @_) }
sub select_components        { shift->_select_records('COMPONENT',         @_) }
sub select_component_classes { shift->_select_records('COMPONENT_CLASS',   @_) }
sub select_component_versions{ shift->_select_records('COMPONENT_VERSION', @_) }
sub select_macro_components  { shift->_select_records('MACRO_COMPONENT',   @_) }
sub select_releases          { shift->_select_records('RELEASE',           @_) }
sub select_screens           { shift->_select_records('SCREEN',           @_) }
sub select_component_version_dependencies 
    { shift->_select_records('COMPONENT_VERSION_DEPENDENCY', @_) }
sub select_release_component_versions    
    { shift->_select_records('RELEASE_COMPONENT_VERSION',    @_) }



# Complex selection

##################
sub expand_macro {
##################
  my $self = shift;
  my %args = @_;
  my @bindvals;

  $self->_check_reqs(['MACRO_NAME'], \%args);
 # PGPORT_1:NO Change #
  my $sql = <<EOSQL;
    SELECT component_class, component_name
    FROM   macro_component
    WHERE  macro_class = ? 
    AND    macro_name = ?
EOSQL
  push(@bindvals, MCLASS, $args{'MACRO_NAME'});

  my @components;
  my $rv = $self->execute($sql, 'MACRO_COMPONENT', FETCH_ARRAYREF, @bindvals);
  push(@components, @$rv);

  if ($args{'RECURSIVE'}) {

    my @macros = grep($_->{'COMPONENT_CLASS'} eq MCLASS, @components);

    foreach my $macro (@macros) {
      my $rv = $self->expand_macro(
                                 MACRO_NAME => $macro->{'COMPONENT_NAME'},
                                 RECURSIVE  => 1,
			       );
      push(@components, @$rv);
    }

  } 

  if ($args{'NO_MACRO'}) {

    @components = grep($_->{'COMPONENT_CLASS'} ne MCLASS, @components);

  } elsif ($args{'MACRO_ONLY'}) {

    @components = grep($_->{'COMPONENT_CLASS'} eq MCLASS, @components);

  } 

  return \@components;

}

###############################
sub select_all_cvs_paths {
###############################
  my $self = shift;
  my @bindvals;
 # PGPORT_4:QUERY_REWRITE(UNIQUE) #
  my $sql = <<EOSQL;
	SELECT UNIQUE CVS_PATH
	FROM COMPONENT
	WHERE CVS_PATH IS NOT NULL
	AND NAME IN (
		SELECT UNIQUE COMPONENT_NAME
		FROM MACRO_COMPONENT
		WHERE COMPONENT_NAME IS NOT NULL
	)
EOSQL

  my $arryref = $self->execute($sql, 
                        [qw(COMPONENT)], 
                        FETCH_ARRAYREF, @bindvals);
  my @result = map { $_->{'CVS_PATH'} } @$arryref;
  return \@result;
}

###############################
sub select_release_components {
###############################
  my $self = shift;
  my %args = @_;
  my @bindvals;

  my($pk) = $self->_details('RELEASE', 'pk');

  $self->_check_reqs($pk, \%args);

  my($wherephrase, $bindvals) = $self->_wherephrase(\%args);
 # PGPORT_1:NO Change #
  my $sql = <<EOSQL;
    SELECT BOX_TYPE, BOX_NAME, VERSION, RELEASE_NUMBER,
           rcv.COMPONENT_CLASS as COMPONENT_CLASS,
           rcv.COMPONENT_NAME as COMPONENT_NAME,
           rcv.COMPONENT_VERSION as COMPONENT_VERSION,
           rcv.CVS_BRANCH as CVS_BRANCH,
           SORT_STRING, INSTALL_SWITCHES, PACKAGE_FILENAME, 
           BUILD_DATE, BUILD_USER
    FROM   component_version cv, release_component_version rcv
    WHERE  $wherephrase
    AND    rcv.COMPONENT_CLASS = cv.COMPONENT_CLASS
    AND    rcv.COMPONENT_NAME = cv.COMPONENT_NAME
    AND    rcv.COMPONENT_VERSION = cv.COMPONENT_VERSION
    AND    rcv.CVS_BRANCH = cv.CVS_BRANCH
EOSQL

  return $self->execute($sql, 
                        [qw(COMPONENT_VERSION RELEASE_COMPONENT_VERSION)], 
                        FETCH_ARRAYREF, @$bindvals);

}


######################################
sub select_current_component_version {
######################################
  my $self = shift;
  my %args = @_;

  $args{'CVS_BRANCH'} ||= DBRANCH;

  my($wherephrase, $bindvals) = $self->_wherephrase(\%args);
 # PGPORT_1:NO Change #
  my $sql = <<EOSQL;
    SELECT *
    FROM   component_version cv
    WHERE  cv.sort_string = (
	SELECT   max(sort_string)
	FROM     component_version
	WHERE    component_name = cv.component_name
	AND      component_class = cv.component_class
	AND      cvs_branch = cv.cvs_branch)
EOSQL

  $sql .= "AND " . $wherephrase if ($wherephrase);

  return $self->execute($sql, 'RELEASE_COMPONENT_VERSION', 
                        FETCH_ARRAYREF, @$bindvals);
}




################################
# MULTI-TABLE RECORD SELECTION #
################################


###################################
sub select_current_macro_versions {
###################################

  my $self = shift;
  my %args = @_;
  my @bindvals;

  $self->_check_reqs(['MACRO_NAME'], \%args);

  $args{'CVS_BRANCH'} ||= DBRANCH;
 # PGPORT_5:POSTGRES_VERSION_QUERY(START WITH CONNECT BY CLAUSE) #
  my $sql = <<EOSQL;
    SELECT *
    FROM   component_version outer
    WHERE  cvs_branch = ?
    AND    component_class || component_name in (
       SELECT     component_class || component_name
       FROM       macro_component
       START WITH macro_name = ?
       CONNECT BY prior component_class = macro_class
       AND        prior component_name = macro_name)
    AND sort_string = (
       SELECT max(sort_string)
       FROM   component_version v
       WHERE  v.component_class = outer.component_class
       AND    v.component_name = outer.component_name
       AND    v.cvs_branch = outer.cvs_branch)
EOSQL

  push(@bindvals, $args{'CVS_BRANCH'}, $args{'MACRO_NAME'});

  my @tables = qw(COMPONENT_VERSION MACRO_COMPONENT);

  return $self->execute($sql, \@tables, FETCH_ARRAYREF, @bindvals);

}



################################
# SINGLE-TABLE RECORD DELETION #
################################

# Single record deletion
sub delete_box               { shift->_delete_record('BOX',               @_) }
sub delete_component         { shift->_delete_record('COMPONENT',         @_) }
sub delete_component_class   { shift->_delete_record('COMPONENT_CLASS',   @_) }
sub delete_component_version { shift->_delete_record('COMPONENT_VERSION', @_) }
sub delete_macro_component   { shift->_delete_record('MACRO_COMPONENT',   @_) }
sub delete_release           { shift->_delete_record('RELEASE',           @_) }
sub delete_screen            { shift->_delete_record('SCREEN',           @_) }
sub delete_component_version_dependency 
    { shift->_delete_record('COMPONENT_VERSION_DEPENDENCY', @_) }
sub delete_release_component_version    
    { shift->_delete_record('RELEASE_COMPONENT_VERSION',    @_) }



# Multiple record deletion
sub delete_boxes             { shift->_delete_records('BOX',               @_) }
sub delete_components        { shift->_delete_records('COMPONENT',         @_) }
sub delete_component_classes { shift->_delete_records('COMPONENT_CLASS',   @_) }
sub delete_component_versions{ shift->_delete_records('COMPONENT_VERSION', @_) }
sub delete_macro_components  { shift->_delete_records('MACRO_COMPONENT',   @_) }
sub delete_releases          { shift->_delete_records('RELEASE',           @_) }
sub delete_screens           { shift->_delete_records('SCREEN',           @_) }
sub delete_component_version_dependencies 
    { shift->_delete_records('COMPONENT_VERSION_DEPENDENCY', @_) }
sub delete_release_component_versions    
    { shift->_delete_records('RELEASE_COMPONENT_VERSION',    @_) }



###############################
# SINGLE-TABLE RECORD UPDATES #
###############################

# Single record update
sub update_box               { shift->_update_record('BOX',               @_) }
sub update_component         { shift->_update_record('COMPONENT',         @_) }
sub update_component_class   { shift->_update_record('COMPONENT_CLASS',   @_) }
sub update_component_version { shift->_update_record('COMPONENT_VERSION', @_) }
sub update_macro_component   { shift->_update_record('MACRO_COMPONENT',   @_) }
sub update_release           { shift->_update_record('RELEASE',           @_) }
sub update_screen            { shift->_update_record('SCREEN',           @_) }
sub update_component_version_dependency 
    { shift->_update_record('COMPONENT_VERSION_DEPENDENCY', @_) }
sub update_release_component_version    
    { shift->_update_record('RELEASE_COMPONENT_VERSION',    @_) }



# Multiple record update
sub update_boxes             { shift->_update_records('BOX',               @_) }
sub update_components        { shift->_update_records('COMPONENT',         @_) }
sub update_component_classes { shift->_update_records('COMPONENT_CLASS',   @_) }
sub update_component_versions{ shift->_update_records('COMPONENT_VERSION', @_) }
sub update_macro_components  { shift->_update_records('MACRO_COMPONENT',   @_) }
sub update_releases          { shift->_update_records('RELEASE',           @_) }
sub update_screens          { shift->_update_records('SCREEN',           @_) }
sub update_component_version_dependencies 
    { shift->_update_records('COMPONENT_VERSION_DEPENDENCY', @_) }
sub update_release_component_versions    
    { shift->_update_records('RELEASE_COMPONENT_VERSION',    @_) }


######################
# COMPLEX OPERATIONS #
######################

#############################
sub verify_macro_components {
#############################
  my $self = shift;
  my %args = @_;
  my @bindvals;


  my ($DEFAULT) = $self->_details('COMPONENT_VERSION', 'defaults');
  $args{'CVS_BRANCH'} ||= $DEFAULT->{'CVS_BRANCH'};

  $self->_check_reqs(['MACRO_NAME'], \%args);

  # Three steps:
  #   1) Verify that macro exists;
  my $rec = $self->select_component(
                    CLASS => MCLASS,
                    NAME  => $args{'MACRO_NAME'},
                  );

  throw NOCpulse::Probe::DataSource::ConfigError(
    "Cannot verify '$args{'MACRO_NAME'}': nonexistent macro\n"
  ) unless ($rec);

 # PGPORT_1:NO Change #
  #   2) Verify all non-macro components;
  my $sql = <<EOSQL;
    SELECT   mc.component_class, mc.component_name
    FROM     macro_component mc
    WHERE    mc.macro_class = ?
    AND      mc.macro_name  = ?
    AND      mc.component_class != ?
    AND      not exists (
      SELECT 1 
      FROM   component_version 
      WHERE  component_class = mc.component_class
      AND    component_name = mc.component_name
      AND    cvs_branch = ?)
EOSQL

  push(@bindvals, MCLASS, $args{'MACRO_NAME'}, MCLASS, $args{'CVS_BRANCH'});

  my $missing = $self->execute($sql, 'MACRO_COMPONENT', FETCH_ARRAYREF, 
                               @bindvals);
  my @missing = map($_->{'COMPONENT_NAME'}, @$missing);

  if (scalar(@$missing)) {

      throw NOCpulse::Probe::DataSource::CommandFailedError(
        "\n  The following $args{MACRO_NAME} components have no version " .
	"on the '$args{CVS_BRANCH}' branch:\n    " . join(" ", @missing) . "\n"
      );
  }



  #   3) Recursively verify macro components;
  my $macro_components = $self->expand_macro(
                                  MACRO_NAME => $args{'MACRO_NAME'},
				  MACRO_ONLY => 1);
  my @macros = map($_->{'COMPONENT_NAME'}, @$macro_components);

  try {

    foreach my $macro (@macros) {
      $self->verify_macro_components(MACRO_NAME => $macro,
                                     CVS_BRANCH => $args{'CVS_BRANCH'});
    }

  } catch NOCpulse::Probe::DataSource::CommandFailedError with {

      my $err = shift;
      my $msg = $err->{'-message'};
      throw NOCpulse::Probe::DataSource::CommandFailedError(
        "\n  Failure verifying $args{'MACRO_NAME'}$msg"
      );

  }

}



##################
sub make_release {
##################
  my $self = shift;
  my %args = @_;
  my @bindvals;

  #   1) Fetch box record to get macro
  #   2) Verify release macro
  #   3) Create a RELEASE record
  #   4) Fetch the latest versions of the components for the release
  #   5) Create RELEASE_COMPONENT_VERSION records for the release 
  #      components

  my ($DEFAULT) = $self->_details('RELEASE', 'defaults');
  $args{'RELEASE_DATE'} ||= $DEFAULT->{'RELEASE_DATE'};
  $args{'RELEASED'}     ||= $DEFAULT->{'RELEASED'};
  $args{'CVS_BRANCH'}   ||= DBRANCH;

  my $boxkey    = $self->_details('BOX', 'pk');
  my @relfields = qw(VERSION RELEASE_NUMBER RELEASE_USER);

  $self->_check_reqs([@$boxkey, @relfields], \%args);


  #   1) Fetch box record to get macro
  my %boxkey;
  foreach my $field (@$boxkey) {
    $boxkey{$field} = $args{$field};
  }

  my $boxrec = $self->select_box(%boxkey);

  $args{'MACRO_NAME'} = $boxrec->{'MACRO_NAME'};

  #   2) Verify release macro
  $self->verify_macro_components(%args);

  #   3) Create a RELEASE record
  $self->create_release(%args);

  #   4) Fetch the latest versions of the components for the release
  my $components = $self->select_current_macro_versions(%args);


  #   5) Create RELEASE_COMPONENT_VERSION records for the release 
  #      components
  foreach my $crec (@$components) {
    $self->create_release_component_version(%args, %$crec);
  }

  return $components;

}



#################
sub make_branch {
#################
  my $self = shift;
  my %args = @_;
  my @bindvals;

  $args{'TRUNK'} ||= DBRANCH;

  $self->_check_reqs([qw(CVS_BRANCH)], \%args);

  # 1) Bail out if the branch already exists
  #  # PGPORT_1:NO Change #
  my $sql = <<EOSQL;
    SELECT count(*) as RECORDS
    FROM   component_version
    WHERE  cvs_branch = ?
EOSQL

  my $rv = $self->execute($sql, 'COMPONENT_VERSION', FETCH_SINGLE, 
                          $args{'CVS_BRANCH'});
  if ($rv->{'RECORDS'}) {
    throw NOCpulse::Probe::DataSource::ConfigError(
      "Branch '$args{CVS_BRANCH}' already exists.\n"
    );
  }


  # 2) Create branch by copying COMPONENT_VERSION
  #    records from the trunk to the branch
  # PGPORT_1:NO Change #
  $sql = <<EOSQL;
  INSERT INTO component_version (
      COMPONENT_CLASS, COMPONENT_NAME, COMPONENT_VERSION, SORT_STRING,
      CVS_BRANCH, INSTALL_SWITCHES, PACKAGE_FILENAME, BUILD_DATE, BUILD_USER)
    SELECT   cv.component_class, cv.component_name, cv.component_version,
	     cv.sort_string, ?, cv.install_switches,
	     cv.package_filename, cv.build_date, cv.build_user
      FROM     component_version cv
      WHERE    cv.cvs_branch = ?
      AND      cv.sort_string = (
	SELECT   max(sort_string)
	FROM     component_version
	WHERE    component_name = cv.component_name
	AND      component_class = cv.component_class
	AND      cvs_branch = cv.cvs_branch)
EOSQL

  $rv = $self->execute($sql, 'COMPONENT_VERSION', FETCH_ROWCOUNT, 
                       $args{'CVS_BRANCH'}, $args{'TRUNK'});

  return $rv;

}


##################
sub merge_branch {
##################
  my $self = shift;
  my %args = @_;
  my @bindvals;

  $args{'TRUNK'} ||= DBRANCH;

  $self->_check_reqs([qw(CVS_BRANCH)], \%args);

  # 1) Bail out if the trunk doesn't exist
  # PGPORT_1:NO Change #
  my $sql = <<EOSQL;
    SELECT count(*) as RECORDS
    FROM   component_version
    WHERE  cvs_branch = ?
EOSQL
  my $rv = $self->execute($sql, 'COMPONENT_VERSION', FETCH_SINGLE, 
                          $args{'TRUNK'});
  unless ($rv->{'RECORDS'}) {
    throw NOCpulse::Probe::DataSource::ConfigError(
      "Trunk '$args{TRUNK}' does not exist.\n"
    );
  }



  # 2) Merge the branch by copying COMPONENT_VERSIONS to the
  #    branch thus:
  #  a) Change on trunk, no change on branch: do nothing (trunk
  #     is current)
  #  b) Change on branch, no change on trunk: COPY LATEST VERSION
  #     FROM BRANCH TO TRUNK.
  #  c) Changes on branch and on trunk:  do nothing (as a rebuild 
  #     on the trunk will be necessary, making the trunk current)
  #  d) No changes: do nothing (trunk is current)
  #
  # Situation b) is indicated when the latest version on the trunk
  # exists on the branch and is not equal to the latest version on
  # the branch.
  # PGPORT_1:NO Change #
  $sql = <<EOSQL;
  INSERT INTO component_version (
      COMPONENT_CLASS, COMPONENT_NAME, COMPONENT_VERSION, SORT_STRING,
      CVS_BRANCH, INSTALL_SWITCHES, PACKAGE_FILENAME, BUILD_DATE, BUILD_USER)
    SELECT   branch.component_class, branch.component_name, 
             branch.component_version, branch.sort_string, ?, 
	     branch.install_switches, branch.package_filename, 
	     branch.build_date, branch.build_user
    FROM     component_version branch
    WHERE    cvs_branch  = ?
    AND      sort_string = (
	  SELECT max(sort_string)
	  FROM   component_version
	  WHERE  component_class = branch.component_class
	  AND    component_name  = branch.component_name
	  AND    cvs_branch      = branch.cvs_branch)
    AND sort_string  != (
	  SELECT max(sort_string)
	  FROM   component_version
	  WHERE  component_class = branch.component_class
	  AND    component_name  = branch.component_name
	  AND    cvs_branch      = ?)
    AND (
      SELECT 1
      FROM   component_version
      WHERE  component_name  = branch.component_name
      AND    component_class = branch.component_class
      AND    cvs_branch      = branch.cvs_branch
      AND    sort_string = (
	  SELECT max(sort_string)
	  FROM   component_version
	  WHERE  component_class = branch.component_class
	  AND    component_name  = branch.component_name
	  AND    cvs_branch      = ?)
    ) = 1
EOSQL

  $rv = $self->execute($sql, 'COMPONENT_VERSION', FETCH_ROWCOUNT, 
                       $args{'TRUNK'}, $args{'CVS_BRANCH'},
		       $args{'TRUNK'}, $args{'TRUNK'});

  return $rv;

}



####################
sub copy_to_branch {
####################
  my $self = shift;
  my %args = @_;

  my $cvkey = $self->_details('COMPONENT_VERSION', 'pk');

  $self->_check_reqs($cvkey, \%args);

  my $branch = $args{'CVS_BRANCH'};
  $args{'CVS_BRANCH'} = delete($args{'TRUNK'}) || DBRANCH;

  my($wherephrase, $bindvals) = $self->_wherephrase(\%args);

  # Copy a single component version to a branch.
  # PGPORT_1:NO Change #
  my $sql = <<EOSQL;
  INSERT INTO component_version (
      COMPONENT_CLASS, COMPONENT_NAME, COMPONENT_VERSION, SORT_STRING,
      CVS_BRANCH, INSTALL_SWITCHES, PACKAGE_FILENAME, BUILD_DATE, BUILD_USER)
    SELECT   cv.component_class, cv.component_name, cv.component_version,
	     cv.sort_string, ?, cv.install_switches,
	     cv.package_filename, cv.build_date, cv.build_user
      FROM     component_version cv
      WHERE $wherephrase
EOSQL

  my $rv = $self->execute($sql, 'COMPONENT_VERSION', FETCH_ROWCOUNT, 
                          $branch, @$bindvals);

  return $rv;

}



##########################
sub delete_whole_release {
##########################
  my $self = shift;
  my %args = @_;

  my $rkey = $self->_details('RELEASE', 'pk');

  $self->_check_reqs($rkey, \%args);

  my($wherephrase, $bindvals) = $self->_wherephrase(\%args);

  # 1) Delete release_component_version records
  # PGPORT_1:NO Change #
  my $sql = <<EOSQL;
    DELETE FROM release_component_version
    WHERE $wherephrase
EOSQL

  $self->execute($sql, 'RELEASE_COMPONENT_VERSION', FETCH_ROWCOUNT, @$bindvals);


  # 2) Delete release record
  # PGPORT_1:NO Change #
  $sql = <<EOSQL;
    DELETE FROM release
    WHERE $wherephrase
EOSQL

  my $rv = $self->execute($sql, 'RELEASE', FETCH_ROWCOUNT, @$bindvals);

  return $rv;

}





##################
# SCHEMA DETAILS #
##################

##################
sub init_details {
##################
  %DETAIL = (

    'BOX' => {

      'cols'     => [qw(BOX_TYPE           BOX_NAME        
			MACRO_CLASS        MACRO_NAME 
			PARTITIONING       SCREEN_NAME
			KERNEL_PKG_NAME    KERNEL_PKG_CLASS 
			LAST_UPDATE_USER   LAST_UPDATE_DATE)],

      'pk'       => [qw(BOX_TYPE           BOX_NAME)],

      'defaults' => {
		      LAST_UPDATE_USER => 'nouser',
		      LAST_UPDATE_DATE => 'sysdate',
		    },
    },



    'COMPONENT' => {

      'cols'     => [qw(CLASS NAME CVS_PATH DEFAULT_SWITCHES)],

      'pk'       => [qw(CLASS NAME)],

      'defaults' => { },
    },

    
    'COMPONENT_CLASS' => {

      'cols'     => [qw(CLASS DESCRIPTION)],

      'pk'       => [qw(CLASS)],

      'defaults' => { },
    },

    
    'COMPONENT_VERSION' => {

      'cols'     => [qw(COMPONENT_CLASS   COMPONENT_NAME  COMPONENT_VERSION
                        SORT_STRING       CVS_BRANCH      INSTALL_SWITCHES 
		        PACKAGE_FILENAME  BUILD_USER      BUILD_DATE)],

      'pk'       => [qw(COMPONENT_CLASS   COMPONENT_NAME  
                        COMPONENT_VERSION CVS_BRANCH)],

      'defaults' => { 
                      CVS_BRANCH  => DBRANCH,
                      BUILD_DATE  => 'sysdate',
                      BUILD_USER  => 'nouser',
                    },
    },

    
    'COMPONENT_VERSION_DEPENDENCY' => {

      'cols'     => [qw(COMPONENT_CLASS  COMPONENT_NAME  COMPONENT_VERSION 
                        TYPE             RESOURCE_NAME   CVS_BRANCH)],

      'pk'       => [qw(COMPONENT_CLASS  COMPONENT_NAME  COMPONENT_VERSION 
                        TYPE             RESOURCE_NAME   CVS_BRANCH)],

      'defaults' => { 
                      CVS_BRANCH => DBRANCH,
                    },
    },

    
    'MACRO_COMPONENT' => {

      'cols'     => [qw(MACRO_CLASS MACRO_NAME COMPONENT_CLASS COMPONENT_NAME)],

      'pk'       => [qw(MACRO_CLASS MACRO_NAME COMPONENT_CLASS COMPONENT_NAME)],

      'defaults' => { },
    },

    
    'RELEASE' => {

      'cols'     => [qw( BOX_TYPE        BOX_NAME      VERSION       RELEASED
                         RELEASE_NUMBER  RELEASE_USER  RELEASE_DATE)],

      'pk'       => [qw(BOX_TYPE BOX_NAME VERSION RELEASE_NUMBER)],

      'defaults' => { 
                      RELEASED => 0,
                      RELEASE_USER => 'nouser',
                      RELEASE_DATE => 'sysdate',
                    },
    },

    
    'SCREEN' => {

      'cols'     => [qw( NAME FKEY DESCRIPTION )],

      'pk'       => [qw(NAME)],

      'defaults' => { 
                    },
    },

    
    'RELEASE_COMPONENT_VERSION' => {

      'cols'     => [qw(BOX_TYPE          BOX_NAME       
                        VERSION           RELEASE_NUMBER
			COMPONENT_CLASS   COMPONENT_NAME 
			COMPONENT_VERSION CVS_BRANCH)],

      'pk'       => [qw(BOX_TYPE          BOX_NAME       
                        VERSION           RELEASE_NUMBER
			COMPONENT_CLASS   COMPONENT_NAME 
			COMPONENT_VERSION CVS_BRANCH)],

      'defaults' => { },
    },


  );
}




######################
# INTERNAL FUNCTIONS #
######################

##############
sub _details {
##############
  my $self  = shift;
  my($table, @req) = @_;
  $table = uc($table);
  my @rv;

  foreach my $req (@req) {
    if (exists($DETAIL{$table}->{$req})) {

      push(@rv, $DETAIL{$table}->{$req});

    } else {

      throw NOCpulse::Probe::DataSource::ConfigError(
        "Unknown field '$req' requested from $table details\n"
      );

    }
  }

  return wantarray ? @rv : $rv[0];

}




#############
sub _create {
#############
  my $self   = shift;
  my $table  = shift;
  my %fields = @_;

  my ($COLS, $DEFAULT) = 
    $self->_details($table, 'cols', 'defaults');

  my($COLSTR) = join(',', @$COLS);

  my(@bindvars, @bindvals);
  foreach my $col (@$COLS) {
    $fields{$col} = $DEFAULT->{$col} unless (exists($fields{$col}));
    if ($DEFAULT->{$col} eq 'sysdate') {
      # Fancy stuff for sysdate
      # PGPORT_5:POSTGRES_VERSION_QUERY(SYSDATE) #
      push(@bindvars, 
	"DECODE(?, 'sysdate', sysdate, TO_DATE(?, 'YYYY-MM-DD HH24:MI:SS'))");
      push(@bindvals, $fields{$col}, $fields{$col});
    } else {
      push(@bindvars, '?');
      push(@bindvals, $fields{$col});
    }
  }
  my $BVSTR = join(',', @bindvars);


  my $sql = "INSERT INTO $table ($COLSTR) VALUES ($BVSTR)";

  return $self->execute($sql, $table, FETCH_ROWCOUNT, @bindvals);
}


####################
sub _select_record {
####################
  my $self  = shift;
  my $table = shift;
  my %args  = @_;

  my $pk    = $self->_details($table, 'pk');

  $self->_check_reqs($pk, \%args, 2);

  my $records = $self->_select_records($table, %args);

  return $records->[0];

}


#####################
sub _select_records {
#####################
  my $self  = shift;
  my $table = shift;
  my %args  = @_;

  my($wherephrase, $bindvals) = $self->_wherephrase(\%args);
 # PGPORT_1:NO Change #
  my $sql = <<EOSQL;
    SELECT *
    FROM   $table
    WHERE  $wherephrase
EOSQL


  return $self->execute($sql, $table, FETCH_ARRAYREF, @$bindvals);
}



####################
sub _delete_record {
####################
  my $self  = shift;
  my $table = shift;
  my %args  = @_;

  my $pk    = $self->_details($table, 'pk');

  $self->_check_reqs($pk, \%args, 2);

  return $self->_delete_records($table, %args);

}


#####################
sub _delete_records {
#####################
  my $self  = shift;
  my $table = shift;
  my %args  = @_;

  my($wherephrase, $bindvals) = $self->_wherephrase(\%args);
 # PGPORT_1:NO Change #
  my $sql = <<EOSQL;
    DELETE
    FROM   $table
    WHERE $wherephrase
EOSQL

  return $self->execute($sql, $table, FETCH_ROWCOUNT, @$bindvals);
}




####################
sub _update_record {
####################
  my $self  = shift;
  my $table = shift;
  my %args  = @_;

  my $pk    = $self->_details($table, 'pk');

  $self->_check_reqs($pk, \%args, 2);

  return $self->_update_records($table, %args);

}


#####################
sub _update_records {
#####################
  my $self  = shift;
  my $table = shift;
  my %args  = @_;

  $self->_check_reqs(['set'], \%args, 3);

  my $set = delete($args{'set'});

  my($setphrase,   $sbindvals) = $self->_wherephrase($set, ',');
  my($wherephrase, $wbindvals) = $self->_wherephrase(\%args);
 # PGPORT_1:NO Change #
  my $sql = <<EOSQL;
    UPDATE $table
    SET    $setphrase
    WHERE  $wherephrase
EOSQL

  return $self->execute($sql, $table, FETCH_ROWCOUNT, @$sbindvals, @$wbindvals);

}



#################
sub _check_reqs {
#################
  my($self, $reqs, $args, $clvl) = @_;
  $clvl ||= 1;

  foreach my $req (@$reqs) {
    unless (exists($args->{$req})) {
      my ($package, $filename, $line, $subroutine) = caller($clvl);
      throw NOCpulse::Probe::DataSource::ConfigError(
        "\n  Missing required params for $subroutine: @$reqs\n"
      );
    }
  }
}



##################
sub _wherephrase {
##################
  my($self, $args, $conj) = @_;
  $conj ||= 'AND';

  # Construct part of a WHERE clause with bind variables
  # given a hash of column => value pairs

  my(@bindvals, @wherephrases);
  while (my($col, $val) = each %$args) {
    push(@wherephrases, "$col = ?");
    push(@bindvals, $val);
  }

  return (join(" $conj ", @wherephrases), \@bindvals);

}


#####################
# UTILITY FUNCTIONS #
#####################

#############
sub ver2str {
#############
  my $self = shift;

  # Given a version string ("<version>-<relnum>"), compute a sort
  # string.
  my $verrel = shift;
  my($ver, $relnum) = split(/-/, $verrel, 2);
  my @verstr;

  foreach my $comp (split(/\./, $ver), '-', split(/\./, $relnum)) {

    if ($comp eq '-') {
      push(@verstr, $comp);
    } elsif ($comp =~ /\D/) {
      my $x = "0" x 10;
      substr($x, 10 - length($comp), length($comp)) = $comp;
      push(@verstr, $x);
    } else {
      push(@verstr, sprintf("%010d", $comp));
    }

  }

  return join('', @verstr);
}





1;

__END__

=head1 NAME

NOCpulse::ReleaseDB - access to the NOCpulse release database

=head1 SYNOPSIS

  use NOCpulse::ReleaseDB;
  
  # INITIALIZATION
  
  my $rdb = NOCpulse::ReleaseDB->new();
  

  # COMMIT OR ROLLBACK - autocommit is *OFF*
  
  # Commit changes to the database
  $rdb->commit();
  
  # Abort changes to the database
  $rdb->rollback();
  

  # RELEASE HANDLING
    
  # Create a branch from a trunk
  my $nrec = $rdb->make_branch(TRUNK => $trunk, CVS_BRANCH => $branch);
  
  # Merge a branch onto a trunk
  my $nrec = $rdb->merge_branch(TRUNK => $trunk, CVS_BRANCH => $branch);
  
  # Copy a component_version record from a trunk to the branch
  my $nrec = $rdb->merge_branch(%key_fields, TRUNK => $trunk);
  
  # Select a list of release component versions
  my $ary = $rdb->select_release_components(%release_fields);
  
  # Create a new release from current component versions
  my $ary = $rdb->make_release(%release_fields);
  
  # Select the current version of a component on a branch
  my $ary = $rdb->select_current_component_version(%key_fields);
  
  # Delete an entire release
  my $nrec = $rdb->delete_whole_release(%key_fields);
  
  

  # MACRO HANDLING
  
  # Expand a macro into its constitutent components
  my $ary = $rdb->expand_macro(MACRO_NAME => $macro_name);
  
  # Verify that all components of a macro have been built
  $rdb->verify_macro_components(MACRO_NAME => $macro_name);
  
  # Select a list of current component versions for a macro
  my $ary = $rdb->select_current_macro_versions(
                    MACRO_NAME => $macro_name
                  );
  
  

  # LOW-LEVEL FUNCTIONS
  
  # Create a record in any table (e.g. COMPONENT) in the database
  my $nrec = $rdb->create_component(%component_fields);
  
  # Select a single record from a table (e.g. COMPONENT) in the database
  my $rec = $rdb->select_component(%key_fields);
  
  # Select multiple records from a table (e.g. COMPONENT) in the database
  my $ary = $rdb->select_components(%key_fields);
  
  # Delete a single record from a table (e.g. COMPONENT) in the database
  my $nrec = $rdb->delete_component(%key_fields);
  
  # Delete multiple records from a table (e.g. COMPONENT) in the database
  my $nrec = $rdb->delete_components(%key_fields);
  
  

  # UTILITY FUNCTIONS
  
  # Convert a <version>-<relnum> string to a sort string
  my $sortstring = $rdb->ver2str($version);


=head1 DESCRIPTION

NOCpulse::ReleaseDB provides DBI-like access methods to the NOCpulse
release database.

Each method returns an array ($ary) of DBI-style database hash 
records (keys == colunm names, values == column values) or a count 
($nrec) of the number of rows affected.


=head1 METHODS

=over 4

=item NOCpulse::ReleaseDB->new()

Connects to the release database and returns a NOCpulse::ReleaseDB object.
 

=item make_branch()

  my $nrec = $rdb->make_branch(
                     CVS_BRANCH => $branch,
                     [TRUNK  => $trunk]
                   );

Create a branch from a trunk.  This method copies the latest versions 
of each component from the TRUNK (default 'main') to the CVS_BRANCH 
(which must not yet exist).  Returns the number of records copied.
 

=item merge_branch()

  my $nrec = $rdb->merge_branch(
                     CVS_BRANCH => $branch,
                     [TRUNK  => $trunk || 'main']
                   );

Merge a branch onto a trunk.  This method merges the branch onto
the trunk (default 'main') by copying the latest record from the
branch onto the trunk, where appropriate.  (Specifically, when
a build was done on the branch but none was done on the trunk.)
Returns the number of records merged (may be zero).


=item copy_to_branch()

  my $nrec = $rdb->copy_to_branch(
                     COMPONENT_CLASS   => $cclass,
                     COMPONENT_NAME    => $component,
                     COMPONENT_VERSION => $version,
                     CVS_BRANCH        => $branch,
                     [TRUNK            => $trunk || 'main']
                   );

Copy a component version from a trunk (default 'main') to a branch. 
Use this method when you need to add to a branch (e.g. when you've
created a new module in CVS and want to branch just that module).
TRUNK is the source branch; CVS_BRANCH is the destination branch.

=item select_release_components()

  my $ary = $rdb->select_release_components(
                    BOX_TYPE       => $boxtype,
		    BOX_NAME       => $boxname,
		    VERSION        => $version,
		    RELEASE_NUMBER => $relnum,
                  );

Selects a list of component versions associated with a release.
Returns an array of hash records.
 

=item make_release()

  my $ary = $rdb->make_release(
                    BOX_TYPE       => $boxtype,
		    BOX_NAME       => $boxname,
		    VERSION        => $version,
		    RELEASE_NUMBER => $relnum,
		    RELEASE_USER   => $reluser,
		    [RELEASE_DATE  => <YYYY-MM-DD HH24:MI:SS>,]
		    [RELEASED      => {1|0},]
		    [CVS_BRANCH    => $branch,]
                  );

Creates a new release by selecting the latest versions of all 
components related to the box macro on the branch (default main).
Returns an array of hash records representing the component
versions for the release.
 

=item delete_whole_release()

  my $rv = $rdb->delete_whole_release(
                   BOX_TYPE       => $boxtype,
                   BOX_NAME       => $boxname,
                   VERSION        => $version,
                   RELEASE_NUMBER => $relnum,
                 );

Deletes an entire release (a RELEASE record and its associated
RELEASE_COMPONENT_VERSION records).  Returns number of records 
deleted on success, throws an error on failure.



=item select_current_component_version()

  my $ary = $rdb->select_current_component_version(
                    [COMPONENT_CLASS   => $component_class],
                    [COMPONENT_NAME    => $component_name],
                    [COMPONENT_VERSION => $component_version],
                    [SORT_STRING       => $sort_string],
                    [CVS_BRANCH        => $cvs_branch || 'main'],
                    [INSTALL_SWITCHES  => $install_switches],
                    [PACKAGE_FILENAME  => $package_filename],
                    [BUILD_USER        => $build_user],
                    [BUILD_DATE        => $build_date],
                  );

Select the current version(s) of one or more component(s) on a branch
(default 'main').
 


=item expand_macro()

  my $ary = $rdb->expand_macro(
                    MACRO_NAME  => $macro_name,
		    [RECURSIVE  => 1],
		    [NO_MACRO   => 1],
		    [MACRO_ONLY => 1],
		  );

Expand a macro into its constitutent components.  Returns an 
arrayref of hashes with COMPONENT_NAME and COMPONENT_CLASS
fields representing the components that make up the macro.
With RECURSIVE => 1, recursively expands macro components
within macro $macro_name.  With MACRO_ONLY => 1, only returns
macro components; with NO_MACRO => 1 (overrides MACRO_ONLY), 
only returns non-macro components.
 

=item verify_macro_components()

  $rdb->verify_macro_components(
          MACRO_NAME  => $macro_name,
          [CVS_BRANCH => $cvs_branch || 'main'],
        );

Verify that all components of a macro have been built on the 
branch (default 'main').  If verification fails, throws an
error which can be caught with Error's try/catch mechanism.
 

=item select_current_macro_versions()

  my $ary = $rdb->select_current_macro_versions(
                    MACRO_NAME  => $macro_name,
                    [CVS_BRANCH => $cvs_branch || 'main'],
		  );

Select a list of current component versions for a macro from a branch
(default 'main').  Returns an arrayref of COMPONENT_VERSION records
representing the current versions of components for the macro on the
named branch.
 


=item create_<TABLE>()

  my $nrec = create_box(%key_fields);
  my $nrec = create_component_class(%key_fields);
  my $nrec = create_component(%key_fields);
  my $nrec = create_component_version_dependency(%key_fields);
  my $nrec = create_component_version(%key_fields);
  my $nrec = create_macro_component(%key_fields);
  my $nrec = create_release_component_version(%key_fields);
  my $nrec = create_release(%key_fields);

Create a record in the database.  Returns 1 on success; throws an 
error on failure.

=item select_<TABLE>()

  my $rec = select_box(%key_fields);
  my $rec = select_component_class(%key_fields);
  my $rec = select_component(%key_fields);
  my $rec = select_component_version_dependency(%key_fields);
  my $rec = select_component_version(%key_fields);
  my $rec = select_macro_component(%key_fields);
  my $rec = select_release_component_version(%key_fields);
  my $rec = select_release(%key_fields);

Select a single record from a table in the database.  Returns a hash 
ref representing the record on success; returns undef if there are no
matching records; throws an error on failure (e.g. failure to supply
values for all of the table's key fields).
 

=item select_<TABLE PLURAL>()

  my $ary = select_boxes(%key_fields);
  my $ary = select_component_classes(%key_fields);
  my $ary = select_components(%key_fields);
  my $ary = select_component_version_dependencies(%key_fields);
  my $ary = select_component_versions(%key_fields);
  my $ary = select_macro_components(%key_fields);
  my $ary = select_release_component_versions(%key_fields);
  my $ary = select_releases(%key_fields);

Select multiple records from a table in the database.  Returns an 
array of hash refs representing the records on success.


=item delete_<TABLE>()

  my $nrec = delete_box(%key_fields);
  my $nrec = delete_component_class(%key_fields);
  my $nrec = delete_component(%key_fields);
  my $nrec = delete_component_version_dependency(%key_fields);
  my $nrec = delete_component_version(%key_fields);
  my $nrec = delete_macro_component(%key_fields);
  my $nrec = delete_release_component_version(%key_fields);
  my $nrec = delete_release(%key_fields);

Delete a record from the database.  Returns the number of records 
deleted on success, throws an error on failure.


=item delete_<TABLE PLURAL>()

  my $ary = delete_boxes(%key_fields);
  my $ary = delete_component_classes(%key_fields);
  my $ary = delete_components(%key_fields);
  my $ary = delete_component_version_dependencies(%key_fields);
  my $ary = delete_component_versions(%key_fields);
  my $ary = delete_macro_components(%key_fields);
  my $ary = delete_release_component_versions(%key_fields);
  my $ary = delete_releases(%key_fields);

Delete multiple records from the database.  Returns the number of
rows deleted on success, throws an error on failure.


=item ver2str()

  my $sortstring = $rdb->ver2str($version);

Create a sort string (suitable for the SORT_STRING column of
the COMPONENT_VERSION table) from a <version>-<relnum> string.


=back

=head1 BUGS

  Dates are not handled in a useful way.  It is currently impossible to
  select by date, and date fields always use the database's default date
  format.

=head1 AUTHOR

  Dave Faraldo <dfaraldo@nocpulse.com>
  Last update:  $Date: 2003-02-21 21:32:33 $

=head1 SEE ALSO

NOCpulse::Probe::DataSource::Oracle
NOCpulse::Probe::DataSource::AbstractDatabase
NOCpulse::Log::LogManager (for debugging)

=cut

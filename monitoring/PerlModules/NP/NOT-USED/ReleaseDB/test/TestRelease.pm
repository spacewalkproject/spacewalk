package TestRelease;
use Data::Dumper;
use NOCpulse::Probe::DataSource::AbstractDatabase qw(:constants);
use Error qw(:try);

use strict;

use NOCpulse::ReleaseDB;

use base qw(Test::Unit::TestCase);


# GLOBAL VARIABLES
my $CCLASS = 'RPMComponent';
my $MCLASS = 'MacroComponent';

############
sub set_up {
############
  # Run before each test
}

###############
sub tear_down {
###############
  # Run after each test
}

# Within tests, use:
#  $self->assert(<boolean>[,<message>]);
#  $self->assert(qr/<pattern>/, $result);
#  $self->assert(sub {$_[0] == $_[1] || die "Expected $_[0], got $_[1]"},
#                1, 2);
#  $self->fail(); # Should not have gotten here


######################
sub test_constructor {
######################
  my $self = shift;

  my $rdb = NOCpulse::ReleaseDB->new();

  # Make sure creation succeeded
  $self->assert(defined($rdb), "Couldn't create RDB: $@");

  # Make sure we got the right type of object
  $self->assert(qr/NOCpulse::ReleaseDB=/, "$rdb");

  # Make sure we can talk to the database (autoconnect is on 
  # by default)
 #PGPORT_5:POSTGRES_VERSION_QUERY(SYSDATE)
  my $rv = $rdb->execute('SELECT sysdate FROM dual', [qw(dual)], FETCH_SINGLE);
  $self->assert(keys %$rv);

  
}



########################################
sub test_create_select_component_class {
########################################
  my $self = shift;

  my $rdb = NOCpulse::ReleaseDB->new();

  my $table   = 'component_class';
  my $testcol = 'CLASS';
  my $testval = 'ReleaseDB_Test';

  my $rv = $rdb->create_component_class(
    $testcol    => $testval,
    DESCRIPTION => 'Unit test record, please ignore'
  );
  $self->assert($rv, "Failed to create $table record");


  my $rec = $rdb->select_component_class($testcol => $testval);
  $self->assert($rec->{$testcol} eq $testval,
                "Bad value for $testcol (expected '$testval', " .
                "got '$rec->{$testcol}')");

}





####################################################
sub test_create_select_shitload_of_related_records {
####################################################
  my $self = shift;

  my $rdb = NOCpulse::ReleaseDB->new();

  # Values for all records
  my $boxtype  = 'Linux';
  my $boxname  = 'ReleaseDB_Test';
  my $mname    = 'ReleaseDB_Macro';
  my $rversion = '0.BOGUS_REL';
  my $rnumber  = 0;
  my $cname    = 'ReleaseDB_Component';
  my $cversion = '0.0.0.BOGUS';   
  my $branch   = 'BOGUS';   
  my($table, $testcol, $testval, $rv, $rec);

  # COMPONENT record for the macro
  $table   = 'component';
  $testcol = 'NAME';
  $testval = $mname;

  $rv = $rdb->create_component(
    CLASS     => $MCLASS,
    $testcol  => $testval,
  );
  $self->assert($rv, "Failed to create $table record");


  $rec = $rdb->select_component(CLASS => $MCLASS, $testcol => $testval);
  $self->assert($rec->{$testcol} eq $testval,
                "Bad value for $testcol (expected '$testval', " .
                "got '$rec->{$testcol}')");


  # COMPONENT record for the macro member
  $table   = 'component';
  $testcol = 'NAME';
  $testval = $cname;

  $rv = $rdb->create_component(
    CLASS     => $CCLASS,
    $testcol  => $testval,
  );
  $self->assert($rv, "Failed to create $table record");


  $rec = $rdb->select_component(CLASS => $CCLASS, $testcol => $testval);
  $self->assert($rec->{$testcol} eq $testval,
                "Bad value for $testcol (expected '$testval', " .
                "got '$rec->{$testcol}')");



  # MACRO_COMPONENT record
  $table   = 'macro_component';
  $testcol = 'COMPONENT_NAME';
  $testval = $cname;

  $rv = $rdb->create_macro_component(
    MACRO_CLASS         => 'BOOGA', # Should be overriden
    MACRO_NAME          => $mname,
    COMPONENT_CLASS     => $CCLASS,
    $testcol            => $testval,
  );
  $self->assert($rv, "Failed to create $table record");

  $rec = $rdb->select_macro_component(
    MACRO_CLASS         => $MCLASS,
    MACRO_NAME          => $mname,
    COMPONENT_CLASS     => $CCLASS,
    $testcol            => $testval,
  );
  $self->assert($rec->{$testcol} eq $testval,
                "Bad value for $testcol (expected '$testval', " .
                "got '$rec->{$testcol}')");



  # COMPONENT_VERSION record
  $table   = 'component_version';
  $testcol = 'COMPONENT_NAME';
  $testval = $cname;

  $rv = $rdb->create_component_version(
    COMPONENT_CLASS     => $CCLASS,
    $testcol            => $testval,
    COMPONENT_VERSION   => $cversion,
    CVS_BRANCH          => $branch,
    PACKAGE_FILENAME    => 'booga',
  );
  $self->assert($rv, "Failed to create $table record");

  $rec = $rdb->select_component_version(
    COMPONENT_CLASS     => $CCLASS,
    $testcol            => $testval,
    COMPONENT_VERSION   => $cversion,
    CVS_BRANCH          => $branch,
  );
  $self->assert($rec->{$testcol} eq $testval,
                "Bad value for $testcol (expected '$testval', " .
                "got '$rec->{$testcol}')");

  # - Check default
  $self->assert(qr/-.*-/, $rec->{'BUILD_DATE'});



  # COMPONENT_VERSION_DEPENDENCY record
  $table   = 'component_version_dependency';
  $testcol = 'COMPONENT_NAME';
  $testval = $cname;

  $rv = $rdb->create_component_version_dependency(
    COMPONENT_CLASS     => $CCLASS,
    $testcol            => $testval,
    COMPONENT_VERSION   => $cversion,
    TYPE                => 'requires',
    RESOURCE_NAME       => 'booga',
    CVS_BRANCH          => $branch,
  );
  $self->assert($rv, "Failed to create $table record");

  $rec = $rdb->select_component_version_dependency(
    COMPONENT_CLASS     => $CCLASS,
    $testcol            => $testval,
    COMPONENT_VERSION   => $cversion,
    TYPE                => 'requires',
    RESOURCE_NAME       => 'booga',
    CVS_BRANCH          => $branch,
  );
  $self->assert($rec->{$testcol} eq $testval,
                "Bad value for $testcol (expected '$testval', " .
                "got '$rec->{$testcol}')");


  # BOX record
  $table   = 'box';
  $testcol = 'BOX_NAME';
  $testval = $boxname;

  $rv = $rdb->create_box(
    BOX_TYPE         => $boxtype,
    $testcol         => $testval,
    MACRO_CLASS      => $MCLASS,
    MACRO_NAME       => $mname,
  );
  $self->assert($rv, "Failed to create $table record");


  $rec = $rdb->select_box(
    BOX_TYPE         => $boxtype,
    $testcol         => $testval,
  );
  $self->assert($rec->{$testcol} eq $testval,
                "Bad value for $testcol (expected '$testval', " .
                "got '$rec->{$testcol}')");

  # - Check default
  $self->assert(qr/-.*-/, $rec->{'LAST_UPDATE_DATE'});


  # RELEASE record
  $table   = 'release';
  $testcol = 'VERSION';
  $testval = $rversion;

  $rv = $rdb->create_release(
    BOX_TYPE       => $boxtype,
    BOX_NAME       => $boxname,
    VERSION        => $rversion,
    RELEASE_NUMBER => $rnumber,
  );
  $self->assert($rv, "Failed to create $table record");

  $rec = $rdb->select_release(
    BOX_TYPE       => $boxtype,
    BOX_NAME       => $boxname,
    VERSION        => $rversion,
    RELEASE_NUMBER => $rnumber,
  );
  $self->assert($rec->{$testcol} eq $testval,
                "Bad value for $testcol (expected '$testval', " .
                "got '$rec->{$testcol}')");

  # - Check defaults
  $self->assert(qr/-.*-/, $rec->{'RELEASE_DATE'});
  $self->assert($rec->{'RELEASED'} eq 0, "Failed to default RELEASED");


  # RELEASE_COMPONENT_VERSION record
  $table   = 'release';
  $testcol = 'BOX_NAME';
  $testval = $boxname;

  $rv = $rdb->create_release_component_version(
    BOX_TYPE           => $boxtype,
    $testcol           => $testval,
    VERSION            => $rversion,
    RELEASE_NUMBER     => $rnumber,
    COMPONENT_CLASS    => $CCLASS,
    COMPONENT_NAME     => $cname,
    COMPONENT_VERSION  => $cversion,
    CVS_BRANCH         => $branch
  );
  $self->assert($rv, "Failed to create $table record");

  $rec = $rdb->select_release_component_version(
    BOX_TYPE           => $boxtype,
    $testcol           => $testval,
    VERSION            => $rversion,
    RELEASE_NUMBER     => $rnumber,
    COMPONENT_CLASS    => $CCLASS,
    COMPONENT_NAME     => $cname,
    COMPONENT_VERSION  => $cversion,
    CVS_BRANCH         => $branch
  );
  $self->assert($rec->{$testcol} eq $testval,
                "Bad value for $testcol (expected '$testval', " .
                "got '$rec->{$testcol}')");


  # Test deletion of an entire release
  $rv = $rdb->delete_whole_release(
                BOX_TYPE       => $boxtype,
                BOX_NAME       => $boxname,
                VERSION        => $rversion,
                RELEASE_NUMBER => $rnumber,
              );

  $self->assert($rv, "Failed to delete $boxname $rversion-$rnumber release");


}


###################
sub test_deletion {
###################
  my $self = shift;

  my $rdb = NOCpulse::ReleaseDB->new();
  my $rv;

  # Test deletion
  my $class = 'BOGUS_DELTEST';
  my $ctemp = 'BOGUS_DELTEST%d';


  # Create a COMPONENT_CLASS record to parent COMPONENT records
  $rv = $rdb->create_component_class(
    CLASS       => $class,
    DESCRIPTION => 'Unit test record, please ignore',
  );
  $self->assert($rv, "Failed to create COMPONENT_CLASS record");



  # - Create COMPONENT records to delete
  for (my $i = 0; $i < 3; $i++) {
    $rv = $rdb->create_component(
      CLASS     => $class,
      NAME      => sprintf($ctemp, $i),
    );
    $self->assert($rv, "Failed to create component record $i");
  }


  # - Single-row deletion
  #  - with insufficient data (should fail)
  my $err;
  try {

    $rv = $rdb->delete_component(
      CLASS => $class,
    );

  } catch NOCpulse::Probe::DataSource::ConfigError with {

    $err = 1;

  };
  $self->assert($err, "Single record deletion (missing key) failed to fail");


  #  - with data (should succeed)
  $rv = $rdb->delete_component(
      CLASS => $class,
      NAME  => sprintf($ctemp, 0),
  );
  $self->assert($rv, "Failed to delete component record 0");



  # - Multiple-row deletion
  $rv = $rdb->delete_components(
      CLASS => $class,
  );
  $self->assert($rv == 2, "Expected to delete 2 records, deleted $rv");

}



##########################
sub test_macro_selection {
##########################
  my $self = shift;

  my $rdb = NOCpulse::ReleaseDB->new();

  my $versions = $self->create_multilevel_macro($rdb);
  my $expected = scalar(keys %$versions);

  # Fetch macro components
  my $rv = $rdb->expand_macro( 
    MACRO_NAME => 'TOP_MACRO',
    RECURSIVE  => 1,
  );
  $self->assert(scalar(@$rv) == 6, 
                "ALL COMPONENTS: expected 6, got " . scalar(@$rv) . "\n");


  $rv = $rdb->expand_macro( 
    MACRO_NAME => 'TOP_MACRO',
    RECURSIVE  => 1,
    MACRO_ONLY => 1,
  );
  $self->assert(scalar(@$rv) == 2, 
                "MACRO COMPONENTS: expected 2, got " . scalar(@$rv) . "\n");


  $rv = $rdb->expand_macro( 
    MACRO_NAME => 'TOP_MACRO',
    RECURSIVE  => 1,
    NO_MACRO   => 1,
  );
  $self->assert(scalar(@$rv) == 4, 
                "NON-MACRO COMPONENTS: expected 4, got " . scalar(@$rv) . "\n");

}



#############################
sub test_macro_verification {
#############################

  my $self = shift;

  my $rdb = NOCpulse::ReleaseDB->new();

  # NONEXISTENT MACRO (should fail)
  my $err = 0;
  try {

    $rdb->verify_macro_components(MACRO_NAME => 'NOSUCHMACRO');

  } catch NOCpulse::Probe::DataSource::ConfigError with {

    $err = 1;

  };
  $self->assert($err, "Nonexistent macro verification failed to fail");

  my $version = $self->create_multilevel_macro($rdb);

  # TOP_MACRO verification (should succeed)
  my $rv = $rdb->verify_macro_components(MACRO_NAME => 'TOP_MACRO');

  # Now delete the COMPONENT_VERSION records for a component and try again
  #PGPORT_1:NO Change
  $rv = $rdb->execute("DELETE FROM component_version 
		       WHERE  component_name = ?",
		       'component_version', FETCH_ROWCOUNT,
		       'SUB_SUB_COMPONENT');
  $self->assert($rv, "Failed to delete COMPONENT_VERSION record ($rv)\n");


  $err = 0;
  try {

    $rv = $rdb->verify_macro_components(MACRO_NAME => 'TOP_MACRO');

  } catch NOCpulse::Probe::DataSource::CommandFailedError with {

    $err = 1;

  };
  $self->assert($err, "Macro component verification failed to fail");


}


########################################
sub test_select_current_macro_versions {
########################################
  my $self = shift;

  my $rdb = NOCpulse::ReleaseDB->new();

  my $versions = $self->create_multilevel_macro($rdb);
  my $expected = scalar(keys %$versions);

  my $rv = $rdb->select_current_macro_versions(MACRO_NAME => 'TOP_MACRO');


  $self->assert(scalar(@$rv) == $expected, 
    "Expected $expected component_version records, got " . scalar(@$rv));

  foreach my $rec (@$rv) {
    my $name = $rec->{'COMPONENT_NAME'};
    my $ver  = $rec->{'COMPONENT_VERSION'};
    my $exp  = $versions->{$name}->[0];

    $self->assert($ver eq $exp, "Expected $name version $exp, got $ver");
  }

}


#######################
sub test_make_release {
#######################
  my $self = shift;

  my $rdb = NOCpulse::ReleaseDB->new();

  my $boxname = 'TESTBOX';
  my $boxtype = 'Linux';
  my $macro   = 'TOP_MACRO';
  my $version = '1.0BOGUS';
  my $relnum  = 0;
  my $user    = 'UNIT_TEST';

  # Create a macro
  my $versions = $self->create_multilevel_macro($rdb);
  my $expected = scalar(keys %$versions);

  # Create a box to build
  my $rv = $rdb->create_box(
    BOX_NAME         => $boxname,
    BOX_TYPE         => $boxtype,
    MACRO_NAME       => $macro,
    LAST_UPDATE_USER => $user,
  );
  $self->assert($rv, "Failed to create BOX record\n");

  $rv = $rdb->make_release(
    BOX_NAME       => $boxname,
    BOX_TYPE       => $boxtype,
    MACRO_NAME     => $macro,
    VERSION        => $version,
    RELEASE_NUMBER => $relnum,
    RELEASE_USER   => $user,
  );
  my $nrec = scalar(@$rv);
  $self->assert($nrec == $expected, "make_release failure: expected $expected records, got $nrec\n");

  $rv = $rdb->select_release(
    BOX_NAME       => $boxname,
    BOX_TYPE       => $boxtype,
    VERSION        => $version,
    RELEASE_NUMBER => $relnum,
  );
  $self->assert(defined($rv), "make_release/select_release failure\n");


  $rv = $rdb->select_release_components(
    BOX_NAME       => $boxname,
    BOX_TYPE       => $boxtype,
    VERSION        => $version,
    RELEASE_NUMBER => $relnum,
  );
  $nrec = scalar(@$rv);
  $self->assert($nrec == $expected, "make_release failure: expected $expected records, got $nrec\n");

  my $cname = $rv->[0]->{'COMPONENT_NAME'};
  my $c_ver = $rv->[0]->{'COMPONENT_VERSION'};
  my $e_ver = $versions->{$cname}->[0];
  $self->assert($c_ver eq $e_ver, "make_release failure: component $cname, expected version $e_ver, got version $c_ver\n");


}


#######################
sub test_branch_merge {
#######################
  my $self = shift;

  my $rdb    = NOCpulse::ReleaseDB->new();
  my $trunk  = 'UNIT_TEST_TRUNK';
  my $branch = 'UNIT_TEST_BRANCH';
  my $rv;

  # Create a macro
  my $versions = $self->create_multilevel_macro($rdb, $trunk);
  my $expected = scalar(keys %$versions);

  # Branch
  my $ncreated = $rdb->make_branch(
    TRUNK          => $trunk,
    CVS_BRANCH     => $branch,
  );
  $self->assert($ncreated, "Failed to create branch");

  # Verify that the branch succeeded
  $rv = $rdb->select_component_versions(
    CVS_BRANCH => $branch,
  );
  my $nselected = scalar(@$rv);
  $self->assert($nselected == $ncreated, 
                "Branched $ncreated records, selected $nselected");

  # Make sure we branched the right records
  foreach my $rec (@$rv) {
    my $name = $rec->{'COMPONENT_NAME'};
    my $ver  = $rec->{'COMPONENT_VERSION'};
    my $exp  = $versions->{$name}->[0];
    $self->assert($ver eq $exp, 
                  "Branched $name record $ver, expected $exp");
  }




  # Delete a record from the branch and copy it from the main
  # to verify sub copy_to_branch()
  my($cname, $cversions) = each %$versions;
  my $cver = $cversions->[0]; # Delete latest version
  $rv = $rdb->delete_component_version(
                COMPONENT_CLASS   => $CCLASS,
                COMPONENT_NAME    => $cname,
                COMPONENT_VERSION => $cver,
                CVS_BRANCH        => $branch,
              );
  $self->assert($rv, "Failed to delete $cname $cver from '$branch' branch");

  my $rec = $rdb->select_component_version(
                    COMPONENT_CLASS   => $CCLASS,
                    COMPONENT_NAME    => $cname,
                    COMPONENT_VERSION => $cver,
                    CVS_BRANCH        => $branch,
                  );
  $self->assert(! defined($rec), "Delete succeeded but there's still a " . 
                                "$cname $cver record on the '$branch' branch");

  my $ncopied = $rdb->copy_to_branch(
                        COMPONENT_CLASS   => $CCLASS,
                        COMPONENT_NAME    => $cname,
                        COMPONENT_VERSION => $cver,
                        CVS_BRANCH        => $branch,
                        TRUNK             => $trunk,
                      );
  $self->assert($ncopied, 
          "Failed to copy $cname $cver from '$trunk' to '$branch' branch");

  $rec = $rdb->select_component_version(
                    COMPONENT_CLASS   => $CCLASS,
                    COMPONENT_NAME    => $cname,
                    COMPONENT_VERSION => $cver,
                    CVS_BRANCH        => $branch,
                  );
  $self->assert(defined($rec), "Copy succeeded but couldn't select " .
                               "$cname $cver from '$branch' branch\n");


  # END OF BRANCH TESTS


  # BEGIN MERGE TESTS

  # Merge logic copies COMPONENT_VERSIONS to the branch thus:
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

  my %merged_version;

  # Create the four situations above to test merging

  #  a) Change on trunk, no change on branch

  # Component: TOP_COMPONENT
  $rv = $rdb->create_component_version(
      COMPONENT_CLASS     => $CCLASS,
      COMPONENT_NAME      => 'TOP_COMPONENT',
      COMPONENT_VERSION   => '1.1BOGUS-1',
      CVS_BRANCH          => $trunk,
  );
  $self->assert($rv, "Failed to create TOP_COMPONENT record");
  $merged_version{'TOP_COMPONENT'} = '1.1BOGUS-1';


  #  b) Change on branch, no change on trunk (SUB_COMPONENT)
  $rv = $rdb->create_component_version(
      COMPONENT_CLASS     => $CCLASS,
      COMPONENT_NAME      => 'SUB_COMPONENT',
      COMPONENT_VERSION   => '1.3BOGUS-1',
      CVS_BRANCH          => $branch,
  );
  $self->assert($rv, "Failed to create SUB_COMPONENT record");
  $merged_version{'SUB_COMPONENT'} = '1.3BOGUS-1';


  #  c) Changes on branch and on trunk (SUB_SUB_COMPONENT)
  $rv = $rdb->create_component_version(
      COMPONENT_CLASS     => $CCLASS,
      COMPONENT_NAME      => 'SUB_SUB_COMPONENT',
      COMPONENT_VERSION   => '2.0BOGUS-3',
      CVS_BRANCH          => $branch,
  );
  $self->assert($rv, "Failed to create SUB_SUB_COMPONENT record (1)");

  $rv = $rdb->create_component_version(
      COMPONENT_CLASS     => $CCLASS,
      COMPONENT_NAME      => 'SUB_SUB_COMPONENT',
      COMPONENT_VERSION   => '2.1BOGUS-2',
      CVS_BRANCH          => $trunk,
  );
  $self->assert($rv, "Failed to create SUB_SUB_COMPONENT record (2)");
  $merged_version{'SUB_SUB_COMPONENT'} = '2.1BOGUS-2';

  #  d) No changes: do nothing (trunk is current) (SUB_SUB_COMPONENT2)
  $merged_version{'SUB_SUB_COMPONENT2'} = $versions->{'SUB_SUB_COMPONENT2'}->[0];


  # Do the merge
  $rv = $rdb->merge_branch(
    TRUNK          => $trunk,
    CVS_BRANCH     => $branch,
  );
  $self->assert($rv, "Merge failed");


  # Verify the merged records
  # Only one record (case b above) should've been merged
  $self->assert($rv == 1, "Expected 1 merge record, got $rv");


  foreach my $cname (sort keys %$versions) {
    $rv = $rdb->select_current_component_version(
      COMPONENT_NAME => $cname,
      CVS_BRANCH     => $trunk,
    );

    my $expected = $merged_version{$cname};
    my $selected = $rv->[0]->{'COMPONENT_VERSION'};

    $self->assert($expected eq $selected, "After merge, expected version $expected of $cname on trunk, got version $selected");
          

  }


}



#################
sub test_update {
#################
  my $self = shift;

  my $rdb = NOCpulse::ReleaseDB->new();

  # Create records to update
  my $boxtype = 'Linux';
  my $boxname = 'ReleaseDB_Test';
  my $mname   = 'ReleaseDB_Macro';
  my $teststr = 'BOOGA BOOGA BOOGA';
  my $rv;

  # COMPONENT record for the macro
  $rv = $rdb->create_component(
                CLASS     => $MCLASS,
                NAME      => $mname,
              );
  $self->assert($rv, "Failed to create component record");

  # BOX record
  $rv = $rdb->create_box(
    BOX_TYPE         => $boxtype,
    BOX_NAME         => $boxname,
    MACRO_CLASS      => $MCLASS,
    MACRO_NAME       => $mname,
  );
  $self->assert($rv, "Failed to create box record");

  # Update records
  $rv = $rdb->update_box( 
               BOX_TYPE        => $boxtype,
               BOX_NAME        => $boxname,
               set             => {
                   POSTINSTALL  => $teststr,
                   PARTITIONING => $teststr,
                 },
           );
  $self->assert($rv, "Failed to update box record");

  # Make sure record was updated
  my $rec = $rdb->select_box(
                    BOX_TYPE        => $boxtype,
                    BOX_NAME        => $boxname,
                  );

  $self->assert($rec->{'POSTINSTALL'} eq $teststr,
                "Box record not updated: expected '$teststr', got " .
                "POSTINSTALL = '$rec->{POSTINSTALL}'");

  $self->assert($rec->{'PARTITIONING'} eq $teststr,
                "Box record not updated: expected '$teststr', got " .
                "PARTITIONING = '$rec->{PARTITIONING}'");

  
}






#######################
# Utility subroutines #
#######################
sub create_simple_macro {
  my $self = shift;

  my($rdb, $MCLASS, $mname, @components) = @_;

  # COMPONENT record for the macro
  my $rv = $rdb->create_component(
    CLASS     => $MCLASS,
    NAME      => $mname
  );
  $self->assert($rv, "Failed to create $mname record");


  # COMPONENT record for the macro member(s)
  while (@components) {
    my $CCLASS = shift(@components);
    my $cname  = shift(@components);
    $rv = $rdb->create_component(
      CLASS     => $CCLASS,
      NAME      => $cname,
    );
    $self->assert($rv, "Failed to create $cname record");

    # MACRO_COMPONENT record
    $rv = $rdb->create_macro_component(
      MACRO_NAME          => $mname,
      COMPONENT_CLASS     => $CCLASS,
      COMPONENT_NAME      => $cname,
    );
    $self->assert($rv, "Failed to create MACRO_COMPONENT record");
  }


}

#############################
sub create_multilevel_macro {
#############################
  my $self = shift;
  my $rdb  = shift;
  my $vbr  = shift || 'main';


  # Version records to create -- LATEST FIRST
  my %version = (
    'TOP_COMPONENT'      => [qw(1.0BOGUS-1)],
    'SUB_COMPONENT'      => [qw(1.21.BOGUS-1 1.2.BOGUS-1)],
    'SUB_SUB_COMPONENT'  => [qw(2.0BOGUS-2 1.0BOGUS-1)],
    'SUB_SUB_COMPONENT2' => [qw(3.4BOGUS-2 2.9BOGUS-1)],
  );

  # COMPONENT record for the top macro
  my $rv = $rdb->create_component(
    CLASS     => $MCLASS,
    NAME      => 'TOP_MACRO'
  );
  $self->assert($rv, "Failed to create TOP_MACRO COMPONENT record");


  # COMPONENT record for the top macro member
  $rv = $rdb->create_component(
    CLASS     => $CCLASS,
    NAME      => 'TOP_COMPONENT',
  );
  $self->assert($rv, "Failed to create TOP_COMPONENT COMPONENT record");


  # COMPONENT record for the sub macro
  $rv = $rdb->create_component(
    CLASS     => $MCLASS,
    NAME      => 'SUB_MACRO'
  );
  $self->assert($rv, "Failed to create SUB_MACRO COMPONENT record");


  # COMPONENT record for the sub macro member
  $rv = $rdb->create_component(
    CLASS     => $CCLASS,
    NAME      => 'SUB_COMPONENT',
  );
  $self->assert($rv, "Failed to create SUB_COMPONENT COMPONENT record");


  # COMPONENT record for the sub sub macro
  $rv = $rdb->create_component(
    CLASS     => $MCLASS,
    NAME      => 'SUB_SUB_MACRO'
  );
  $self->assert($rv, "Failed to create SUB_SUB_MACRO COMPONENT record");


  # COMPONENT records for the sub sub macro members
  $rv = $rdb->create_component(
    CLASS     => $CCLASS,
    NAME      => 'SUB_SUB_COMPONENT',
  );
  $self->assert($rv, "Failed to create SUB_SUB_COMPONENT COMPONENT record");

  $rv = $rdb->create_component(
    CLASS     => $CCLASS,
    NAME      => 'SUB_SUB_COMPONENT2',
  );
  $self->assert($rv, "Failed to create SUB_SUB_COMPONENT2 COMPONENT record");


  # MACRO_COMPONENT records for the top macro
  $rv = $rdb->create_macro_component(
    MACRO_NAME          => 'TOP_MACRO',
    COMPONENT_CLASS     => $MCLASS,
    COMPONENT_NAME      => 'SUB_MACRO',
  );
  $self->assert($rv, "Failed to create SUB_MACRO MACRO_COMPONENT record");

  $rv = $rdb->create_macro_component(
    MACRO_NAME          => 'TOP_MACRO',
    COMPONENT_CLASS     => $CCLASS,
    COMPONENT_NAME      => 'TOP_COMPONENT',
  );
  $self->assert($rv, "Failed to create TOP_COMPONENT MACRO_COMPONENT record");

  # Create MACRO_COMPONENT record for the sub macro
  $rv = $rdb->create_macro_component(
    MACRO_NAME          => 'SUB_MACRO',
    COMPONENT_CLASS     => $CCLASS,
    COMPONENT_NAME      => 'SUB_COMPONENT',
  );
  $self->assert($rv, "Failed to create SUB_COMPONENT MACRO_COMPONENT record");

  # Create MACRO_COMPONENT record for the sub macro
  $rv = $rdb->create_macro_component(
    MACRO_NAME          => 'SUB_MACRO',
    COMPONENT_CLASS     => $MCLASS,
    COMPONENT_NAME      => 'SUB_SUB_MACRO',
  );
  $self->assert($rv, "Failed to create SUB_SUB_MACRO MACRO_COMPONENT record");

  # Create MACRO_COMPONENT record for the sub macro
  $rv = $rdb->create_macro_component(
    MACRO_NAME          => 'SUB_SUB_MACRO',
    COMPONENT_CLASS     => $CCLASS,
    COMPONENT_NAME      => 'SUB_SUB_COMPONENT',
  );
  $self->assert($rv, "Failed to create SUB_SUB_COMPONENT MACRO_COMPONENT record");

  # Create MACRO_COMPONENT record for the sub macro
  $rv = $rdb->create_macro_component(
    MACRO_NAME          => 'SUB_SUB_MACRO',
    COMPONENT_CLASS     => $CCLASS,
    COMPONENT_NAME      => 'SUB_SUB_COMPONENT2',
  );
  $self->assert($rv, "Failed to create SUB_SUB_COMPONENT2 MACRO_COMPONENT record");




  # Create COMPONENT_VERSION records
  foreach my $comp (keys %version) {
    foreach my $version (@{$version{$comp}}) {

      $rv = $rdb->create_component_version(
	COMPONENT_CLASS     => $CCLASS,
	COMPONENT_NAME      => $comp,
	COMPONENT_VERSION   => $version,
	CVS_BRANCH          => $vbr,
      );
      $self->assert($rv, "Failed to create $comp $version COMPONENT_VERSION record");
    }
  }

  return \%version;

}




1;

package Test::Unit::TestLoader;
use strict;
use FileHandle;
use constant DEBUG => 0;

use Test::Unit::TestSuite;
use Test::Unit::TestCase;
use Test::Unit::UnitHarness;

# should really do something in here about a local @INC.
sub obj_load {
  my $class=shift;
  load(@_);
}

sub load {
  my $test_case=shift;
  my $suite;
  # Is it a test class?
  if ($test_case=~/^[\w:]+$/ 
	  and eval "require $test_case"
	  and not $@) {
	# first up: is this a real test case?
	$suite=try_test_case($test_case);
	return $suite if ($suite);
	$suite=try_test_suite($test_case);
	return $suite if ($suite);
  } elsif ($test_case=~/\.pm$/ 
		   and eval "require \"$test_case\""
		   and not $@) {
	#In this case I need to figure out what the class
	#was I just loaded!
	$test_case=get_package_name_from_file($test_case);
	$suite=try_test_case($test_case);
	return $suite if ($suite);
	$suite=try_test_suite($test_case);
	return $suite if ($suite);
  } else {
	print "Debug: ".$@ if DEBUG;
  }
  for my $file ("$test_case",
			  "$test_case.t",
			  "t/$test_case",
			  "t/$test_case.t" ) {
	# try it out as a test::harness type test.
	$suite=try_test_harness($file);
	return $suite if $suite;
  }
  # one last shot: is it a _directory_?
  $suite=try_test_dir($test_case);
  return $suite if $suite;
  die "(This error is expected) Suite class " . $test_case . " not found: $@";
 
}

sub try_test_case {
  my $test_case=shift;
  no strict 'refs';
  if ($test_case->isa("Test::Unit::TestCase")) {
	return Test::Unit::TestSuite->new($test_case);
  } 
}
sub try_test_suite {
  my $test_case=shift;
  no strict 'refs';
  if ($test_case->can("suite")) {
	return $test_case->suite();
  } 
}
sub try_test_harness {
  my $test_case=shift;
  if (-r $test_case) {
	my $fh = new FileHandle;
	$fh->open($test_case) or return;
	my $first = <$fh>;
	$fh->close or return;
	return Test::Unit::UnitHarness->new($test_case);
  }
}
sub try_test_dir {
  my $test_case=shift;
  if (-d $test_case) {
	die "This is a test directory. I havent implemented that.\n";
	return Test::Unit::UnitHarness::new_dir($test_case);
  }
}

# The next bit of code is a helper function which attempts
# to identify the class we are trying to use from a '.pm'
# file. If we've reached this point, we managed to 'require'
# the file already, but we dont know the file the package was
# loaded from. Somehow I feel this information is in perl
# somwhere but if it is I dont know where...
sub get_package_name_from_file {
  my $test_case=shift;
  my $fh = new FileHandle;
  my $filename;
  # first off we've actually got to find the thing. It's in
  # @INC somewhere...
  foreach my $file (map {"$_/$test_case"} @INC) {
	$fh->open($file) or next; 
	foreach my $line (<$fh>) {
	  if ($line=~/^\s*package\s+([\w:]+)/) {
		return $1;
	  }
	}
	$fh->close or 
	  die "Didnt find 'package' in $test_case and couldnt close it!";
  }
  die "Got a $test_case but cant find 'package'";
}

1;
__END__


=head1 NAME

Test::Unit::TestLoader - unit testing framework helper class

=head1 SYNOPSIS

This class is not intended to be used directly 

=head1 DESCRIPTION

This class is used by the framework to load testcase classes into the
runtime environment. It handles testcase class names (that is, classes
inheriting from Test::Unit::TestCase), Test::Harness style test files,
and directory names.

=head1 AUTHOR

Copyright (c) 2000 Brian Ewins.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as Perl itself.

Thanks go to the other PerlUnit framework people: 
Christian Lemburg, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::TestCase>

=item *

L<Test::Unit::UnitHarness>

=item *

L<Test::Unit::TkTestRunner>

=back

=cut

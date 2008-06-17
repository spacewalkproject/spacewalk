package Test::Unit::tests::TestUnitTest;

use strict;

use base qw(Test::Unit::TestCase);

use constant DEBUG => 0;

sub new {
    my $self = shift()->SUPER::new(@_);
    $self->{_my_tmpfile} = "./_tmpfile";
    return $self;
}

sub set_up {
    my $self = shift;
    my $filename = $self->{_my_tmpfile};
    die "Please remove $filename, I need it for testing ..." if (-e $filename);
    open(FH, ">$filename") or die "Could not open $filename: $!";
    close(FH);
}

sub tear_down {
    my $self = shift;
    my $filename = $self->{_my_tmpfile};
    if (DEBUG) {
	print " LOOK NOW in $filename "; 
	my $answer = <STDIN>;
    }
    die "Could not remove $filename: $!" unless unlink($filename);
}
    
# test subs

sub test_pkg_main_ok {
    my $self = shift;
    my $filename = $self->{_my_tmpfile};
    # we must redefine subs test_1 and test_2 in the eval 
    # to get new results for test_1 and test_2 in package main
    # if we just introduce new tests here, 
    # test_1 and test_2 will be run, too, ruining our ok result,
    # so switch warnings off to keep nice output
    local $^W = 0;
    eval << "EOT";
package main; 
use Test::Unit;
sub test_1 { assert(42 == 42); }
sub test_2 { assert(23 == 23); }
create_suite(); 
open(FH, '>$filename');
run_suite(undef, \*FH);
close(FH);
EOT
    $self->assert(not $@); # exit status
    $self->assert(-s $self->{_my_tmpfile}); # visible output
}

sub test_pkg_main_fail {
    my $self = shift;
    my $filename = $self->{_my_tmpfile};
    eval << "EOT";
package main; 
use Test::Unit;
sub test_1 { assert(23 == 42); }
sub test_2 { assert(42 == 23); }
create_suite(); 
open(FH, '>$filename');
run_suite(undef, \*FH);
close(FH);
EOT
    # must close open file (from eval())
    close(main::FH) or die "Could not close $filename: $!";
    # this depends on the die message in Test::Unit::TestRunner
    $self->assert($@ eq "\nTest was not successful.\n"); # exit status
    $self->assert(-s $self->{_my_tmpfile}); # visible output
}

sub test_other_pkg_ok {
    my $self = shift;
    my $filename = $self->{_my_tmpfile};
    eval << "EOT";
package Foo_Ok;
use Test::Unit;
sub test_1 { assert(42 == 42); }
sub test_2 { assert(23 == 23); }
package Bar_Ok; 
use Test::Unit;
create_suite("Foo_Ok"); 
open(FH, '>$filename');
run_suite("Foo_Ok", \*FH);
close(FH);
EOT
    $self->assert(not $@); # exit status
    $self->assert(-s $self->{_my_tmpfile}); # visible output
}

sub test_other_pkg_fail {
    my $self = shift;
    my $filename = $self->{_my_tmpfile};
    eval << "EOT";
package Foo_Fail;
use Test::Unit;
sub test_1 { assert(23 == 42); }
sub test_2 { assert(42 == 23); }
package Bar_Fail; 
use Test::Unit;
create_suite("Foo_Fail"); 
open(FH, '>$filename');
run_suite("Foo_Fail", \*FH);
close(FH);
EOT
    # must close open file (from eval())
    close(Bar_Fail::FH) or die "Could not close $filename: $!";
    # this depends on the die message in Test::Unit::TestRunner
    $self->assert($@ eq "\nTest was not successful.\n"); # exit status
    $self->assert(-s $self->{_my_tmpfile}); # visible output
}

sub test_adding_suites_to_default_package {
    my $self = shift;
    my $filename = $self->{_my_tmpfile};
    eval << "EOT";
package To_Add_Fails;
use Test::Unit;
sub test_1 { assert(23 == 42); }
sub test_2 { assert(42 == 23); }
package To_Add_To; 
use Test::Unit;
sub test_1 { assert(42 == 42); }
sub test_2 { assert(23 == 23); }
create_suite();
create_suite("To_Add_Fails"); 
add_suite("To_Add_Fails");
open(FH, '>$filename');
run_suite(undef, \*FH);
close(FH);
EOT
    # must close open file (from eval())
    close(To_Add_To::FH) or die "Could not close $filename: $!";
    # this depends on the die message in Test::Unit::TestRunner
    $self->assert($@ eq "\nTest was not successful.\n"); # exit status
    $self->assert(-s $self->{_my_tmpfile}); # visible output
}

sub test_adding_suites_to_explicit_package {
    my $self = shift;
    my $filename = $self->{_my_tmpfile};
    eval << "EOT";
package To_Add_Fails_Too;
use Test::Unit;
sub test_1 { assert(23 == 42); }
sub test_2 { assert(42 == 23); }
package To_Add_To_Explicitly; 
use Test::Unit;
sub test_1 { assert(42 == 42); }
sub test_2 { assert(23 == 23); }
package A_Third_Package;
use Test::Unit;
create_suite("To_Add_To_Explicitly");
create_suite("To_Add_Fails_Too"); 
add_suite("To_Add_Fails_Too", "To_Add_To_Explicitly");
open(FH, '>$filename');
run_suite("To_Add_To_Explicitly", \*FH);
close(FH);
EOT
    # must close open file (from eval())
    close(A_Third_Package::FH) or die "Could not close $filename: $!";
    # this depends on the die message in Test::Unit::TestRunner
    $self->assert($@ eq "\nTest was not successful.\n"); # exit status
    $self->assert(-s $self->{_my_tmpfile}); # visible output
}


1;

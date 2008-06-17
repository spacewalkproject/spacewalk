# This is a makeover of Test::Harness to allow its tests
# to be retrofitted as unit tests.
package Test::Unit::UnitHarness;

BEGIN {require 5.002;}
use base qw(Test::Unit::TestListener Test::Unit::Test);
use Exporter;
use Config;
use Carp;
use FileHandle;
use constant DEBUG => 0;
use Test::Unit::TestCase;
use Test::Unit::InnerClass;
use Test::Unit::Exception;

use strict;

use vars qw($VERSION $verbose $switches $have_devel_corestack $curtest
	    @ISA @EXPORT @EXPORT_OK);
$have_devel_corestack = 0;

$VERSION = "1.1502";

@ISA=('Exporter');
@EXPORT= qw(&runtests);
@EXPORT_OK= qw($verbose $switches);

$verbose = 0;
$switches = "-w";

# class and object methods

sub new {
    my $class = shift;
    my ($name) = @_;
    
    my @_Tests = ();
    my $self = {
	_Tests => \@_Tests,
	_Name => $name,
	_Names => [],
    };
    bless $self, $class;
    print ref($self) . "::new($name) called\n" if DEBUG;
    
    return $self;
}

sub run {
  my $self=shift;
  my $result=shift;
  my $test=$self->{_Name};
  my $fh = new FileHandle;
  my $next=1;
  my $max=0;
  my $message="";

  # pass -I flags to children
  my $old5lib = $ENV{PERL5LIB};
  local($ENV{'PERL5LIB'}) = join($Config{path_sep}, @INC);
  
  if ($^O eq 'VMS') { $switches =~ s/-(\S*[A-Z]\S*)/"-$1"/g }

  $fh->open($test) or print "can't open $test. $!\n";
  my $first = <$fh>;
  my $s = $switches;
  $s .= q[ "-T"] if $first =~ /^#!.*\bperl.*-\w*T/;
    $fh->close or print "can't close $test. $!\n";
  my $cmd = "$^X $s $test|";
  $cmd = "MCR $cmd" if $^O eq 'VMS';
  $fh->open($cmd) or print "can't run $test. $!\n";
  for my $line (<$fh>) {
    if( $verbose ){ print $line; }
    if ($line=~/^1\.\.([0-9]+)/) {
	  # Not supported in TestResult - It's needed!!!
      #$result->plan($1);
      $next=1;
      $max=$1;
	  $message="";
    } elsif ($max && $line=~/^(not\s+)?ok\b/) {
      my $this = $next;
      if ($line=~/^not ok\s*(\d*)/){
		$this = $1 if $1 > 0;
		my $testcase=new Test::Unit::TestCase("$test case $this");
		$result->start_test($testcase);
		$result->
		  add_failure(
					  Test::Unit::UnitHarness::TestCase
					  ->new("$test case $this"),
					  Test::Unit::UnitHarness::Exception
					  ->new($message));
		$result->end_test($testcase);
		$message="";
      } elsif ($line=~/^ok\s*(\d*)/) {
		$this = $1 if defined $1 and $1 ne "" and $1 > 0;
		my $testcase=Test::Unit::UnitHarness::TestCase
		  ->new("$test case $this");
		$result->start_test($testcase);
		$result->add_pass($testcase);
		$result->end_test($testcase);
		$message="";
      }
      $next++;
    } else {
	  # this is the message, not the medium...
	  # this wasnt part of the Test::Harness protocol, so it
	  # must be output from the program. Collect this, it might
	  # prove useful!
	  $message.=$line;
	}
  }
  $fh->close; # must close to reap child resource values
  if ($^O eq 'VMS') {
    if (defined $old5lib) {
      $ENV{PERL5LIB} = $old5lib;
    } else {
      delete $ENV{PERL5LIB};
    }
  }
}

sub name {
    my $self = shift;
    return $self->{_Name};
}

sub names {
    my $self = shift;
    return $self->{_Names};
}

sub add_test {
  croak "This is suite is not mutable.";
}

sub add_test_method {
  croak "This suite is not mutable.";
}
 
sub count_test_cases {
  return 0;
}

sub to_string {
    my $self = shift;
    return $self->{_Name};
}

sub warning {
    my $self = shift;
    my ($message) = @_;
    return Test::Unit::InnerClass::make_inner_class("Test::Unit::TestCase", <<"EOIC", "warning");
sub run_test {
    my \$self = shift;
    \$self->fail('$message');
EOIC
}

package Test::Unit::UnitHarness::TestCase;
use base qw(Test::Unit::TestCase);

sub run_test {
    my $self = shift;
    my $class = ref($self);
    my $method = $self->name();
	$self->fail("This test is not restartable");
}

package Test::Unit::UnitHarness::Exception;
use base qw(Test::Unit::Exception);
use strict;

sub new {
    my $class = shift;
    my ($message) = @_;
	my $stacktrace = '';
    
    $message = '' unless defined($message);
    $stacktrace = $class . ": Output from external test\n" 
	  . $message . "\n";
    
    bless { stacktrace => $stacktrace }, $class;
}

sub stacktrace {
    my $self = shift;
    return $self->{stacktrace};
}
1;
__END__

=head1 NAME

Test::Unit::UnitHarness - unit testing framework helper class

=head1 SYNOPSIS

This class is not intended to be used directly 

=head1 DESCRIPTION

This is a makeover of Test::Harness to allow its tests to be
retrofitted as unit tests.

=head1 AUTHOR

Copyright (c) 2000 Brian Ewins.

All rights reserved. This program is free software; you can
redistribute it and/or modify it under the same terms as
Perl itself.

Thanks go to the other PerlUnit framework people: 
Christian Lemburg, Cayte Lindner, J.E. Fritz, Zhon Johansen.

=head1 SEE ALSO

=over 4

=item *

L<Test::Unit::UnitHarness>

=item *

L<Test::Unit::TestRunner>

=item *

L<Test::Unit::TkTestRunner>

=back

=cut

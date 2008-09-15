package fail_example_testsuite_setup;
use strict;
use constant DEBUG => 0;

use base qw(Test::Unit::TestSetup);

sub set_up{
	my $self = shift()->SUPER::set_up(@_);
	print "fail_example_testsuite_setup\n" if DEBUG;
}

sub tear_down{
	my $self = shift();
	print "fail_example_testsuite_tear_down\n" if DEBUG;
	$self->SUPER::tear_down(@_);
}


package fail_example;
use strict;
use constant DEBUG => 0;

use base qw(Test::Unit::TestCase);
use Test::Unit::TestSuite;

sub new 
{
	my $self = shift()->SUPER::new(@_);

	return $self;
}

sub test_ok {
    my $self = shift();
	$self->assert(23 == 23);
}	

sub test_fail {
    my $self = shift();
	$DB::single=1 if DEBUG;	#this breaks into the debugger
	$self->assert(scalar "born" =~ /loose/, "Born to lose ...");
}

sub set_up {
	my $self = shift()->SUPER::set_up(@_);
	print "hello world\n" if DEBUG;
}

sub tear_down {
    my $self = shift();
	print "leaving world again\n" if DEBUG;
	$self->SUPER::tear_down(@_);
}

sub suite {
	my $testsuite = Test::Unit::TestSuite->new(__PACKAGE__);

	my $wrapper = fail_example_testsuite_setup->new($testsuite);
	return $wrapper;
}

1;

package fail_example; # this is the test case to be decorated

use strict;

use Test::Unit::Debug qw(debug debugged);
use Test::Unit::TestSuite;

use base qw(Test::Unit::TestCase);

sub test_ok {
    my $self = shift();
    $self->assert(23 == 23);
}   

sub test_fail {
    my $self = shift();
    $DB::single = $DB::single; # avoid 'used only once' warning
    $DB::single = 1 if debugged(); #this breaks into the debugger
    $self->assert(scalar "born" =~ /loose/, "Born to lose ...");
}

sub set_up {
    my $self = shift()->SUPER::set_up(@_);
    debug("hello world\n");
}

sub tear_down {
    my $self = shift();
    debug("leaving world again\n");
    $self->SUPER::tear_down(@_);
}

sub suite {
    my $testsuite = Test::Unit::TestSuite->new(__PACKAGE__);
    my $wrapper = fail_example_testsuite_setup->new($testsuite);
    return $wrapper;
}

1;

package fail_example_testsuite_setup;
# this suite will decorate fail_example with additional fixture

use strict;
use Test::Unit::Debug qw(debug);

use base qw(Test::Unit::Setup);

sub set_up {
    my $self = shift()->SUPER::set_up(@_);
    debug("fail_example_testsuite_setup\n");
}

sub tear_down {
    my $self = shift();
    debug("fail_example_testsuite_tear_down\n");
    $self->SUPER::tear_down(@_);
}

1;

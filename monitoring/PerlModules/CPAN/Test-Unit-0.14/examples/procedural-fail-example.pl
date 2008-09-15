use Test::Unit;

use constant DEBUG => 0;

# code to be tested will be somewhere around here

# define tests, set_up and tear_down

sub test_ok {
	assert(23 == 23);
}	

sub test_fail {
	assert("born" =~ /loose/, "Born to lose ...");
}

sub set_up {
	print "hello world\n" if DEBUG;
}

sub tear_down {
	print "leaving world again\n" if DEBUG;
}

# and run them

create_suite();
run_suite();

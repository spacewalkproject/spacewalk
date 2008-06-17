# --------------------------------------------------
package Foo;

use Test::Unit;

use constant DEBUG => 0;

# code to be tested will be somewhere around here

# define tests, set_up and tear_down

sub test_foo_ok_1 {
	assert(23 == 23);
}	

sub test_foo_ok_2 {
	assert(42 == 42);
}

sub set_up {
	print "hello world\n" if DEBUG;
}

sub tear_down {
	print "leaving world again\n" if DEBUG;
}

# --------------------------------------------------
package Bar;

use Test::Unit;

use constant DEBUG => 0;

# code to be tested will be somewhere around here

# define tests, set_up and tear_down

sub test_bar_ok_1 {
	assert(23 == 23);
}	

sub test_bar_ok_2 {
	assert(42 == 42);
}

sub set_up {
	print "hello world\n" if DEBUG;
}

sub tear_down {
	print "leaving world again\n" if DEBUG;
}

# --------------------------------------------------
package FooBar;

use Test::Unit;

create_suite();
create_suite("Foo");
create_suite("Bar");

add_suite("Foo"); # add Foo to this package
add_suite("Bar"); # add Bar to this package

print "\n--- Testing FooBar ---\n";
run_suite();

add_suite("Foo", "Bar"); # add Foo to Bar
print "\n--- Testing Bar with Foo added to it ---\n";
run_suite("Bar");

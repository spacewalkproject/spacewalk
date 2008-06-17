# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..5\n"; }
END {print "not ok 1\n" unless $loaded;}
use Mail::Alias;
$loaded = 1;
print "ok 1\n";


# Insert your test code below 

my ($alias_obj);

print "Testing some of the Mail::Alias methods.........\n";

if ($alias_obj = Mail::Alias->new(test_alias_file))
	{ print "ok 2\n"} else {print "not ok 2\n"};

print "Setting the current alias file name\n";
($alias_obj->alias_file eq "test_alias_file") or die "Couldn't set the filename using MAIL::ALIAS";

print "Appending some aliases to the file\n";
if ($alias_obj->append("test_alias3", 'person1@place1.com, person2@place2.net')) 
	{print "ok 3\n"} else {print "not ok 3\n"};

print "Verifying the aliases were added\n";
if ($alias_obj->exists("test_alias3")) 
	{print "ok 4\n"} else {print "not ok 4\n"};

if ($alias_obj->delete("test_alias3")) 
	{print "ok 5\n"} else {print "not ok 5\n"};


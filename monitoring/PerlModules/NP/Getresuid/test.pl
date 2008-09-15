# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 1 };
use Getresuid;
ok(1); # If we made it this far, we're ok.

#########################

# Make sure getresuid() and getresgid() think our real and effective 
# user/group IDs are what Perl thinks they are.

my($ruid, $euid, $suid) = getresuid();
my($rgid, $egid, $sgid) = getresgid();


# Test 2:  Verify real UID
ok($ruid, $<);

# Test 3:  Verify effective UID
ok($euid, $>);

# Test 4:  Verify real GID
ok($rgid, (split(/\s+/, $())[0]);

# Test 5:  Verify effective UID
ok($egid, (split(/\s+/, $())[0]);


# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 1;

# Test 1 - load the module
BEGIN { use_ok('FcntlLock') };

diag('Use "tst" script to run actual tests');



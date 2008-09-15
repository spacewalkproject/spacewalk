use strict;
use Test;
use Config::IniFiles;

BEGIN { plan tests => 2 }

my ($ini, $value);

# Test 1
# Multiple equals in a parameter - should split on the first
$ini = new Config::IniFiles( -file => 't/test.ini' );
$value = $ini->val('test7', 'criterion') || '';
ok($value eq 'price <= maximum');

# Test 2
# Parameters whose name is a substring of existing parameters should be loaded
$value = $ini->val('substring', 'jacques');
ok( $value eq 'smarty');


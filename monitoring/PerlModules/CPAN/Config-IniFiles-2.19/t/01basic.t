use strict;
use Test;
use Config::IniFiles;

BEGIN { plan tests => 4 }

# test 1
my $ini = new Config::IniFiles -file => "t/test.ini";
ok($ini);

# test 2
# print "Reading a value .................. ";
my $value = $ini->val('test2', 'five') || '';
ok ($value eq 'value5');

# test 3
# print "Creating a new value ............. ";
$ini->newval('test2', 'seven', 'value7');
$ini->RewriteConfig;
$ini->ReadConfig;
$value='';
$value = $ini->val('test2', 'seven');
ok ($value eq 'value7');

# test 4
# print "Deleting a value ................. ";
$ini->delval('test2', 'seven');
$ini->RewriteConfig;
$ini->ReadConfig;
$value='';
$value = $ini->val('test2', 'seven');
ok (! defined ($value));

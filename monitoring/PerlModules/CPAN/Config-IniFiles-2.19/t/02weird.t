use strict;
use Test;
use Config::IniFiles;

BEGIN { plan tests => 2 }

my ($ini, $value);

$ini = new Config::IniFiles -file => "t/test.ini";
# print "Weird characters in section name . ";
$value = $ini->val('[w]eird characters', 'multiline');
ok($value eq "This\nis a multi-line\nvalue");

$ini->newval("test7|anything", "exists", "yes");
$value = $ini->val("test7|anything", "exists");
ok($value eq "yes");

